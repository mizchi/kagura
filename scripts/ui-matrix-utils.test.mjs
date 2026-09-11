import { test } from 'node:test';
import assert from 'node:assert/strict';
import { matrixCells, validateMatrixFrame } from './ui-matrix-utils.mjs';
const manifest = { version: 1, states: { idle: { frames: 1 }, focus: { frames: 2, inputs: [{}, { keys: [9] }] } } };
test('all declared states run at each distinct aspect ratio', () => {
  const cells = matrixCells(manifest);
  assert.equal(cells.length, 8);
  assert.equal(new Set(cells.map(c => c.name)).size, 8);
  assert.deepEqual(cells.find(c => c.state === 'focus').inputs, [{}, { keys: [9] }]);
});
test('empty matrices, duplicate viewports and unsafe artifact names are rejected', () => {
  for (const bad of [{ version: 1, states: {} }, { ...manifest, states: { '../oops': { frames: 1 } } },
    { ...manifest, viewports: [{ name: 'a', width: 10, height: 10 }, { name: 'a', width: 20, height: 20 }] },
    { ...manifest, states: { idle: { frames: 0 } } }]) assert.throws(() => matrixCells(bad));
});
test('a resized PNG without matching layout metadata is not responsive coverage', () => {
  const cell = { width: 360, height: 640, frames: 1, expectedFocus: 'button_1' };
  const frame = { width: 360, height: 640, frames: 1, skippedCommands: 0, uiSnapshot: {
    screen: { width: 640, height: 480, dpr: 1 }, nodes: [],
  } };
  assert.throws(() => validateMatrixFrame(cell, frame), /coordinates/);
  frame.uiSnapshot.screen = { width: 360, height: 640, dpr: 1 };
  assert.throws(() => validateMatrixFrame(cell, frame), /focus/);
  frame.uiSnapshot.nodes = [{ id: 'button_1', focused: true }];
  validateMatrixFrame(cell, frame);
});

test('initialState is distinct from the artifact label and must actually be applied', () => {
  const cell = matrixCells({ version: 1, states: { dialog_case: { frames: 1, initialState: 'dialog' } } })[0];
  assert.equal(cell.state, 'dialog_case');
  assert.equal(cell.initialState, 'dialog');
  const frame = { ...cell, skippedCommands: 0, initialState: null, uiSnapshot: {
    screen: { width: cell.width, height: cell.height, dpr: 1 }, nodes: [],
  } };
  assert.throws(() => validateMatrixFrame(cell, frame), /initial state/i);
  frame.initialState = 'dialog';
  validateMatrixFrame(cell, frame);
  for (const initialState of ['', '../a', 1, null]) {
    assert.throws(() => matrixCells({ version: 1, states: { test: { frames: 1, initialState } } }));
  }
});
