import { test, expect } from '@playwright/test';

test('pause, edit live physics and generated objects, step, checkpoint and resume without changing source', async ({
  page,
}) => {
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('flappy_bird');
  await expect(page.getByRole('status')).toContainText('Opened project');
  const authoring = await page.evaluate(() => kagura.snapshot());
  const controls = page.getByRole('group', { name: 'Project controls' });
  await controls.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  await page.frameLocator('.game-frame').locator('canvas').press('Space');
  await controls.getByRole('button', { name: 'Pause', exact: true }).click();
  const initial = await page.evaluate(() => kagura.runtime.snapshot());
  expect(initial.paused).toBe(true);
  expect(initial.state.frame_count).toBeGreaterThan(0);
  // Rendering continues, but no game ticks advance while paused.
  await page.evaluate(
    () =>
      new Promise((resolve) => {
        let frames = 0;
        const tick = () => (++frames === 8 ? resolve() : requestAnimationFrame(tick));
        requestAnimationFrame(tick);
      }),
  );
  expect(await page.evaluate(() => kagura.runtime.snapshot())).toEqual(initial);
  await page.getByText('Raw state JSON', { exact: true }).click();
  const input = page.getByLabel('Runtime state JSON');
  const state = {
    ...initial.state,
    mode: 1,
    score: 42,
    bird_y: 80,
    velocity: -2,
    pipe_timer: 119,
    pipes: [{ x: 180, gap_y: 90 }],
  };
  state.layout.objects.find((o) => o.id === 'bird').width = 24;
  await input.fill(JSON.stringify(state));
  await page.getByRole('button', { name: 'Apply state', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Runtime state applied');
  expect((await page.evaluate(() => kagura.runtime.snapshot())).state).toEqual(state);
  await controls.getByRole('button', { name: 'Step', exact: true }).click();
  const stepped = await page.evaluate(() => kagura.runtime.snapshot());
  expect(stepped.paused).toBe(true);
  expect(stepped.state.bird_y).toBe(78.25);
  expect(stepped.state.pipes).toHaveLength(2);
  await expect(
    page.getByLabel('Scene hierarchy').locator('[data-scene-id="world/pipes"] > details'),
  ).toHaveCount(4);
  expect(stepped.state.pipes[0].x).toBe(178.5);
  expect(stepped.state.frame_count).toBe(initial.state.frame_count + 1);
  await input.fill(JSON.stringify({ ...stepped.state, mode: 99, score: 900 }));
  await page.getByRole('button', { name: 'Apply state', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Invalid runtime counters');
  expect(await page.evaluate(() => kagura.runtime.snapshot())).toEqual(stepped);
  await page.getByRole('button', { name: 'Read state', exact: true }).click();
  const download = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Export checkpoint' }).click();
  const file = await download;
  expect(file.suggestedFilename()).toBe('flappy_bird.kgrstate');
  await controls.getByRole('button', { name: 'Step', exact: true }).click();
  await page.getByLabel('Import checkpoint').setInputFiles(await file.path());
  await expect(page.getByRole('status')).toContainText('Checkpoint loaded');
  await page.getByRole('button', { name: 'Apply state', exact: true }).click();
  expect((await page.evaluate(() => kagura.runtime.snapshot())).state).toEqual(stepped.state);
  await page.screenshot({ path: '/tmp/kgr-runtime-paused.png' });
  await controls.getByRole('button', { name: 'Resume', exact: true }).click();
  await expect
    .poll(() => page.evaluate(() => kagura.runtime.snapshot().state.frame_count))
    .toBeGreaterThan(stepped.state.frame_count);
  await controls.getByRole('button', { name: 'Stop', exact: true }).click();
  await expect(input).toHaveCount(0);
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(authoring);
  await controls.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  await controls.getByRole('button', { name: 'Pause', exact: true }).click();
  const stale = await page.evaluate((old) => {
    try {
      kagura.runtime.replace(old.state, old);
    } catch (e) {
      return e.message;
    }
  }, stepped);
  expect(stale).toContain('session conflict');
  await controls.getByRole('button', { name: 'Stop', exact: true }).click();
  expect(errors).toEqual([]);
});
