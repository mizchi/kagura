import assert from "node:assert/strict";
import { test } from "node:test";

import {
  artifactPaths,
  bundlePathFor,
  normalizeState,
  parseCursor,
  parseKeys,
  parseModuleName,
  parseRenderFrameArgs,
} from "./render-frame-utils.mjs";

test("the default render is one tick of the example's own viewport", () => {
  const options = parseRenderFrameArgs(["ui_demo"]);
  assert.equal(options.example, "ui_demo");
  assert.equal(options.frames, 1);
  assert.equal(options.width, null);
  assert.equal(options.height, null);
  assert.equal(options.state, "default");
  assert.equal(options.build, true);
});

test("frames of 0 is allowed -- it captures the state before any update", () => {
  assert.equal(parseRenderFrameArgs(["ui_demo", "--frames", "0"]).frames, 0);
});

test("a negative or fractional frame count is rejected", () => {
  assert.throws(() => parseRenderFrameArgs(["ui_demo", "--frames", "-1"]), /non-negative/);
  assert.throws(() => parseRenderFrameArgs(["ui_demo", "--frames", "1.5"]), /non-negative/);
});

test("a zero viewport is rejected rather than silently falling back", () => {
  assert.throws(() => parseRenderFrameArgs(["ui_demo", "--width", "0"]), /positive integer/);
});

test("--cursor and --keys parse into input the engine can hold for a tick", () => {
  const options = parseRenderFrameArgs([
    "ui_demo",
    "--cursor",
    "100,74",
    "--keys",
    "9,32",
  ]);
  assert.equal(options.cursorX, 100);
  assert.equal(options.cursorY, 74);
  assert.deepEqual(options.keys, [9, 32]);
});

test("a malformed cursor is rejected", () => {
  assert.throws(() => parseCursor("100"), /x,y/);
  assert.throws(() => parseCursor("a,b"), /two numbers/);
});

test("keys must be integers", () => {
  assert.deepEqual(parseKeys("9, 32 ,13"), [9, 32, 13]);
  assert.throws(() => parseKeys("9,tab"), /integers/);
});

test("an unknown flag is an error, not a silently ignored typo", () => {
  assert.throws(() => parseRenderFrameArgs(["ui_demo", "--frame", "3"]), /unknown option/);
});

test("a second positional argument is an error", () => {
  assert.throws(() => parseRenderFrameArgs(["ui_demo", "flappy_bird"]), /extra argument/);
});

test("--help does not require an example", () => {
  assert.equal(parseRenderFrameArgs(["--help"]).help, true);
});

test("normalizeState clamps and defaults every field", () => {
  assert.deepEqual(normalizeState({}), {
    name: "default",
    frames: 1,
    width: null,
    height: null,
    cursorX: null,
    cursorY: null,
    keys: [],
  });
  assert.equal(normalizeState({ frames: -3 }).frames, 0);
  assert.equal(normalizeState({ width: 0 }).width, null);
});

test("the module name decides the build path, not the directory name", () => {
  assert.equal(parseModuleName('name = "mizchi/ui_demo"\n'), "mizchi/ui_demo");
  assert.equal(parseModuleName('{ "name": "mizchi/ui_demo" }'), "mizchi/ui_demo");
  assert.throws(() => parseModuleName("version = 1\n"), /could not read/);
});

test("bundlePathFor mirrors moon's js build layout", () => {
  assert.equal(
    bundlePathFor("examples/demos-2d/ui_demo", "mizchi/ui_demo"),
    "examples/demos-2d/ui_demo/_build/js/debug/build/mizchi/ui_demo/ui_demo.js",
  );
});

test("the default state's artifacts are unsuffixed, other states are labelled", () => {
  const plain = artifactPaths("out", "ui_demo", "default");
  assert.equal(plain.png, "out/ui_demo.png");
  assert.equal(plain.snapshot, "out/ui_demo.snapshot.json");
  const hover = artifactPaths("out", "ui_demo", "hover");
  assert.equal(hover.png, "out/ui_demo.hover.png");
  assert.equal(hover.elements, "out/ui_demo.hover.elements.json");
});
