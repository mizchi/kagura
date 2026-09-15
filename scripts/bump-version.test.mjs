import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, readFileSync, writeFileSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, resolve} from 'node:path';
import {spawnSync} from 'node:child_process';
import test from 'node:test';
import {planVersionUpdate, applyVersionUpdate, updateManifest} from './bump-version.mjs';
import {publishModules, PUBLISH_MODULE_DIRS} from './release-modules.mjs';
import {readModuleManifest} from './moon-mod-manifest.mjs';
import {readMoonWorkMembers} from './moon-release-utils.mjs';

function fixture(t) {
  const root = mkdtempSync(join(tmpdir(), 'kagura-version-'));
  t.after(() => rmSync(root, {recursive: true, force: true}));
  const write = (file, source) => {
    mkdirSync(resolve(root, file, '..'), {recursive: true});
    writeFileSync(join(root, file), source);
  };
  write('moon.mod', 'name = "test/root"\nversion = "0.4.0"\nimport { "test/core@0.2.0", "external/lib@3.0.0" }\n');
  write('core/moon.mod', 'name = "test/core"\nversion = "0.2.0"\n');
  write('examples/game/moon.mod.json', JSON.stringify({name: 'test/game', version: '0.1.0', deps: {'test/core': '0.2.0', 'external/lib': '3.0.0'}}, null, 2) + '\n');
  write('cmd/kagura/templates/web/moon.mod.template', 'name = "user/__PROJECT_NAME__"\nversion = "0.1.0"\nimport { "test/root@0.4.0" }\n');
  write('assets/vendor/vendor/moon.mod', 'name = "vendor/pkg"\nversion = "9.0.0"\nimport { "test/core@0.2.0" }\n');
  write('_build/fixture/moon.mod', 'invalid generated manifest');
  return {root, write, options: {repoRoot: root, moduleDirs: ['.', 'core']}};
}

test('plan updates public versions and consumer/template dependencies without writing', t => {
  const {root, options} = fixture(t);
  const before = readFileSync(join(root, 'moon.mod'), 'utf8');
  const plan = planVersionUpdate('0.5.0', options);
  assert.equal(plan.modules.length, 2);
  assert.equal(plan.changes.length, 4);
  assert.equal(readFileSync(join(root, 'moon.mod'), 'utf8'), before);
  applyVersionUpdate(plan);
  assert.equal(readModuleManifest(root).version, '0.5.0');
  assert.equal(readModuleManifest(root).deps['external/lib'], '3.0.0');
  assert.equal(readModuleManifest(join(root, 'core')).version, '0.5.0');
  const game = readModuleManifest(join(root, 'examples/game'));
  assert.equal(game.version, '0.1.0');
  assert.equal(game.deps['test/core'], '0.5.0');
  assert.equal(game.deps['external/lib'], '3.0.0');
  const template = readFileSync(join(root, 'cmd/kagura/templates/web/moon.mod.template'), 'utf8');
  assert.match(template, /version = "0.1.0"/);
  assert.match(template, /test\/root@0.5.0/);
  assert.match(readFileSync(join(root, 'assets/vendor/vendor/moon.mod'), 'utf8'), /test\/core@0.2.0/);
  assert.deepEqual(planVersionUpdate('0.5.0', options).changes, []);
});

test('Moon manifests preserve comments, unrelated strings and formatting', () => {
  const source = `// version = "9.0.0"
name = "test/core"
version = "0.2.0" // current
description = "test/core@0.2.0"
import {
  // "test/core@8.0.0"
  /* "test/core@7.0.0" */
  "test/core@0.2.0", // actual dependency
  "test/core_extra@4.0.0",
}
options(note: "test/core@0.2.0")
`;
  const updated = updateManifest(source, {version: '0.5.0', publicNames: new Set(['test/core']), updateOwnVersion: true});
  assert.equal(updated, source.replace('version = "0.2.0" // current', 'version = "0.5.0" // current')
    .replace('"test/core@0.2.0", // actual', '"test/core@0.5.0", // actual'));
});

