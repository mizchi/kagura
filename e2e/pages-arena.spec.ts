import {test, expect} from '@playwright/test';

for (const firstPerson of [false, true]) {
  test(`shots remain visible in flight and hit on arrival (${firstPerson ? 'FPS' : 'TPS'})`, async ({page}, info) => {
    const errors: string[] = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.addInitScript(() => {
      globalThis.__kaguraScene = {
        game: 'arena3d', data: {version: 1, entities: [
          {id: 'floor', kind: 'floor', position: [0, -0.125, 0], scale: [18, 0.25, 24], color: 6649958, target: ''},
          {id: 'spawn', kind: 'spawn', position: [0, 0.5, 5], scale: [1, 1, 1], color: 4508774, target: ''},
          {id: 'crate', kind: 'crate', position: [0, 1, -5], scale: [2, 2, 2], color: 13398616, target: ''},
        ]},
      };
    });
    await page.goto('./arena3d/');
    const canvas = page.locator('#app');
    await expect(canvas).toBeVisible();
    await canvas.focus();
    const snapshot = () => page.evaluate(() => globalThis.kaguraSceneRuntime?.snapshot());
    await expect.poll(async () => (await snapshot())?.sceneId).toBe('preview');
    if (firstPerson) await page.keyboard.press('v', {delay: 60});
    await expect.poll(async () => (await snapshot()).firstPerson).toBe(firstPerson);
    const box = (await canvas.boundingBox())!;
    const x = box.x + box.width / 2, y = box.y + box.height / 2;
    const before = await snapshot();
    await page.mouse.move(x, y);
    await page.mouse.down({button: 'right'});
    await page.waitForTimeout(60);
    await page.mouse.move(x, y - before.camera.pitch / 0.005, {steps: 4});
    await page.mouse.up({button: 'right'});
    await expect.poll(async () => Math.abs((await snapshot()).camera.pitch)).toBeLessThan(0.02);
    await page.keyboard.press('f', {delay: 40});
    await expect.poll(async () => (await snapshot()).shots.length, {intervals: [20]}).toBe(1);
    const early = await snapshot();
    expect(early.shots[0].impactFrames).toBe(0);
    expect(early.shots[0].position[0]).toBeGreaterThan(early.player[0] + 0.2);
    expect(Math.abs(early.physics.find(body => body.id === 2).velocity[2])).toBeLessThan(0.01);
    await expect.poll(async () => (await snapshot()).shots[0]?.position[2], {intervals: [20]}).toBeLessThan(early.shots[0].position[2] - 0.8);
    await canvas.screenshot({path: info.outputPath('shot-flight.png')});
    await expect.poll(async () => (await snapshot()).shots[0]?.impactFrames ?? 0, {intervals: [20]}).toBeGreaterThan(0);
    await canvas.screenshot({path: info.outputPath('shot-impact.png')});
    await expect.poll(async () => (await snapshot()).physics.find(body => body.id === 2).position[2]).toBeLessThan(-5.1);
    await expect.poll(async () => (await snapshot()).shots.length).toBe(0);
    expect(errors).toEqual([]);
  });
}

test('Arena shares physics and controls across first and third person', async ({page}, info) => {
  const errors: string[] = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('./arena3d/');
  const canvas = page.locator('#app');
  await expect(canvas).toBeVisible();
  const snapshot = () => page.evaluate(() => globalThis.kaguraSceneRuntime?.snapshot());
  await expect.poll(async () => (await snapshot())?.physics?.length).toBe(10);
  await canvas.focus();
  const start = await snapshot();
  await page.keyboard.press('v', {delay: 80});
  await expect.poll(async () => (await snapshot()).firstPerson).toBe(true);
  expect(Math.hypot(...(await snapshot()).player.map((value, i) => value - start.player[i]))).toBeLessThan(0.02);
  await page.keyboard.down('Space');
  await expect.poll(async () => (await snapshot()).player[1]).toBeGreaterThan(start.player[1] + 0.1);
  await page.keyboard.up('Space');
  await expect.poll(async () => (await snapshot()).grounded).toBe(true);
  expect(Math.abs((await snapshot()).player[1] - start.player[1])).toBeLessThan(0.02);
  await canvas.screenshot({path: info.outputPath('arena-first-person.png')});

  // Aim through real mouse input at the uppermost crate, then shoot it.
  await expect.poll(async () => (await snapshot()).physics.some(body => body.sleeping)).toBe(true);
  const before = await snapshot();
  const crateIds = before.scene.entities.flatMap((entity, index) => entity.kind === 'crate' ? [index] : []);
  const target = before.physics.filter(body => crateIds.includes(body.id))
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
  await expect.poll(async () => (await snapshot()).physics.length).toBe(10);
  expect((await snapshot()).score).toBe(0);
  expect(Math.hypot(...(await snapshot()).player.map((value, i) => value - start.player[i]))).toBeLessThan(0.02);
  await expect.poll(async () => (await snapshot()).rainCount).toBeGreaterThanOrEqual(3);
  const raining = await snapshot();
  expect(raining.scene.entities.filter(entity => entity.id.startsWith('rail-')).every(entity => entity.scale[1] >= 3)).toBe(true);
  expect(raining.scene.entities.some(entity => entity.kind === 'slide')).toBe(true);
  expect(raining.physics.filter(body => crateIds.includes(body.id)).every(body => body.position[1] >= 0.42)).toBe(true);
  expect(raining.physics.length).toBeLessThanOrEqual(10 + raining.rainCapacity);
  await canvas.screenshot({path: info.outputPath('arena-third-person.png')});
  expect(errors).toEqual([]);
});

