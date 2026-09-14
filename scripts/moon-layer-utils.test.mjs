import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {validateWorkspaceLayers} from './moon-layer-utils.mjs';

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'kagura-layers-'));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const modules = {core: 'test/core', 'core/numeric': 'test/numeric', engine: 'test/engine', game: 'test/game', platform: 'test/platform'};
  fs.writeFileSync(path.join(root, 'moon.work'), `members = ${JSON.stringify(Object.keys(modules))}\n`);
  for (const [dir, name] of Object.entries(modules)) {
    fs.mkdirSync(path.join(root, dir), {recursive: true});
    fs.writeFileSync(path.join(root, dir, 'moon.mod.json'), JSON.stringify({name}));
    fs.writeFileSync(path.join(root, dir, 'moon.pkg'), '');
  }
  return root;
}

test('workspace layer gate covers every actual module', () => {
  const result = validateWorkspaceLayers();
  assert.ok(result.modules.length >= 20);
  assert.deepEqual(result.errors, []);
});

test('nested calculation modules cannot hide rendering or game dependencies', t => {
  const root = fixture(t);
  fs.writeFileSync(path.join(root, 'core/numeric/moon.pkg'), 'import {\n "test/engine/draw",\n "test/game/rules",\n "mizchi/gfx",\n}\n');
  const result = validateWorkspaceLayers({repoRoot: root});
  assert.equal(result.errors.length, 3);
  assert.ok(result.errors.every(error => error.startsWith('core/numeric/moon.pkg:')));
});

test('manifest-only reverse dependencies and host FFI are rejected', t => {
  const root = fixture(t);
  fs.writeFileSync(path.join(root, 'engine/moon.mod.json'), JSON.stringify({name: 'test/engine', deps: {'test/game': '0.1.0'}}));
  fs.writeFileSync(path.join(root, 'core/clock.mbt'), 'extern "js" fn now() -> Double = "now"\n');
  const result = validateWorkspaceLayers({repoRoot: root});
  assert.equal(result.errors.length, 2);
  assert.match(result.errors.join('\n'), /must not call a host/);
  assert.match(result.errors.join('\n'), /must not depend on test\/game/);
});

test('rendering consumes calculations and gameplay consumes rendering', t => {
  const root = fixture(t);
  fs.writeFileSync(path.join(root, 'core/numeric/moon.pkg'), 'import { "test/core" }\n');
  fs.writeFileSync(path.join(root, 'engine/moon.pkg'), 'import { "test/numeric" }\n');
  fs.writeFileSync(path.join(root, 'game/moon.pkg'), 'import { "test/engine" }\n');
  assert.deepEqual(validateWorkspaceLayers({repoRoot: root}).errors, []);
});
