#!/usr/bin/env node
// Explicit native integration target: JS-only Node test jobs do not need a native toolchain.
import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { prepareNativeCapture, renderNativeCapture } from './ui-capture-native.mjs';
import { buildCaptureConfig } from './stage-capture-config.mjs';
import { prepareBundle } from './render-frame.mjs';
import { renderHeadlessFrame } from '../assets/web/kagura-headless-frame.js';
import { diffPng } from './vlmkit-png.mjs';

const demo = prepareNativeCapture('ui_demo');
const js = prepareBundle('ui_demo');
const out = mkdtempSync(join(tmpdir(), 'kagura-native-integration-'));
try {
  const cell = { width: 360, height: 640, frames: 2, inputs: [{}, { mouseButtons: [0], cursorX: 280, cursorY: 74 }], expectedFocus: 'button_4' };
  const native = renderNativeCapture(demo, cell);
  const browserless = await renderHeadlessFrame(js.bundlePath, cell);
  assert.deepEqual(native.uiSnapshot, browserless.uiSnapshot, 'native and JS must publish the same UI meaning');
  writeFileSync(join(out, 'native.png'), native.png);
  writeFileSync(join(out, 'js.png'), browserless.png);
  assert.equal(diffPng(join(out, 'native.png'), join(out, 'js.png')).diffPixels, 0);

  const initialized = { width: 360, height: 640, frames: 1, inputs: [], initialState: 'last_button_focused', expectedFocus: 'button_6' };
  const initializedNative = renderNativeCapture(demo, initialized);
  const initializedJs = await renderHeadlessFrame(js.bundlePath, initialized);
  assert.equal(initializedNative.initialState, initialized.initialState);
  assert.deepEqual(initializedNative.uiSnapshot, initializedJs.uiSnapshot);
  assert.equal(initializedNative.uiSnapshot.frame, 1);
  const advanced = { ...initialized, frames: 2, inputs: [{}, { keys: [9] }], expectedFocus: 'button_1' };
  const advancedNative = renderNativeCapture(demo, advanced);
  const advancedJs = await renderHeadlessFrame(js.bundlePath, advanced);
  assert.deepEqual(advancedNative.uiSnapshot, advancedJs.uiSnapshot, 'inputs must run after named initialization');
  await assert.rejects(renderHeadlessFrame(js.bundlePath, { ...initialized, initialState: 'missing' }), /Unknown initial state/);
  assert.throws(() => renderNativeCapture(demo, { ...initialized, initialState: 'missing' }), /Unknown initial state/);

  // Textured game checks the native web-runtime adapter, not just untextured UI.
  const sprite = prepareNativeCapture('sprite_anim');
  const spriteJs = prepareBundle('sprite_anim');
  const unicodeDir = join(out, '日本語のパス');
  mkdirSync(unicodeDir);
  const config = join(unicodeDir, 'capture.txt');
  const request = join(unicodeDir, 'request.json');
  writeFileSync(config, buildCaptureConfig({ outDir: unicodeDir, name: 'sprite' }) + `request_path=${request}\n`);
  writeFileSync(request, JSON.stringify({ width: 320, height: 240, frames: 20, inputs: [] }));
  execFileSync(sprite.binaryPath, [], { cwd: sprite.exampleDir, env: { ...process.env, KAGURA_CAPTURE_CONFIG: config }, timeout: 30000 });
  const spriteFrame = await renderHeadlessFrame(spriteJs.bundlePath, { width: 320, height: 240, frames: 20 });
  writeFileSync(join(out, 'sprite-js.png'), spriteFrame.png);
  assert.equal(diffPng(join(unicodeDir, 'sprite.png'), join(out, 'sprite-js.png')).diffPixels, 0);

  writeFileSync(request, JSON.stringify({ width: 320, height: 240, frames: 1, inputs: [], initial_state: 'unhandled' }));
  assert.throws(() => execFileSync(sprite.binaryPath, [], { cwd: sprite.exampleDir,
    env: { ...process.env, KAGURA_CAPTURE_CONFIG: config }, timeout: 5000, stdio: ['ignore', 'pipe', 'pipe'] }), error => /not applied/.test(error.stdout?.toString()));
  await assert.rejects(renderHeadlessFrame(spriteJs.bundlePath, { initialState: 'unhandled' }), /not applied/);

  for (const bad of ['missing', 'bad-request', 'bad-config']) {
    if (bad === 'bad-request') writeFileSync(request, '{"width":0}');
    if (bad === 'bad-config') writeFileSync(config, 'request_path=missing');
    const result = spawnSync(demo.binaryPath, [], { cwd: demo.exampleDir,
      env: { ...process.env, KAGURA_CAPTURE_CONFIG: bad === 'missing' ? join(out, 'missing') : config }, timeout: 5000 });
    assert.notEqual(result.status, 0, `${bad} must fail`);
    assert.notEqual(result.error?.code, 'ETIMEDOUT', `${bad} must not fall back to a window loop`);
    assert.match(result.stderr.toString(), /capture/i);
  }
  console.log('native capture: PNG + snapshot parity, textured sprite, UTF-8 paths and invalid configuration passed');
} finally { rmSync(out, { recursive: true, force: true }); }
