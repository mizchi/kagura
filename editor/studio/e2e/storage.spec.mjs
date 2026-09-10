import { test, expect } from '@playwright/test';

test('IndexedDB and File System providers preserve bytes and paginate; IDB prevents stale writes', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  const result = await page.evaluate(async () => {
    const storage = kagura.storage;
    const folder = await storage.connectDirectory(await navigator.storage.getDirectory());
    const results = [];
    for (const store of ['indexeddb', folder]) {
      const ref = { store, key: 'game/mesh.glb' }, blob = new Blob([new Uint8Array([0, 255, 1])], { type: 'model/gltf-binary' });
      const saved = await storage.write(ref, blob);
      const read = await storage.read(ref);
      await storage.write({ store, key: 'game/other.bin' }, blob);
      const first = await storage.list(store, { prefix: 'game/', limit: 1 });
      const second = await storage.list(store, { prefix: 'game/', cursor: first.cursor, limit: 1 });
      results.push({ bytes: [...new Uint8Array(await read.blob.arrayBuffer())], first: first.objects[0].key, second: second.objects[0].key });
      if (store === 'indexeddb') {
        const races = await Promise.allSettled([storage.write(ref, new Blob(['A']), { ifMatch: saved.etag }), storage.write(ref, new Blob(['B']), { ifMatch: saved.etag })]);
        results.push(races.map(r => r.status).sort());
      }
      await storage.remove(ref);
    }
    await storage.dispose(); return results;
  });
  expect(result[0].bytes).toEqual([0, 255, 1]);
  expect(result[0].first).not.toBe(result[0].second);
  expect(result[1]).toEqual(['fulfilled', 'rejected']);
  expect(result[2].bytes).toEqual([0, 255, 1]);
  expect(result[2].first).not.toBe(result[2].second);
});

test('storage pane uploads and downloads arbitrary binary resources', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.getByRole('button', { name: 'Browse storage' }).click();
  await page.getByLabel('Upload resource').setInputFiles({ name: 'mesh.glb', mimeType: 'model/gltf-binary', buffer: Buffer.from([0, 255, 1]) });
  await expect(page.getByRole('button', { name: 'mesh.glb', exact: true })).toBeVisible();
  const event = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Download mesh.glb', exact: true }).click();
  const download = await event; const stream = await download.createReadStream(), chunks = [];
  for await (const chunk of stream) chunks.push(chunk);
  expect(Buffer.concat(chunks)).toEqual(Buffer.from([0, 255, 1]));
  expect(download.suggestedFilename()).toBe('mesh.glb');
});

test('legacy saves migrate to IndexedDB and remain readable after reload', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.evaluate(() => {
    const document = kagura.snapshot().document; document.name = 'Migrated project';
    localStorage.setItem('kagura.studio.document.v1', JSON.stringify(document));
  });
  await page.reload();
  await page.waitForFunction(() => !!globalThis.kagura);
  expect(await page.evaluate(() => kagura.snapshot().document.name)).toBe('Migrated project');
  expect(await page.evaluate(() => localStorage.getItem('kagura.studio.document.v1'))).toBe(null);
  await page.reload();
  await page.waitForFunction(() => !!globalThis.kagura);
  expect(await page.evaluate(() => kagura.snapshot().document.name)).toBe('Migrated project');
});

test('HTTP resource sources download original bytes without modifying the scene', async ({ page }) => {
  await page.route('**/downloadable.bin', route => route.fulfill({ status: 200, contentType: 'application/octet-stream', body: Buffer.from([5, 0, 255]) }));
  await page.goto('/'); await page.waitForFunction(() => !!globalThis.kagura);
  const before = await page.evaluate(() => kagura.snapshot());
  const event = page.waitForEvent('download');
  await page.evaluate(() => kagura.storage.download({ url: new URL('/downloadable.bin', location.href).href }));
  const download = await event, stream = await download.createReadStream(), chunks = [];
  for await (const chunk of stream) chunks.push(chunk);
  expect(Buffer.concat(chunks)).toEqual(Buffer.from([5, 0, 255]));
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(before);
});
