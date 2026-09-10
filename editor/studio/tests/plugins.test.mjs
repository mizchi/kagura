import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHeadlessEditor } from '../headless/index.mjs';
import { createPluginHost } from '../plugins/host.mjs';
import { defineJSPlugin } from '../plugins/adapters.mjs';

const schema = { type: 'object', properties: { name: { type: 'string', minLength: 1 } }, required: ['name'], additionalProperties: false };
const manifest = { apiVersion: 1, id: 'game.tools', title: 'Game tools', tools: [{ name: 'rename', description: 'Rename the selected node', effect: 'transaction', inputSchema: schema, outputSchema: schema }] };
const rename = request => ({ result: { name: request.arguments.name }, commands: [{ op: 'node.rename', id: request.snapshot.selection, name: request.arguments.name }] });

test('declarative tools validate input/output and commit through the parent transaction', async () => {
  const editor = createHeadlessEditor(), host = createPluginHost(editor);
  host.register(defineJSPlugin({ manifest, invoke: rename }));
  assert.equal(host.tools()[0].name, 'kagura.pane.game.tools.rename');
  const before = editor.snapshot();
  assert.equal((await host.invoke('game.tools', 'rename', { name: 5 }, { expectedRevision: 0 })).error.code, 'invalid');
  assert.deepEqual(editor.snapshot(), before);
  assert.equal((await host.invoke('game.tools', 'rename', { name: 'Agent actor' })).error.code, 'conflict');
  const result = await host.invoke('game.tools', 'rename', { name: 'Agent actor' }, { expectedRevision: 0 });
  assert.equal(result.ok, true); assert.equal(result.revision, 1);
  assert.equal(editor.snapshot().document.nodes[1].name, 'Agent actor');
  editor.undo(1); assert.deepEqual(editor.snapshot().document, before.document);
  host.register(defineJSPlugin({ manifest, invoke: () => ({ result: { name: 99 }, commands: [{ op: 'node.remove', id: 'hero' }] }) }));
  assert.equal((await host.invoke('game.tools', 'rename', { name: 'Bad output' }, { expectedRevision: 2 })).ok, false);
  assert.equal(editor.snapshot().revision, 2);
  const readManifest = { ...manifest, tools: [{ ...manifest.tools[0], effect: 'read' }] };
  host.register(defineJSPlugin({ manifest: readManifest, invoke: rename }));
  assert.equal((await host.invoke('game.tools', 'rename', { name: 'Read cannot edit' })).ok, false);
  assert.equal(editor.snapshot().revision, 2);
});

test('replacement, cancellation and concurrent UI edits reject late plugin results', async () => {
  const editor = createHeadlessEditor(), host = createPluginHost(editor);
  let finish, released = 0;
  const plugin = () => defineJSPlugin({ manifest, invoke: request => new Promise(resolve => { finish = () => resolve(rename(request)); }), dispose: () => released++ });
  host.register(plugin());
  const pending = host.invoke('game.tools', 'rename', { name: 'Too late' }, { expectedRevision: 0 });
  await Promise.resolve();
  host.register(defineJSPlugin({ manifest, invoke: rename })); finish();
  assert.equal((await pending).error.code, 'canceled'); assert.equal(released, 1);
  host.register(plugin());
  const concurrent = host.invoke('game.tools', 'rename', { name: 'Old snapshot' }, { expectedRevision: 0 });
  await Promise.resolve(); editor.dispatch({ expectedRevision: 0, commands: [{ op: 'node.rename', id: 'hero', name: 'Human' }] }); finish();
  assert.equal((await concurrent).error.code, 'conflict');
  assert.equal(editor.snapshot().document.nodes[1].name, 'Human');
  const stale = host.tools()[0]; host.unregister('game.tools');
  assert.equal((await stale.execute({ arguments: { name: 'Stale' }, expectedRevision: 1 })).error.code, 'canceled');
  assert.equal(host.tools().length, 0);
});

test('invalid replacement preserves the previous plugin and manifests cannot be mutated externally', () => {
  const host = createPluginHost(createHeadlessEditor());
  const definition = structuredClone(manifest);
  host.register(defineJSPlugin({ manifest: definition, invoke: rename }));
  definition.tools[0].name = 'mutated';
  assert.equal(host.tools()[0].name, 'kagura.pane.game.tools.rename');
  assert.throws(() => host.register(defineJSPlugin({ manifest: { ...manifest, apiVersion: 2 }, invoke: rename })));
  assert.equal(host.tools().length, 1);
  assert.throws(() => { host.tools()[0].inputSchema.properties.arguments.properties.name.type = 'number'; }, TypeError);
  assert.throws(() => { host.tools()[0].annotations.readOnlyHint = true; }, TypeError);
  assert.throws(() => host.register(defineJSPlugin({ manifest: { ...manifest, tools: [manifest.tools[0], manifest.tools[0]] }, invoke: rename })));
});

test('registration captures transport methods until explicit replacement', async () => {
  const host = createPluginHost(createHeadlessEditor());
  const plugin = defineJSPlugin({ manifest, invoke: rename });
  host.register(plugin);
  plugin.transport.invoke = () => { throw new Error('Mutated'); };
  assert.equal((await host.invoke('game.tools', 'rename', { name: 'Captured' }, { expectedRevision: 0 })).ok, true);
});
