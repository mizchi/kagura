import { test, expect, type Page } from '@playwright/test';

type UiNode = { id: string; path: string; left: number; top: number; width: number; height: number; text?: string };
const snapshot = (page: Page) => page.evaluate(() => (globalThis as any).__kaguraUISnapshot?.parsed);
const effectStates = ['card_play', 'enemy_turn', 'draw_hand', 'battle_outcome', 'transition'];
async function settle(page: Page) {
  await expect.poll(async () => effectStates.includes((await snapshot(page)).state)).toBe(false);
}
async function node(page: Page, id: string, ancestor?: string): Promise<UiNode> {
  const ui = await snapshot(page);
  const result = ui.nodes.find((n: UiNode) => n.id === id && (!ancestor || n.path.startsWith(ancestor + '>')));
  expect(result, `snapshot contains ${id}`).toBeTruthy();
  return result;
}
async function point(page: Page, n: UiNode) {
  const box = await page.locator('#app').boundingBox();
  expect(box).toBeTruthy();
  const ui = await snapshot(page);
  return { x: box!.x + (n.left + n.width / 2) * box!.width / ui.screen.width,
    y: box!.y + (n.top + n.height / 2) * box!.height / ui.screen.height };
}
async function clickNode(page: Page, id: string) {
  const p = await point(page, await node(page, id));
  await page.mouse.click(p.x, p.y, { delay: 80 });
}
async function expectHeroOnLeft(page: Page) {
  const hero = await node(page, 'player');
  const enemies = (await snapshot(page)).nodes.filter((n: UiNode) => /^enemy_body_\d+$/.test(n.id));
  expect(enemies.length).toBeGreaterThan(0);
  for (const enemy of enemies) expect(hero.left + hero.width).toBeLessThan(enemy.left);
}
async function dragCard(page: Page, index: number, target: UiNode) {
  const start = await point(page, await node(page, `card_frame_${index}`));
  const end = await point(page, target);
  await page.mouse.move(start.x, start.y);
  await page.mouse.down();
  // A game tick must observe the press before the pointer moves.
  await expect.poll(async () => (await snapshot(page)).nodes.some((n: UiNode) => n.id === 'hint' && n.text?.startsWith('DROP ON'))).toBe(true);
  await page.mouse.move(end.x, end.y, { steps: 12 });
  await expect.poll(async () => (await snapshot(page)).state).toBe('dragging');
  await page.mouse.up();
  await expect.poll(async () => (await snapshot(page)).state).toBe('battle');
}

test.beforeEach(async ({ page }) => {
  await page.goto('/');
  await expect.poll(async () => (await snapshot(page))?.state).toBe('battle');
  await page.locator('#app').focus();
});

test('cards are spent on a valid drop; cancellation and keyboard controls work', async ({ page }, info) => {
  const errors: string[] = [];
  page.on('pageerror', error => errors.push(error.message));
  await expectHeroOnLeft(page);
  const energy = (await node(page, 'energy')).text;
  const target = await node(page, 'enemy_body_1');
  const hp = (await node(page, 'value', 'enemy_body_1>hp')).text;
  await dragCard(page, 0, target);
  await expect.poll(async () => (await node(page, 'energy')).text).toBe('ENERGY 2/3');
  expect((await node(page, 'value', 'enemy_body_1>hp')).text).not.toBe(hp);
  expect(energy).toBe('ENERGY 3/3');
  await dragCard(page, 0, await node(page, 'player'));
  await expect.poll(async () => (await node(page, 'block')).text).toContain('BLOCK 6');
  await expect.poll(async () => (await node(page, 'energy')).text).toBe('ENERGY 1/3');

  const start = await point(page, await node(page, 'card_frame_0'));
  await page.mouse.move(start.x, start.y);
  await page.mouse.down();
  await page.waitForTimeout(60);
  await page.mouse.move(start.x, start.y - 80, { steps: 8 });
  await expect.poll(async () => (await snapshot(page)).state).toBe('dragging');
  await page.keyboard.press('Escape', { delay: 80 });
  await page.mouse.up();
  await expect.poll(async () => (await node(page, 'energy')).text).toBe('ENERGY 1/3');
  await page.keyboard.press('KeyE', { delay: 80 });
  await expect.poll(async () => (await node(page, 'turn')).text).toContain('TURN 2');
  await expect.poll(async () => (await node(page, 'energy')).text).toBe('ENERGY 3/3');
  await page.locator('#app').screenshot({ path: info.outputPath('battle.png') });
  expect(errors).toEqual([]);
});

