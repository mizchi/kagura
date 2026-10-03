import {test, expect} from '@playwright/test';
import {writeFileSync} from 'node:fs';
import {captureGameFrame} from '../scripts/capture-web.mjs';
import {
  cardGameSnapshot, cardGameNode, cardGamePoint, clickCardGameNode,
  startCardGameAdventure, waitForCardGameState,
} from './helpers/card-game-pages';

for (const viewport of [{width: 1280, height: 900}, {width: 390, height: 844}]) {
  test(`published Ember Ascent plays the branching adventure at ${viewport.width}px`, async ({page}, info) => {
    await page.setViewportSize(viewport);
    const capture = async (name: string) => {
      await captureGameFrame(page, {path: info.outputPath(`published-${name}.png`)});
      writeFileSync(info.outputPath(`published-${name}.snapshot.json`),
        JSON.stringify(await cardGameSnapshot(page), null, 2));
    };
    const errors: string[] = [];
    const failedAssets: string[] = [];
    page.on('pageerror', error => errors.push(error.message));
    page.on('response', response => {
      if (response.status() >= 400 && /\.(?:js|mjs|css|wasm|ttf)(?:\?|$)/.test(response.url())) {
        failedAssets.push(`${response.status()} ${response.url()}`);
      }
    });
    await page.goto('./examples/');
    await page.getByRole('link', {name: 'Play Ember Ascent', exact: true}).click();
    await expect(page).toHaveURL(/\/kagura\/card_game\/$/);
    await expect(page).toHaveTitle(/Ember Ascent/);
    // Production must start at the title, even when a debug fixture is requested.
    await page.goto('./card_game/?preview=unique_reward');
    await startCardGameAdventure(page);
    expect(await page.locator('#app').evaluate(canvas => getComputedStyle(canvas).imageRendering)).toBe('pixelated');
    const snapshot = (await cardGameSnapshot(page))!;
    expect(snapshot.nodes.filter(node => /^map_node_\d+$/.test(node.id) && node.focusable)
      .map(node => node.id)).toEqual(['map_node_0', 'map_node_1', 'map_node_2']);
    expect((await cardGameNode(page, 'run_gold')).text).toBe('GOLD 99');
    await capture('map');
    await clickCardGameNode(page, 'map_node_0');
    await waitForCardGameState(page, 'battle');
    expect((await cardGameNode(page, 'floor')).text).toContain('FLOOR 1');
    const hero = await cardGameNode(page, 'player');
    const enemy = await cardGameNode(page, 'enemy_body_0');
    expect(hero.left + hero.width).toBeLessThan(enemy.left);
    expect((await cardGameNode(page, 'energy')).text).toBe('ENERGY 3/3');

    await clickCardGameNode(page, 'draw_pile_btn');
    await waitForCardGameState(page, 'draw_pile');
    expect((await cardGameSnapshot(page))!.nodes.some(node => node.id === 'end_turn_btn')).toBe(false);
    await page.keyboard.press('Tab', {delay: 80});
    await expect(page.locator('#app')).toBeFocused();
    await page.keyboard.press('Escape', {delay: 80});
    await waitForCardGameState(page, 'battle');

    const hand = (await cardGameSnapshot(page))!.nodes.filter(node => /^card_frame_\d+$/.test(node.id));
    let attack = hand[0];
    for (const card of hand) {
      if (/^(STRIKE|BASH)$/.test((await cardGameNode(page, 'name_0', card.path)).text ?? '')) {
        attack = card;
        break;
      }
    }
    expect((await cardGameNode(page, 'name_0', attack.path)).text).toMatch(/^(STRIKE|BASH)$/);
    const before = (await cardGameNode(page, 'value', enemy.path + '>hp')).text;
    const from = await cardGamePoint(page, attack);
    const to = await cardGamePoint(page, enemy);
    await page.mouse.move(from.x, from.y);
    await page.mouse.down();
    await expect.poll(async () => (await cardGameSnapshot(page))!.nodes.some(node =>
      node.id === 'hint' && node.text?.startsWith('DROP ON'))).toBe(true);
    await page.mouse.move(to.x, to.y, {steps: 12});
    await waitForCardGameState(page, 'dragging');
    await page.mouse.up();
    await waitForCardGameState(page, 'battle');
    expect((await cardGameNode(page, 'value', enemy.path + '>hp')).text).not.toBe(before);
    expect((await cardGameSnapshot(page))!.nodes.filter(node => /^card_frame_\d+$/.test(node.id))).toHaveLength(hand.length - 1);
    await capture('battle');
    await page.keyboard.press('KeyE', {delay: 80});
    await expect.poll(async () => (await cardGameNode(page, 'turn')).text).toContain('TURN 2');
    await waitForCardGameState(page, 'battle');
    expect((await cardGameNode(page, 'energy')).text).toBe('ENERGY 3/3');
    const box = (await page.locator('#app').boundingBox())!;
    const screen = (await cardGameSnapshot(page))!.screen;
    const width = Math.min(viewport.width, (viewport.height - 48) * screen.width / screen.height);
    expect(box.width).toBeCloseTo(width, 1);
    expect(box.height).toBeCloseTo(width * screen.height / screen.width, 1);
    expect(box.y).toBeGreaterThanOrEqual(48);
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
    expect(failedAssets).toEqual([]);
    expect(errors).toEqual([]);
  });
}
