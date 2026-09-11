#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { PNG } from 'pngjs';
import { toVlmkitIntegrityElements, unwrapSnapshot } from './ui-snapshot-utils.mjs';
import { analyzeSnapshot } from './ui-integrity-utils.mjs';

/** Preserve both reports: vlmkit's skipped rules are not claimed as coverage. */
export function checkImageIntegrity(snapshot, image, outDir) {
  mkdirSync(outDir, { recursive: true });
  const elementsPath = resolve(outDir, 'integrity.elements.json');
  writeFileSync(elementsPath, JSON.stringify(toVlmkitIntegrityElements(snapshot), null, 2));
  const result = spawnSync('pnpm', ['exec', 'vlmkit', 'check', 'integrity', '--elements', elementsPath,
    '--image', image, '--json', '--no-ledger'], { cwd: resolve(import.meta.dirname, '..'), encoding: 'utf8' });
  if (result.error || ![0, 1].includes(result.status)) throw Error(`vlmkit integrity failed: ${result.error?.message ?? result.stderr}`);
  const vlmkit = JSON.parse(result.stdout);
  if (vlmkit.gate !== 'check.integrity' || !Array.isArray(vlmkit.findings) ||
      !['clean', 'defects'].includes(vlmkit.report?.verdict)) throw Error('Invalid vlmkit integrity report');
  const screen = unwrapSnapshot(snapshot).screen;
  const viewport = vlmkit.report.viewports?.[0];
  const dpr = screen?.dpr ?? 1;
  if (!screen || !viewport || viewport.width !== screen.width * dpr || viewport.height !== screen.height * dpr) {
    throw Error('Snapshot coordinates do not match image dimensions');
  }
  const geometry = analyzeSnapshot(snapshot, { image: PNG.sync.read(readFileSync(image)) });
  const report = { ok: result.status === 0 && vlmkit.verdict === 'pass' && geometry.findings.length === 0,
    geometry, vlmkit };
  writeFileSync(resolve(outDir, 'integrity.report.json'), JSON.stringify(report, null, 2) + '\n');
  return report;
}
if (process.argv[1] === new URL(import.meta.url).pathname) {
  try {
    const [snapshot, image, out = 'output/ui-vlmkit-integrity', ...extra] = process.argv.slice(2);
    if (!snapshot || snapshot === '--help') console.log('Usage: just ui-vlmkit-check <snapshot.json> <frame.png> [out_dir]');
    else {
      if (!image || extra.length) throw Error('Expected snapshot JSON, frame PNG and optional output directory');
      const result = checkImageIntegrity(readFileSync(snapshot, 'utf8'), resolve(image), resolve(out));
      console.log(JSON.stringify(result, null, 2));
      if (!result.ok) process.exitCode = 1;
    }
  } catch (error) { console.error(error.message); process.exitCode = 2; }
}