test('the shared launch page maximizes the game and supports browser fullscreen and resize', async ({ page }, info) => {
  const expectMaximumSurface = async () => {
    await expect.poll(async () => {
      const bounds = await page.locator('#app').boundingBox();
      const viewport = page.viewportSize()!;
      const ui = await snapshot(page);
      const width = Math.min(viewport.width, (viewport.height - 48) * ui.screen.width / ui.screen.height);
      return Math.abs(bounds!.width - width);
    }).toBeLessThan(0.05);
    const bounds = await page.locator('#app').boundingBox();
    const viewport = page.viewportSize()!;
    const ui = await snapshot(page);
    const width = Math.min(viewport.width, (viewport.height - 48) * ui.screen.width / ui.screen.height);
    expect(bounds!.width).toBeCloseTo(width, 1);
    expect(bounds!.height).toBeCloseTo(width * ui.screen.height / ui.screen.width, 1);
    expect(bounds!.y).toBeGreaterThanOrEqual(48);
    expect(await page.evaluate(() => document.documentElement.scrollHeight)).toBe(viewport.height);
  };
  await expectMaximumSurface();
  await page.getByRole('button', {name: '全画面', exact: true}).click();
  await expect.poll(() => page.evaluate(() => Boolean(document.fullscreenElement))).toBe(true);
  await page.getByRole('button', {name: '全画面を終了', exact: true}).click();
  await expect.poll(() => page.evaluate(() => Boolean(document.fullscreenElement))).toBe(false);
  await page.setViewportSize({width: 1000, height: 600});
  await expectMaximumSurface();
  await expectHeroOnLeft(page);
  await dragCard(page, 0, await node(page, 'enemy_body_1'));
  expect((await node(page, 'energy')).text).toBe('ENERGY 2/3');
  await page.locator('#game-guide summary').click();
  await expect(page.getByRole('heading', {name: 'Controls'})).toBeVisible();
  const energy = (await node(page, 'energy')).text;
  await page.keyboard.press('KeyE', {delay: 80});
  expect((await node(page, 'energy')).text).toBe(energy);
  await page.keyboard.press('Escape', {delay: 80});
  await expect(page.getByRole('heading', {name: 'Controls'})).toBeHidden();
  await page.screenshot({path: info.outputPath('fullscreen-page.png')});
});

