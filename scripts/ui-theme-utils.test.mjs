import assert from "node:assert/strict";
import test from "node:test";

import { analyzeTheme, parseHex, rgbDistance } from "./ui-theme-utils.mjs";

const THEME = {
  version: 1,
  tokens: ["#343454", "#4c4c6c", "#fcfcfc"],
  maxDistance: 12,
  minShare: 0.002,
};

test("parseHex reads #rrggbb", () => {
  assert.deepEqual(parseHex("#343454"), { r: 52, g: 52, b: 84 });
});

test("rgbDistance is Euclidean in 8-bit RGB", () => {
  assert.equal(rgbDistance({ r: 0, g: 0, b: 0 }, { r: 0, g: 0, b: 0 }), 0);
  assert.equal(rgbDistance({ r: 3, g: 4, b: 0 }, { r: 0, g: 0, b: 0 }), 5);
});

test("a frame using only declared tokens is clean", () => {
  const result = analyzeTheme(
    [
      { hex: "#343454", share: 0.7 },
      { hex: "#4c4c6c", share: 0.3 },
    ],
    THEME,
  );
  assert.equal(result.ok, true);
  assert.deepEqual(result.extras, []);
});

test("a color within maxDistance of a token is not a hardcoded literal", () => {
  const result = analyzeTheme([{ hex: "#353555", share: 0.5 }], THEME);
  assert.equal(result.ok, true);
});

test("a color far from every token is a hardcoded literal", () => {
  const result = analyzeTheme(
    [
      { hex: "#343454", share: 0.8 },
      { hex: "#ff00aa", share: 0.2 },
    ],
    THEME,
  );
  assert.equal(result.ok, false);
  assert.equal(result.extras[0].hex, "#ff00aa");
  assert.match(result.extras[0].message, /hard-coded/);
});

test("a color below minShare is ignored as extraction noise", () => {
  const result = analyzeTheme(
    [
      { hex: "#343454", share: 0.999 },
      { hex: "#ff00aa", share: 0.001 },
    ],
    THEME,
  );
  assert.equal(result.ok, true);
});

test("unused tokens are listed but do not fail the gate", () => {
  const result = analyzeTheme([{ hex: "#343454", share: 1 }], THEME);
  assert.equal(result.ok, true);
  assert.ok(result.unused.includes("#4c4c6c"));
  assert.ok(result.unused.includes("#fcfcfc"));
});

test("an invalid theme is rejected before it can pass a frame", () => {
  assert.throws(() => analyzeTheme([], { version: 1, tokens: [] }), /token/);
  assert.throws(() => analyzeTheme([], { version: 2, tokens: ["#000000"] }), /version/);
  assert.throws(() => analyzeTheme([], { version: 1, tokens: ["red"] }), /#rrggbb/);
});
