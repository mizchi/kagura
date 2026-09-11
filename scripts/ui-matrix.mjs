#!/usr/bin/env node
import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { prepareBundle } from './render-frame.mjs';
import { renderHeadlessFrame } from '../assets/web/kagura-headless-frame.js';
import { toVlmkitElements } from './ui-snapshot-utils.mjs';
import { matrixCells, validateMatrixFrame } from './ui-matrix-utils.mjs';
import { checkImageIntegrity } from './ui-vlmkit-integrity.mjs';
import { blankFrameVerdict, parsePaletteShares } from './frame-vrt-utils.mjs';
import { diffPng } from './vlmkit-png.mjs';
import { prepareNativeCapture, renderNativeCapture } from './ui-capture-native.mjs';

export async function runMatrix(example, { build = true, outDir, baselineDir, update = false, backend = 'js' } = {}) {
  if (!['js', 'native'].includes(backend)) throw Error('Expected --backend js or native');
  if (backend === 'native' && update) throw Error('Update the shared baseline with JS, then compare native to it');
  const prepared = backend === 'native' ? prepareNativeCapture(example, { build }) : prepareBundle(example, { build });
  const { exampleDir, bundlePath } = prepared;
  const cells = matrixCells(JSON.parse(readFileSync(resolve(exampleDir, 'editor/verification.json'), 'utf8')));
  const out = outDir ?? resolve(import.meta.dirname, backend === 'native' ? '../output/ui-matrix-native' : '../output/ui-matrix', example);
  const baselines = baselineDir ?? resolve(import.meta.dirname, '../e2e/ui-matrix-snapshots', example);
  mkdirSync(out, { recursive: true });
  const results = [];
  for (const cell of cells) {
    const dir = resolve(out, cell.name);
    mkdirSync(dir, { recursive: true });
    try {
      const frame = backend === 'native' ? renderNativeCapture(prepared, cell) : await renderHeadlessFrame(bundlePath, cell);
      const png = resolve(dir, 'frame.png');
      writeFileSync(png, frame.png);
      if (frame.uiSnapshotJson) writeFileSync(resolve(dir, 'snapshot.json'), frame.uiSnapshotJson);
      validateMatrixFrame(cell, frame);
      const palette = execFileSync('pnpm', ['exec', 'vlmkit', 'check', 'palette', png],
        { cwd: resolve(import.meta.dirname, '..'), encoding: 'utf8' });
      const blank = blankFrameVerdict(parsePaletteShares(palette), {});
      if (!blank.ok) throw Error(blank.reason);
      const elements = resolve(dir, 'elements.json');
      writeFileSync(elements, JSON.stringify(toVlmkitElements(frame.uiSnapshot)));
      const integrity = checkImageIntegrity(frame.uiSnapshot, png, dir);
      const baseline = resolve(baselines, `${cell.name}.png`);
      let diff;
      if (!update) {
        if (!existsSync(baseline)) throw Error(`Missing baseline ${baseline}; inspect captures and use --update for intended changes`);
        diff = diffPng(baseline, png, { elements });
        writeFileSync(resolve(dir, 'diff.json'), JSON.stringify(diff, null, 2));
      }
      results.push({ cell: cell.name, png, baseline, ok: integrity.ok && (!diff || diff.diffPixels === 0),
        integrity: integrity.ok, changedPixels: diff?.diffPixels ?? null });
    } catch (error) {
      results.push({ cell: cell.name, ok: false, error: error.message });
    }
  }
  const ok = results.every(cell => cell.ok);
  // Do not partially re-pin a failing matrix.
  if (update && ok) {
    mkdirSync(baselines, { recursive: true });
    for (const result of results) copyFileSync(result.png, result.baseline);
  }
  const report = { example, backend, update, updated: update && ok, results, ok };
  writeFileSync(resolve(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
  return report;
}
async function main(args) {
  const example = args.shift();
  if (!example || example === '--help') {
    console.log('Usage: just ui-matrix <example> ["--backend js|native --update --no-build --out-dir dir --baseline-dir dir"]\nReads states/viewports from editor/verification.json; compares every cell without updating baselines by default.');
    return;
  }
  const options = {};
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--no-build') options.build = false;
    else if (args[i] === '--update') options.update = true;
    else if (args[i] === '--backend' && args[i + 1]) options.backend = args[++i];
    else if (['--out-dir', '--baseline-dir'].includes(args[i]) && args[i + 1]) {
      options[args[i] === '--out-dir' ? 'outDir' : 'baselineDir'] = resolve(args[++i]);
    } else throw Error(`Unknown or incomplete option: ${args[i]}`);
  }
  const report = await runMatrix(example, options);
  console.log(JSON.stringify(report, null, 2));
  if (!report.ok) process.exitCode = 1;
}
if (process.argv[1] === new URL(import.meta.url).pathname) main(process.argv.slice(2)).catch(error => {
  console.error(error.message); process.exitCode = 2;
});
