import assert from "node:assert/strict";
import test from "node:test";

import {
  LARGE_TEXT_PX,
  WCAG_LARGE_FLOOR,
  WCAG_NORMAL_FLOOR,
  contrastRatio,
  measureRegionContrast,
  relativeLuminance,
} from "./ui-contrast-utils.mjs";
import { analyzeSnapshot } from "./ui-integrity-utils.mjs";

function rgba(width, height, color = [0, 0, 0, 255]) {
  const data = new Uint8Array(width * height * 4);
  for (let i = 0; i < width * height; i += 1) data.set(color, i * 4);
  return { width, height, data };
}

function fill(image, left, top, width, height, color) {
  for (let y = top; y < top + height; y += 1) {
    for (let x = left; x < left + width; x += 1) {
      image.data.set(color, (y * image.width + x) * 4);
    }
  }
}

/** Gray #777 on white is just under the normal WCAG AA floor and above the large-text floor. */
const GRAY_777 = [0x77, 0x77, 0x77, 255];
const WHITE = [255, 255, 255, 255];
const BLACK = [0, 0, 0, 255];

function labeledSnapshot(node, screen = { width: 40, height: 16, dpr: 1 }) {
  return {
    screen,
    frame: 0,
    state: "playing",
    nodes: [node],
    focus_order: [],
  };
}

test("ui_demo pressed green must keep yellow label above the AA floor", () => {
  const yellow = [0xff, 0xff, 0x2d];
  const oldPressed = [0x60, 0xdd, 0x60];
  const pressed = [0x1e, 0x6b, 0x32];
  assert.ok(contrastRatio(yellow, oldPressed) < WCAG_NORMAL_FLOOR);
  assert.ok(contrastRatio(yellow, pressed) >= WCAG_NORMAL_FLOOR);
  assert.ok(contrastRatio([255, 255, 255], pressed) >= WCAG_NORMAL_FLOOR);
});

test("relative luminance and contrast ratio match WCAG 2.x", () => {
  assert.equal(relativeLuminance(0, 0, 0), 0);
  assert.equal(relativeLuminance(255, 255, 255), 1);
  assert.equal(contrastRatio([0, 0, 0], [255, 255, 255]), 21);
  const grayOnWhite = contrastRatio(GRAY_777, WHITE);
  assert.ok(grayOnWhite < WCAG_NORMAL_FLOOR, `expected ${grayOnWhite} < 4.5`);
  assert.ok(grayOnWhite > WCAG_LARGE_FLOOR, `expected ${grayOnWhite} > 3`);
});

test("a crop of black glyphs on white reports a passing ratio", () => {
  const image = rgba(40, 16, WHITE);
  fill(image, 2, 2, 20, 12, BLACK);
  const measured = measureRegionContrast(image, { left: 0, top: 0, width: 40, height: 16 });
  assert.ok(measured.ratio >= WCAG_NORMAL_FLOOR);
  assert.equal(measured.fg, "#000000");
  assert.equal(measured.bg, "#ffffff");
});

test("a crop of #777 glyphs on white reports the gray-on-white ratio", () => {
  const image = rgba(40, 16, WHITE);
  fill(image, 2, 2, 20, 12, GRAY_777);
  const measured = measureRegionContrast(image, { left: 0, top: 0, width: 40, height: 16 });
  assert.ok(measured.ratio < WCAG_NORMAL_FLOOR);
  assert.ok(measured.ratio > WCAG_LARGE_FLOOR);
  assert.equal(measured.fg, "#777777");
  assert.equal(measured.bg, "#ffffff");
});

test("a uniform crop is unmeasurable rather than invented contrast", () => {
  const image = rgba(40, 16, WHITE);
  assert.equal(measureRegionContrast(image, { left: 0, top: 0, width: 40, height: 16 }), null);
});

test("low-contrast small text is a defect", () => {
  const image = rgba(40, 16, WHITE);
  fill(image, 2, 2, 20, 12, GRAY_777);
  const result = analyzeSnapshot(
    labeledSnapshot({
      path: "hud[0]>hp[0]",
      id: "hp_label",
      left: 0,
      top: 0,
      width: 40,
      height: 16,
      text: "HP",
      text_measured: { width: 20, height: 12 },
      visible: true,
    }),
    { image },
  );
  assert.deepEqual(
    result.findings.map((finding) => finding.kind),
    ["low-contrast-text"],
  );
  assert.equal(result.findings[0].evidence.floor, WCAG_NORMAL_FLOOR);
  assert.equal(result.findings[0].evidence.large, false);
  assert.match(result.findings[0].message, /hp_label: contrast .* < 4\.5:1/);
});

