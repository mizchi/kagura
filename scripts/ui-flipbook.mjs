#!/usr/bin/env node
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { PNG } from 'pngjs';
import { prepareBundle } from './render-frame.mjs';
import { renderHeadlessFrame } from '../assets/web/kagura-headless-frame.js';
import { toVlmkitElements } from './ui-snapshot-utils.mjs';
import { analyzeSnapshot } from './ui-integrity-utils.mjs';
import { validateTransition, analyzeTransition } from './ui-flipbook-utils.mjs';
import { diffPng } from './vlmkit-png.mjs';

export async function runFlipbook(example, transition, { build = true, outDir } = {}) {
  if (!/^[a-zA-Z0-9_-]+$/.test(transition)) throw Error('Invalid transition name');
  const { bundlePath, exampleDir } = prepareBundle(example, { build });
  const manifest = JSON.parse(readFileSync(resolve(exampleDir, 'editor/verification.json'), 'utf8'));
  if (manifest.version !== 1) throw Error('Unsupported verification manifest version');
  const spec = validateTransition(manifest.transitions?.[transition]);
  const out = outDir ?? resolve(import.meta.dirname, '../output/ui-flipbook', example, transition);
  mkdirSync(out, { recursive: true });
  const captures = [], comparisons = [], findings = [];
  for (let tick = 1; tick <= spec.frames; tick++) {
    const frame = await renderHeadlessFrame(bundlePath, { frames: tick, inputs: spec.inputs });
    if (frame.skippedCommands || !frame.uiSnapshot) throw Error('Flipbook needs complete 2D frames and UI snapshots');
    if (frame.uiSnapshot.screen.width !== frame.width || frame.uiSnapshot.screen.height !== frame.height || frame.uiSnapshot.screen.dpr !== 1) {
      throw Error('Flipbook snapshot coordinates must match the captured frame (dpr=1)');
    }
    const base = resolve(out, String(tick).padStart(4, '0'));
    writeFileSync(`${base}.png`, frame.png);
    writeFileSync(`${base}.snapshot.json`, frame.uiSnapshotJson);
    writeFileSync(`${base}.elements.json`, JSON.stringify(toVlmkitElements(frame.uiSnapshot, { scale: 1 })));
    findings.push(...analyzeSnapshot(frame.uiSnapshot, { image: PNG.sync.read(frame.png) }).findings.map(f => ({ ...f, frame: tick })));
    const capture = { frame: tick, png: `${base}.png`, elements: `${base}.elements.json` };
    if (captures.length) {
      const diff = diffPng(captures.at(-1).png, capture.png, { elements: capture.elements });
      writeFileSync(`${base}.diff.json`, JSON.stringify(diff, null, 2));
      comparisons.push({ from: tick - 1, to: tick, pixels: diff.diffPixels });
    }
    captures.push(capture);
  }
  findings.push(...analyzeTransition(spec, comparisons.map(c => c.pixels)));
  const report = { example, transition, settleFrame: spec.settleFrame, captures, comparisons, findings, ok: findings.length === 0 };
  writeFileSync(resolve(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
  return report;
}

async function main(args) {
  const [example, transition, ...flags] = args;
  if (!example || example === '--help') {
    console.log('Usage: just ui-flipbook <example> <transition> ["--no-build --out-dir dir"]\nTransitions are declared in the example editor/verification.json. Deadlines use game ticks.');
    return;
  }
  const options = {};
  for (let i = 0; i < flags.length; i++) {
    if (flags[i] === '--no-build') options.build = false;
    else if (flags[i] === '--out-dir' && flags[i + 1]) options.outDir = resolve(flags[++i]);
    else throw Error(`Unknown or incomplete option: ${flags[i]}`);
  }
  const report = await runFlipbook(example, transition, options);
  console.log(JSON.stringify(report, null, 2));
  if (!report.ok) process.exitCode = 1;
}
if (process.argv[1] === new URL(import.meta.url).pathname) main(process.argv.slice(2)).catch(error => {
  console.error(error.message); process.exitCode = 2;
});
