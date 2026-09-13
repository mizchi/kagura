import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
const atlas=async page=>(await hud(page)).atlas;
const frame=page=>page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame);
async function go(page,url='/?snapshot=playing&frames=0&seed=42&mute=1') {
  await page.goto(url);await page.waitForFunction(()=>globalThis.__ashenHud?.mode==='playing');
}
async function holdEast(page) { await page.keyboard.down('KeyD');await page.keyboard.down('KeyS'); }
async function releaseEast(page) { await page.keyboard.up('KeyD');await page.keyboard.up('KeyS'); }

test('world map names connected regions and only reached waypoints are unlocked',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await go(page);await page.keyboard.press('KeyG');
  await expect(page.getByRole('heading',{name:'世界地図',exact:true})).toBeVisible();
  const stopped=await frame(page);
  await expect(page.locator('[data-world-region]')).toHaveCount(4);
  expect((await atlas(page)).regions.filter(r=>r.unlocked).map(r=>r.id)).toEqual([0]);
  await page.locator('[data-world-region="1"]').click();
  await expect(page.locator('.atlas-detail')).toContainText('赤錆の荒野');
  await expect(page.locator('.atlas-travel')).toBeDisabled();
  await expect(page.locator('.atlas-travel')).toContainText('未解放');
  await captureGameFrame(page,{path:info.outputPath('world-map-desktop.png')});
  expect(await frame(page)).toBe(stopped);
  await page.keyboard.press('Escape');
  await expect.poll(async()=>(await hud(page)).menu).toBe('none');
  expect(errors).toEqual([]);
});

test('walking toward the border preloads its neighbor and crosses continuously in both directions',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await go(page,'/?snapshot=border&region=0&seed=42&mute=1');
  expect((await atlas(page)).regions[1].progress).toBe(0);
  await holdEast(page);
  await expect.poll(async()=>(await atlas(page)).regions[1].progress).toBe(100);
  expect((await atlas(page)).current).toBe(0);
  expect((await hud(page)).map_x).toBeLessThan(95);
  const built=(await atlas(page)).chunks_built;
  expect(built).toBe(20);
  await expect.poll(async()=>(await hud(page)).map_x,{timeout:12000}).toBeGreaterThan(94);
  await releaseEast(page);
  await captureGameFrame(page,{path:info.outputPath('world-preloaded-border.png')});
  await page.evaluate(()=>{
    globalThis.__worldTravelSamples=[];
    const sample=()=>{
      const a=globalThis.__ashenHud.atlas;
      globalThis.__worldTravelSamples.push([a.current,a.global_x]);
      if(globalThis.__worldTravelSamples.length<90)requestAnimationFrame(sample);
    };requestAnimationFrame(sample);
  });
  await holdEast(page);
  await expect.poll(async()=>(await atlas(page)).current,{timeout:8000}).toBe(1);
  await releaseEast(page);
  expect((await atlas(page)).regions[1].unlocked).toBe(false);
  expect((await atlas(page)).chunks_built).toBe(built);
  await expect(page.locator('#region-name')).toHaveText('赤錆の荒野');
  const samples=await page.evaluate(()=>globalThis.__worldTravelSamples);
  const crossing=samples.findIndex((sample,i)=>i>0&&sample[0]!==samples[i-1][0]);
  expect(crossing).toBeGreaterThan(0);
  expect(Math.abs(samples[crossing][1]-samples[crossing-1][1])).toBeLessThan(1);
  await captureGameFrame(page,{path:info.outputPath('world-rustland-arrival.png')});
  await page.keyboard.down('KeyA');await page.keyboard.down('KeyW');
  await expect.poll(async()=>(await atlas(page)).current,{timeout:8000}).toBe(0);
  await page.keyboard.up('KeyA');await page.keyboard.up('KeyW');
  expect((await atlas(page)).chunks_built).toBe(built);
  expect((await hud(page)).remaining).toBe(0); // cleared original area stays cleared
  expect(errors).toEqual([]);
});

test('waypoint jump prepares the destination, retains unlocks and saves the current area',async({page})=>{
  await go(page,'/?snapshot=waypoint&region=1&seed=42&mute=1');
  await page.keyboard.press('KeyG');
  await page.locator('[data-world-region="0"]').click();
  await expect(page.locator('.atlas-travel')).toBeEnabled();
  const hp=(await hud(page)).hp;
  await page.locator('.atlas-travel').click();
  await expect.poll(async()=>(await atlas(page)).current).toBe(0);
  expect((await hud(page)).hp).toBe(hp);
  expect((await atlas(page)).regions.filter(r=>r.unlocked).map(r=>r.id)).toEqual([0,1]);
  await page.goto('/?mute=1&seed=42');
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  expect((await atlas(page)).current).toBe(0);
  await page.keyboard.press('KeyG');
  await page.locator('[data-world-region="1"]').click();
  await page.locator('.atlas-travel').click();
  await expect.poll(async()=>(await atlas(page)).current).toBe(1);
  await page.reload();
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  expect((await atlas(page)).current).toBe(1);
  expect((await atlas(page)).near_waypoint).toBe(true);
});

test('distant waypoints remain viewable but cannot initiate a jump',async({page})=>{
  await go(page,'/?snapshot=waypoint&region=1&seed=42&mute=1');
  await holdEast(page);
  await expect.poll(async()=>(await atlas(page)).near_waypoint).toBe(false);
  await releaseEast(page);
  await page.keyboard.press('KeyG');
  await page.locator('[data-world-region="0"]').click();
  await expect(page.locator('.atlas-travel')).toBeDisabled();
  await expect(page.locator('.atlas-travel')).toContainText('灯火の近く');
});

test.describe('touch world map',()=>{
  test.use({viewport:{width:390,height:844},isMobile:true,hasTouch:true,deviceScaleFactor:1});
  test('touch waypoint travel and world map fit portrait, narrow and landscape screens',async({page},info)=>{
    const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
    await go(page,'/?snapshot=waypoint&region=2&seed=42&mute=1');
    await page.getByRole('button',{name:'ウェイポイントを使う',exact:true}).tap();
    await page.locator('[data-world-region="0"]').tap();
    await expect(page.locator('[data-world-region="0"]')).toHaveAttribute('aria-pressed','true');
    const stopped=await frame(page);
    for(const viewport of [{width:390,height:844},{width:844,height:390},{width:320,height:640}]){
      await page.setViewportSize(viewport);
      await page.locator('.atlas-chart').scrollIntoViewIfNeeded();
      const chart=(await page.locator('.atlas-chart').boundingBox())!;
      expect(chart.x).toBeGreaterThanOrEqual(0);expect(chart.x+chart.width).toBeLessThanOrEqual(viewport.width);
      expect(await page.locator('.hunter-panel').evaluate(el=>el.scrollWidth<=el.clientWidth)).toBe(true);
      await captureGameFrame(page,{path:info.outputPath(`world-map-${viewport.width}.png`)});
    }
    expect(await frame(page)).toBe(stopped);
    await page.locator('.atlas-travel').tap();
    await expect.poll(async()=>(await atlas(page)).current).toBe(0);
    expect((await atlas(page)).near_waypoint).toBe(true);
    expect(errors).toEqual([]);
  });
});
