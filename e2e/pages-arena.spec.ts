import {test, expect} from '@playwright/test';

test('Arena shares physics and controls across first and third person', async ({page}, info) => {
  const errors: string[] = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('./arena3d/');
  const canvas = page.locator('#app');
  await expect(canvas).toBeVisible();
  const snapshot = () => page.evaluate(() => globalThis.kaguraSceneRuntime?.snapshot());
  await expect.poll(async () => (await snapshot())?.physics?.length).toBe(9);
  await canvas.focus();
  const start = await snapshot();
  await page.keyboard.press('v', {delay: 80});
  await expect.poll(async () => (await snapshot()).firstPerson).toBe(true);
  expect((await snapshot()).player).toEqual(start.player);
  await page.keyboard.down('Space');
  await expect.poll(async () => (await snapshot()).player[1]).toBeGreaterThan(start.player[1] + 0.1);
  await page.keyboard.up('Space');
  await expect.poll(async () => (await snapshot()).player[1]).toBe(start.player[1]);
  await canvas.screenshot({path: info.outputPath('arena-first-person.png')});

  // Aim through real mouse input at the uppermost crate, then shoot it.
  await expect.poll(async () => (await snapshot()).physics.some(body => body.sleeping)).toBe(true);
  const before = await snapshot();
  const target = before.physics.filter(body => body.position[0] < 0)
    .sort((a, b) => b.position[1] - a.position[1])[0];
  const [px, py, pz] = before.player;
  const [tx, ty, tz] = target.position;
  const yaw = Math.atan2(-(tx - px), -(tz - pz));
  const pitch = Math.atan2(-(ty - py - 0.8), Math.hypot(tx - px, tz - pz));
  const box = (await canvas.boundingBox())!;
  const x = box.x + box.width / 2, y = box.y + box.height / 2;
  await page.mouse.move(x, y);
  await page.mouse.down({button: 'right'});
  await expect.poll(() => page.evaluate(() => globalThis.__kaguraGfx?.lastRenderCpuMs?.() ?? 0)).toBeGreaterThan(0);
  await page.waitForTimeout(60); // register the drag anchor on a game tick
  await page.mouse.move(x - (yaw - before.camera.yaw) / 0.005, y + (pitch - before.camera.pitch) / 0.005, {steps: 8});
  await expect.poll(async () => Math.abs((await snapshot()).camera.yaw - yaw)).toBeLessThan(0.03);
  await page.mouse.up({button: 'right'});
  await page.keyboard.press('f', {delay: 80});
  await expect.poll(async () => {
    const body = (await snapshot()).physics.find(body => body.id === target.id);
    return Math.hypot(...body.position.map((value, i) => value - target.position[i]));
  }).toBeGreaterThan(0.12);

  await page.keyboard.press('v', {delay: 80});
  await expect.poll(async () => (await snapshot()).firstPerson).toBe(false);
  await page.keyboard.press('r', {delay: 80});
  await expect.poll(async () => (await snapshot()).physics.length).toBe(9);
  expect((await snapshot()).score).toBe(0);
  expect((await snapshot()).player).toEqual(start.player);
  await canvas.screenshot({path: info.outputPath('arena-third-person.png')});
  expect(errors).toEqual([]);
});
