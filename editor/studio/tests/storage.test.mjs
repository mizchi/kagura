import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHeadlessEditor } from '../headless/index.mjs';
import { createStorageRegistry } from '../storage/registry.mjs';
import { createDocumentStorage } from '../storage/document.mjs';

function memory() {
  const data = new Map(); let revision = 0;
  return {
    capabilities: { conditionalWrite: true },
    async read(key) { if (!data.has(key)) throw Object.assign(Error('Missing'), { code: 'not_found' }); return data.get(key); },
    async write(key, blob, { ifMatch } = {}) {
      if (ifMatch !== undefined && (data.get(key)?.etag ?? null) !== ifMatch) throw Object.assign(Error('Conflict'), { code: 'conflict' });
      const object = { key, blob, size: blob.size, type: blob.type, etag: String(++revision), modified: new Date().toISOString() };
      data.set(key, object); return object;
    },
    async remove(key) { data.delete(key); },
    async list() { return { objects: [...data.values()], cursor: null }; },
  };
}

test('resource references route binary reads, copies and reject traversal', async () => {
  const storage = createStorageRegistry(); storage.register('local', memory()); storage.register('remote', memory());
  const ref = { store: 'local', key: 'game/mesh.glb' };
  const bytes = new Blob([new Uint8Array([0, 1, 255])], { type: 'model/gltf-binary' });
  await storage.write(ref, bytes);
  await storage.copy(ref, { store: 'remote', key: 'copy.glb' }, { ifMatch: null });
  assert.deepEqual(new Uint8Array(await (await storage.read({ store: 'remote', key: 'copy.glb' })).blob.arrayBuffer()), new Uint8Array([0, 1, 255]));
  await assert.rejects(storage.read({ store: 'local', key: '../outside' }), { code: 'invalid' });
  await assert.rejects(storage.read({ store: 'missing', key: 'a' }), { code: 'not_found' });
});

test('loading validates and detects edits during I/O; stale saves never overwrite', async () => {
  const storage = createStorageRegistry(), provider = memory(); storage.register('local', provider);
  const a = createHeadlessEditor(), b = createHeadlessEditor();
  const sa = createDocumentStorage(a, storage), sb = createDocumentStorage(b, storage);
  const ref = { store: 'local', key: 'scene.json' };
  await sa.save(ref, 0);
  await sb.load(ref, 0);
  a.dispatch({ expectedRevision: 0, commands: [{ op: 'node.rename', id: 'hero', name: 'A' }] });
  await sa.save(ref, 1);
  await assert.rejects(sb.save(ref, 1), { code: 'conflict' });
  const originalRead = provider.read;
  provider.read = async key => { const object = await originalRead(key); b.dispatch({ expectedRevision: b.snapshot().revision, commands: [{ op: 'node.rename', id: 'hero', name: 'During load' }] }); return object; };
  await assert.rejects(sb.load(ref, b.snapshot().revision), { code: 'conflict' });
  assert.equal(b.snapshot().document.nodes[1].name, 'During load');
  provider.read = originalRead;
  await storage.write({ store: 'local', key: 'bad.json' }, new Blob(['{"version":99}']));
  const before = b.snapshot();
  await assert.rejects(sb.load({ store: 'local', key: 'bad.json' }, before.revision), { code: 'invalid' });
  assert.deepEqual(b.snapshot(), before);
});
