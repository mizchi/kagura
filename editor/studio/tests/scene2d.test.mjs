import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createHeadlessEditor } from '../headless/index.mjs';
import {
  readScene2D,
  editObject,
  compileScene2D,
  screenPoint,
  resizedObject,
} from '../scene2d/model.mjs';
import { profile } from '../../../examples/games/flappy_bird/editor/scene.mjs';
import { decodeSceneFile } from '../scene/moonbit.mjs';
const path = new URL(
  '../../../examples/games/flappy_bird/scenes/training.mbt',
  import.meta.url,
);
const document = () => readFile(path, 'utf8').then((text) => decodeSceneFile(path.pathname, text));
test('2D edits use pixel coordinates, validate the game and share undo with headless commands', async () => {
  const editor = createHeadlessEditor(await document());
  const before = editor.snapshot();
  const commands = editObject(
    before.document,
    'bird',
    { x: 90, y: 80, width: 18, height: 16 },
    profile,
  );
  assert.equal(editor.dispatch({ expectedRevision: before.revision, commands }).ok, true);
  const result = compileScene2D(editor.snapshot().document, profile);
  assert.equal(result.game, 'flappy_bird');
  assert.deepEqual(
    result.data.objects.find((o) => o.id === 'bird'),
    {
      id: 'bird',
      name: 'Bird',
      kind: 'bird',
      x: 90,
      y: 80,
      width: 18,
      height: 16,
      color: 0xffd700,
    },
  );
  editor.undo(editor.snapshot().revision);
  assert.deepEqual(editor.snapshot().document, before.document);
  for (const patch of [
    { width: 0 },
    { x: NaN },
    { x: -10 },
    { z: 1 },
    { color: 0x1000000 },
    { y: 230 },
  ])
    assert.throws(() => editObject(before.document, 'bird', patch, profile));
  assert.throws(() => editObject(before.document, 'missing', { x: 1 }, profile));
  const ground = editObject(
    before.document,
    'ground',
    { y: 210 },
    profile,
  )[0].resource.data.objects.find((o) => o.id === 'ground');
  assert.equal(ground.height, 30);
  assert.equal(ground.y, 210);
});
test('the plane contract rejects ambiguity and does not reinterpret 3D nodes', async () => {
  const doc = await document();
  const data = readScene2D(doc);
  assert.equal(data.coordinates, 'pixels-y-down');
  for (const patch of [
    { width: 0 },
    { coordinates: 'meters' },
    { objects: [...data.objects, data.objects[0]] },
    { extra: true },
  ]) {
    const copy = structuredClone(doc);
    copy.resources.find((r) => r.id === 'kagura.scene2d').data = { ...data, ...patch };
    assert.throws(() => compileScene2D(copy, profile));
  }
});
test('pan/zoom and resize convert screen deltas to scene pixels', () => {
  assert.deepEqual(screenPoint(210, 130, { left: 10, top: 10 }, { x: 40, y: 20, zoom: 2 }), {
    x: 80,
    y: 50,
  });
  assert.deepEqual(resizedObject({ x: 60, y: 80, width: 12, height: 12 }, { x: 82, y: 102 }, 4), {
    width: 24,
    height: 24,
  });
});

test('MoonBit compiled layout and editor decoding have the same source of truth', async () => {
  const { resolveBuildArtifact } = await import('../../../scripts/moon-build-artifact-utils.mjs');
  const { pathToFileURL } = await import('node:url');
  const module = await import(
    pathToFileURL(
      resolveBuildArtifact(
        new URL(
          '../../../examples/games/flappy_bird/_build/js/release/build/scenes.js',
          import.meta.url,
        ).pathname,
      ),
    )
  );
  assert.deepEqual(JSON.parse(module.document_json('training')), await document());
});
