import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { decodeMoonScene, encodeMoonScene } from '../scene/moonbit.mjs';
import { openProject } from '../projects/project.mjs';
const doc = decodeMoonScene(
  await readFile(
    new URL('../../../examples/games/arena3d/scenes/training.mbt', import.meta.url),
    'utf8',
  ),
);
test('MoonBit declarations round trip without evaluating code and preserve surrounding code', () => {
  const edited = structuredClone(doc);
  edited.name = '部屋 "A"\n\\ path \u0001';
  const source = encodeMoonScene(edited, { name: 'training' });
  assert.match(source, /pub fn training\(\) -> @scene_document.Document/);
  assert.deepEqual(decodeMoonScene(source), edited);
  const handwritten = '\n///|\nfn custom_logic() -> Int { 42 }\n';
  const next = encodeMoonScene(doc, { source: source + handwritten });
  assert.ok(next.endsWith(handwritten));
  assert.deepEqual(decodeMoonScene(next), doc);
  assert.throws(() => decodeMoonScene(source.replace('version: 1', 'version: evil()')), /literal/);
  assert.throws(() => decodeMoonScene(source + source), /region/);
});
test('project save writes MoonBit source and reopens the edited declaration', async () => {
  const manifest = {
    format: 'kagura.project',
    version: 1,
    name: 'Moon scene',
    scenes: { training: 'scenes/training.mbt' },
    entryScene: 'training',
    resources: {},
  };
  const code = encodeMoonScene(doc, { name: 'training' }) + '\n// keep this comment\n';
  const files = new Map([
    ['game.kgrprj', new Blob([JSON.stringify(manifest)])],
    ['scenes/training.mbt', new Blob([code])],
  ]);
  const store = {
    read: async (key) => ({ blob: files.get(key) }),
    write: async (key, blob) => files.set(key, blob),
  };
  const project = await openProject(store, 'game.kgrprj');
  const scene = await project.readScene();
  scene.nodes.find((n) => n.id === 'wall').position[0] = 6;
  await project.saveScene(scene);
  const saved = await files.get('scenes/training.mbt').text();
  assert.match(saved, /pub fn training/);
  assert.ok(saved.endsWith('// keep this comment\n'));
  assert.equal(
    (await (await project.reopen()).readScene()).nodes.find((n) => n.id === 'wall').position[0],
    6,
  );
});
test('MoonBit escapes distinguish Unicode literals from literal backslashes', () => {
  for (const name of [
    String.raw`literal \u{41} and \u0041`,
    '部屋 😀\n\t\r\b\f\u0001',
    '// kagura-scene:begin',
    'quotes " and slash \\',
  ]) {
    const scene = { ...doc, name };
    assert.equal(decodeMoonScene(encodeMoonScene(scene)).name, name);
  }
});
test('external edits in the managed region cause a save conflict', async () => {
  const path = 'training.mbt';
  const manifest = {
    format: 'kagura.project',
    version: 1,
    name: 'Conflict',
    scene: path,
    resources: {},
  };
  const files = new Map([
    ['game.kgrprj', new Blob([JSON.stringify(manifest)])],
    [path, new Blob([encodeMoonScene(doc)])],
  ]);
  const project = await openProject(
    {
      read: async (key) => ({ blob: files.get(key) }),
      write: async (key, blob) => files.set(key, blob),
    },
    'game.kgrprj',
  );
  await project.readScene();
  const changed = { ...doc, name: 'Changed externally' };
  files.set(path, new Blob([encodeMoonScene(changed)]));
  await assert.rejects(project.saveScene(doc), /changed on disk/);
  assert.equal(decodeMoonScene(await files.get(path).text()).name, changed.name);
});
test('compiled MoonBit and the browser literal reader produce the same scene', async () => {
  const { resolveBuildArtifact } = await import('../../../scripts/moon-build-artifact-utils.mjs');
  const { fileURLToPath, pathToFileURL } = await import('node:url');
  for (const game of ['arena3d', 'fps_demo']) {
    const root = new URL(`../../../examples/games/${game}/`, import.meta.url);
    const artifact = resolveBuildArtifact(
      fileURLToPath(new URL('_build/js/release/build/scenes.js', root)),
    );
    assert.ok(artifact, 'Build scenes for ' + game);
    const compiled = await import(pathToFileURL(artifact));
    const manifest = JSON.parse(await readFile(new URL(game + '.kgrprj', root)));
    for (const [id, path] of Object.entries(manifest.scenes)) {
      const source = decodeMoonScene(await readFile(new URL(path, root), 'utf8'));
      assert.deepEqual(JSON.parse(compiled.document_json(id)), source);
    }
  }
});
test('JSON numeric literals use compilable MoonBit float notation', () => {
  const scene = structuredClone(doc);
  scene.resources.push({
    id: 'numbers',
    kind: 'numbers',
    version: 1,
    data: { large: 1700000000000, small: 1e-10, huge: 1e25 },
  });
  const source = encodeMoonScene(scene);
  assert.match(source, /1700000000000\.0/);
  assert.match(source, /1\.0e-10/);
  assert.match(source, /1\.0e\+25/);
  assert.deepEqual(decodeMoonScene(source), scene);
});
