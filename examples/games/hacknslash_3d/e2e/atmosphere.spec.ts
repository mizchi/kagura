import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);

test.beforeEach(async({page})=>{
  await page.addInitScript(()=>{
    globalThis.__atmosphereErrors=[];
    const request=GPUAdapter.prototype.requestDevice;
    GPUAdapter.prototype.requestDevice=async function(...args){
      const device=await request.apply(this,args);
      device.addEventListener('uncapturederror',e=>globalThis.__atmosphereErrors.push(e.error.message));
      return device;
    };
  });
});

test('TPS reveals the player through masonry and rotates without collapsing its boom',async({page},info)=>{
  await page.goto('/?snapshot=landscape&landmark=occlusion&seed=42&mute=1');
  await expect.poll(async()=>(await hud(page))?.camera.mode).toBe(1);
  await expect.poll(async()=>(await hud(page)).camera.effective_distance).toBeGreaterThan(4.4);
  await captureGameFrame(page,{path:info.outputPath('tps-through-wall.png')});
  const start=await page.evaluate(()=>globalThis.__ashenHunt.yaw);
  await page.keyboard.down('KeyQ');
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.yaw)).toBeGreaterThan(start+Math.PI);
  await page.keyboard.up('KeyQ');
  expect((await hud(page)).camera.effective_distance).toBeGreaterThan(2);
  await captureGameFrame(page,{path:info.outputPath('tps-rotated.png')});
  expect(await page.evaluate(()=>globalThis.__atmosphereErrors)).toEqual([]);
});

test('a resting camp notices an approach, stands up and begins combat',async({page},info)=>{
  await page.goto('/?snapshot=camp&seed=42&mute=1');
  await expect.poll(async()=>(await hud(page))?.resting_enemies).toBeGreaterThan(0);
  const resting=(await hud(page)).resting_enemies;
  await page.waitForTimeout(500);
  expect((await hud(page)).resting_enemies).toBe(resting);
  await captureGameFrame(page,{path:info.outputPath('resting-camp.png')});
  await page.keyboard.down('KeyW');
  await expect.poll(async()=>(await hud(page)).waking_enemies,{intervals:[50],timeout:8000}).toBeGreaterThan(0);
  await page.keyboard.up('KeyW');
  await captureGameFrame(page,{path:info.outputPath('camp-standing-up.png')});
  await expect.poll(async()=>(await hud(page)).resting_enemies).toBe(0);
  await expect.poll(async()=>(await hud(page)).waking_enemies).toBe(0);
  await captureGameFrame(page,{path:info.outputPath('alerted-camp.png')});
  expect(await page.evaluate(()=>globalThis.__atmosphereErrors)).toEqual([]);
});

test('woodland and relics render in a wide low-poly landscape',async({page},info)=>{
  await page.goto('/?snapshot=landscape&landmark=woodland&seed=42&mute=1');
  await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  await captureGameFrame(page,{path:info.outputPath('woodland.png')});
  expect(await page.evaluate(()=>globalThis.__atmosphereErrors)).toEqual([]);
});
