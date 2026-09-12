import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import {
  UI_MATRIX_EXAMPLES,
  matrixExampleDir,
  matrixThemePath,
  nativeUiMatrixExamples,
  pkgSupportsNative,
  GPU_MATRIX_EXAMPLES,
} from './ui-matrix-manifest.mjs';
import { matrixCells } from './ui-matrix-utils.mjs';
import { loadTheme } from './ui-theme-utils.mjs';

test('every CI matrix example has a parseable verification.json', () => {
  assert.ok(UI_MATRIX_EXAMPLES.includes('ui_demo'));
  for (const example of UI_MATRIX_EXAMPLES) {
    const dir = matrixExampleDir(example);
    const cells = matrixCells(JSON.parse(readFileSync(resolve(dir, 'editor/verification.json'), 'utf8')));
    assert.ok(cells.length >= 1, example);
    assert.ok(existsSync(dir));
  }
});

test('pkgSupportsNative reads moon.pkg supported_targets', () => {
  assert.equal(pkgSupportsNative('supported_targets = "js"'), false);
  assert.equal(pkgSupportsNative('supported_targets = "js+native"'), true);
  assert.equal(pkgSupportsNative('supported_targets = "native"'), true);
  assert.equal(pkgSupportsNative(''), true);
});

test('native matrix skips js-only examples', () => {
  const native = nativeUiMatrixExamples();
  assert.ok(native.includes('ui_demo'));
  assert.ok(native.includes('flappy_bird'));
  assert.ok(native.includes('survivor'));
  assert.ok(native.includes('action_rpg'));
  assert.ok(native.includes('card_game'));
  assert.equal(native.includes('hacknslash'), false);
  for (const example of native) {
    const pkg = readFileSync(resolve(matrixExampleDir(example), 'moon.pkg'), 'utf8');
    assert.equal(pkgSupportsNative(pkg), true, example);
  }
});

test('GPU matrix examples stay out of the JS CPU list', () => {
  assert.equal(UI_MATRIX_EXAMPLES.includes('hacknslash_3d'), false);
  assert.ok(GPU_MATRIX_EXAMPLES.includes('hacknslash_3d'));
  for (const example of GPU_MATRIX_EXAMPLES) {
    const dir = matrixExampleDir(example);
    assert.ok(existsSync(resolve(dir, 'editor/verification.json')), example);
  }
});

test('every CI matrix example declares a theme token table', () => {
  for (const example of UI_MATRIX_EXAMPLES) {
    const themePath = matrixThemePath(example);
    assert.ok(existsSync(themePath), themePath);
    const theme = loadTheme(JSON.parse(readFileSync(themePath, 'utf8')));
    assert.ok(theme.tokens.length >= 1, example);
  }
});
