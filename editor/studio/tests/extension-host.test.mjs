import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createExtensionHost } from '../extensions/host.mjs';
import { createHeadlessEditor } from '../headless/index.mjs';
import * as core from '../extensions/core.mjs';
test('generic project loading validates before replacing the document and saves into its folder', async () => {
  const editor = createHeadlessEditor(),
    doc = editor.snapshot().document;
  doc.name = 'Project scene';
  let saved,
    closed = false;
  const host = createExtensionHost({ editor }, { 'kagura.scene': async () => core });
  const project = {
    manifest: { name: 'Generic', scene: 'scene.json', resources: {} },
    writable: true,
    async readScene() {
      return doc;
    },
    async saveScene(value) {
      saved = value;
    },
    dispose() {
      closed = true;
    },
  };
  await host.openProject(project);
  assert.equal(editor.snapshot().document.name, 'Project scene');
  await host.save();
  assert.deepEqual(saved, editor.snapshot().document);
  await assert.rejects(
    host.openProject({
      ...project,
      dispose() {},
      async readScene() {
        return { invalid: true };
      },
    }),
  );
  assert.equal(host.project(), project);
  assert.equal(closed, false);
  host.dispose();
  assert.equal(closed, true);
});
test('a domain pane can extend the built-in editor without implementing document operations', async () => {
  const editor = createHeadlessEditor();
  let disposed = false;
  const module = {
    apiVersion: 1,
    id: 'combat',
    activate({ base }) {
      assert.equal(base.readDocument().version, 1);
      return {
        dispose() {
          disposed = true;
        },
      };
    },
  };
  const host = createExtensionHost({ editor }, { combat: async () => module });
  await host.useBuiltin('combat');
  const doc = editor.snapshot().document;
  doc.name = 'Shared core';
  await host.importScene(doc, editor.snapshot().revision);
  assert.equal(host.document().name, 'Shared core');
  host.showGeneric();
  assert.equal(disposed, false);
  host.dispose();
  assert.equal(disposed, true);
});
test('switching project scenes preserves drafts and saves each to its own path', async () => {
  const editor = createHeadlessEditor();
  const a = editor.snapshot().document;
  a.name = 'A';
  const b = structuredClone(a);
  b.name = 'B';
  const files = new Map([
    ['a', a],
    ['b', b],
  ]);
  const host = createExtensionHost({ editor }, { 'kagura.scene': async () => core });
  await host.openProject({
    manifest: {
      name: 'Many',
      entryScene: 'a',
      scenes: { a: 'a.json', b: 'b.json' },
      resources: {},
    },
    writable: true,
    readScene: async (id = 'a') => structuredClone(files.get(id)),
    saveScene: async (doc, id) => files.set(id, structuredClone(doc)),
    dispose() {},
  });
  const edit = host.document();
  edit.name = 'Edited A';
  await host.importScene(edit, editor.snapshot().revision);
  await host.selectScene('b');
  assert.equal(host.document().name, 'B');
  assert.equal(
    editor.undo(editor.snapshot().revision).ok,
    false,
    'Undo must never cross scene files',
  );
  await host.selectScene('a');
  assert.equal(host.document().name, 'Edited A');
  await assert.rejects(host.selectScene('missing'));
  assert.equal(host.sceneId(), 'a');
  await host.save();
  assert.equal(files.get('a').name, 'Edited A');
  assert.equal(files.get('b').name, 'B');
  host.dispose();
});

test('incompatible schema and missing runtime keep the current project and its edits', async () => {
  const editor = createHeadlessEditor();
  const host = createExtensionHost({ editor }, { 'kagura.scene': async () => core });
  let disposed = false;
  const project = {
    manifest: { name: 'Current', scene: 'scene.json', resources: {} },
    readScene: async () => editor.snapshot().document,
    dispose() {
      disposed = true;
    },
  };
  await host.openProject(project);
  const before = editor.snapshot();
  for (const patch of [
    { sceneSchema: { id: 'kagura.scene', version: 2 } },
    { editor: { id: 'kagura.scene', apiVersion: 2 } },
    { runtime: { kind: 'script', apiVersion: 2, targets: ['js'], entry: 'runtime.js' } },
    { runtime: { kind: 'script', apiVersion: 1, targets: ['js'], entry: 'missing.js' } },
  ]) {
    let rejectedDisposed = false;
    await assert.rejects(
      host.openProject({
        ...project,
        manifest: { ...project.manifest, ...patch },
        read: async () => {
          throw Error('Missing file');
        },
        dispose() {
          rejectedDisposed = true;
        },
      }),
    );
    assert.equal(rejectedDisposed, true);
    assert.equal(host.project(), project);
    assert.equal(disposed, false);
    assert.deepEqual(editor.snapshot(), before);
  }
  host.dispose();
});

test('project transport delegates to the active extension and releases capabilities on switch', async () => {
  const editor = createHeadlessEditor();
  let playing = false,
    edits = 0,
    stops = 0,
    notifications = 0,
    notify;
  const extension = {
    apiVersion: 1,
    id: 'sample',
    activate(context) {
      notify = context.notifyState;
      return {
        play() {
          playing = true;
          notify();
        },
        stop() {
          playing = false;
          stops++;
          notify();
        },
        playing: () => playing,
        open() {
          edits++;
        },
        dispose() {
          playing = false;
        },
      };
    },
  };
  const host = createExtensionHost(
    { editor },
    { sample: async () => extension, 'kagura.scene': async () => core },
  );
  const unsubscribe = host.subscribe(() => notifications++);
  assert.deepEqual(host.transport(), {
    available: false,
    canPlay: false,
    playing: false,
    debugging: false,
    paused: false,
  });
  await assert.rejects(host.play(), /not available/);
  const project = {
    manifest: { name: 'Sample', editor: { id: 'sample' }, resources: {} },
    readScene: async () => editor.snapshot().document,
    dispose() {},
  };
  await host.openProject(project);
  assert.deepEqual(host.transport(), {
    available: true,
    canPlay: true,
    playing: false,
    debugging: false,
    paused: false,
  });
  await host.play();
  assert.equal(host.transport().playing, true);
  await host.edit();
  assert.equal(host.transport().playing, false);
  assert.equal(edits, 1);
  assert.equal(stops, 1);
  await host.useBuiltin('kagura.scene');
  assert.deepEqual(host.transport(), {
    available: false,
    canPlay: false,
    playing: false,
    debugging: false,
    paused: false,
  });
  assert.ok(notifications >= 4);
  unsubscribe();
  const count = notifications;
  notify();
  assert.equal(notifications, count);
  host.dispose();
});
