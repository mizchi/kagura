import { decodeMoonScene } from '../scene/moonbit.mjs';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { compileProject } from '../scene/profile.mjs';
for (const game of ['arena3d', 'fps_demo'])
  test(game + ' owns a portable scene profile', async () => {
    const { compileScene } = await import(`../../../examples/games/${game}/editor/scene.mjs`);
    const doc = decodeMoonScene(
      await readFile(
        new URL(`../../../examples/games/${game}/scenes/training.mbt`, import.meta.url),
        'utf8',
      ),
    );
    const recipe = compileScene(doc);
    assert.equal(recipe.game, game);
    const spawn = doc.nodes.find((n) => n.id === 'spawn');
    spawn.position[0] = 4;
    spawn.position[2] = 0;
    assert.throws(() => compileScene(doc), /blocked/);
    if (game === 'arena3d')
      assert.throws(
        () => compileProject('training', [{ id: 'training', data: recipe.data }]),
        /destination/,
      );
  });
test('profile add/remove commands are real atomic editor transactions', async () => {
  const { createHeadlessEditor } = await import('../headless/index.mjs');
  const { sceneCommands, compileScene } = await import(
    '../../../examples/games/arena3d/editor/scene.mjs'
  );
  const doc = decodeMoonScene(
    await readFile(
      new URL('../../../examples/games/arena3d/scenes/training.mbt', import.meta.url),
      'utf8',
    ),
  );
  const editor = createHeadlessEditor(doc);
  const commands = sceneCommands('scene_add', { kind: 'item' }, editor.snapshot());
  const reply = editor.dispatch({ commands, expectedRevision: 0 });
  assert.equal(reply.ok, true);
  assert.equal(
    compileScene(editor.snapshot().document).data.entities.filter((e) => e.kind === 'item').length,
    2,
  );
  assert.throws(() => sceneCommands('scene_remove', { id: 'spawn' }, editor.snapshot()));
});
