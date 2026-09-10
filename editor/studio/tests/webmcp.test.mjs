import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHeadlessEditor } from '../headless/index.mjs';
import { registerWebMCP } from '../web/webmcp.mjs';

test('WebMCP uses the editor revision contract and cleans up only its own registrations', async () => {
  const registered = new Map([['foreign.tool', {}]]);
  const modelContext = { async registerTool(tool, { signal }) {
    registered.set(tool.name, tool); signal.addEventListener('abort', () => registered.delete(tool.name));
  } };
  const editor = createHeadlessEditor();
  const adapter = registerWebMCP(editor, modelContext);
  await adapter.ready;
  assert.equal(adapter.status().state, 'ready');
  const execute = (name, args) => registered.get(name).execute(args);
  const snapshot = await execute('kagura.snapshot', {});
  assert.equal(snapshot.snapshot.revision, 0);
  const transaction = { expectedRevision: 0, commands: [{ op: 'node.rename', id: 'hero', name: 'WebMCP actor' }] };
  assert.equal((await execute('kagura.dispatch', transaction)).ok, true);
  assert.equal((await execute('kagura.dispatch', transaction)).error.code, 'conflict');
  assert.equal((await execute('kagura.history', { direction: 'undo', expectedRevision: 1 })).ok, true);
  assert.equal((await execute('kagura.history', { direction: 'oops', expectedRevision: 2 })).ok, false);
  const aborted = AbortSignal.abort();
  assert.equal((await registered.get('kagura.dispatch').execute({ ...transaction, expectedRevision: 2 }, { signal: aborted })).ok, false);
  assert.equal(editor.snapshot().revision, 2);
  const staleTool = registered.get('kagura.dispatch');
  adapter.dispose();
  assert.deepEqual([...registered.keys()], ['foreign.tool']);
  assert.equal((await staleTool.execute({ ...transaction, expectedRevision: 2 })).ok, false);
});

test('unsupported and failed registration do not disable editing or leave partial tools', async () => {
  const editor = createHeadlessEditor();
  const missing = registerWebMCP(editor, undefined);
  await missing.ready; assert.equal(missing.status().state, 'unsupported');
  const registered = new Map();
  const failed = registerWebMCP(editor, { async registerTool(tool, { signal }) {
    if (registered.size === 2) throw new Error('Registration denied');
    registered.set(tool.name, tool); signal.addEventListener('abort', () => registered.delete(tool.name));
  } });
  await failed.ready;
  assert.equal(failed.status().state, 'error');
  assert.equal(registered.size, 0);
  assert.equal(editor.seek(0.03).ok, true);
});
