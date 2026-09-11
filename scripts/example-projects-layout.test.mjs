import test from 'node:test';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';

const list = (target, mode) => execFileSync(process.execPath, [
  new URL('./example-projects.mjs', import.meta.url).pathname,
  '--target', target, '--mode', mode,
], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim().split('\n');

test('CI discovery preserves target filtering for flat and legacy source packages', () => {
  const js = list('js', 'check');
  assert.ok(js.includes('examples/games/arena3d'));
  assert.ok(!js.includes('examples/demos-3d/terrain_demo'));
  assert.ok(!js.includes('examples/smoke/runtime_smoke_native'));
  const nativeCheck = list('native', 'check');
  assert.ok(nativeCheck.includes('examples/demos-3d/terrain_demo'));
  assert.ok(nativeCheck.includes('examples/games/arena3d'));
  const nativeTest = list('native', 'test');
  assert.ok(!nativeTest.includes('examples/games/arena3d'));
  assert.ok(!nativeTest.includes('examples/smoke/runtime_smoke_native'));
});