test('a falling ball knocks the player aside and real input can resist it', async ({page}, info) => {
  const errors: string[] = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.addInitScript(() => {
    globalThis.__kaguraVrtReadbackEnabled = true;
    globalThis.__kaguraScene = {
      game: 'arena3d', data: {version: 1,
      entities: [
        {id: 'floor', kind: 'floor', position: [0, -0.125, 0], scale: [18, 0.25, 18], color: 6649958, target: ''},
        {id: 'spawn', kind: 'spawn', position: [0, 0.5, 5], scale: [1, 1, 1], color: 4508774, target: ''},
        {id: 'ball', kind: 'ball', position: [0.65, 4, 5], scale: [1, 1, 1], color: 5490648, target: ''},
      ]},
    };
  });
  await page.goto('./arena3d/');
  const canvas = page.locator('#app');
  await expect(canvas).toBeVisible();
  await canvas.focus();
  const snapshot = () => page.evaluate(() => globalThis.kaguraSceneRuntime?.snapshot());
  await expect.poll(async () => (await snapshot())?.sceneId).toBe('preview');
  expect(errors).toEqual([]);
  await expect.poll(async () => (await snapshot()).playerVelocity[0], {intervals: [30]}).toBeLessThan(-0.3);
  await expect.poll(async () => (await snapshot()).player[0]).toBeLessThan(-0.05);
  await canvas.screenshot({path: info.outputPath('player-knockback.png')});
  const pushed = await snapshot();
  await page.keyboard.down('d');
  await expect.poll(async () => (await snapshot()).playerVelocity[0]).toBeGreaterThan(0.5);
  await expect.poll(async () => (await snapshot()).player[0]).toBeGreaterThan(pushed.player[0] + 0.1);
  await page.keyboard.up('d');
  await canvas.screenshot({path: info.outputPath('player-recovery.png')});
  const recovered = await snapshot();
  await info.attach('physics-state', {body: JSON.stringify(recovered, null, 2), contentType: 'application/json'});
  // Metal's canvas capture can omit layers. Verify completed GPU textures,
  // with a new readback each time, while the character finishes recovering.
  let lastReadback = 0;
  const coverage: number[] = [];
  for (let frame = 0; frame < 20; frame++) {
    await expect.poll(() => page.evaluate(() => globalThis.__kaguraGfx?.lastReadbackSummary?.()?.id ?? 0), {intervals: [20]}).toBeGreaterThan(lastReadback);
    const readback = await page.evaluate(() => globalThis.__kaguraGfx.lastReadbackSummary());
    lastReadback = readback.id;
    coverage.push(readback.nonDarkPixelRatio);
    expect(readback.nonTransparentPixelRatio).toBeGreaterThan(0.99);
    expect(readback.nonDarkPixelRatio).toBeGreaterThan(0.5);
  }
  await info.attach('gpu-coverage', {body: JSON.stringify(coverage), contentType: 'application/json'});
  const body = recovered.physics.find(body => body.id === recovered.playerBodyId);
  expect(body.position).toEqual(recovered.player);
  expect(recovered.player[1]).toBeGreaterThan(0.45);
  expect(errors).toEqual([]);
});
