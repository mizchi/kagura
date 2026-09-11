import { test } from 'node:test';
import assert from 'node:assert/strict';
import { runMatrix } from './ui-matrix.mjs';
import { nativeCaptureRequest, parseNativeCapture } from './ui-capture-native.mjs';

test('native request uses the same full input wire contract as JS', () => {
  const request = nativeCaptureRequest({ width: 360, height: 640, frames: 2, initialState: 'dialog', inputs: [{}, { keys: [9], mouseButtons: [0] }] });
  assert.equal(request.initial_state, 'dialog');
  assert.deepEqual(request.inputs[1], { cursor_x: -1, cursor_y: -1, keys: [9], mouse_buttons: [0], gamepads: [] });
  assert.throws(() => nativeCaptureRequest({ width: 0, height: 640, frames: 1 }), /viewport/);
});
test('native artifacts require complete rendering and matching image dimensions', () => {
  const png = Buffer.alloc(24);
  Buffer.from([137,80,78,71,13,10,26,10]).copy(png);
  png.writeUInt32BE(13,8); png.write('IHDR',12);
  png.writeUInt32BE(360,16); png.writeUInt32BE(640,20);
  const meta = { backend: 'native-cpu', width: 360, height: 640, frames: 2, skipped_commands: 0, drawn_triangles: 1, draw_commands: 1 };
  const snapshot = JSON.stringify({ screen: { width: 360, height: 640, dpr: 1 }, nodes: [] });
  assert.equal(parseNativeCapture(png, JSON.stringify(meta), snapshot).frames, 2);
  assert.throws(() => parseNativeCapture(png, JSON.stringify({ ...meta, skipped_commands: 1 }), snapshot), /incomplete/);
  assert.throws(() => parseNativeCapture(png, JSON.stringify({ ...meta, width: 640 }), snapshot), /dimensions/);
  assert.throws(() => parseNativeCapture(png, JSON.stringify(meta), 'null'), /snapshot/);
  assert.equal(parseNativeCapture(png, JSON.stringify({ ...meta, backend: 'native-gpu' }), snapshot).backend, 'native-gpu');
  assert.throws(() => parseNativeCapture(png, JSON.stringify({ ...meta, backend: 'webgpu' }), snapshot), /incomplete/);
});

test('native comparisons cannot rewrite the shared JS baseline', async () => {
  await assert.rejects(runMatrix('unused', { backend: 'native', update: true }), /shared baseline/);
  await assert.rejects(runMatrix('unused', { backend: 'unknown' }), /backend/);
});