test('a won encounter offers cards and the chosen reward is in the deck', async ({ page }, info) => {
  // Play the first two louses through the public keyboard controls.
  for (let turn = 0; turn < 18; turn++) {
    if ((await snapshot(page)).state !== 'battle') break;
    for (let action = 0; action < 12; action++) {
      const ui = await snapshot(page);
      if (ui.state !== 'battle') break;
      const cards = ui.nodes.filter((n: UiNode) => /^card_frame_\d+$/.test(n.id));
      let played = false;
      for (let i = 0; i < cards.length; i++) {
        await page.keyboard.press(`Digit${i + 1}`, { delay: 80 });
        await page.waitForTimeout(45);
        const hint = await node(page, 'hint');
        if (hint.text === 'NOT ENOUGH ENERGY') continue;
        await page.keyboard.press('Enter', { delay: 80 });
        await settle(page);
        const after = await snapshot(page);
        if (after.state !== 'battle' || after.nodes.filter((n: UiNode) => /^card_frame_\d+$/.test(n.id)).length < cards.length) {
          played = true; break;
        }
      }
      if (!played) break;
    }
    if ((await snapshot(page)).state === 'battle') {
      await page.keyboard.press('KeyE', { delay: 80 });
      await settle(page);
    }
  }
  await expect.poll(async () => (await snapshot(page)).state).toBe('battle_victory');
  await clickNode(page, 'continue_btn');
  await expect.poll(async () => (await snapshot(page)).state).toBe('card_reward');
  const reward = (await node(page, 'name_0', 'reward_0')).text;
  await page.locator('#app').screenshot({ path: info.outputPath('reward.png') });
  await clickNode(page, 'reward_0');
  await expect.poll(async () => (await snapshot(page)).state).toBe('battle');
  await expect.poll(async () => (await node(page, 'floor')).text).toContain('FLOOR 2');
  await clickNode(page, 'deck_btn');
  await expect.poll(async () => (await snapshot(page)).state).toBe('deck');
  await clickNode(page, 'deck_next');
  const names = (await snapshot(page)).nodes.filter((n: UiNode) => n.id.startsWith('deck_card_')).map((n: UiNode) => n.text).join(' ');
  expect(names).toContain(reward);
  await page.keyboard.press('Escape', { delay: 80 });
  await expect.poll(async () => (await snapshot(page)).state).toBe('battle');
});

test('card effects visibly move, settle and reject repeated actions', async ({ page }, info) => {
  const hero = await node(page, 'hero');
  await page.keyboard.press('Digit1', { delay: 60 });
  await page.keyboard.press('Enter', { delay: 40 });
  await expect.poll(async () => (await snapshot(page)).state, { intervals: [10] }).toBe('card_play');
  await expect.poll(async () => Math.abs((await node(page, 'hero')).left - hero.left), { intervals: [10] }).toBeGreaterThan(1);
  await page.locator('#app').screenshot({ path: info.outputPath('card-impact.png') });
  await page.keyboard.down('Digit1');
  await page.keyboard.down('Enter');
  await page.keyboard.down('KeyE');
  await settle(page);
  await page.keyboard.up('Digit1');
  await page.keyboard.up('Enter');
  await page.keyboard.up('KeyE');
  expect((await node(page, 'energy')).text).toBe('ENERGY 2/3');
  expect((await node(page, 'turn')).text).toContain('TURN 1');
  expect((await node(page, 'hero')).left).toBe(hero.left);
  expect((await snapshot(page)).nodes.some((n: UiNode) => n.id.startsWith('combat_popup_') || n.id === 'played_card')).toBe(false);
});

test('enemy turns pause, resolve one by one and then deal a new hand', async ({ page }, info) => {
  const hp = (await node(page, 'value', 'player>hp_bar')).text;
  const started = Date.now();
  await page.keyboard.press('KeyE', { delay: 40 });
  await expect.poll(async () => (await snapshot(page)).state, { intervals: [10] }).toBe('enemy_turn');
  expect((await node(page, 'value', 'player>hp_bar')).text).toBe(hp);
  expect((await snapshot(page)).nodes.some((n: UiNode) => /^card_frame_\d+$/.test(n.id))).toBe(false);
  await expect.poll(async () => (await snapshot(page)).nodes.some((n: UiNode) => n.path === 'combat_popup_0>amount' && n.text === 'GUARD'), { intervals: [20] }).toBe(true);
  expect((await node(page, 'value', 'player>hp_bar')).text).toBe(hp);
  await expect.poll(async () => (await snapshot(page)).nodes.some((n: UiNode) => n.path === 'combat_popup_-1>amount' && n.text === '-6'), { intervals: [20] }).toBe(true);
  await page.locator('#app').screenshot({ path: info.outputPath('enemy-impact.png') });
  await expect.poll(async () => (await snapshot(page)).state, { intervals: [20] }).toBe('draw_hand');
  await settle(page);
  expect(Date.now() - started).toBeGreaterThan(1500);
  expect((await node(page, 'turn')).text).toContain('TURN 2');
  expect((await snapshot(page)).nodes.filter((n: UiNode) => /^card_frame_\d+$/.test(n.id))).toHaveLength(5);
});

