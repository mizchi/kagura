import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validateProject } from '../projects/project.mjs';
import {
  runtimeEntry,
  runtimeSettings,
  assertProjectCompatibility,
} from '../projects/settings.mjs';
const legacy = {
  format: 'kagura.project',
  version: 1,
  name: 'Test',
  scene: 'scene.json',
  resources: {},
};
const modern = {
  ...legacy,
  id: 'org.example.levels',
  game: 'arena3d',
  save: { namespace: 'org.example.progress', version: 2 },
  editor: { id: 'arena3d', apiVersion: 1 },
  sceneSchema: { id: 'arena3d.scene', version: 1 },
  runtime: {
    kind: 'script',
    apiVersion: 1,
    entry: 'editor/dist/runtime.js',
    targets: ['js', 'native'],
  },
  build: { package: 'src', artifact: 'arena3d.js', scenePackage: 'src/scenes' },
  display: { width: 800, height: 600 },
};
test('project settings round-trip without deriving identity from a display name', () => {
  assert.deepEqual(validateProject(modern), modern);
  const old = validateProject(legacy);
  assert.equal(old.id, undefined);
  assert.equal(runtimeEntry(old), undefined);
  assert.equal(runtimeEntry({ ...old, resources: { runtime: 'old.js' } }), 'old.js');
  assert.equal(runtimeEntry(modern), 'editor/dist/runtime.js');
  assert.deepEqual(runtimeSettings(modern, { width: 1, height: 1 }), {
    id: modern.id,
    game: modern.game,
    save: modern.save,
    sceneSchema: modern.sceneSchema,
    display: modern.display,
  });
  assert.deepEqual(runtimeSettings(old, { width: 640, height: 480 }).display, {
    width: 640,
    height: 480,
  });
});
test('settings reject ambiguous runtime, unsafe build paths, invalid versions and dimensions', () => {
  for (const patch of [
    { id: '../bad' },
    { game: undefined },
    { save: { namespace: '', version: 1 } },
    { save: { namespace: 'valid', version: 0 } },
    { sceneSchema: { id: 'test', version: 1.5 } },
    { editor: { id: 'arena3d', apiVersion: 0 } },
    { runtime: { ...modern.runtime, entry: '../out.js' } },
    { runtime: { ...modern.runtime, entry: 'module.mjs' } },
    { runtime: { ...modern.runtime, targets: ['native'] } },
    { runtime: { ...modern.runtime, targets: ['js', 'js'] } },
    { runtime: { ...modern.runtime, kind: 'wasm' } },
    { runtime: { ...modern.runtime, unknown: true } },
    { resources: { runtime: 'different.js' } },
    { build: { package: '--help', artifact: 'app.js' } },
    { build: { package: 'src', artifact: '../app.js' } },
    { display: { width: 0, height: 600 } },
    { display: { width: 800, height: 9000 } },
    { display: { width: 800, height: 600, unknown: true } },
  ])
    assert.throws(() => validateProject({ ...modern, ...patch }), JSON.stringify(patch));
  assert.throws(() => validateProject({ ...legacy, save: modern.save }));
  assert.throws(() =>
    validateProject({
      ...modern,
      runtime: { kind: 'native', apiVersion: 1, targets: ['native'], entry: 'app.js' },
    }),
  );
});
test('extension and runtime compatibility are separate from manifest format version', () => {
  const extension = { apiVersion: 1, game: 'arena3d', sceneSchema: modern.sceneSchema };
  assertProjectCompatibility(modern, extension);
  assertProjectCompatibility(legacy, { apiVersion: 1 });
  for (const patch of [
    { game: 'another' },
    { editor: { id: 'arena3d', apiVersion: 2 } },
    { runtime: { ...modern.runtime, apiVersion: 2 } },
    { sceneSchema: { ...modern.sceneSchema, version: 2 } },
    { sceneSchema: { ...modern.sceneSchema, id: 'other.scene' } },
  ])
    assert.throws(() =>
      assertProjectCompatibility(validateProject({ ...modern, ...patch }), extension),
    );
  assert.throws(() => assertProjectCompatibility(modern, { apiVersion: 1 }));
});

test('flat MoonBit packages allow only the exact root sentinel', () => {
  const project = {
    ...modern,
    build: { package: '.', artifact: 'arena3d.js', scenePackage: 'scenes' },
  };
  assert.deepEqual(validateProject(project), project);
  for (const path of ['./', './app', '../', 'a/../b', '/app', '--help'])
    assert.throws(() =>
      validateProject({ ...modern, build: { package: path, artifact: 'arena3d.js' } }),
    );
});

test('build discovery uses the root and scenes convention unless explicitly overridden', async () => {
  const { projectBuild } = await import('../projects/settings.mjs');
  assert.deepEqual(projectBuild({ game: 'sample', scene: 'scenes/main.mbt' }), {
    package: '.',
    artifact: 'sample.js',
    scenePackage: 'scenes',
  });
  assert.deepEqual(projectBuild({ game: 'sample', scene: 'editor/studio.json' }), {
    package: '.',
    artifact: 'sample.js',
  });
  assert.deepEqual(
    projectBuild({
      ...modern,
      build: { package: 'app', artifact: 'app/app.js', scenePackage: 'levels' },
    }),
    {
      package: 'app',
      artifact: 'app/app.js',
      scenePackage: 'levels',
    },
  );
});

test('editor builds explicitly select debug without changing the distribution build default', async () => {
  const { projectBuild } = await import('../projects/settings.mjs');
  const manifest = validateProject({ ...modern, build: { ...modern.build, editorMode: 'debug' } });
  assert.equal(projectBuild(manifest).editorMode, 'debug');
  assert.equal(projectBuild(modern).editorMode, undefined);
  assert.throws(() => validateProject({ ...modern, build: { ...modern.build, editorMode: 'unsafe' } }));
});
