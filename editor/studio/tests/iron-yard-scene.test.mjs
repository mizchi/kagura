import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHeadlessEditor } from '../headless/index.mjs';
import { createPluginHost } from '../plugins/host.mjs';
import { createIronYardPlugin } from '../games/iron-yard.mjs';
import { defaultScene, readScene } from '../games/iron-yard-scene.mjs';
import { simulateScene, replayAttack } from '../../../examples/games/iron_yard/editor/headless.mjs';

test('scene-editor document edits are atomic, validated, undoable and export compatible', async () => {
  const editor = createHeadlessEditor(),
    host = createPluginHost(editor);
  host.register(createIronYardPlugin());
  const invoke = (name, args) =>
    host.invoke('iron-yard', name, args, { expectedRevision: editor.snapshot().revision });
  assert.equal((await invoke('scene_load', { document: defaultScene() })).ok, true);
  assert.equal(
    (
      await invoke('scene_edit', {
        id: 'hangar-a',
        changes: { center: [-30, 7, -15], size: [20, 14, 30], color: '#ffcc00' },
      })
    ).ok,
    true,
  );
  assert.equal(readScene(editor.snapshot()).stage.solids[0].center[0], -30);
  const before = editor.snapshot();
  assert.equal((await invoke('scene_edit', { id: 'spawn', changes: { position: [-30, 0, -15] } })).ok, false);
  assert.deepEqual(editor.snapshot(), before);
  editor.undo(before.revision);
  assert.equal(readScene(editor.snapshot()).stage.solids[0].center[0], -28);
  editor.redo(editor.snapshot().revision);
  const added = await invoke('scene_add', { kind: 'enemy', wave: 1 });
  assert.equal(added.ok, true);
  assert.ok(readScene(editor.snapshot()).mission.waves[1].targets.includes(added.result.id));
  assert.equal((await invoke('scene_remove', { id: added.result.id })).ok, true);
  const exported = await invoke('scene_export', {});
  assert.deepEqual(exported.result, readScene(editor.snapshot()));
  assert.deepEqual(readScene(createHeadlessEditor(editor.snapshot().document).snapshot()), exported.result);
  assert.equal((await invoke('scene_load', { document: { ...defaultScene(), version: 99 } })).ok, false);
  host.dispose();
});

test('edited colliders, custom enemies, rifle damage and mission duration reach the MoonBit game', () => {
  const doc = defaultScene();
  doc.stage.solids = [];
  doc.stage.spawn = [0, 0, -40];
  doc.stage.targets = [{ id: 'target-a', position: [0, 0, -10], yaw: 3 }];
  doc.mission.waves = [{ id: 'wave-one', targets: ['target-a'] }];
  doc.mission.timeLimit = 10;
  const moving = simulateScene(doc, { frames: 120, forward: 1, boost: true, ai: false });
  doc.stage.solids.push({
    id: 'new-wall',
    kind: 'wall',
    center: [0, 4, -28],
    size: [24, 8, 2],
    color: '#ffffff',
  });
  const blocked = simulateScene(doc, { frames: 120, forward: 1, boost: true, ai: false });
  assert.ok(moving.pilot.position[2] > blocked.pilot.position[2] + 4);
  assert.equal(blocked.units[0].name, 'target-a');
  const timed = simulateScene(doc, { frames: 601, forward: 0, boost: false, ai: true });
  assert.equal(timed.phase, 'lost');
  assert.equal(timed.elapsed, 10);
  const action = { ...doc.action, damage: 180 };
  assert.equal(replayAttack(action, 0.5).units[0].hp, 0);
  assert.equal(replayAttack(action, 0.5).shots, 1);
  assert.equal(replayAttack(action, 0).shots, 0);
  assert.equal(replayAttack(doc.action, 0.5).units[0].hp, 168);
});
