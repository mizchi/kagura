import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHeadlessEditor } from '../headless/index.mjs';
import { createPluginHost } from '../plugins/host.mjs';
import { createIronYardPlugin, readSettings, defaultSettings, simulate } from '../games/iron-yard.mjs';

test('IRON YARD settings use editor transactions, survive export, and undo atomically', async () => {
  const editor = createHeadlessEditor(), host = createPluginHost(editor);
  host.register(createIronYardPlugin());
  const before = editor.snapshot();
  const settings = { ...defaultSettings, ai: false, spawnX: 5, yaw: 1 };
  assert.equal((await host.invoke('iron-yard', 'configure', settings, { expectedRevision: 0 })).ok, true);
  assert.deepEqual(readSettings(editor.snapshot()), settings);
  assert.deepEqual(readSettings(createHeadlessEditor(editor.snapshot().document).snapshot()), settings);
  assert.equal((await host.invoke('iron-yard', 'configure', { ...settings, spawnX: 100 }, { expectedRevision: 1 })).ok, false);
  assert.equal(editor.snapshot().revision, 1);
  assert.equal((await host.invoke('iron-yard', 'configure', settings, { expectedRevision: 0 })).error.code, 'conflict');
  editor.undo(1);
  assert.deepEqual(editor.snapshot().document, before.document);
  editor.redo(2);
  assert.deepEqual(readSettings(editor.snapshot()), settings);
  host.dispose();
});

test('IRON YARD can simulate an editor document without DOM or GPU, without mutating it', async () => {
  const editor = createHeadlessEditor(), host = createPluginHost(editor);
  host.register(createIronYardPlugin());
  await host.invoke('iron-yard', 'configure', { ...defaultSettings, ai: false, spawnX: 4 }, { expectedRevision: 0 });
  const before = editor.snapshot();
  const result = await host.invoke('iron-yard', 'simulate', { frames: 60, forward: 1, boost: false });
  assert.equal(result.ok, true);
  assert.equal(result.result.ai, false);
  assert.equal(result.result.pilot.position[0], 4);
  assert.ok(result.result.pilot.position[2] > defaultSettings.spawnZ + 2);
  assert.deepEqual(editor.snapshot(), before);
  assert.deepEqual(result.result, await simulate(readSettings(before), { frames: 60, forward: 1, boost: false }));
  assert.equal((await host.invoke('iron-yard', 'simulate', { frames: 100000, forward: 1, boost: false })).ok, false);
  host.dispose();
});

test('preview tools publish versioned requests without creating runtime state in the document', async () => {
  const editor = createHeadlessEditor(), host = createPluginHost(editor);
  host.register(createIronYardPlugin());
  const result = await host.invoke('iron-yard', 'preview', { action: 'play' }, { expectedRevision: 0 });
  assert.equal(result.ok, true);
  assert.deepEqual(editor.snapshot().document.resources.find(r => r.id === 'iron-yard.preview').data, { action: 'play', token: 1 });
  assert.equal((await host.invoke('iron-yard', 'preview', { action: 'eval' }, { expectedRevision: 1 })).ok, false);
  assert.equal(editor.snapshot().revision, 1);
  host.dispose();
});

test('invalid imported game resources are rejected at the game boundary', () => {
  const editor = createHeadlessEditor();
  editor.dispatch({ expectedRevision: 0, commands: [{ op: 'resource.put', resource: {
    id: 'iron-yard.settings', kind: 'iron-yard.settings', version: 2, data: defaultSettings,
  } }] });
  assert.throws(() => readSettings(editor.snapshot()), /version/i);
});
