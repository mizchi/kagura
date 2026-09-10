import { test, expect } from '@playwright/test';
import { createHeadlessEditor } from '../headless/index.mjs';

test('browser and browser-free editor produce identical snapshots and errors', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  const headless = createHeadlessEditor();
  const methods = [
    ['dispatch', { expectedRevision: 0, commands: [{ op: 'node.add', id: 'test-node', name: 'Test', asset: 'primitive.sphere' }] }],
    ['select', 'test-node'], ['seek', 0.03],
    ['dispatch', { expectedRevision: 0, commands: [{ op: 'node.remove', id: 'hero' }] }],
    ['undo', 1], ['redo', 2],
    ['dispatch', { expectedRevision: 3, commands: [{ op: 'node.remove', id: 'test-node' }] }],
  ];
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(headless.snapshot());
  for (const [method, argument] of methods) {
    const result = headless[method](argument);
    expect(await page.evaluate(([method, argument]) => kagura[method](argument), [method, argument])).toEqual(result);
    expect(await page.evaluate(() => kagura.snapshot())).toEqual(headless.snapshot());
  }
});
