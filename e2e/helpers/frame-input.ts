import {expect, type Page} from '@playwright/test';

// Game input is sampled once per rendered frame. Wait for both the press and
// release to be observed rather than assuming a fixed browser frame rate.
async function nextFrame(page: Page) {
  const frames = () => page.evaluate(() =>
    (globalThis as any).__kaguraPresentation.captureTarget().renderedFrames);
  const before = await frames();
  await expect.poll(frames, {intervals: [5]}).toBeGreaterThan(before);
}

export async function tapGameKey(page: Page, chord: string, options: {delay?: number} = {}) {
  const keys = chord.split('+');
  for (const key of keys) await page.keyboard.down(key);
  await nextFrame(page);
  if (options.delay) await page.waitForTimeout(options.delay);
  for (const key of keys.toReversed()) await page.keyboard.up(key);
  await nextFrame(page);
}

export async function clickGamePoint(page: Page, point: {x: number; y: number}) {
  await page.mouse.move(point.x, point.y);
  await page.mouse.down();
  await nextFrame(page);
  await page.mouse.up();
  await nextFrame(page);
}
