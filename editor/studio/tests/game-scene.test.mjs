import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { readGameScene } from '../scene/contract.mjs';
import {
  compileScene,
  sceneCommands,
} from '../../../examples/games/hacknslash_3d/editor/scene.mjs';
import { createHeadlessEditor } from '../headless/index.mjs';
import { createSceneRuntime } from '../../../examples/games/hacknslash_3d/editor/headless.mjs';
const source = () =>
  readFile(
    new URL('../../../examples/games/hacknslash_3d/scenes/training.kgrscene', import.meta.url),
    'utf8',
  ).then(JSON.parse);
test('generic node deletion removes scene bindings in the same undo transaction', async () => {
  const editor = createHeadlessEditor(await source()),
    before = editor.snapshot().document;
  assert.equal(
    editor.dispatch({ expectedRevision: 0, commands: [{ op: 'node.remove', id: 'enemy-a' }] }).ok,
    true,
  );
  assert.equal(compileScene(editor.snapshot().document).data.enemies.length, 1);
  editor.undo(editor.snapshot().revision);
  assert.deepEqual(editor.snapshot().document, before);
});
test('a saved game scene defines visible nodes and the exact runtime collision/spawn recipe', async () => {
  const doc = await source(),
    scene = readGameScene(doc, 'hacknslash_3d');
  assert.equal(scene.bindings.length, doc.nodes.length);
  const editor = createHeadlessEditor(doc),
    before = compileScene(doc);
  const wall = doc.nodes.find((n) => n.id === 'barrier');
  const transaction = {
    expectedRevision: 0,
    commands: [
      {
        op: 'node.transform',
        id: wall.id,
        position: [22.5, ...wall.position.slice(1)],
        rotation: wall.rotation,
        scale: wall.scale,
      },
    ],
  };
  assert.equal(editor.dispatch(transaction).ok, true);
  const after = compileScene(editor.snapshot().document);
  assert.notDeepEqual(after.data.rectangles, before.data.rectangles);
  assert.equal(after.data.rectangles.find((r) => r.id === 'barrier').x, 22);
  const originalGame = createSceneRuntime(doc),
    editedGame = createSceneRuntime(editor.snapshot().document);
  assert.equal(originalGame.blocked(20.5, 20.5), true);
  assert.equal(editedGame.blocked(20.5, 20.5), false);
  assert.equal(editedGame.blocked(22.5, 20.5), true);
  assert.deepEqual(editedGame.snapshot().player, after.data.spawn);
  assert.equal(editedGame.snapshot().enemyCount, 2);
  editor.undo(editor.snapshot().revision);
  assert.deepEqual(compileScene(editor.snapshot().document), before);
  assert.deepEqual(compileScene(JSON.parse(JSON.stringify(doc))), before);
});
test('bindings and domain constraints reject ambiguous or unplayable scenes before launch', async () => {
  for (const mutate of [
    (d) =>
      d.resources
        .find((r) => r.id === 'kagura.scene')
        .data.bindings.push({ node: 'absent', component: 'wall', properties: {} }),
    (d) => (d.nodes.find((n) => n.id === 'barrier').rotation[1] = 0.5),
    (d) => (d.nodes.find((n) => n.id === 'spawn').position[0] = 0),
    (d) => (d.nodes.find((n) => n.id === 'barrier').position[0] = 20.2),
  ]) {
    const doc = await source();
    mutate(doc);
    assert.throws(() => compileScene(doc));
  }
});
test('domain node additions/removals update bindings atomically through the standard editor', async () => {
  const editor = createHeadlessEditor(await source());
  assert.equal(
    editor.dispatch({
      expectedRevision: 0,
      commands: sceneCommands(
        'scene_properties',
        { id: 'enemy-a', properties: { kind: 'tank', hp: 90 } },
        editor.snapshot(),
      ),
    }).ok,
    true,
  );
  assert.equal(createSceneRuntime(editor.snapshot().document).snapshot().scene.enemies[0].hp, 90);
  const commands = sceneCommands('scene_add', { kind: 'enemy' }, editor.snapshot());
  assert.equal(
    editor.dispatch({ expectedRevision: editor.snapshot().revision, commands }).ok,
    true,
  );
  assert.equal(compileScene(editor.snapshot().document).data.enemies.length, 3);
  const id = commands[0].id;
  assert.equal(
    editor.dispatch({
      expectedRevision: editor.snapshot().revision,
      commands: sceneCommands('scene_remove', { id }, editor.snapshot()),
    }).ok,
    true,
  );
  assert.equal(compileScene(editor.snapshot().document).data.enemies.length, 2);
});
