import { test, expect } from '@playwright/test';
import { createTestWorker } from '../tests/worker-runtime.mjs';

test('storage pane connects to a real local Worker and R2, then saves and reloads a scene', async ({ page, baseURL }) => {
  const worker = createTestWorker(new URL(baseURL).origin);
  try {
    const workerURL = await worker.ready;
    await page.goto('/'); await page.waitForFunction(() => !!globalThis.kagura);
    await page.getByRole('button', { name: 'Browse storage' }).click();
    await page.getByLabel('Worker endpoint', { exact: true }).fill(new URL('/api/storage/objects', workerURL).href);
    await page.getByLabel('Worker token', { exact: true }).fill('test-token');
    await page.getByRole('button', { name: 'Connect R2', exact: true }).click();
    await expect(page.getByLabel('Storage provider')).toHaveValue('r2-1');
    await page.getByLabel('Resource key', { exact: true }).fill('game/scene.json');
    await page.getByRole('button', { name: 'Save scene here', exact: true }).click();
    await expect(page.locator('.statusbar')).toContainText('Saved');
    await page.getByLabel('Name', { exact: true }).fill('Unsaved actor');
    await page.getByLabel('Name', { exact: true }).press('Tab');
    await page.getByRole('button', { name: 'Load scene', exact: true }).click();
    await expect(page.getByLabel('Name', { exact: true })).toHaveValue('Actor');
    const event = page.waitForEvent('download');
    await page.getByRole('button', { name: 'Download resource', exact: true }).click();
    const download = await event;
    expect(download.suggestedFilename()).toBe('scene.json');
    await page.screenshot({ path: 'test-results/storage-r2.png' });
  } finally { await worker.dispose(); }
});
