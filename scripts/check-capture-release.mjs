#!/usr/bin/env node
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { renderHeadlessFrame } from '../assets/web/kagura-headless-frame.js';
import { resolveBuildArtifact } from './moon-build-artifact-utils.mjs';

const target = process.argv[2] ?? 'js';
if (!['js', 'native'].includes(target)) throw Error('Expected js or native');
const dir = resolve(import.meta.dirname, '../examples/demos-2d/ui_demo');
function build(target, mode) {
  execFileSync('moon', ['build', '.', '--target', target, '--' + mode, '--deny-warn'], { cwd: dir, stdio: 'inherit' });
  const artifact = resolveBuildArtifact(resolve(dir, `_build/${target}/${mode}/build/ui_demo.${target === 'js' ? 'js' : 'c'}`));
  assert.ok(artifact, 'missing generated artifact');
  return artifact;
}
const debug = build('js', 'debug');
const debugSource = readFileSync(debug, 'utf8');
assert.ok(/last_+button_+focused_+fixture/.test(debugSource), "debug factory missing");
assert.ok(debugSource.includes('"last_button_focused"'), "debug registration missing");
const release = build(target, 'release');
assert.ok(!/last_+button_+focused/.test(readFileSync(release, 'utf8')), 'capture fixture leaked into release');
if (target === 'js') {
  const inputs = { frames: 2, width: 360, height: 640 };
  const a = await renderHeadlessFrame(debug, inputs);
  const b = await renderHeadlessFrame(release, inputs);
  assert.deepEqual(a.png, b.png, 'removing fixtures changed normal rendering');
  assert.deepEqual(a.uiSnapshot, b.uiSnapshot);
  const initialized = await renderHeadlessFrame(debug, { ...inputs, initialState: 'last_button_focused' });
  assert.equal(initialized.initialState, 'last_button_focused');
  await assert.rejects(renderHeadlessFrame(release, { ...inputs, initialState: 'last_button_focused' }), /Unknown initial state/);
}
console.log(`capture fixtures removed from ${target} release artifact`);
