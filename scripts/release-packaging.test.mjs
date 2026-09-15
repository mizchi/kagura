import assert from 'node:assert/strict';
import {existsSync, mkdtempSync, readFileSync, readdirSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {basename, join} from 'node:path';
import test from 'node:test';
import {writePreparedManifests, DEFAULT_RELEASE_MODULE_DIRS} from './moon-release-utils.mjs';
import {PUBLISH_MODULE_DIRS} from './release-modules.mjs';

test('every published module stages independently with metadata, source and local build support', t => {
  assert.deepEqual([...DEFAULT_RELEASE_MODULE_DIRS].sort(), [...PUBLISH_MODULE_DIRS].sort());
  const outDir = mkdtempSync(join(tmpdir(), 'kagura-release-package-'));
  t.after(() => rmSync(outDir, {recursive: true, force: true}));
  const staged = writePreparedManifests({outDir});
  assert.deepEqual(staged.validation.errors, []);
  for (const mod of staged.summary.modules) {
    const dir = join(outDir, mod.outputDir);
    const manifest = JSON.parse(readFileSync(join(dir, 'moon.mod.json'), 'utf8'));
    for (const field of ['name', 'version', 'license', 'description', 'repository']) assert.ok(manifest[field], `${mod.name}: ${field}`);
    const files = readdirSync(join(dir, manifest.source ?? '.'), {recursive: true});
    assert.ok(files.some(file => basename(file) === 'moon.pkg'), `${mod.name}: missing packages`);
    assert.ok(files.some(file => file.endsWith('.mbt')), `${mod.name}: missing source`);
    assert.equal(existsSync(join(dir, 'moon.work')), false);
    const prebuild = manifest['--moonbit-unstable-prebuild'];
    if (prebuild) {
      assert.ok(!prebuild.startsWith('..'), prebuild);
      assert.ok(existsSync(join(dir, prebuild)), `${mod.name}: ${prebuild}`);
    }
  }
  for (const file of ['mizchi__kagura_engine/run_js.mbt', 'mizchi__native_runtime_hooks/gfx_wgpu_native/wgpu_native_stub.c',
    'mizchi__web_runtime_hooks/hooks_js.mbt', 'mizchi__kagura/cmd/kagura/moon.pkg',
    'mizchi__kagura/cmd/kagura/main_native.mbt', 'mizchi__kagura/cmd/kagura/embedded_host_native.mbt',
    'mizchi__kagura/cmd/kagura/launcher_native.c', 'mizchi__kagura/cmd/kagura/browser.mjs',
    'mizchi__kagura/cmd/diagnostics/moon.pkg', 'mizchi__kagura/cmd/diagnostics/performance.generated.js'])
    assert.ok(existsSync(join(outDir, file)), file);
  assert.ok(!staged.summary.modules.some(mod => mod.name === 'mizchi/kagura_cli'));
  assert.equal(existsSync(join(outDir, 'mizchi__kagura/cmd/moon.mod')), false);
});
