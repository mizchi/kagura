import {expect, type Page} from '@playwright/test';

export type CardGameNode = {
  id: string; path: string; left: number; top: number; width: number; height: number;
  text?: string; focused: boolean; focusable: boolean; role: string;
};
export type CardGameSnapshot = {
  state: string; screen: {width: number; height: number}; nodes: CardGameNode[];
};

export const cardGameSnapshot = (page: Page): Promise<CardGameSnapshot | undefined> =>
  page.evaluate(() => (globalThis as any).__kaguraUISnapshot?.parsed);

export async function waitForCardGameState(page: Page, state: string) {
  await expect.poll(async () => (await cardGameSnapshot(page))?.state).toBe(state);
}

export async function cardGameNode(page: Page, id: string, parent?: string) {
  const node = (await cardGameSnapshot(page))!.nodes.find(node =>
    node.id === id && (!parent || node.path.startsWith(parent + '>')));
  expect(node, `${parent ?? ''} ${id}`).toBeTruthy();
  return node!;
}

export async function cardGamePoint(page: Page, node: CardGameNode) {
  const snapshot = (await cardGameSnapshot(page))!;
  const box = (await page.locator('#app').boundingBox())!;
  return {
    x: box.x + (node.left + node.width / 2) * box.width / snapshot.screen.width,
    y: box.y + (node.top + node.height / 2) * box.height / snapshot.screen.height,
  };
}

export async function clickCardGameNode(page: Page, id: string) {
  const point = await cardGamePoint(page, await cardGameNode(page, id));
  await page.mouse.click(point.x, point.y, {delay: 80});
}

export async function startCardGameAdventure(page: Page) {
  await waitForCardGameState(page, 'title');
  for (const state of ['character_select', 'map']) {
    await clickCardGameNode(page, 'scene_choice_0');
    await waitForCardGameState(page, state);
  }
}
