import assert from "node:assert/strict";
import test from "node:test";

import {
  DOT_TEXT_GLYPHS,
  applyProfile,
  analyzeI18nStress,
  dotTextSize,
  inflateWords,
  missingGlyphs,
  stressSnapshot,
  toFullwidth,
} from "./ui-i18n-utils.mjs";

function snapshot(nodes) {
  return {
    screen: { width: 640, height: 480, dpr: 1, safe_area: { top: 0, right: 0, bottom: 0, left: 0 } },
    frame: 0,
    state: "playing",
    nodes,
    focus_order: [],
  };
}

function node(overrides) {
  return {
    path: "hud[0]>hp[0]",
    id: "hp_label",
    tag: "label",
    role: "label",
    left: 0,
    top: 0,
    width: 60,
    height: 20,
    z: 0,
    visible: true,
    text: "HP",
    text_measured: { width: 21, height: 15 },
    ...overrides,
  };
}

test("dotTextSize matches the engine formula used by append_dot_text", () => {
  assert.deepEqual(dotTextSize(0), { width: 0, height: 0 });
  assert.deepEqual(dotTextSize(1), { width: 9, height: 15 });
  assert.deepEqual(dotTextSize(5), { width: 57, height: 15 });
});

test("inflateWords pads each word the way vlmkit stress i18n does", () => {
  assert.equal(inflateWords("BTN 1", 1.35), "BTNXX 1X");
  assert.equal(inflateWords("HP", 1.35), "HPX");
});

test("toFullwidth maps ASCII onto the fullwidth block", () => {
  assert.equal(toFullwidth("HP 1"), "ＨＰ　１");
});

test("missingGlyphs reports code points the renderer alphabet does not have", () => {
  assert.deepEqual(missingGlyphs("HP 1", DOT_TEXT_GLYPHS), []);
  assert.deepEqual(missingGlyphs("ＨＰ", DOT_TEXT_GLYPHS), ["Ｈ", "Ｐ"]);
  assert.ok(missingGlyphs("HP⚠️", DOT_TEXT_GLYPHS).includes("⚠"));
});

test("de inflate that still fits the box is clean", () => {
  const result = analyzeI18nStress(
    snapshot([node({ width: 200, text: "BTN 1", text_measured: { width: 57, height: 15 } })]),
    { profiles: ["de"] },
  );
  assert.equal(result.ok, true);
  assert.deepEqual(result.profiles.de.findings, []);
});

test("de inflate flags text-overflow when the box has no slack", () => {
  const result = analyzeI18nStress(snapshot([node({ width: 24 })]), { profiles: ["de"] });
  assert.equal(result.ok, false);
  assert.equal(result.profiles.de.findings[0].kind, "text-overflow");
  assert.equal(result.profiles.de.nodes[0].text, "HPX");
});

test("fullwidth flags missing glyphs even when the box still fits", () => {
  const result = analyzeI18nStress(
    snapshot([node({ width: 200, text: "HP", text_measured: { width: 21, height: 15 } })]),
    { profiles: ["fullwidth"] },
  );
  assert.equal(result.ok, false);
  assert.deepEqual(result.profiles.fullwidth.missingGlyphs[0].chars, ["Ｈ", "Ｐ"]);
  assert.equal(result.profiles.fullwidth.missingGlyphs[0].id, "hp_label");
});

test("digits replace numbers with a overflowing magnitude", () => {
  assert.equal(applyProfile("HP 12", "digits"), "HP 9,999,999");
  assert.equal(applyProfile("HP -3", "digits"), "HP -99999");
  const result = analyzeI18nStress(
    snapshot([node({ text: "12", text_measured: { width: 21, height: 15 }, width: 40 })]),
    { profiles: ["digits"] },
  );
  assert.equal(result.ok, false);
  assert.ok(result.profiles.digits.findings.some((finding) => finding.kind === "text-overflow"));
  assert.ok(result.profiles.digits.missingGlyphs[0].chars.includes(","));
});

test("rtl and emoji introduce glyphs the ASCII HUD cannot draw", () => {
  const result = analyzeI18nStress(snapshot([node({ width: 200 })]), { profiles: ["rtl", "emoji"] });
  assert.equal(result.ok, false);
  assert.ok(result.profiles.rtl.missingGlyphs[0].chars.length > 0);
  assert.ok(result.profiles.emoji.missingGlyphs[0].chars.length > 0);
});

test("stressSnapshot leaves nodes without text alone", () => {
  const stressed = stressSnapshot(
    snapshot([node({ text: undefined, text_measured: undefined, id: "panel" })]),
    "de",
  );
  assert.equal(stressed.nodes[0].text, undefined);
});
