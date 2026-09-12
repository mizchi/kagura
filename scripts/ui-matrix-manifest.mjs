import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { findExampleDir } from './example-dirs.mjs';

/**
 * Examples whose `editor/verification.json` is green on the JS CPU matrix.
 * Games that still fail integrity or skip 3D (hacknslash_3d) stay out until
 * those gates can pass without pinning a defective HUD.
 */
export const UI_MATRIX_EXAMPLES = [
  'ui_demo',
  'flappy_bird',
  'survivor',
  'action_rpg',
  'hacknslash',
  'card_game',
];

/**
 * 3D examples whose CPU rasterizer skips draw commands. Captured with
 * `--backend gpu` (native wgpu). Not in JS CI: Linux has no portable GPU.
 */
export const GPU_MATRIX_EXAMPLES = [
  'hacknslash_3d',
];

export function matrixExampleDir(example, repoRoot = resolve(import.meta.dirname, '..')) {
  const dir = findExampleDir(example, [resolve(repoRoot, 'examples')]);
  if (!dir) throw Error(`Unknown matrix example: ${example}`);
  if (!existsSync(resolve(dir, 'editor/verification.json'))) {
    throw Error(`${example} is listed for ui-matrix but has no editor/verification.json`);
  }
  return dir;
}

export function matrixThemePath(example, repoRoot = resolve(import.meta.dirname, '..')) {
  return resolve(matrixExampleDir(example, repoRoot), 'editor/theme.json');
}

export function pkgSupportsNative(pkgText) {
  const match = /supported_targets\s*=\s*"([^"]+)"/.exec(pkgText);
  if (!match) return true;
  return match[1].split('+').includes('native');
}

export function nativeUiMatrixExamples(repoRoot = resolve(import.meta.dirname, '..')) {
  return UI_MATRIX_EXAMPLES.filter((example) => {
    const pkgPath = resolve(matrixExampleDir(example, repoRoot), 'moon.pkg');
    return pkgSupportsNative(readFileSync(pkgPath, 'utf8'));
  });
}
