import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

const scene='/?snapshot=terrain&terrain=perlin&seed=42&mute=1';
const terrain=page=>page.evaluate(()=>globalThis.__ashenHud?.terrain);
const frame=page=>page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame);

test('terrain lab compares seeded algorithms without moving the world, and restores preferences',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto(scene);
  await expect.poll(async()=>(await terrain(page))?.pattern).toBe(1);
  await page.keyboard.press('KeyN');
  const panel=page.getByRole('dialog',{name:'地形実験',exact:true});
  await expect(panel).toBeVisible();
  const stopped=await frame(page);
  const original=await page.evaluate(()=>globalThis.__ashenHunt);
  const maxima=[];
  for(const [index,name] of ['平坦','Perlin','Diamond Square','Voronoi','Voronoi + Perlin'].entries()){
    await panel.getByRole('button',{name,exact:true}).click();
    await expect.poll(async()=>(await terrain(page)).pattern).toBe(index);
    const state=await terrain(page);
    expect(state.seed).toBe(42);
    expect(state.stats.max_slope).toBeLessThanOrEqual(.637);
    if(index===0)expect(state.stats.maximum).toBe(0);
    else {expect(state.stats.maximum).toBeGreaterThan(1);maxima.push(state.stats.maximum);}
    expect(await frame(page)).toBe(stopped);
    const now=await page.evaluate(()=>globalThis.__ashenHunt);
    expect(now.x).toBe(original.x);expect(now.y).toBe(original.y);expect(now.yaw).toBe(original.yaw);
    await captureGameFrame(page,{path:info.outputPath(`terrain-${index}.png`)});
  }
  expect(new Set(maxima.map(v=>v.toFixed(4))).size).toBeGreaterThan(2);
  await panel.getByRole('button',{name:'次のシード',exact:true}).click();
  await expect.poll(async()=>(await terrain(page)).seed).toBe(43);
  const range=panel.getByRole('slider',{name:'起伏の高さ',exact:true});
  await range.evaluate(element=>{(element as HTMLInputElement).value='6';element.dispatchEvent(new Event('input',{bubbles:true}));});
  expect((await terrain(page)).amplitude).toBe(4);
  await panel.getByRole('button',{name:'生成して比較',exact:true}).click();
  await expect.poll(async()=>(await terrain(page)).amplitude).toBe(6);
  await panel.getByRole('button',{name:'カメラ設定',exact:true}).click();
  await expect(page.getByRole('dialog',{name:'カメラ設定',exact:true})).toBeVisible();
  await page.getByRole('button',{name:'地形実験',exact:true}).click();
  await expect(panel).toBeVisible();
  await page.keyboard.press('Escape');
  await expect(page.getByRole('dialog',{name:'一時停止メニュー',exact:true})).toBeVisible();
  expect(await frame(page)).toBe(stopped);
  await page.goto('/?snapshot=terrain&mute=1');
  await expect.poll(async()=>(await terrain(page))?.pattern).toBe(4);
  expect((await terrain(page)).seed).toBe(43);
  expect((await terrain(page)).amplitude).toBe(6);
  expect(errors).toEqual([]);
});

test('TPS moves over elevated ground and can aim a ground strike there',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto(scene);
  await expect.poll(async()=>(await terrain(page))?.player_height).toBeGreaterThan(.2);
  const before=await page.evaluate(()=>({player:globalThis.__ashenHunt,height:globalThis.__ashenHud.terrain.player_height}));
  await page.keyboard.press('KeyZ');
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud?.camera.mode)).toBe(1);
  await page.keyboard.down('KeyW');await page.waitForTimeout(350);await page.keyboard.up('KeyW');
  const after=await page.evaluate(()=>({player:globalThis.__ashenHunt,height:globalThis.__ashenHud.terrain.player_height}));
  expect(Math.hypot(after.player.x-before.player.x,after.player.y-before.player.y)).toBeGreaterThan(1);
  expect(Math.abs(after.height-before.height)).toBeGreaterThan(.001);
  await page.mouse.move(580,450);
  await page.keyboard.press('KeyT');
  await expect(page.locator('#target-hint')).toBeVisible();
  await captureGameFrame(page,{path:info.outputPath('terrain-tps-target.png')});
  await page.mouse.click(640,520);
  await expect(page.locator('#target-hint')).toBeHidden();
  expect(errors).toEqual([]);
});

test.describe('mobile terrain lab',()=>{
  test.use({viewport:{width:390,height:844},hasTouch:true,isMobile:true,deviceScaleFactor:1});
  test('portrait reserves a visible preview and can change terrain by touch',async({page},info)=>{
    await page.goto(scene);
    await page.getByRole('button',{name:'一時停止メニュー',exact:true}).tap();
    await page.getByRole('button',{name:'地形実験 N',exact:true}).tap();
    const panel=page.getByRole('dialog',{name:'地形実験',exact:true});
    await panel.getByRole('button',{name:'Voronoi',exact:true}).tap();
    await expect.poll(async()=>(await terrain(page)).pattern).toBe(3);
    const preview=(await page.locator('#app').boundingBox())!;
    const settings=(await panel.boundingBox())!;
    expect(preview.y+preview.height).toBeLessThanOrEqual(settings.y+1);
    expect(settings.x).toBeGreaterThanOrEqual(0);
    expect(settings.x+settings.width).toBeLessThanOrEqual(390);
    await captureGameFrame(page,{path:info.outputPath('terrain-mobile.png')});
    await panel.getByRole('button',{name:'冒険を再開する',exact:true}).tap();
    await expect(panel).toHaveCount(0);
  });
});
