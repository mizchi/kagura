import assert from "node:assert/strict";
import { test } from "node:test";

import { FRAME_VRT_ENTRIES } from "./frame-vrt-manifest.mjs";
import {
  baselinePathFor,
  blankFrameVerdict,
  formatFrameVrtReport,
  normalizeEntries,
  normalizeEntry,
  parseFrameVrtArgs,
  parsePaletteShares,
  regressionVerdict,
  selectEntries,
} from "./frame-vrt-utils.mjs";

const PALETTE_OUTPUT = [
  "# Palette: output/frame-vrt/ui_demo.png",
  "",
  "Outer background: `#2a2a3e`  Inner background: `#333350`",
  "",
  "| Color | Share |",
  "|---|---|",
  "| `#343454` | 56.5% |",
  "| `#4c4c6c` | 19.7% |",
  "| `#fcfcfc` | 1.1% |",
].join("\n");

test("an entry without a state keeps the example's own name as its stem", () => {
  const entry = normalizeEntry({ example: "ui_demo", frames: 3 });
  assert.equal(entry.key, "ui_demo");
  assert.equal(entry.frames, 3);
  assert.equal(entry.cursorX, null);
  assert.deepEqual(entry.keys, []);
});

test("a state is appended to the stem so its artifacts stay tellable apart", () => {
  const entry = normalizeEntry({ example: "ui_demo", state: "hover", cursor: [100, 74] });
  assert.equal(entry.key, "ui_demo.hover");
  assert.equal(entry.cursorX, 100);
  assert.equal(entry.cursorY, 74);
  assert.equal(entry.frames, 1);
});

test("a malformed entry is rejected rather than rendered as something else", () => {
  assert.throws(() => normalizeEntry({}), /needs an `example`/);
  assert.throws(() => normalizeEntry({ example: "x", cursor: [1] }), /wants \[x, y\]/);
  assert.throws(() => normalizeEntry({ example: "x", frames: -1 }), /non-negative integer/);
});

test("two entries writing one baseline is caught, not silently last-wins", () => {
  assert.throws(
    () => normalizeEntries([{ example: "ui_demo" }, { example: "ui_demo" }]),
    /duplicate frame-vrt entry: ui_demo/,
  );
  assert.doesNotThrow(() =>
    normalizeEntries([{ example: "ui_demo" }, { example: "ui_demo", state: "hover" }]),
  );
});

test("baselines are named after the entry stem", () => {
  const entry = normalizeEntry({ example: "ui_demo", state: "focus" });
  assert.equal(baselinePathFor("snaps", entry), "snaps/ui_demo.focus.png");
});

test("the palette table is read back as colors with shares", () => {
  const shares = parsePaletteShares(PALETTE_OUTPUT);
  assert.equal(shares.length, 3);
  assert.deepEqual(shares[0], { hex: "#343454", share: 0.565 });
  assert.equal(shares[2].hex, "#fcfcfc");
});

test("a palette with no table reads as no colors, not as an empty success", () => {
  assert.deepEqual(parsePaletteShares("no table here\n"), []);
  assert.equal(blankFrameVerdict([]).ok, false);
});

test("a frame with real content passes the blank check", () => {
  assert.deepEqual(blankFrameVerdict(parsePaletteShares(PALETTE_OUTPUT)), {
    ok: true,
    reason: null,
  });
});

