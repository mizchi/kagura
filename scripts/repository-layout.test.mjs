import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readdirSync, readFileSync, mkdtempSync, rmSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { tmpdir } from 'node:os';
import { REPO_ROOT } from './example-dirs.mjs';
import { loadReleaseModules, writePreparedManifests, readMoonWorkMembers } from './moon-release-utils.mjs';
import { readModuleManifest } from './moon-mod-manifest.mjs';

test('static Moon test and benchmark task paths resolve after package moves', () => {
  const source = readFileSync(join(REPO_ROOT, 'justfile'), 'utf8');
  for (const match of source.matchAll(/^\s+moon -C (\S+) (?:test|bench) ([^\n]+)/gm)) {
    if (match[1].includes('{{')) continue;
    for (const argument of match[2].split(/\s+/)) {
      if (argument.startsWith('-') || argument.includes('{{')) break;
      assert.ok(existsSync(resolve(REPO_ROOT, match[1], argument)), `justfile: ${match[0].trim()}`);
    }
  }
});

test('example and tool workspaces resolve every local transitive dependency', () => {
  const local = new Set(readMoonWorkMembers(REPO_ROOT).map(dir => readModuleManifest(join(REPO_ROOT, dir)).name));
  for (const file of modules()) {
    const directory = resolve(file, '..');
    if (!existsSync(join(directory, 'moon.work'))) continue;
    const members = readMoonWorkMembers(directory).map(dir => readModuleManifest(resolve(directory, dir)));
    const available = new Set(members.map(mod => mod.name));
    for (const mod of members) {
      for (const dep of Object.keys(mod.deps ?? {})) {
        if (local.has(dep)) assert.ok(available.has(dep), `${directory}/moon.work: ${mod.name} needs local ${dep}`);
      }
    }
  }
});

test('calculation, rendering, and gameplay packages have distinct owners', () => {
  for (const file of [
    'platform_native/gfx_wgpu_native/moon.pkg', 'platform_native/capture/moon.pkg',
    'core/physics2d/moon.pkg', 'core/physics3d/moon.pkg', 'core/collision3d/moon.pkg',
    'core/anim3d/ik3d/moon.pkg', 'core/pathfind/moon.mod',
    'core/terrain3d/moon.pkg', 'core/procedural3d/moon.pkg',
    'engine/application/moon.pkg', 'engine/scene/moon.pkg', 'engine/scene2d/moon.pkg',
    'engine/hud/moon.pkg', 'engine/tilemap2d/moon.pkg', 'engine/sprite_packer/moon.pkg',
    'engine/inspection/moon.pkg', 'engine/landscape_bench/moon.pkg',
    'game/gameplay2d/moon.pkg', 'game/progression/moon.pkg',
    'game/scene_flow/moon.pkg', 'game/scene_manager/moon.pkg', 'game/inventory_web/moon.pkg',
    'core/inputstate/moon.pkg', 'game/inpututil/moon.pkg',
  ]) assert.ok(existsSync(join(REPO_ROOT, file)), file);
  const core = readFileSync(join(REPO_ROOT, 'core/pkg.generated.mbti'), 'utf8');
  assert.doesNotMatch(core, /pub (?:trait Game|fn run_game|struct RunOptions)/);
  assert.match(readFileSync(join(REPO_ROOT, 'engine/application/pkg.generated.mbti'), 'utf8'), /trait Game/);
  const input = readFileSync(join(REPO_ROOT, 'core/inputstate/pkg.generated.mbti'), 'utf8');
  assert.doesNotMatch(input, /\b(?:InputHelper|is_move_up|is_confirm_just_pressed|key_w)\b/);
});

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
  for (const file of ['contracts.mbt', 'inputstate/moon.pkg', 'hierarchy/moon.pkg', 'physics2d/moon.pkg', 'physics3d/moon.pkg', 'collision3d/moon.pkg'])
    assert.ok(existsSync(join(coreDir, file)), file);
  for (const file of ['run_js.mbt', 'runtime/moon.pkg', 'scene3d/moon.pkg', 'scripts/moon-prebuild-native-link-flags.cjs'])
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
