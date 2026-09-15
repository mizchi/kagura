import {test, expect} from '@playwright/test';
import {mkdirSync} from 'node:fs';
import {join} from 'node:path';
import {catalog} from '../scripts/example-catalog.mjs';

// Explicit maintenance task: never overwrite checked-in artwork in ordinary E2E runs.
test.skip(process.env.KAGURA_UPDATE_THUMBNAILS !== '1', 'Run just pages-thumbnails to refresh gameplay captures');
test.use({viewport: {width: 960, height: 600}});

for (const game of catalog.filter(item => item.gallery)) {
  test(`capture gameplay thumbnail: ${game.id}`, async ({page}) => {
    const errors: string[] = [];
    page.on('pageerror', error => errors.push(error.message));
    const path = game.gallery.playPath ?? `${game.id}/`;
    const query = game.id === 'hacknslash_3d' ? '?snapshot=site&site=ruins&seed=42&mute=1'
      : game.id === 'emberwing' ? '?encounter=swarm' : '';
    expect((await page.goto(`./${path}${query}`))?.ok()).toBe(true);
    const canvas = page.locator('#app');
    await expect(canvas).toBeVisible();
    if (game.id === 'iron_yard') {
      await expect(page.getByRole('button', {name: '出撃する', exact: true})).toBeEnabled();
      await page.getByRole('button', {name: '出撃する', exact: true}).click();
      await expect(page.getByRole('dialog', {name: '出撃メニュー'})).not.toBeVisible();
    } else if (game.id === 'emberwing') {
      await page.getByRole('button', {name: '飛び立つ ↗', exact: true}).click();
      await expect.poll(() => page.evaluate(() => globalThis.emberwing?.snapshot().mode)).toBe('playing');
      await expect.poll(() => page.evaluate(() => globalThis.emberwing?.snapshot().targets.length)).toBeGreaterThan(0);
    } else {
      await expect.poll(() => page.evaluate(() => globalThis.__kaguraGfx?.lastRenderCpuMs?.() ?? 0)).toBeGreaterThan(0);
      if (['flappy_bird', 'survivor', 'arena3d'].includes(game.id)) {
        await canvas.focus();
        await page.keyboard.press('Space', {delay: 100});
      }
    }
    if (game.id === 'flappy_bird') {
      // Keep the bird in flight until pipes enter the stage.
      for (let flap = 0; flap < 5; flap++) {
        await page.waitForTimeout(580);
        await page.keyboard.press('Space', {delay: 40});
      }
    }
    // Let the first gameplay frame, animation and GPU present settle before capture.
    await page.waitForTimeout(['survivor', 'arena3d'].includes(game.id) ? 3000 : game.id === 'flappy_bird' ? 100 : 500);
    expect(errors).toEqual([]);
    const directory = 'assets/pages/thumbnails';
    mkdirSync(directory, {recursive: true});
    const destination = join(directory, `${game.id}.jpg`);
    if (['emberwing', 'hacknslash_3d', 'iron_yard'].includes(game.id)) {
      await page.screenshot({path: destination, type: 'jpeg', quality: 85});
    } else {
      await canvas.screenshot({path: destination, type: 'jpeg', quality: 85});
    }
  });
}
