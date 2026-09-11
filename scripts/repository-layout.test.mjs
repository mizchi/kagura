import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { REPO_ROOT } from './example-dirs.mjs';

function modules(dir = REPO_ROOT) {
  const found = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (
      entry.name.startsWith('.') ||
      [
        'node_modules',
        '_build',
        '_site',
        'target',
        'dist',
        'public',
        'test-results',
        'playwright-report',
      ].includes(entry.name)
    )
      continue;
    const path = join(dir, entry.name);
    if (entry.isDirectory()) found.push(...modules(path));
    else if (['moon.mod', 'moon.mod.json'].includes(entry.name)) found.push(path);
  }
  return found;
}

test('MoonBit modules use flat source roots while Rust and Zig retain their own conventions', () => {
  const paths = modules();
  assert.ok(paths.length > 50);
  for (const path of paths) {
    const source = readFileSync(path, 'utf8');
    if (path.endsWith('.json')) assert.notEqual(JSON.parse(source).source, 'src', path);
    else assert.doesNotMatch(source, /\bsource\s*=\s*"src"/, path);
  }
  assert.ok(existsSync(join(REPO_ROOT, 'moon.pkg')));
  assert.ok(existsSync(join(REPO_ROOT, 'examples/experimental/wasm_game/guest/rust/src/lib.rs')));
});

test('shared web runtime and vendored native headers live under assets', () => {
  for (const file of [
    'assets/web/kagura-gfx.js',
    'assets/web/kagura-init.js',
    'assets/vendor/glfw/include/GLFW/glfw3.h',
  ])
    assert.ok(existsSync(join(REPO_ROOT, file)), file);
  for (const file of ['lib/web/kagura-gfx.js', 'vendor/glfw/include/GLFW/glfw3.h', 'src/moon.pkg'])
    assert.ok(!existsSync(join(REPO_ROOT, file)), file);
});
