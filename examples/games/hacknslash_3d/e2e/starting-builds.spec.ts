import {test, expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud = page => page.evaluate(() => globalThis.__ashenHud);

for (const [id, name, weapon, helmet] of [
  ['melee', '狩人', '狩人の鉈', '狩人の三角帽'],
  ['mage', '魔法使い', '燐火の触媒', '見習いの尖り帽'],
  ['ranger', '弓使い', '骨の長弓', '射手の革帽'],
  ['summoner', '召喚師', '燐火の触媒', '喚霊の尖り帽'],
]) {
  test(`${name} starts with the advertised equipment and keeps it after saving`, async ({page}, info) => {
    const errors = []; page.on('pageerror', e => errors.push(e.message));
    await page.goto('/?mute=1');
    await expect(page).toHaveTitle(/ASHEN REALMS/);
    await page.locator('[data-save-slot="0"]').click();
    await expect(page.getByRole('heading', {name: '初期ビルドを選択'})).toBeVisible();
    const card = page.locator(`[data-build="${id}"]`);
    await expect(card).toContainText(weapon);
    await expect(card).toContainText(helmet);
    const build = (await hud(page)).builds.find(b => b.id === id);
    if (id === 'mage') await captureGameFrame(page, {path: info.outputPath('builds-desktop.png')});
    await card.click();
    await expect.poll(async () => (await hud(page))?.mode).toBe('playing');
    expect((await hud(page)).skills.map(s => s.name)).toEqual(build.skills);
    await page.keyboard.press('Escape');
    await page.getByRole('button', {name: /セーブして選択画面へ/}).click();
    await page.reload();
    await expect(page.locator('[data-save-slot="0"]')).toContainText(name);
    await page.locator('[data-save-slot="0"]').click();
    await expect.poll(async () => (await hud(page))?.mode).toBe('playing');
    await page.keyboard.press('KeyI');
    await expect(page.locator('.inv-cell')).toHaveCount(48);
    const gear = (await hud(page)).inventory_grid.equipment;
    expect(gear[0].item.name).toBe(weapon);
    expect(gear[3].item.name).toBe(helmet);
    expect(gear.filter(slot => slot.item).map(slot => slot.item.name).sort()).toEqual([weapon, ...build.equipment].sort());
    await captureGameFrame(page, {path: info.outputPath(`${id}-equipment.png`)});
    await page.keyboard.press('Escape');
    await expect.poll(async () => (await hud(page))?.menu).toBe('none');
    await captureGameFrame(page, {path: info.outputPath(`${id}-field.png`)});
    expect(errors).toEqual([]);
  });
}

test('all build cards are readable and selectable on a portrait phone', async ({browser}, info) => {
  const context = await browser.newContext({viewport: {width: 390, height: 844}, isMobile: true, hasTouch: true});
  const page = await context.newPage();
  await page.goto('/?mute=1');
  await page.locator('[data-save-slot="0"]').tap();
  await expect(page.locator('[data-build]')).toHaveCount(4);
  expect(await page.evaluate(() => document.documentElement.scrollWidth)).toBe(390);
  for (const card of await page.locator('[data-build]').all()) {
    await card.scrollIntoViewIfNeeded();
    const box = await card.boundingBox();
    expect(box.x).toBeGreaterThanOrEqual(0);
    expect(box.x + box.width).toBeLessThanOrEqual(390);
    expect(await card.evaluate(el => el.scrollWidth <= el.clientWidth)).toBe(true);
  }
  await captureGameFrame(page, {path: info.outputPath('builds-mobile.png')});
  await page.locator('[data-build="summoner"]').tap();
  await expect.poll(async () => (await hud(page))?.preset_name).toBe('召喚師');
  await context.close();
});
