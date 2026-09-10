import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHeadlessEditor } from '../headless/index.mjs';

test('game resources round-trip, share atomic history, and accept legacy documents', () => {
  const editor = createHeadlessEditor();
  const resource = { id: 'game.mission', kind: 'game.settings', version: 1, data: { difficulty: 3, enabled: true } };
  const dispatch = commands => editor.dispatch({ expectedRevision: editor.snapshot().revision, commands });
  assert.equal(dispatch([{ op: 'resource.put', resource }]).ok, true);
  assert.deepEqual(editor.snapshot().document.resources, [resource]);
  assert.deepEqual(createHeadlessEditor(editor.snapshot().document).snapshot().document.resources, [resource]);
  const before = editor.snapshot();
  assert.equal(dispatch([{ op: 'resource.remove', id: resource.id }, { op: 'node.remove', id: 'missing' }]).ok, false);
  assert.deepEqual(editor.snapshot(), before);
  assert.equal(dispatch([{ op: 'resource.put', resource: { ...resource, version: 1.5 } }]).ok, false);
  assert.equal(dispatch([{ op: 'resource.put', resource: { ...resource, data: null } }]).ok, false);
  assert.equal(dispatch([{ op: 'resource.remove', id: resource.id }]).ok, true);
  editor.undo(editor.snapshot().revision);
  assert.deepEqual(editor.snapshot().document.resources, [resource]);
  const legacy = editor.snapshot().document;
  delete legacy.resources;
  assert.deepEqual(createHeadlessEditor(legacy).snapshot().document.resources, []);
});

test('resource input limits and unknown fields reject without partial changes', () => {
  const editor = createHeadlessEditor();
  const resource = { id: 'game.test', kind: 'game.settings', version: 1, data: {} };
  const doc = editor.snapshot().document;
  for (const resources of [
    [resource, resource],
    [{ ...resource, typo: true }],
    [{ ...resource, data: { huge: 'x'.repeat(262145) } }],
    [{ ...resource, data: Array.from({ length: 33 }).reduce(data => ({ child: data }), {}) }],
    Array.from({ length: 129 }, (_, i) => ({ ...resource, id: 'r' + i })),
  ]) {
    const result = editor.dispatch({ expectedRevision: 0, commands: [{ op: 'document.replace', document: { ...doc, resources } }] });
    assert.equal(result.ok, false);
    assert.deepEqual(editor.snapshot().document, doc);
  }
});
