import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readdirSync, readFileSync, mkdtempSync, rmSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { tmpdir } from 'node:os';
import { REPO_ROOT } from './example-dirs.mjs';
import { loadReleaseModules, writePreparedManifests } from './moon-release-utils.mjs';

test('core and engine publish from layer roots without bundling independent child modules', t => {
  const {byName} = loadReleaseModules();
  const core = byName.get('mizchi/kagura_core');
  const engine = byName.get('mizchi/kagura_engine');
  assert.equal(core.dir, 'core');
  assert.equal(engine.dir, 'engine');
  assert.equal(resolve(engine.root, engine.manifest['--moonbit-unstable-prebuild']),
    join(REPO_ROOT, 'scripts/moon-prebuild-native-link-flags.cjs'));
  const outDir = mkdtempSync(join(tmpdir(), 'kagura-layer-stage-'));
  t.after(() => rmSync(outDir, {recursive: true, force: true}));
  const staged = writePreparedManifests({outDir, moduleFilter: [core.name, engine.name]});
  assert.deepEqual(staged.validation.errors, []);
  const coreDir = join(outDir, 'mizchi__kagura_core');
  const engineDir = join(outDir, 'mizchi__kagura_engine');
  for (const file of ['contracts.mbt', 'inpututil/moon.pkg', 'hierarchy/moon.pkg'])
    assert.ok(existsSync(join(coreDir, file)), file);
  for (const file of ['run_js.mbt', 'runtime/moon.pkg', 'scene3d/moon.pkg', 'gfx_wgpu_native/wgpu_native_stub.c', 'scripts/moon-prebuild-native-link-flags.cjs'])
    assert.ok(existsSync(join(engineDir, file)), file);
  for (const [source, destination] of [[core.root, coreDir], [engine.root, engineDir]]) {
    for (const entry of readdirSync(source, {withFileTypes: true})) {
      if (entry.isDirectory() && existsSync(join(source, entry.name, 'moon.mod')))
        assert.equal(existsSync(join(destination, entry.name)), false, `bundled child module ${entry.name}`);
    }
  }
});

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

test('shared web runtime, fonts and vendored native headers live under assets', () => {
  for (const file of [
    'assets/web/kagura-gfx.js',
    'assets/web/kagura-init.js',
    'assets/fonts/NotoSansJP-subset.otf',
    'assets/vendor/glfw/include/GLFW/glfw3.h',
  ])
    assert.ok(existsSync(join(REPO_ROOT, file)), file);
  for (const file of ['lib/web/kagura-gfx.js', 'vendor/glfw/include/GLFW/glfw3.h', 'src/moon.pkg'])
    assert.ok(!existsSync(join(REPO_ROOT, file)), file);
});
