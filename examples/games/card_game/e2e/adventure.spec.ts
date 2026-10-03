import { test, expect, type Page } from '@playwright/test';
import {tapGameKey, clickGamePoint} from '../../../../e2e/helpers/frame-input';

type Node = { id: string; path: string; left: number; top: number; width: number; height: number;
  text?: string; role: string; focused: boolean; focusable: boolean };
const snapshot = (page: Page) => page.evaluate(() => (globalThis as any).__kaguraUISnapshot?.parsed);
async function state(page: Page, value: string) {
  await expect.poll(async () => (await snapshot(page))?.state).toBe(value);
}
async function node(page: Page, id: string, parent?: string): Promise<Node> {
  const result = (await snapshot(page)).nodes.find((n: Node) => n.id === id && (!parent || n.path.startsWith(parent + '>')));
  expect(result, `${parent ?? ''} ${id}`).toBeTruthy();
  return result;
}
async function click(page: Page, id: string, twice = false) {
  const n = await node(page, id);
  const ui = await snapshot(page);
  const box = (await page.locator('#app').boundingBox())!;
  const x = box.x + (n.left + n.width / 2) * box.width / ui.screen.width;
  const y = box.y + (n.top + n.height / 2) * box.height / ui.screen.height;
  if (twice) await page.mouse.dblclick(x, y, { delay: 70 });
  else await clickGamePoint(page, {x, y});
}
async function preview(page: Page, name: string, expected = name) {
  await page.goto(`/?preview=${name}`);
  await state(page, expected);
  await page.locator('#app').focus();
}

test('new adventure reaches the branching map and directions select a connected first battle', async ({ page }) => {
  await page.goto('/');
  await state(page, 'title');
  for (const next of ['character_select', 'stage_select', 'map']) {
    await click(page, 'scene_choice_0');
    await state(page, next);
  }
  const nodes = (await snapshot(page)).nodes.filter((n: Node) => n.id.startsWith('map_node_') && n.focusable);
  expect(nodes.map((n: Node) => n.id)).toEqual(['map_node_0', 'map_node_1', 'map_node_2']);
  await tapGameKey(page, 'ArrowRight', { delay: 60 });
  expect((await node(page, 'map_node_1')).focused).toBe(true);
  await tapGameKey(page, 'Enter', { delay: 60 });
  await state(page, 'battle');
  expect((await node(page, 'floor')).text).toContain('FLOOR 1');
  expect((await node(page, 'run_gold')).text).toBe('GOLD 99');
});

test('map rejects an unconnected future room and enters the unique enemy through its edge', async ({ page }) => {
  await preview(page, 'map_unique', 'map');
  expect((await node(page, 'map_node_21')).focusable).toBe(false);
  await click(page, 'map_node_21');
  await state(page, 'map');
  await click(page, 'map_node_18');
  await state(page, 'unique_battle');
  expect((await node(page, 'name', 'enemy_body_0')).text).toMatch(/^U \/ (CINDER DUELIST|GILDED SENTINEL|HOLLOW ORACLE)$/);
});

for (const [id, room] of [[19, 'treasure'], [20, 'shop']] as const) {
  test(`connected map node enters ${room}`, async ({ page }) => {
    await preview(page, 'map_unique', 'map');
    await click(page, `map_node_${id}`);
    await state(page, room);
  });
}

test('event costs are visible and unavailable choices cannot run before healing returns to the map', async ({ page }) => {
  await preview(page, 'event');
  expect((await node(page, 'event_1')).focusable).toBe(false);
  await click(page, 'event_1');
  await state(page, 'event');
  expect((await node(page, 'run_hp')).text).toBe('HP 40/80');
  expect((await node(page, 'run_gold')).text).toBe('GOLD 20');
  await click(page, 'event_0');
  await state(page, 'map');
  expect((await node(page, 'run_hp')).text).toBe('HP 56/80');
  expect((await node(page, 'run_gold')).text).toBe('GOLD 20');
});

test('shop buys once during a double click and removal charges only after selecting a card', async ({ page }) => {
  await preview(page, 'shop');
  await click(page, 'shop_0', true);
  await state(page, 'shop');
  await expect.poll(async () => (await node(page, 'price', 'shop_0')).text).toBe('SOLD');
  expect((await node(page, 'run_gold')).text).toBe('GOLD 185');
  expect((await node(page, 'text', 'deck_btn')).text).toBe('DECK 11');
  expect((await node(page, 'shop_0')).focusable).toBe(false);
  await click(page, 'remove_card');
  await state(page, 'card_removal');
  expect((await node(page, 'run_gold')).text).toBe('GOLD 185');
  await click(page, 'cancel_removal');
  await state(page, 'shop');
  expect((await node(page, 'run_gold')).text).toBe('GOLD 185');
  await click(page, 'remove_card');
  await state(page, 'card_removal');
  await tapGameKey(page, 'Enter', { delay: 60 });
  await state(page, 'shop');
  expect((await node(page, 'run_gold')).text).toBe('GOLD 135');
  expect((await node(page, 'text', 'deck_btn')).text).toBe('DECK 10');
  expect((await node(page, 'text', 'remove_card')).text).toContain('75 GOLD');
  await tapGameKey(page, 'Escape', { delay: 60 });
  await state(page, 'map');
});

