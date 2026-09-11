import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
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
