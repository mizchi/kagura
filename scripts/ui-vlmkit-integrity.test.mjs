import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import { PNG } from 'pngjs';
import { checkImageIntegrity } from './ui-vlmkit-integrity.mjs';

test('real vlmkit consumes measured text and rejects a clipped label without a browser', () => {
  const dir = mkdtempSync(join(tmpdir(), 'kgr-image-integrity-'));
  const image = resolve(import.meta.dirname, '../e2e/frame-vrt-snapshots/ui_demo.png');
  const snapshot = { screen: { width: 640, height: 480, dpr: 1 }, nodes: [
    { path: 'root', id: 'root', left: 0, top: 0, width: 640, height: 480 },
    { path: 'root>label', id: 'hp', role: 'label', left: 10, top: 10, width: 200, height: 20,
      text: 'HP', text_measured: { width: 30, height: 16 }, clip: { left: 10, top: 10, width: 200, height: 20 } },
  ] };
  try {
    assert.equal(checkImageIntegrity(snapshot, image, dir).ok, true);
    snapshot.nodes[1].text_measured.width = 400;
    const bad = checkImageIntegrity(snapshot, image, dir);
    assert.equal(bad.ok, false);
    assert.equal(bad.vlmkit.report.verdict, 'defects');
    assert.ok(bad.vlmkit.report.findings.some(f => f.kind === 'text-clipped'));
    assert.ok(bad.vlmkit.report.skippedRules.some(f => f.rule === 'low-contrast-text'));
    snapshot.screen.width = 320;
    assert.throws(() => checkImageIntegrity(snapshot, image, dir), /coordinates do not match/);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test('geometry reports the contrast vlmkit skips on image-only integrity', () => {
  const dir = mkdtempSync(join(tmpdir(), 'kgr-image-contrast-'));
  const png = new PNG({ width: 640, height: 480 });
  png.data.fill(255);
  for (let y = 12; y < 24; y += 1) {
    for (let x = 12; x < 32; x += 1) {
      const i = (y * 640 + x) * 4;
      png.data[i] = 0x77;
      png.data[i + 1] = 0x77;
      png.data[i + 2] = 0x77;
    }
  }
  const image = resolve(dir, 'frame.png');
  writeFileSync(image, PNG.sync.write(png));
  const snapshot = { screen: { width: 640, height: 480, dpr: 1 }, nodes: [
    { path: 'root', id: 'root', left: 0, top: 0, width: 640, height: 480 },
    { path: 'root>label', id: 'hp', role: 'label', left: 10, top: 10, width: 200, height: 20,
      text: 'HP', text_measured: { width: 30, height: 16 }, clip: { left: 10, top: 10, width: 200, height: 20 } },
  ] };
  try {
    const report = checkImageIntegrity(snapshot, image, dir);
    assert.equal(report.ok, false);
    assert.ok(report.geometry.findings.some(f => f.kind === 'low-contrast-text'));
    assert.ok(report.vlmkit.report.skippedRules.some(f => f.rule === 'low-contrast-text'));
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
