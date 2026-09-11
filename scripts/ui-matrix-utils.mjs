import { createHeadlessRequest } from '../assets/web/kagura-headless-frame.js';
export const MATRIX_VIEWPORTS = [
  { name: 'wide', width: 640, height: 360 },
  { name: 'standard', width: 640, height: 480 },
  { name: 'portrait', width: 360, height: 640 },
  { name: 'ultrawide', width: 840, height: 360 },
];
const name = value => typeof value === 'string' && /^[a-zA-Z0-9_-]+$/.test(value);
export function matrixCells(manifest) {
  if (manifest?.version !== 1 || !manifest.states || Array.isArray(manifest.states) || typeof manifest.states !== 'object') throw Error('Expected version 1 verification states');
  const states = Object.entries(manifest.states);
  const viewports = manifest.viewports ?? MATRIX_VIEWPORTS;
  if (!states.length || states.length > 32 || !Array.isArray(viewports) || !viewports.length || viewports.length > 16) throw Error('Empty or excessive matrix');
  const seen = new Set();
  for (const vp of viewports) {
    if (!name(vp.name) || seen.has(vp.name) || !Number.isInteger(vp.width) || !Number.isInteger(vp.height) ||
      vp.width < 1 || vp.height < 1 || vp.width > 4096 || vp.height > 4096 || vp.width * vp.height > 4194304) throw Error('Invalid matrix viewport');
    seen.add(vp.name);
  }
  return states.flatMap(([state, recipe]) => {
    if (!name(state) || !Number.isInteger(recipe?.frames) || recipe.frames < 1 || recipe.frames > 600 ||
      (recipe.expectedFocus !== undefined && recipe.expectedFocus !== null && typeof recipe.expectedFocus !== 'string') ||
      (recipe.expectedState !== undefined && typeof recipe.expectedState !== 'string') ||
      (recipe.initialState !== undefined && (!name(recipe.initialState) || recipe.initialState.length > 128))) throw Error('Invalid matrix state');
    createHeadlessRequest({ inputs: recipe.inputs });
    if (recipe.inputs && recipe.inputs.length > recipe.frames) throw Error('Matrix inputs extend beyond capture');
    return viewports.map(vp => ({ state, name: `${state}.${vp.name}`, width: vp.width, height: vp.height,
      frames: recipe.frames, initialState: recipe.initialState, inputs: recipe.inputs ?? [], expectedFocus: recipe.expectedFocus, expectedState: recipe.expectedState }));
  });
}
export function validateMatrixFrame(cell, frame) {
  if (frame.skippedCommands || !frame.uiSnapshot) throw Error('Matrix requires complete 2D rendering and UI snapshots');
  if ((cell.initialState ?? null) !== (frame.initialState ?? null)) throw Error('Requested initial state was not applied');
  const screen = frame.uiSnapshot.screen;
  if (frame.width !== cell.width || frame.height !== cell.height || frame.frames !== cell.frames ||
    screen.width !== cell.width || screen.height !== cell.height || screen.dpr !== 1) throw Error('Matrix capture and snapshot coordinates do not match the requested viewport');
  if (cell.expectedState !== undefined && frame.uiSnapshot.state !== cell.expectedState) throw Error('Matrix did not reach the expected game state');
  if (cell.expectedFocus !== undefined) {
    const selected = frame.uiSnapshot.nodes.filter(n => n.focused).map(n => n.id);
    const expected = cell.expectedFocus === null ? [] : [cell.expectedFocus];
    if (JSON.stringify(selected) !== JSON.stringify(expected)) throw Error('Matrix did not reach the expected focus');
  }
}