test('JSON path dependencies retain their local resolution and update the version hint', () => {
  const source = JSON.stringify({name: 'consumer/app', version: '0.1.0', deps: {'test/core': {path: '../core', version: '0.2.0'}, 'external/lib': {path: '../lib'}}});
  const updated = JSON.parse(updateManifest(source, {json: true, version: '0.5.0', publicNames: new Set(['test/core'])}));
  assert.deepEqual(updated.deps['test/core'], {path: '../core', version: '0.5.0'});
  assert.deepEqual(updated.deps['external/lib'], {path: '../lib'});
  assert.equal(updated.version, '0.1.0');
});

test('invalid versions, downgrades and malformed consumers fail before any write', t => {
  const {root, write, options} = fixture(t);
  const before = readFileSync(join(root, 'moon.mod'), 'utf8');
  for (const version of ['0.3.0', 'v0.5.0', '0.05.0', '0.5', '0.5.0;echo bad', '0.5.0-beta.1'])
    assert.throws(() => planVersionUpdate(version, options), /version|downgrade/i);
  write('editor/broken/moon.mod.json', '{bad');
  assert.throws(() => planVersionUpdate('0.5.0', options));
  assert.equal(readFileSync(join(root, 'moon.mod'), 'utf8'), before);
});

test('concurrent changes are detected before applying any planned write', t => {
  const {root, write, options} = fixture(t);
  const before = readFileSync(join(root, 'moon.mod'), 'utf8');
  const plan = planVersionUpdate('0.5.0', options);
  write('core/moon.mod', 'name = "test/core"\nversion = "0.3.0"\n');
  assert.throws(() => applyVersionUpdate(plan), /changed/i);
  assert.equal(readFileSync(join(root, 'moon.mod'), 'utf8'), before);
});

test('publication catalog covers the distributable workspace and orders dependencies first', () => {
  const repoRoot = resolve(import.meta.dirname, '..');
  const privateDirs = ['benchmarks', 'experiments'];
  assert.deepEqual([...PUBLISH_MODULE_DIRS].sort(), readMoonWorkMembers(repoRoot).filter(dir => !privateDirs.includes(dir)).sort());
  const modules = publishModules();
  const order = new Map(modules.map((mod, i) => [mod.name, i]));
  for (const name of ['mizchi/kagura', 'mizchi/web_runtime_hooks', 'mizchi/native_runtime_hooks', 'mizchi/machinations'])
    assert.ok(order.has(name), name);
  assert.ok(!order.has('mizchi/kagura_cli'));
  for (const mod of modules)
    for (const dep of Object.keys(mod.manifest.deps ?? {}))
      if (order.has(dep)) assert.ok(order.get(dep) < order.get(mod.name), `${dep} must precede ${mod.name}`);
});

test('publication catalog rejects dependency cycles', t => {
  const {write, options} = fixture(t);
  write('core/moon.mod', 'name = "test/core"\nversion = "0.2.0"\nimport { "test/root@0.4.0" }\n');
  assert.throws(() => publishModules(options), /cycle/i);
});

test('CLI dry-run is read-only, check reports drift, and invalid flags fail', () => {
  const script = resolve(import.meta.dirname, 'bump-version.mjs');
  const version = `${BigInt(readModuleManifest(resolve(import.meta.dirname, '..')).version.split('.')[0]) + 1n}.0.0`;
  const run = (...args) => spawnSync(process.execPath, [script, ...args], {encoding: 'utf8', cwd: tmpdir()});
  const before = readFileSync(resolve(import.meta.dirname, '../moon.mod'), 'utf8');
  const preview = run(version, '--dry-run');
  assert.equal(preview.status, 0, preview.stderr);
  assert.match(preview.stdout, /mizchi\/kagura:/);
  assert.match(preview.stdout, /templates\/web\/moon.mod.template/);
  assert.equal(run(version, '--check').status, 1);
  assert.equal(run(version, '--unknown').status, 1);
  assert.equal(readFileSync(resolve(import.meta.dirname, '../moon.mod'), 'utf8'), before);
});