test("a single-color frame is refused -- a baseline that cannot fail is not coverage", () => {
  const verdict = blankFrameVerdict([{ hex: "#fcfcfc", share: 1 }]);
  assert.equal(verdict.ok, false);
  assert.match(verdict.reason, /#fcfcfc at 100\.0%/);
  assert.match(verdict.reason, /allowUniform/);
});

test("a near-uniform frame is refused too, not just an exactly uniform one", () => {
  const verdict = blankFrameVerdict([
    { hex: "#000000", share: 0.999 },
    { hex: "#000001", share: 0.001 },
  ]);
  assert.equal(verdict.ok, false);
});

test("a uniform frame passes only with an explicit reason, which is echoed back", () => {
  const verdict = blankFrameVerdict([{ hex: "#000000", share: 1 }], {
    allowUniform: "the loading screen is intentionally black",
  });
  assert.equal(verdict.ok, true);
  assert.match(verdict.reason, /intentionally black/);
});

test("an unchanged frame passes, and any change fails at the default threshold", () => {
  const clean = { changedRatio: 0, selectors: [], regions: [] };
  assert.deepEqual(regressionVerdict(clean), { ok: true, detail: null });
  const changed = {
    changedRatio: 0.0207,
    selectors: ["(16,48) 192x48 -> .button (medium, coverage 0.7188)"],
    regions: ["(16,48) 192x48 [content] #4a4a6a -> #6a6a9a"],
  };
  const verdict = regressionVerdict(changed);
  assert.equal(verdict.ok, false);
  assert.match(verdict.detail, /2\.07% of pixels changed/);
  assert.match(verdict.detail, /\.button/);
});

test("a failure names the region when no UI node owns it", () => {
  const verdict = regressionVerdict({
    changedRatio: 0.5,
    selectors: [],
    regions: ["(0,0) 64x64 [content] #000000 -> #ffffff"],
  });
  assert.match(verdict.detail, /\(0,0\) 64x64/);
});

test("an unmeasured diff fails -- a missing number is not a clean result", () => {
  const verdict = regressionVerdict({ changedRatio: null, selectors: [], regions: [] });
  assert.equal(verdict.ok, false);
  assert.match(verdict.detail, /no diff measurement/);
});

test("a threshold lets a known-noisy frame through without disabling the gate", () => {
  const diff = { changedRatio: 0.001, selectors: [], regions: [] };
  assert.equal(regressionVerdict(diff, { threshold: 0.01 }).ok, true);
  assert.equal(regressionVerdict(diff, { threshold: 0.0001 }).ok, false);
});

test("the report ends with a count and says which entries failed", () => {
  const report = formatFrameVrtReport([
    { key: "ui_demo", status: "ok", detail: null },
    { key: "ui_demo.hover", status: "failed", detail: "2.07% of pixels changed" },
  ]);
  assert.match(report, /ok\s+ui_demo/);
  assert.match(report, /FAILED\s+ui_demo\.hover: 2\.07%/);
  assert.match(report, /frame VRT: 1 of 2 FAILED/);
});

test("a clean run says so rather than printing nothing", () => {
  const report = formatFrameVrtReport([{ key: "ui_demo", status: "ok", detail: null }]);
  assert.match(report, /1 checked, all clean/);
});

test("the CLI defaults to an exact comparison", () => {
  const options = parseFrameVrtArgs([]);
  assert.equal(options.update, false);
  assert.equal(options.threshold, 0);
  assert.equal(options.build, true);
  assert.deepEqual(options.only, []);
});

test("a bare name filters, an unknown flag is an error", () => {
  assert.deepEqual(parseFrameVrtArgs(["ui_demo", "card_game"]).only, ["ui_demo", "card_game"]);
  assert.throws(() => parseFrameVrtArgs(["--nope"]), /unknown option/);
  assert.throws(() => parseFrameVrtArgs(["--threshold", "2"]), /between 0 and 1/);
});

test("filtering to a name the manifest does not carry is an error, not an empty run", () => {
  const entries = normalizeEntries([{ example: "ui_demo" }, { example: "card_game" }]);
  assert.equal(selectEntries(entries, ["ui_demo"]).length, 1);
  assert.equal(selectEntries(entries, []).length, 2);
  assert.throws(() => selectEntries(entries, ["nope"]), /not in the frame-vrt manifest: nope/);
});

test("a state filter selects every state of that example", () => {
  const entries = normalizeEntries([
    { example: "ui_demo" },
    { example: "ui_demo", state: "hover" },
    { example: "card_game" },
  ]);
  assert.deepEqual(
    selectEntries(entries, ["ui_demo"]).map((entry) => entry.key),
    ["ui_demo", "ui_demo.hover"],
  );
});

test("the shipped manifest is well formed and free of duplicates", () => {
  const entries = normalizeEntries(FRAME_VRT_ENTRIES);
  assert.ok(entries.length > 0);
  for (const entry of entries) {
    assert.ok(entry.frames >= 0);
    assert.equal(typeof entry.key, "string");
  }
});

test("the manifest excludes the examples the rasterizer cannot render honestly", () => {
  const names = new Set(FRAME_VRT_ENTRIES.map((entry) => entry.example));
  // Its only geometry is one sprite quad sampling an unregistered texture, so
  // the frame is 100% white -- the blank baseline this gate exists to reject.
  assert.equal(names.has("sprite_anim"), false);
  // 3D: the CPU rasterizer skips those commands, so a baseline would pin an
  // empty scene and pass forever.
  assert.equal(names.has("particle_demo"), false);
  assert.equal(names.has("hacknslash_3d"), false);
});
