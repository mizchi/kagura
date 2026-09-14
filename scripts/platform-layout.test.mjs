import assert from 'node:assert/strict';
import {existsSync, mkdtempSync, readFileSync, rmSync, mkdirSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, resolve} from 'node:path';
import test from 'node:test';
import {loadReleaseModules, readMoonWorkMembers, writePreparedManifests} from './moon-release-utils.mjs';
import {readModuleManifest} from './moon-mod-manifest.mjs';
import {validateModuleImportBoundaries} from './moon-boundary-utils.mjs';

test('top-level native platform resolves its workspace and native prebuild dependencies', () => {
  const repoRoot = resolve(import.meta.dirname, '..');
  assert.ok(readMoonWorkMembers(repoRoot).includes('platform_native'));
  const nativeRoot = join(repoRoot, 'platform_native');
  const manifest = readModuleManifest(nativeRoot);
  assert.equal(manifest.deps['mizchi/kagura_platform'], readModuleManifest(join(repoRoot, 'platform')).version);
  const prebuild = resolve(nativeRoot, manifest['--moonbit-unstable-prebuild']);
  assert.equal(prebuild, join(repoRoot, 'scripts/moon-prebuild-native-link-flags.cjs'));
  assert.ok(existsSync(prebuild));
  for (const member of readMoonWorkMembers(nativeRoot)) {
    assert.ok(readModuleManifest(resolve(nativeRoot, member)).name, `missing native workspace member ${member}`);
  }
});

test('platform contract and JS implementation stage as separate publishable modules', t => {
  const {byName} = loadReleaseModules();
  const contract = byName.get('mizchi/kagura_platform');
  const implementation = byName.get('mizchi/kagura_platform_web');
  assert.equal(contract.dir, 'platform');
  assert.equal(implementation?.dir, 'platform_web');
  assert.equal(implementation.manifest.deps[contract.name], contract.version);
  const outDir = mkdtempSync(join(tmpdir(), 'kagura-platform-stage-'));
  t.after(() => rmSync(outDir, {recursive: true, force: true}));
  const staged = writePreparedManifests({outDir, moduleFilter: [contract.name, implementation.name]});
  assert.deepEqual(staged.validation.errors, []);
  const contractDir = join(outDir, 'mizchi__kagura_platform');
  const implementationDir = join(outDir, 'mizchi__kagura_platform_web');
  assert.ok(existsSync(join(contractDir, 'contracts.mbt')));
  assert.ok(existsSync(join(implementationDir, 'web_core', 'controls.mbt')));
  for (const nested of ['web_runtime_hooks', 'native_runtime_hooks', 'platform_web']) {
    assert.equal(existsSync(join(contractDir, nested)), false, `contract must not bundle ${nested}`);
  }
  const published = JSON.parse(readFileSync(join(implementationDir, 'moon.mod.json'), 'utf8'));
  assert.equal(published.deps[contract.name], contract.version);
});

test('default boundary policy permits implementations to use the contract and rejects reverse or engine dependencies', t => {
  const repoRoot = mkdtempSync(join(tmpdir(), 'kagura-platform-boundaries-'));
  t.after(() => rmSync(repoRoot, {recursive: true, force: true}));
  const modules = {
    platform: 'mizchi/kagura_platform',
    platform_web: 'mizchi/kagura_platform_web',
    engine: 'mizchi/kagura_engine',
  };
  for (const [dir, name] of Object.entries(modules)) {
    mkdirSync(join(repoRoot, dir));
    writeFileSync(join(repoRoot, dir, 'moon.mod.json'), JSON.stringify({name, version: '0.1.0'}));
    writeFileSync(join(repoRoot, dir, 'moon.pkg'), '');
  }
  const check = () => validateModuleImportBoundaries({repoRoot, moduleDirs: Object.keys(modules)});
  writeFileSync(join(repoRoot, 'platform_web/moon.pkg'), 'import { "mizchi/kagura_platform" @platform }\n');
  assert.deepEqual(check().errors, []);
  writeFileSync(join(repoRoot, 'platform/moon.pkg'), 'import { "mizchi/kagura_platform_web/web_core" }\n');
  assert.equal(check().violations.length, 1);
  writeFileSync(join(repoRoot, 'platform/moon.pkg'), '');
  writeFileSync(join(repoRoot, 'platform_web/moon.pkg'), 'import { "mizchi/kagura_engine/runtime" }\n');
  assert.equal(check().violations.length, 1);
});
