import { test, expect } from '@playwright/test';

test('project settings override catalog size and reach the running game', async ({ page }) => {
  await page.route('**/examples/draw2d_ui_demo/draw2d_ui_demo.kgrprj', async (route) => {
    const response = await route.fetch();
    const manifest = await response.json();
    manifest.id = 'org.test.custom-project';
    manifest.save = { namespace: 'org.test.progress', version: 3 };
    manifest.display = { width: 320, height: 240 };
    await route.fulfill({ response, json: manifest });
  });
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('draw2d_ui_demo');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  const actual = await page
    .frameLocator('.game-frame')
    .locator('body')
    .evaluate(() => ({
      project: __kaguraProject,
      canvas: [__kaguraWebRuntime.canvas.width, __kaguraWebRuntime.canvas.height],
    }));
  expect(actual.project.id).toBe('org.test.custom-project');
  expect(actual.project.save).toEqual({ namespace: 'org.test.progress', version: 3 });
  expect(actual.project.display).toEqual({ width: 320, height: 240 });
  expect(actual.canvas).toEqual([320, 240]);
});

test('a different game or future schema is rejected without losing the open scene', async ({
  page,
}) => {
  let patch = { game: 'different_game' };
  await page.route('**/examples/draw2d_ui_demo/draw2d_ui_demo.kgrprj', async (route) => {
    const response = await route.fetch();
    await route.fulfill({ response, json: { ...(await response.json()), ...patch } });
  });
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('arena3d');
  await expect(page.getByRole('status')).toContainText('Opened project');
  const before = await page.evaluate(() => kagura.snapshot());
  await page.getByLabel('Examples', { exact: true }).selectOption('draw2d_ui_demo');
  await expect(page.getByRole('status')).toContainText('Project game does not match');
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(before);
  expect(await page.evaluate(() => kagura.projects.current().manifest.game)).toBe('arena3d');
  patch = { sceneSchema: { id: 'kagura.example', version: 2 } };
  await page.getByLabel('Examples', { exact: true }).selectOption('draw2d_ui_demo');
  await expect(page.getByRole('status')).toContainText('Incompatible scene schema');
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(before);
});

test('IRON YARD carries project identity into its domain editor and game', async ({ page }) => {
  test.setTimeout(60000);
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('iron_yard');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(page.getByLabel('Project settings')).toContainText(
    'mizchi.kagura.examples.iron_yard',
  );
  await page.getByRole('button', { name: 'Edit', exact: true }).click();
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toHaveAttribute(
    'data-ready',
    'true',
    { timeout: 30000 },
  );
  const settings = await page
    .frameLocator('.iron-scene-canvas')
    .locator('body')
    .evaluate(() => __kaguraProject);
  expect(settings.game).toBe('iron_yard');
  expect(settings.sceneSchema).toEqual({ id: 'iron_yard.scene', version: 1 });
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect
    .poll(
      () =>
        page
          .frameLocator('.game-frame')
          .locator('body')
          .evaluate(() => window.kaguraGame?.snapshot().phase),
      { timeout: 30000 },
    )
    .toBe('playing');
  expect(
    await page
      .frameLocator('.game-frame')
      .locator('body')
      .evaluate(() => __kaguraProject),
  ).toEqual(settings);
});
