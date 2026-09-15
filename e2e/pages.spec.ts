import {test, expect} from '@playwright/test';
import {captureGameFrame} from '../scripts/capture-web.mjs';

test('published Studio opens and edits the shared kawaiko model', async ({page}, info) => {
  const errors: string[] = [];
  const failedAssets: string[] = [];
  page.on('pageerror', error => errors.push(error.message));
  page.on('response', response => {
    if (response.status() >= 400 && /\.(?:js|mjs|css|wasm)(?:\?|$)/.test(response.url())) {
      failedAssets.push(`${response.status()} ${response.url()}`);
    }
  });
  await page.goto('./');
  await page.locator('a[href="./studio/?mode=modeling&model=kawaiko"]').click();
  const viewport = page.getByLabel('Modeling viewport', {exact: true});
  await expect(viewport).toBeVisible();
  await expect.poll(() => page.evaluate(() => globalThis.kagura.modeling.stats().triangles)).toBeGreaterThan(0);
  const initial = await page.evaluate(() => globalThis.kagura.modeling.snapshot());
  expect(initial.document.nodes.map(node => node.id)).toContain('beak');
  expect(initial.canUndo).toBe(false);
  await page.getByRole('button', {name: 'Add model cube', exact: true}).click();
  expect(await page.evaluate(() => globalThis.kagura.modeling.snapshot().document.nodes.length))
    .toBe(initial.document.nodes.length + 1);
  await page.reload();
  await expect(viewport).toBeVisible();
  expect(await page.evaluate(() => globalThis.kagura.modeling.snapshot().document)).toEqual(initial.document);
  await page.screenshot({path: info.outputPath('published-kawaiko.png')});
  expect(failedAssets).toEqual([]);
  expect(errors).toEqual([]);
});

test('published playground opens ASHEN REALMS and plays the summoner build', async ({page}, info) => {
  const errors: string[] = [];
  const failedAssets: string[] = [];
  page.on('pageerror', error => errors.push(error.message));
  page.on('response', response => {
    if (response.status() >= 400 && /\.(?:js|mjs|css|ttf|otf|ogg|wav)(?:\?|$)/.test(response.url())) {
      failedAssets.push(`${response.status()} ${response.url()}`);
    }
  });
  const landing = await page.goto('./');
  expect(landing?.ok()).toBe(true);
  await page.locator('a[href="./hacknslash_3d/"]').click();
  await expect(page).toHaveTitle(/ASHEN REALMS/);
  await page.locator('[data-save-slot="0"]').click();
  await page.getByRole('button', {name: /召喚師/}).click();
  await expect.poll(() => page.evaluate(() => globalThis.__ashenHud?.preset_name)).toBe('召喚師');
  await page.keyboard.press('Escape');
  await expect.poll(() => page.evaluate(() => globalThis.__ashenHud?.paused)).toBe(true);

  // Use the deterministic preview to exercise the packaged runtime and assets.
  await page.goto('./hacknslash_3d/?snapshot=summons&peaceful=1&seed=42&mute=1');
  await expect.poll(() => page.evaluate(() => globalThis.__ashenHud?.weapon_locked)).toBe(false);
  await page.mouse.click(580, 400, {button: 'right'});
  await expect.poll(() => page.evaluate(() => globalThis.__ashenHud?.summons.zombies.length)).toBe(1);
  await expect.poll(() => page.evaluate(() => globalThis.__ashenHud?.weapon_locked)).toBe(false);
  await page.mouse.down();
  try {
    await expect.poll(() => page.evaluate(() => globalThis.__ashenHud?.summons.skulls.length), {timeout: 12_000}).toBe(8);
  } finally {
    await page.mouse.up();
  }
  await captureGameFrame(page, {path: info.outputPath('published-summoner.png')});
  expect(await page.locator('#game-surface').boundingBox()).toEqual({x: 0, y: 0, width: 1280, height: 900});
  expect(failedAssets).toEqual([]);
  expect(errors).toEqual([]);
});
