import { test, expect } from '@playwright/test';

test('Luna UI edits share the AI command history and survive save/reload', async ({ page }) => {
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await expect(page.getByRole('heading', { name: 'Hierarchy', exact: true })).toBeVisible();
  await expect(page.locator('canvas')).toBeVisible();
  await page.getByRole('button', { name: 'Add box', exact: true }).click();
  await page.getByLabel('Name', { exact: true }).fill('AI crate');
  await page.getByLabel('Name', { exact: true }).press('Tab');
  await page.getByLabel('Position X', { exact: true }).fill('3');
  await page.getByLabel('Position X', { exact: true }).press('Tab');
  const result = await page.evaluate(() => {
    const s = kagura.snapshot();
    return kagura.dispatch({ expectedRevision: s.revision, commands: [{ op: 'node.rename', id: s.selection, name: 'Shared crate' }] });
  });
  expect(result.ok).toBe(true);
  await expect(page.getByLabel('Name', { exact: true })).toHaveValue('Shared crate');
  await page.getByRole('button', { name: 'Undo', exact: true }).click();
  await expect(page.getByLabel('Name', { exact: true })).toHaveValue('AI crate');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Saved');
  await page.reload();
  await page.waitForFunction(() => !!globalThis.kagura);
  const doc = await page.evaluate(() => kagura.snapshot().document);
  expect(doc.nodes.find(n => n.name === 'AI crate').position[0]).toBe(3);
  expect(errors).toEqual([]);
});

test('AI rejects conflicts and partial batches; layout and preview preserve the document', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  const initial = await page.evaluate(() => kagura.snapshot());
  const bad = await page.evaluate(() => kagura.dispatch({ expectedRevision: 0, commands: [
    { op: 'node.rename', id: 'hero', name: 'Should rollback' }, { op: 'node.remove', id: 'missing' }
  ] }));
  expect(bad.ok).toBe(false);
  expect((await page.evaluate(() => kagura.snapshot())).document).toEqual(initial.document);
  await page.getByRole('button', { name: 'Action layout', exact: true }).click();
  await page.getByLabel('Preview time', { exact: true }).fill('0.03');
  expect((await page.evaluate(() => kagura.snapshot())).preview.flash).toBe(true);
  await page.getByLabel('Preview time', { exact: true }).fill('0.7');
  expect((await page.evaluate(() => kagura.snapshot())).preview.flash).toBe(false);
  expect((await page.evaluate(() => kagura.snapshot())).document).toEqual(initial.document);
  const stale = await page.evaluate(() => kagura.dispatch({ expectedRevision: 20, commands: [{ op: 'node.remove', id: 'hero' }] }));
  expect(stale.error.code).toBe('conflict');
});

test('invalid imported document keeps the last good scene, and scene can be exported', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  const before = await page.evaluate(() => kagura.snapshot().document);
  await page.getByLabel('Import scene').setInputFiles({ name: 'invalid.json', mimeType: 'application/json', buffer: Buffer.from('{"version":99}') });
  await expect(page.getByRole('status')).toContainText('Error');
  expect(await page.evaluate(() => kagura.snapshot().document)).toEqual(before);
  const download = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Export JSON', exact: true }).click();
  expect((await download).suggestedFilename()).toBe('scene.kagura.json');
});

test('retargeting, playback, layout restoration and subscriptions keep state coherent', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.getByLabel('Target', { exact: true }).fill('block');
  await page.getByLabel('Target', { exact: true }).press('Tab');
  await page.evaluate(() => {
    globalThis.changes = 0;
    globalThis.unsubscribe = kagura.subscribe(() => { changes++; });
  });
  await page.getByRole('button', { name: 'Play preview', exact: true }).click();
  await expect.poll(() => page.evaluate(() => kagura.snapshot().preview.time)).toBeGreaterThan(0.1);
  await page.getByRole('button', { name: 'Pause', exact: true }).click();
  const paused = await page.evaluate(() => {
    unsubscribe(); return { snapshot: kagura.snapshot(), changes };
  });
  expect(paused.snapshot.document.action.target).toBe('block');
  expect(paused.snapshot.revision).toBe(1);
  await page.getByLabel('Preview time', { exact: true }).fill('0');
  expect(await page.evaluate(() => changes)).toBe(paused.changes);
  await page.getByRole('button', { name: 'Action layout', exact: true }).click();
  await page.reload();
  await page.waitForFunction(() => !!globalThis.kagura);
  await expect(page.locator('.studio')).toHaveClass('studio layout-action');
});

test('GLB contains authoring transforms even while preview is displaced', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.getByLabel('Preview time', { exact: true }).fill('0.1');
  const downloadEvent = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Export GLB', exact: true }).click();
  const download = await downloadEvent;
  const stream = await download.createReadStream();
  const buffers = [];
  for await (const chunk of stream) buffers.push(chunk);
  const glb = Buffer.concat(buffers);
  expect(glb.readUInt32LE(0)).toBe(0x46546c67);
  expect(glb.readUInt32LE(4)).toBe(2);
  expect(glb.readUInt32LE(8)).toBe(glb.length);
  const jsonLength = glb.readUInt32LE(12);
  const gltf = JSON.parse(glb.subarray(20, 20 + jsonLength).toString());
  const hero = gltf.nodes.find(n => n.name === 'hero');
  expect(hero.matrix.slice(12, 15)).toEqual([0, 1, 0]);
  expect(gltf.meshes).toHaveLength(3);
  expect((await page.evaluate(() => kagura.snapshot())).preview.offset).toBeLessThan(0);
});

test('narrow screen has no horizontal overflow and all panels remain accessible', async ({ page }) => {
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await expect(page.locator('canvas')).toBeVisible();
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  await page.getByRole('button', { name: 'Add sphere', exact: true }).click();
  await expect(page.getByLabel('Name', { exact: true })).toHaveValue('New object');
});

test('rejected inspector edits show the committed value and preserve history', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.getByLabel('Scale X', { exact: true }).fill('0');
  await page.getByLabel('Scale X', { exact: true }).press('Tab');
  await expect(page.getByRole('status')).toContainText('Error');
  await expect(page.getByLabel('Scale X', { exact: true })).toHaveValue('1');
  expect((await page.evaluate(() => kagura.snapshot())).revision).toBe(0);
});
