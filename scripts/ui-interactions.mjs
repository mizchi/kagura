#!/usr/bin/env node
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { prepareBundle } from './render-frame.mjs';
import { renderHeadlessFrame } from '../assets/web/kagura-headless-frame.js';
import { analyzeSnapshot } from './ui-integrity-utils.mjs';
import { toVlmkitElements } from './ui-snapshot-utils.mjs';
import { analyzeInteractions, outsideRegions, validateNavigationProfile } from './ui-interactions-utils.mjs';
import { diffPng } from './vlmkit-png.mjs';

const root = resolve(import.meta.dirname, '..');
const defaults = {
  keyboard: { next: { keys: [9] }, previous: { keys: [9, 16] } },
  gamepad: { next: { gamepads: [{ id: 0, buttons: [13] }] }, previous: { gamepads: [{ id: 0, buttons: [12] }] } },
};
const focused = snapshot => {
  const nodes = snapshot.nodes.filter(n => n.focused);
  return nodes.length === 1 ? nodes[0].id : null;
};

export async function runInteractions(example, { build = true, outDir, profile = defaults } = {}) {
  validateNavigationProfile(profile);
  const out = outDir ?? resolve(root, 'output/ui-interactions', example);
  mkdirSync(out, { recursive: true });
  const { bundlePath } = prepareBundle(example, { build });
  let index = 0;
  async function capture(inputs) {
    const frame = await renderHeadlessFrame(bundlePath, { frames: inputs.length, inputs });
    if (frame.skippedCommands || !frame.uiSnapshot) throw Error('Interaction capture requires complete 2D rendering and a UI snapshot');
    if (frame.uiSnapshot.screen.width !== frame.width || frame.uiSnapshot.screen.height !== frame.height || frame.uiSnapshot.screen.dpr !== 1) {
      throw Error('Interaction snapshot coordinates must match the captured frame (dpr=1)');
    }
    const name = String(index++).padStart(3, '0');
    const png = resolve(out, `${name}.png`);
    writeFileSync(png, frame.png);
    writeFileSync(resolve(out, `${name}.snapshot.json`), frame.uiSnapshotJson);
    return { ...frame, png };
  }
  const initial = await capture([{}]);
  const snapshot = initial.uiSnapshot;
  if (!snapshot.focus_order?.length || snapshot.focus_order.length > 128) throw Error('Expected 1..128 focusable controls');
  if (focused(snapshot)) throw Error('Interaction fixture must start unfocused');
  const elements = resolve(out, 'elements.json');
  writeFileSync(elements, JSON.stringify(toVlmkitElements(snapshot, { scale: 1 })));
  const probes = [], integrity = [], hits = {};
  const check = frame => integrity.push(...analyzeSnapshot(frame.uiSnapshot).findings);
  check(initial);
  for (const device of ['keyboard', 'gamepad']) {
    for (const direction of ['next', 'previous']) {
      if (!profile[device]?.[direction]) throw Error(`Missing ${device}.${direction} input profile`);
      const inputs = [{}], targets = [], visible = [];
      for (let i = 0; i <= snapshot.focus_order.length; i++) {
        const control = await capture([...inputs, {}]);
        inputs.push(profile[device][direction]);
        const current = await capture(inputs);
        check(current);
        const id = focused(current.uiSnapshot);
        targets.push(id);
        if (i < snapshot.focus_order.length) {
          const node = current.uiSnapshot.nodes.find(n => n.id === id);
          let changed = false;
          if (node) {
            const diff = diffPng(control.png, current.png, {
              elements, ignore: outsideRegions(node, current.width, current.height),
            });
            changed = diff.diffPixels > 0;
          }
          visible.push(changed);
        }
        inputs.push({}); // release before the next press
      }
      probes.push({ device, direction, targets, visible });
    }
  }
  for (const id of snapshot.focus_order) {
    const node = snapshot.nodes.find(n => n.id === id);
    if (!node) continue;
    const current = await capture([{}, { cursorX: node.left + node.width / 2,
      cursorY: node.top + node.height / 2, mouseButtons: [0] }]);
    check(current);
    hits[id] = focused(current.uiSnapshot);
  }
  const findings = [...integrity, ...analyzeInteractions(snapshot, probes, hits)];
  const report = { example, probes, hits, captures: index, findings, ok: findings.length === 0 };
  writeFileSync(resolve(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
  return report;
}

async function main(args) {
  const example = args.shift();
  if (!example || example === '--help') {
    console.log('Usage: just ui-interactions <example> ["--no-build --profile inputs.json --out-dir dir"]\nDefault navigation: Tab/Shift-Tab and gamepad D-pad down/up. Requires an unfocused fixture.');
    return;
  }
  const options = {};
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--no-build') options.build = false;
    else if (args[i] === '--out-dir' && args[i + 1]) options.outDir = resolve(args[++i]);
    else if (args[i] === '--profile' && args[i + 1]) options.profile = JSON.parse(readFileSync(args[++i], 'utf8'));
    else throw Error(`Unknown or incomplete option: ${args[i]}`);
  }
  const report = await runInteractions(example, options);
  console.log(JSON.stringify(report, null, 2));
  if (!report.ok) process.exitCode = 1;
}
if (process.argv[1] === new URL(import.meta.url).pathname) main(process.argv.slice(2)).catch(error => {
  console.error(error.message); process.exitCode = 2;
});
