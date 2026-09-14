import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);

test('exploration terrain, local return travel and permanent cache unlocks',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/?snapshot=site&site=ruins&peaceful=1&seed=42&mute=1');
  await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  await expect.poll(async()=>(await hud(page)).terrain.pattern).toBe(5);
  expect((await hud(page)).terrain.player_height).toBeGreaterThan(1);
  await captureGameFrame(page,{path:info.outputPath('expedition-ruins.png')});
  await page.keyboard.press('KeyB');
  await expect.poll(async()=>(await hud(page)).exploration.chests[0].opened).toBe(true);
  await page.keyboard.press('KeyG');
  await expect(page.getByRole('region',{name:'地域の探索進行'})).toBeVisible();
  await expect(page.locator('.expedition-heading')).toContainText('解放 1 / 4');
  const map=(await hud(page)).atlas.expedition;
  expect(map.report.unreachable_targets).toBe(0);
  expect(map.report.max_walk_slope).toBeLessThanOrEqual(.72);
  expect(map.report.ground_triangles).toBe(16000);
  await expect(page.locator('[data-expedition-site="0"]')).toBeEnabled();
  await expect(page.locator('[data-expedition-site="1"]')).toBeDisabled();
  await page.locator('.atlas-expedition').scrollIntoViewIfNeeded();
  await captureGameFrame(page,{path:info.outputPath('expedition-map.png')});
  await page.locator('.atlas-travel').click();
  await expect.poll(async()=>(await hud(page)).menu).toBe('none');
  await expect.poll(async()=>(await hud(page)).atlas.at_region_waypoint).toBe(true);
  await page.keyboard.press('KeyG');
  await page.locator('[data-expedition-site="0"]').click();
  await expect.poll(async()=>(await hud(page)).menu).toBe('none');
  expect((await hud(page)).terrain.player_height).toBeGreaterThan(1);
  await page.goto('/?mute=1&seed=42');
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  expect((await hud(page)).exploration.chests[0].opened).toBe(true);
  expect((await hud(page)).terrain.pattern).toBe(5);
  await page.keyboard.press('KeyN');
  await page.getByRole('button',{name:'平坦',exact:true}).click();
  await expect.poll(async()=>(await hud(page)).terrain.pattern).toBe(0);
  expect((await hud(page)).terrain.stats.maximum).toBe(0);
  await page.getByRole('button',{name:'探索地形',exact:true}).click();
  await expect.poll(async()=>(await hud(page)).terrain.pattern).toBe(5);
  expect((await hud(page)).terrain.player_height).toBeGreaterThan(1);
  expect(errors).toEqual([]);
});

test('expedition routes and controls fit portrait and landscape',async({page},info)=>{
  await page.goto('/?snapshot=playing&frames=0&seed=43&mute=1');
  await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  await page.keyboard.press('KeyG');
  await expect.poll(async()=>(await hud(page)).menu).toBe('waypoints');
  for(const viewport of [{width:390,height:844},{width:844,height:390},{width:320,height:640}]){
    await page.setViewportSize(viewport);
    await page.locator('.atlas-expedition').scrollIntoViewIfNeeded();
    expect(await page.locator('.hunter-panel').evaluate(el=>el.scrollWidth<=el.clientWidth)).toBe(true);
    await page.locator('[data-expedition-site="3"]').scrollIntoViewIfNeeded();
    const rect=await page.locator('[data-expedition-site="3"]').boundingBox();
    expect(rect!.x).toBeGreaterThanOrEqual(0);
    expect(rect!.x+rect!.width).toBeLessThanOrEqual(viewport.width);
    await captureGameFrame(page,{path:info.outputPath(`expedition-${viewport.width}.png`)});
  }
});