test('free relic choice enters the inventory and then returns to the map', async ({ page }) => {
  await preview(page, 'treasure');
  const relic = (await node(page, 'name', 'relic_0')).text!;
  await click(page, 'relic_0');
  await state(page, 'map');
  await tapGameKey(page, 'KeyD', { delay: 60 });
  await state(page, 'deck');
  await click(page, 'deck_next');
  expect((await snapshot(page)).nodes.some((n: Node) => n.text?.includes(`RELIC / ${relic}`))).toBe(true);
  await tapGameKey(page, 'Escape', { delay: 60 });
  await state(page, 'map');
});

test('unique sentinel shielding persists into the player turn and its next attack is telegraphed', async ({ page }) => {
  await preview(page, 'unique_battle');
  expect((await node(page, 'name', 'enemy_body_0')).text).toBe('U / GILDED SENTINEL');
  expect((await node(page, 'intent', 'enemy_body_0')).text).toBe('BLOCK 12');
  await tapGameKey(page, 'KeyE', { delay: 60 });
  await state(page, 'unique_battle');
  await expect.poll(async () => (await node(page, 'status', 'enemy_body_0')).text).toContain('B 12');
  expect((await node(page, 'intent', 'enemy_body_0')).text).toBe('ATTACK 15');
});

test('portrait map fits its viewport and browsing confirm returns to the visible available nodes', async ({ page }, info) => {
  await page.setViewportSize({ width: 375, height: 812 });
  await preview(page, 'map_unique', 'map');
  const ui = await snapshot(page);
  for (const n of ui.nodes.filter((n: Node) => n.id.startsWith('map_node_'))) {
    expect(n.left).toBeGreaterThanOrEqual(0);
    expect(n.top).toBeGreaterThanOrEqual(104);
    expect(n.left + n.width).toBeLessThanOrEqual(ui.screen.width);
    expect(n.top + n.height).toBeLessThanOrEqual(ui.screen.height - 110);
  }
  await click(page, 'map_next');
  await state(page, 'map');
  await tapGameKey(page, 'Enter', { delay: 60 });
  await state(page, 'map');
  expect((await node(page, 'map_node_18')).focused).toBe(true);
  await page.locator('#app').screenshot({ path: info.outputPath('route-map-portrait.png') });
});

test('unique enemy victory grants signature loot once and skipping the card follows the next map edges', async ({ page }) => {
  await preview(page, 'unique_reward', 'unique_battle');
  await tapGameKey(page, 'Digit1', { delay: 60 });
  await click(page, 'enemy_body_0');
  await state(page, 'battle_victory');
  await click(page, 'continue_btn');
  await state(page, 'card_reward');
  expect((await node(page, 'run_gold')).text).toBe('GOLD 176');
  expect((await node(page, 'reward_hint')).text).toBe('+77 GOLD / MERCHANT CHARM');
  await click(page, 'skip_reward');
  await state(page, 'map');
  expect((await node(page, 'floor')).text).toContain('FLOOR 7');
  const next = (await snapshot(page)).nodes.filter((n: Node) => n.id.startsWith('map_node_') && n.focusable);
  expect(next.map((n: Node) => n.id)).toEqual(['map_node_21', 'map_node_22']);
  await tapGameKey(page, 'KeyD', { delay: 60 });
  await state(page, 'deck');
  await click(page, 'deck_next');
  expect((await snapshot(page)).nodes.some((n: Node) => n.text === 'RELIC / MERCHANT CHARM')).toBe(true);
});

test('browser resizing keeps the selected removal card usable through scaled pointer coordinates', async ({ page }) => {
  await page.setViewportSize({ width: 1280, height: 900 });
  await preview(page, 'card_removal');
  for (let i = 0; i < 5; i++) {
    await tapGameKey(page, 'ArrowRight', { delay: 60 });
    await expect.poll(async () => (await node(page, `remove_${i + 1}`)).focused).toBe(true);
    const frame = await page.evaluate(() => (globalThis as any).__kaguraPresentation.captureTarget().renderedFrames);
    await expect.poll(() => page.evaluate(() => (globalThis as any).__kaguraPresentation.captureTarget().renderedFrames)).toBeGreaterThan(frame);
  }
  expect((await node(page, 'remove_5')).focused).toBe(true);
  await page.setViewportSize({ width: 375, height: 812 });
  await expect.poll(async () => (await page.locator('#app').boundingBox())!.width).toBeLessThanOrEqual(375);
  await expect.poll(async () => (await snapshot(page)).nodes.some((n: Node) => n.id === 'remove_5' && n.focused)).toBe(true);
  expect((await snapshot(page)).screen.width).toBe(960);
  await click(page, 'remove_5');
  await state(page, 'shop');
  expect((await node(page, 'run_gold')).text).toBe('GOLD 190');
  expect((await node(page, 'text', 'deck_btn')).text).toBe('DECK 9');
});

test('deck modal on the map returns one focus and confirm reopens it before navigation resumes', async ({ page }) => {
  await preview(page, 'map');
  await tapGameKey(page, 'KeyD', { delay: 60 });
  await state(page, 'deck');
  await tapGameKey(page, 'Escape', { delay: 60 });
  await state(page, 'map');
  expect((await snapshot(page)).nodes.filter((n: Node) => n.focused).map((n: Node) => n.id)).toEqual(['deck_btn']);
  await tapGameKey(page, 'Enter', { delay: 60 });
  await state(page, 'deck');
  await tapGameKey(page, 'Escape', { delay: 60 });
  await state(page, 'map');
  await tapGameKey(page, 'ArrowRight', { delay: 60 });
  await expect.poll(async () => (await snapshot(page)).nodes.filter((n: Node) => n.focused).map((n: Node) => n.id)).toEqual(['map_node_0']);
  await tapGameKey(page, 'Enter', { delay: 60 });
  await state(page, 'battle');
});
