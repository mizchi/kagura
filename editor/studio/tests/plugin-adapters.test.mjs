import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import wabtFactory from 'wabt';
import { createHeadlessEditor } from '../headless/index.mjs';
import { createPluginHost } from '../plugins/host.mjs';
import { defineJSPlugin, fromJSONModule, fromWasm } from '../plugins/adapters.mjs';
import * as javascript from '../public/plugins/js-demo.mjs';
import * as moonbit from '../public/plugins/moonbit-demo.mjs';

test('JavaScript example authors game resources as one undoable transaction', async () => {
  const editor = createHeadlessEditor(), host = createPluginHost(editor);
  host.register(defineJSPlugin(javascript));
  assert.equal((await host.invoke('demo.js', 'set_damage', { damage: 42 }, { expectedRevision: 0 })).ok, true);
  assert.deepEqual(editor.snapshot().document.resources[0].data, { damage: 42 });
  editor.undo(1);
  assert.deepEqual(editor.snapshot().document.resources, []);
  host.dispose();
});

test('compiled MoonBit module reads and edits through the same JSON contract', async () => {
  const editor = createHeadlessEditor(), host = createPluginHost(editor);
  host.register(fromJSONModule(moonbit));
  assert.deepEqual(await host.invoke('demo.moonbit', 'count_nodes', {}), { ok: true, result: 3, revision: 0 });
  const reply = await host.invoke('demo.moonbit', 'rename_selected', { name: '月の勇者' }, { expectedRevision: 0 });
  assert.deepEqual(reply, { ok: true, result: '月の勇者', revision: 1 });
  assert.equal(editor.snapshot().document.nodes[1].name, '月の勇者');
  host.dispose();
});

test('actual wasm32 ABI handles UTF-8, memory growth, repeated calls and disposal', async () => {
  const editor = createHeadlessEditor(), host = createPluginHost(editor);
  const plugin = await fromWasm(await readFile(new URL('../public/plugins/wasm-demo.wasm', import.meta.url)));
  host.register(plugin);
  for (const value of ['日本語 🐈', '長'.repeat(70000), 'again']) {
    const response = await host.invoke('demo.wasm', 'inspect_request', { value });
    assert.equal(response.ok, true, JSON.stringify(response));
    assert.equal(response.result.arguments.value, value);
    assert.deepEqual(response.result.snapshot, editor.snapshot());
  }
  host.unregister('demo.wasm');
  assert.throws(() => plugin.transport.invoke('{}'), { code: 'canceled' });
});

test('invalid wasm memory ranges are rejected before decoding', async () => {
  const wabt = await wabtFactory();
  const module = wabt.parseWat('invalid.wat', `(module
    (memory (export "memory") 1)
    (func (export "kagura_alloc") (param i32) (result i32) (i32.const 0))
    (func (export "kagura_free") (param i32 i32) unreachable)
    (func (export "kagura_manifest") (result i32) (i32.const 65530))
    (func (export "kagura_result_len") (result i32) (i32.const 100))
    (func (export "kagura_invoke") (param i32 i32) (result i32) (i32.const 0)))`);
  try { await assert.rejects(fromWasm(module.toBinary({}).buffer), /out of bounds/); }
  finally { module.destroy(); }
});

test('wasm rejects overlapping input/result buffers without freeing the same allocation twice', async () => {
  const wabt = await wabtFactory();
  const bytes = new TextEncoder().encode(JSON.stringify({ apiVersion: 1, id: 'overlap', title: 'Overlap', tools: [] }));
  const data = [...bytes].map(byte => `\\${byte.toString(16).padStart(2, '0')}`).join('');
  const module = wabt.parseWat('overlap.wat', `(module
    (memory (export "memory") 1)
    (data (i32.const 0) "${data}")
    (global $length (mut i32) (i32.const ${bytes.length}))
    (global $freed (mut i32) (i32.const 0))
    (func (export "kagura_alloc") (param i32) (result i32) (i32.const 1024))
    (func (export "kagura_free") (param $ptr i32) (param i32)
      (if (i32.eq (local.get $ptr) (i32.const 1024)) (then
        (if (global.get $freed) (then unreachable))
        (global.set $freed (i32.const 1)))))
    (func (export "kagura_manifest") (result i32) (i32.const 0))
    (func (export "kagura_result_len") (result i32) (global.get $length))
    (func (export "kagura_invoke") (param $ptr i32) (param $len i32) (result i32)
      (global.set $length (local.get $len)) (local.get $ptr)))`);
  try {
    const plugin = await fromWasm(module.toBinary({}).buffer);
    assert.throws(() => plugin.transport.invoke('{}'), /overlap/);
    plugin.transport.dispose();
  } finally { module.destroy(); }
});
