import { test, expect } from '@playwright/test';

test('the shell has no default game and owns one transport across project switches', async ({
  page,
}) => {
  await page.goto('/');
  await expect(page.getByRole('button', { name: /^(Edit|Play|Open) IRON YARD$/ })).toHaveCount(0);
  const transport = page.getByRole('group', { name: 'Project controls', exact: true });
  await expect(transport).toBeHidden();
  expect(
    await page.evaluate(() => kagura.panes.tools().some((t) => t.name.includes('iron-yard'))),
  ).toBe(false);
  await page.getByLabel('Examples', { exact: true }).selectOption('iron_yard');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(transport).toBeVisible();
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toHaveAttribute(
    'data-ready',
    'true',
    { timeout: 30000 },
  );
  await page.screenshot({ path: '/tmp/kgr-transport-iron-yard.png' });
  await transport.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(transport.getByRole('button', { name: 'Stop', exact: true })).toBeEnabled();
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
  await transport.getByRole('button', { name: 'Stop', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveCount(0);
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toBeVisible();
  await page.getByLabel('Examples', { exact: true }).selectOption('flappy_bird');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(page.locator('.iron-scene-canvas')).toHaveCount(0);
  await expect(transport).toHaveCount(1);
  await transport.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  await transport.getByRole('button', { name: 'Edit', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveCount(0);
  await page.getByLabel('Examples', { exact: true }).selectOption('terrain_demo');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(transport.getByRole('button', { name: 'Play', exact: true })).toBeDisabled();
  await expect(transport.getByRole('button', { name: 'Stop', exact: true })).toBeDisabled();
  await expect(page.getByRole('button', { name: /^(Edit|Play|Open) IRON YARD$/ })).toHaveCount(0);
  await page.screenshot({ path: '/tmp/kgr-project-transport.png' });
});
