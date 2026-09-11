import { test, expect } from '@playwright/test';

test('declared subject drives the Inspector and AI edits share game validation', async ({
  page,
}) => {
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('flappy_bird');
  await expect(page.getByRole('status')).toContainText('Opened project');
  const authored = await page.evaluate(() => kagura.snapshot());
  const controls = page.getByRole('group', { name: 'Project controls' });
  await controls.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true');
  await controls.getByRole('button', { name: 'Pause', exact: true }).click();
  await page.locator('[data-scene-id="world/body"] > summary').click();
  await expect(page.getByLabel('Bird Y', { exact: true })).toBeEnabled();
  await expect(page.getByLabel('Bird Speed', { exact: true })).toBeDisabled();
  await page.getByLabel('Bird Y', { exact: true }).fill('80');
  await page.getByRole('button', { name: 'Apply Y', exact: true }).click();
  expect((await page.evaluate(() => kagura.runtime.snapshot())).state.bird_y).toBe(80);
  await page.evaluate(() => {
    const current = kagura.runtime.snapshot();
    kagura.runtime.replace({ ...current.state, mode: 1 }, current);
  });
  const edited = await page.evaluate(() =>
    kagura.runtime.edit(
      { subject: 'bird', field: 'velocity', value: -2 },
      kagura.runtime.inspect(),
    ),
  );
  await expect(page.getByLabel('Bird Speed', { exact: true })).toHaveValue('2');
  const rejected = await page.evaluate(() => {
    try {
      kagura.runtime.edit({ subject: 'bird', field: 'speed', value: 10 }, kagura.runtime.inspect());
    } catch (error) {
      return error.message;
    }
  });
  expect(rejected).toContain('not writable');
  expect(await page.evaluate(() => kagura.runtime.snapshot())).toEqual(edited);
  await controls.getByRole('button', { name: 'Step', exact: true }).click();
  expect((await page.evaluate(() => kagura.runtime.snapshot())).state.bird_y).toBe(78.25);
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(authored);
  await page.screenshot({ path: '/tmp/kgr-inspection.png' });
  await controls.getByRole('button', { name: 'Stop', exact: true }).click();
  await expect(page.getByLabel('Selected runtime subject')).toHaveCount(0);
});
