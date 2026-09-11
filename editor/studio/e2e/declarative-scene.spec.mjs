import { test, expect } from '@playwright/test';

test('runtime hierarchy follows the declared scene, including generated branches', async ({
  page,
}) => {
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('flappy_bird');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  await page
    .getByRole('group', { name: 'Project controls' })
    .getByRole('button', { name: 'Pause', exact: true })
    .click();
  const tree = page.getByLabel('Scene hierarchy');
  await expect(tree.locator('[data-scene-id="world/body"]')).toBeVisible();
  await expect(tree.locator('[data-scene-id="world/hud/score"]')).toBeVisible();
  await expect(tree.locator('[data-scene-id="world/body"]')).toHaveAttribute(
    'data-generated',
    'false',
  );
  const state = await page.evaluate(() => {
    const snapshot = kagura.runtime.snapshot();
    return kagura.runtime.replace(
      { ...snapshot.state, mode: 1, bird_y: 80, pipes: [{ x: 180, gap_y: 90 }] },
      snapshot,
    );
  });
  expect(state.state.pipes.length).toBe(1);
  await expect(tree.locator('[data-scene-id="world/pipes"] > details')).toHaveCount(2);
  const snapshot = await page.evaluate(() => kagura.runtime.hierarchy());
  expect(snapshot[0].children.map((n) => n.id)).toEqual([
    'world/sky',
    'world/ground',
    'world/pipes',
    'world/body',
    'world/hud',
  ]);
  expect(
    snapshot[0].children.find((n) => n.id === 'world/pipes').children.every((n) => n.generated),
  ).toBe(true);
  await page.screenshot({ path: '/tmp/kgr-declarative-flappy.png' });
  await page.getByRole('button', { name: 'Stop', exact: true }).click();
  await expect(tree).toHaveCount(0);
  await page.getByLabel('Examples', { exact: true }).selectOption('arena3d');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  await expect(tree.locator('[data-scene-id="arena/level/wall"]')).toBeVisible();
  expect((await page.evaluate(() => kagura.runtime.hierarchy()))[0].id).toBe('arena');
  await page.screenshot({ path: '/tmp/kgr-declarative-arena.png' });
  await page.getByRole('button', { name: 'Stop', exact: true }).click();
  await expect(tree).toHaveCount(0);
});
