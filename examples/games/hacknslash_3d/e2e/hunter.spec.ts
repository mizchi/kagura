import { test, expect } from '@playwright/test';
import { PNG } from 'pngjs';
import { captureGameFrame } from '../../../../scripts/capture-web.mjs';
const snapshot = page => page.evaluate(() => globalThis.__ashenHunt);

test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status === testInfo.expectedStatus) return;
  try {
    const body=await captureGameFrame(page,{timeout:3000});
    await testInfo.attach('game-failure',{body,contentType:'image/png'});
  } catch { /* Startup failures have no initialized game surface to capture. */ }
});

test('engine fills the viewport and captures only the game after landscape and portrait resizes', async ({ page }, testInfo) => {
  await page.goto('/?snapshot=playing&frames=0&mute=1');
  await page.waitForFunction(() => globalThis.__ashenHunt?.bones === 14);
  const canvas = page.locator('canvas');
  expect(await canvas.boundingBox()).toEqual({x:0,y:0,width:1280,height:900});
  await page.setViewportSize({width:1600,height:900});
  await expect.poll(() => canvas.boundingBox()).toEqual({x:0,y:0,width:1600,height:900});
  // Even chrome overlapping the canvas must be excluded from the engine capture.
  await page.evaluate(() => {
    const overlay=document.createElement('div');
    overlay.setAttribute('data-kagura-overlay','');
    overlay.id='capture-overlay-fixture';
    overlay.style.cssText='position:fixed;inset:0;background:rgb(255,0,255);z-index:999';
    document.body.appendChild(overlay);
  });
  const screenshot=await captureGameFrame(page,{path:testInfo.outputPath('hunter-fullscreen.png')});
  const png=PNG.sync.read(screenshot);
  expect([png.width,png.height]).toEqual([1600,900]);
  const middle=(Math.floor(png.height/2)*png.width+Math.floor(png.width/2))*4;
  expect([...png.data.slice(middle,middle+3)]).not.toEqual([255,0,255]);
  await expect(page.locator('#capture-overlay-fixture')).toBeVisible();
  await page.setViewportSize({width:600,height:900});
  await expect.poll(() => canvas.boundingBox()).toEqual({x:0,y:0,width:600,height:900});
  const portrait=PNG.sync.read(await captureGameFrame(page,{path:testInfo.outputPath('hunter-portrait.png')}));
  expect([portrait.width,portrait.height]).toEqual([600,900]);
  await page.locator('#capture-overlay-fixture').evaluate(element=>element.remove());
  await page.setViewportSize({width:1280,height:900});
  await page.getByRole('button',{name:'全画面',exact:true}).click();
  await expect.poll(()=>page.evaluate(()=>document.fullscreenElement !== null)).toBe(true);
  await page.evaluate(()=>document.exitFullscreen());
});

test('hunter can run, attack, dodge, orbit, zoom and pause in the actual dungeon', async ({ page }, testInfo) => {
  const errors: string[] = [];
  page.on('pageerror', e => errors.push(e.message));
  await page.goto('/?snapshot=playing&frames=0&mute=1');
  await page.waitForFunction(() => globalThis.__ashenHunt?.bones === 14);
  const canvas = page.locator('canvas');
  await expect(canvas).toBeVisible();
  await expect(page).toHaveTitle(/ASHEN HUNT/);
  const start = await snapshot(page);
  expect(start.materials).toBe(7);
  const box = (await canvas.boundingBox())!;
  await page.mouse.move(box.x+box.width*.7,box.y+box.height*.6);
  await page.keyboard.down('d');
  await expect.poll(async () => {const s=await snapshot(page);return Math.hypot(s.x-start.x,s.y-start.y);}).toBeGreaterThan(5);
  await page.mouse.down();
  await expect.poll(async () => (await snapshot(page)).attacks).toBeGreaterThan(0);
  await page.mouse.up();
  await page.keyboard.press('Space', {delay:90});
  await expect.poll(async () => (await snapshot(page)).dodges).toBe(1);
  await page.keyboard.up('d');
  await expect.poll(async () => (await snapshot(page)).animation).toBe('idle');
  await page.keyboard.down('q');
  await expect.poll(async () => (await snapshot(page)).yaw).toBeLessThan(start.yaw-.1);
  await page.keyboard.up('q');
  await page.mouse.wheel(0,-200);
  await expect.poll(async () => (await snapshot(page)).distance).toBeLessThan(start.distance);
  await page.keyboard.press('r', {delay:90});
  await expect.poll(async () => (await snapshot(page)).distance).toBe(18);
  await page.keyboard.press('p');
  await expect.poll(async () => (await snapshot(page)).paused).toBe(true);
  const paused = await snapshot(page);
  await page.keyboard.down('w');
  await page.waitForTimeout(200);
  await page.keyboard.up('w');
  const still = await snapshot(page);
  expect([still.x,still.y]).toEqual([paused.x,paused.y]);
  await page.keyboard.press('p');
  await expect.poll(async () => (await snapshot(page)).paused).toBe(false);
  const screenshot = await captureGameFrame(page,{path:testInfo.outputPath('hunter-gameplay.png')});
  const png = PNG.sync.read(screenshot);
  const colors = new Set();
  for (let y=Math.floor(png.height*.25); y<png.height*.75; y+=3) {
    for (let x=Math.floor(png.width*.25); x<png.width*.75; x+=3) {
      const i=(y*png.width+x)*4;
      colors.add([png.data[i]>>3,png.data[i+1]>>3,png.data[i+2]>>3].join(','));
    }
  }
  expect(colors.size, 'the rendered game must contain geometry, not a blank canvas').toBeGreaterThan(30);
  expect(errors).toEqual([]);
});

test('normal title flow starts the hunter and inventory can be closed', async ({ page }, testInfo) => {
  await page.goto('/?mute=1');
  await page.waitForFunction(() => globalThis.__hacknslash3dRuntime?.mode === 'title');
  await page.keyboard.press('Space', {delay:90});
  await page.waitForFunction(() => globalThis.__hacknslash3dRuntime?.mode === 'character_select');
  const releasedAt = await page.evaluate(() => globalThis.__hacknslash3dRuntime.frame);
  await page.waitForFunction(frame => globalThis.__hacknslash3dRuntime.frame > frame + 3, releasedAt);
  await page.keyboard.press('Space', {delay:90});
  await page.waitForFunction(() => globalThis.__hacknslash3dRuntime?.mode === 'playing');
  await page.keyboard.press('i', {delay:90});
  await page.keyboard.press('Escape', {delay:90});
  await page.keyboard.down('j');
  await expect.poll(async () => (await snapshot(page)).attacks).toBeGreaterThan(0);
  await page.keyboard.up('j');
  await captureGameFrame(page,{path:testInfo.outputPath('hunter-attack.png')});
});
