import { test, expect } from '@playwright/test';

test('2D layout dragging, resizing, AI edits and MoonBit export feed the real Flappy Bird runtime', async ({
  page,
}) => {
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('flappy_bird');
  await expect(page.getByRole('status')).toContainText('Opened project');
  const view = page.getByLabel('2D scene viewport', { exact: true });
  await expect(view).toBeVisible();
  await expect(page.getByLabel('3D scene viewport')).toBeHidden();
  await expect(page.getByRole('button', { name: 'Perspective', exact: true })).toBeHidden();
  await expect(page.getByRole('button', { name: 'Add box', exact: true })).toBeHidden();
  await page.getByRole('button', { name: 'Bird', exact: true }).click();
  await expect(page.getByLabel('2D X', { exact: true })).toHaveValue('60');
  const revision = await page.evaluate(() => kagura.snapshot().revision);
  const bird = view.locator('[data-object-id=bird]');
  const box = await bird.boundingBox();
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
  await page.mouse.down();
  await page.mouse.move(box.x + box.width * 2, box.y + box.height / 2, { steps: 4 });
  await page.mouse.up();
  await expect(page.getByLabel('2D X', { exact: true })).toHaveValue('78');
  expect(await page.evaluate(() => kagura.snapshot().revision)).toBe(revision + 1);
  await page.getByRole('button', { name: 'Undo', exact: true }).click();
  await expect(page.getByLabel('2D X', { exact: true })).toHaveValue('60');
  const handle = await view.locator('[data-resize-id=bird]').boundingBox();
  await page.mouse.move(handle.x + handle.width / 2, handle.y + handle.height / 2);
  await page.mouse.down();
  await page.mouse.move(
    handle.x + handle.width / 2 + box.width / 2,
    handle.y + handle.height / 2 + box.height / 2,
  );
  await page.mouse.up();
  await expect(page.getByLabel('2D Width', { exact: true })).toHaveValue('18');
  await expect(page.getByLabel('2D Height', { exact: true })).toHaveValue('18');
  await page.getByLabel('2D X', { exact: true }).fill('-10');
  await page.getByLabel('2D X', { exact: true }).press('Tab');
  await expect(page.getByRole('status')).toContainText('Bird must fit');
  await expect(page.getByLabel('2D X', { exact: true })).toHaveValue('60');
  const result = await page.evaluate(async () =>
    kagura.panes.invokeTool(
      'studio.scene2d',
      'object_edit',
      { id: 'bird', changes: { x: 90, y: 80 } },
      { expectedRevision: kagura.snapshot().revision },
    ),
  );
  expect(result.ok).toBe(true);
  await expect(page.getByLabel('2D X', { exact: true })).toHaveValue('90');
  const snapshot = await page.evaluate(() => kagura.snapshot().document);
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  const runtime = await page
    .frameLocator('.game-frame')
    .locator('body')
    .evaluate(() => kaguraSceneRuntime.snapshot());
  expect(runtime.layout.objects.find((o) => o.id === 'bird')).toMatchObject({
    x: 90,
    y: 80,
    width: 18,
    height: 18,
  });
  expect(runtime.birdY).toBe(80);
  await page.getByRole('button', { name: 'Stop', exact: true }).click();
  await expect(view).toBeVisible();
  expect(await page.evaluate(() => kagura.snapshot().document)).toEqual(snapshot);
  const download = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  expect((await download).suggestedFilename()).toBe('training.mbt');
  await page.screenshot({ path: '/tmp/kgr-2d-editor.png' });
  await page.getByLabel('Examples', { exact: true }).selectOption('arena3d');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(view).toHaveCount(0);
  await expect(page.getByLabel('3D scene viewport')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Perspective', exact: true })).toBeVisible();
  expect(errors).toEqual([]);
});

test('2D games without a layout adapter have a dedicated workspace and preserve their own launch settings', async ({
  page,
}) => {
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('draw2d_ui_demo');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(page.getByLabel('2D scene viewport', { exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Add box', exact: true })).toBeHidden();
  await expect(page.getByLabel('2D X', { exact: true })).toHaveCount(0);
  await page.getByRole('button', { name: 'Example設定', exact: true }).click();
  await expect(page.getByRole('button', { name: '起動設定を適用', exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  await page.getByRole('button', { name: 'Stop', exact: true }).click();
  await expect(page.getByLabel('2D scene viewport', { exact: true })).toBeVisible();
  await page.setViewportSize({ width: 768, height: 650 });
  expect(await page.evaluate(() => document.documentElement.scrollHeight <= innerHeight)).toBe(
    true,
  );
});
