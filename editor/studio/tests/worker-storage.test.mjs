import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createTestWorker } from './worker-runtime.mjs';
import { createWorkerStore } from '../storage/worker-http.mjs';
import { createStorageRegistry } from '../storage/registry.mjs';

// Actual workerd + local R2, with no Cloudflare account or external writes.
test('Worker/R2 round-trip, metadata, pagination, auth, CORS and conditional writes', async () => {
  const mf = createTestWorker();
  try {
    const storage = createStorageRegistry();
    const endpoint = 'http://localhost/api/storage/objects';
    storage.register('r2', createWorkerStore({ endpoint, getToken: () => 'test-token', fetch: (url, options) => mf.dispatchFetch(url, options) }));
    const ref = { store: 'r2', key: 'game/日本語.glb' };
    const bytes = new Blob([new Uint8Array([0, 255, 10])], { type: 'model/gltf-binary' });
    const saved = await storage.write(ref, bytes, { ifMatch: null });
    assert.match(saved.etag, /^".*"$/);
    const read = await storage.read(ref);
    assert.equal(read.type, 'model/gltf-binary');
    assert.deepEqual(new Uint8Array(await read.blob.arrayBuffer()), new Uint8Array([0, 255, 10]));
    await assert.rejects(storage.write(ref, bytes, { ifMatch: null }), { code: 'conflict' });
    const races = await Promise.allSettled([storage.write(ref, new Blob(['A']), { ifMatch: saved.etag }), storage.write(ref, new Blob(['B']), { ifMatch: saved.etag })]);
    assert.equal(races.filter(r => r.status === 'fulfilled').length, 1);
    await storage.write({ store: 'r2', key: 'game/other.bin' }, bytes);
    const page = await storage.list('r2', { prefix: 'game/', limit: 1 });
    assert.equal(page.objects.length, 1); assert.ok(page.cursor);
    const next = await storage.list('r2', { prefix: 'game/', limit: 1, cursor: page.cursor });
    assert.equal(next.objects.length, 1); assert.notEqual(next.objects[0].key, page.objects[0].key);
    assert.equal((await mf.dispatchFetch(endpoint)).status, 401);
    assert.equal((await mf.dispatchFetch(endpoint, { headers: { Authorization: 'Bearer test-token', Origin: 'https://unrelated.example' } })).status, 403);
    const preflight = await mf.dispatchFetch(endpoint, { method: 'OPTIONS', headers: { Origin: 'http://localhost:5190' } });
    assert.equal(preflight.status, 204); assert.equal(preflight.headers.get('access-control-allow-origin'), 'http://localhost:5190');
    assert.equal((await mf.dispatchFetch(endpoint + '?key=../invalid', { headers: { Authorization: 'Bearer test-token' } })).status, 400);
    await storage.remove(ref); await assert.rejects(storage.read(ref), { code: 'not_found' });
  } finally { await mf.dispose(); }
});
