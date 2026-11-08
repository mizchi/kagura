import test from 'node:test';
import assert from 'node:assert/strict';
import {existsSync, readdirSync, readFileSync} from 'node:fs';
import {resolve, join, relative} from 'node:path';
import {spawnSync} from 'node:child_process';
import {readMoonWorkMembers} from './moon-release-utils.mjs';

const root = resolve(import.meta.dirname, '..');
const standalone = ['editor/studio', 'editor/model-viewer', 'editor/modeling3d', 'editor/effect-studio',
  'examples/experimental/wasm_game/guest/moonbit', 'assets/vendor/glfw'];
const external = ['examples/experimental/crater_paint', 'examples/smoke/browser_headless'];
const ignored = new Set(['_build', '_site', 'target', 'node_modules', 'dist', 'output', 'fixtures']);
function sourceModules() {
  const found = ['.'];
  function walk(directory) {
    if (existsSync(join(directory, 'moon.mod')) || existsSync(join(directory, 'moon.mod.json'))) {
      found.push(relative(root, directory));
    }
    for (const entry of readdirSync(directory, {withFileTypes: true})) {
      if (entry.isDirectory() && !entry.name.startsWith('.') && !ignored.has(entry.name)) walk(join(directory, entry.name));
    }
  }
  for (const name of ['core', 'engine', 'game', 'platform', 'platform_web', 'platform_native', 'editor',
    'examples', 'experiments', 'benchmarks', 'assets/vendor']) walk(join(root, name));
  return found;
}

test('every source-owned MoonBit module has a workspace, example, standalone or explicit external check route', () => {
  const result = spawnSync(process.execPath, ['scripts/example-projects.mjs', '--target', 'native', '--mode', 'check'],
    {cwd: root, encoding: 'utf8'});
  assert.equal(result.status, 0, result.stderr);
  const covered = new Set([...readMoonWorkMembers(root), ...result.stdout.trim().split('\n'), ...standalone, ...external]);
  assert.deepEqual(sourceModules().filter(path => !covered.has(path)).sort(), []);
  const tasks = readFileSync(join(root, 'justfile'), 'utf8');
  for (const path of [...standalone, ...external]) assert.ok(tasks.includes(path), `missing check recipe for ${path}`);
});

test('source-owned modules no longer contain legacy JSON manifests', () => {
  assert.deepEqual(sourceModules().filter(path => existsSync(join(root, path, 'moon.mod.json'))).sort(), []);
});