test("the same pair on large text uses the 3:1 floor and passes", () => {
  const image = rgba(40, 28, WHITE);
  fill(image, 2, 2, 20, 24, GRAY_777);
  const result = analyzeSnapshot(
    labeledSnapshot(
      {
        path: "hud[0]>title[0]",
        id: "title",
        left: 0,
        top: 0,
        width: 40,
        height: 28,
        text: "GO",
        text_measured: { width: 20, height: LARGE_TEXT_PX },
        visible: true,
      },
      { width: 40, height: 28, dpr: 1 },
    ),
    { image },
  );
  assert.deepEqual(result.findings, []);
});

test("black on white text is clean", () => {
  const image = rgba(40, 16, WHITE);
  fill(image, 2, 2, 20, 12, BLACK);
  const result = analyzeSnapshot(
    labeledSnapshot({
      path: "hud[0]>hp[0]",
      id: "hp_label",
      left: 0,
      top: 0,
      width: 40,
      height: 16,
      text: "HP",
      visible: true,
    }),
    { image },
  );
  assert.deepEqual(result.findings, []);
});

test("nodes without text are not contrast-checked", () => {
  const image = rgba(40, 16, WHITE);
  fill(image, 2, 2, 20, 12, GRAY_777);
  const result = analyzeSnapshot(
    labeledSnapshot({
      path: "hud[0]",
      id: "panel",
      left: 0,
      top: 0,
      width: 40,
      height: 16,
      visible: true,
    }),
    { image },
  );
  assert.deepEqual(result.findings, []);
});

test("dpr scales the crop onto the frame pixels", () => {
  const image = rgba(80, 32, WHITE);
  fill(image, 4, 4, 40, 24, GRAY_777);
  const result = analyzeSnapshot(
    labeledSnapshot(
      {
        path: "hud[0]>hp[0]",
        id: "hp_label",
        left: 0,
        top: 0,
        width: 40,
        height: 16,
        text: "HP",
        text_measured: { width: 20, height: 12 },
        visible: true,
      },
      { width: 40, height: 16, dpr: 2 },
    ),
    { image },
  );
  assert.deepEqual(
    result.findings.map((finding) => finding.kind),
    ["low-contrast-text"],
  );
});

test("a clip rect keeps contrast sampling inside the visible scissor", () => {
  const image = rgba(80, 16, WHITE);
  fill(image, 2, 2, 20, 12, BLACK);
  fill(image, 42, 2, 20, 12, GRAY_777);
  const result = analyzeSnapshot(
    labeledSnapshot(
      {
        path: "hud[0]>hp[0]",
        id: "hp_label",
        left: 0,
        top: 0,
        width: 80,
        height: 16,
        text: "HP",
        text_measured: { width: 20, height: 12 },
        clip: { left: 40, top: 0, width: 40, height: 16 },
        visible: true,
      },
      { width: 80, height: 16, dpr: 1 },
    ),
    { image },
  );
  assert.ok(result.findings.some((finding) => finding.kind === "low-contrast-text"));
});

test("without a frame image the gate does not invent contrast findings", () => {
  const result = analyzeSnapshot(
    labeledSnapshot({
      path: "hud[0]>hp[0]",
      id: "hp_label",
      left: 0,
      top: 0,
      width: 40,
      height: 16,
      text: "HP",
      visible: true,
    }),
  );
  assert.deepEqual(result.findings, []);
});

test("an allow rule exempts low-contrast-text with its reason", () => {
  const image = rgba(40, 16, WHITE);
  fill(image, 2, 2, 20, 12, GRAY_777);
  const result = analyzeSnapshot(
    labeledSnapshot({
      path: "hud[0]>hp[0]",
      id: "hp_label",
      left: 0,
      top: 0,
      width: 40,
      height: 16,
      text: "HP",
      text_measured: { width: 20, height: 12 },
      visible: true,
    }),
    { image, allow: ["low-contrast-text@hp_label;disabled hint"] },
  );
  assert.deepEqual(result.findings, []);
  assert.equal(result.exempted.length, 1);
  assert.equal(result.exempted[0].reason, "disabled hint");
});