test('reduced motion keeps the action pause without travel or shaking', async ({ page }) => {
  await page.emulateMedia({ reducedMotion: 'reduce' });
  const hero = await node(page, 'hero');
  await page.keyboard.press('Digit1', { delay: 60 });
  await page.keyboard.press('Enter', { delay: 40 });
  await expect.poll(async () => (await snapshot(page)).state, { intervals: [10] }).toBe('card_play');
  expect((await node(page, 'hero')).left).toBe(hero.left);
  expect((await snapshot(page)).nodes.some((n: UiNode) => n.id === 'played_card')).toBe(false);
  await settle(page);
  expect((await node(page, 'energy')).text).toBe('ENERGY 2/3');
});

test('result transitions preserve the outgoing screen and consume repeated choices', async ({ page }, info) => {
  await page.goto('/?preview=battle_victory');
  await expect.poll(async () => (await snapshot(page))?.state).toBe('battle_victory');
  await page.locator('#app').focus();
  await page.keyboard.press('Enter', { delay: 40 });
  await expect.poll(async () => (await snapshot(page)).state, { intervals: [10] }).toBe('transition');
  expect((await snapshot(page)).nodes.some((n: UiNode) => n.text === 'BATTLE WON')).toBe(true);
  expect((await snapshot(page)).nodes.some((n: UiNode) => n.id === 'screen_fade')).toBe(true);
  await page.keyboard.press('Digit1', { delay: 40 });
  await page.locator('#app').screenshot({ path: info.outputPath('result-transition.png') });
  await settle(page);
  expect((await snapshot(page)).state).toBe('card_reward');
  expect((await node(page, 'floor')).text).toContain('FLOOR 1');
  expect((await node(page, 'text', 'deck_btn')).text).toBe('DECK 10');
});

test('leaving the window during a drag cancels the card', async ({ page }) => {
  const start = await point(page, await node(page, 'card_frame_0'));
  const target = await point(page, await node(page, 'enemy_body_1'));
  await page.mouse.move(start.x, start.y);
  await page.mouse.down();
  await page.waitForTimeout(80);
  await page.mouse.move(target.x, target.y, { steps: 10 });
  await expect.poll(async () => (await snapshot(page)).state).toBe('dragging');
  await page.evaluate(() => window.dispatchEvent(new Event('blur')));
  await expect.poll(async () => (await snapshot(page)).state).toBe('battle');
  await page.mouse.up();
  expect((await node(page, 'energy')).text).toBe('ENERGY 3/3');
});

test.describe('phone', () => {
  test.use({ viewport: { width: 375, height: 812 }, hasTouch: true, isMobile: true, deviceScaleFactor: 2 });
  test('touch dragging uses portrait layout and the displayed drop targets', async ({ page }, info) => {
    const ui = await snapshot(page);
    expect(ui.screen.width).toBe(360);
    expect(ui.screen.height).toBe(640);
    await expect.poll(async () => {
      const box = await page.locator('#app').boundingBox();
      return box!.width / box!.height;
    }).toBeCloseTo(360 / 640, 3);
    expect((await page.locator('#app').boundingBox())!.height).toBeGreaterThan(600);
    await expectHeroOnLeft(page);
    const start = await point(page, await node(page, 'card_frame_0'));
    const target = await point(page, await node(page, 'enemy_body_1'));
    const session = await page.context().newCDPSession(page);
    await session.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: start.x, y: start.y, id: 7 }] });
    await expect.poll(async () => (await node(page, 'hint')).text).toBe('DROP ON AN ENEMY');
    await session.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: target.x, y: target.y, id: 7 }] });
    await expect.poll(async () => (await snapshot(page)).state).toBe('dragging');
    await page.locator('#app').screenshot({ path: info.outputPath('touch-drag.png') });
    await session.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await expect.poll(async () => (await node(page, 'energy')).text).toBe('ENERGY 2/3');
    await page.locator('#app').screenshot({ path: info.outputPath('portrait.png') });
    await session.detach();
  });
});
