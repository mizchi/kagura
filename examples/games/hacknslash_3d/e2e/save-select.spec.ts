import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
const storage=page=>page.evaluate(()=>Object.fromEntries(Object.entries(localStorage).filter(([key])=>key.startsWith('hacknslash3d_save'))));
const slot= (page,index)=>page.locator(`[data-save-slot="${index}"]`);
async function returnToSelect(page){
  await page.keyboard.press('Escape');
  await page.getByRole('button',{name:/セーブして選択画面へ/}).click();
  await expect(page.getByRole('heading',{name:'セーブデータ選択',exact:true})).toBeVisible();
}

test('startup selects independent save slots, keeps the legacy save and saves before returning from pause',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/?mute=1');
  await expect(page.getByRole('heading',{name:'セーブデータ選択',exact:true})).toBeVisible();
  await expect(page.locator('[data-save-slot]')).toHaveCount(3);
  await slot(page,0).click();
  await page.getByRole('button',{name:/刃の狩人/}).click();
  await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  await expect.poll(async()=>Object.keys(await storage(page))).toEqual(['hacknslash3d_save']);
  await page.keyboard.press('KeyX');
  await expect.poll(async()=>(await hud(page)).weapon_index).toBe(1);
  await returnToSelect(page);
  const first=(await storage(page)).hacknslash3d_save;
  await expect(slot(page,0)).toContainText('Lv. 1');
  await slot(page,1).click();await page.getByRole('button',{name:/術の狩人/}).click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  expect((await hud(page)).active_save_slot).toBe(1);
  expect((await storage(page)).hacknslash3d_save).toBe(first);
  expect((await storage(page)).hacknslash3d_save_slot_2).toBeTruthy();
  await returnToSelect(page);
  await captureGameFrame(page,{path:info.outputPath('save-select-desktop.png')});
  await page.reload();await slot(page,0).click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  expect((await hud(page)).weapon_index).toBe(1);
  expect((await hud(page)).active_save_slot).toBe(0);
  await returnToSelect(page);await slot(page,2).click();await page.keyboard.press('Escape');
  await expect(slot(page,2)).toContainText('新しく始める');
  expect((await storage(page)).hacknslash3d_save_slot_3).toBeUndefined();
  expect(errors).toEqual([]);
});

test('death resumes at a waypoint and a reload after death preserves progression and checkpoint',async({page},info)=>{
  await page.goto('/?snapshot=gameover&mute=1');
  await expect(page.getByRole('button',{name:/ウェイポイントから再開/})).toBeVisible();
  await captureGameFrame(page,{path:info.outputPath('death-checkpoint.png')});
  await page.getByRole('button',{name:/ウェイポイントから再開/}).click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  expect((await hud(page)).atlas.near_waypoint).toBe(true);
  await page.goto('/?snapshot=waypoint&region=1&seed=42&mute=1');
  await expect.poll(async()=>(await hud(page))?.atlas?.current).toBe(1);
  await returnToSelect(page);
  expect(JSON.parse(decodeURIComponent((await storage(page)).hacknslash3d_save.split('|')[18])).last_waypoint).toBe(1);
  await page.evaluate(()=>{
    const parts=localStorage.getItem('hacknslash3d_save').split('|');
    parts[1]='4321';parts[2]='8';parts[20]='dead';
    localStorage.setItem('hacknslash3d_save',parts.join('|'));
  });
  await page.goto('/?mute=1');await slot(page,0).click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  const loaded=await hud(page);
  expect(loaded.score).toBe(4321);expect(loaded.skill_points).toBe(8);
  expect(loaded.atlas.current).toBe(1);expect(loaded.atlas.near_waypoint).toBe(true);
  expect(loaded.hp).toBe(loaded.max_hp);
  expect((await storage(page)).hacknslash3d_save.split('|')[20]).toBe('alive');
});

test('a failed write keeps the session paused and allows saving again',async({page})=>{
  await page.goto('/?mute=1');await slot(page,0).click();
  await page.getByRole('button',{name:/刃の狩人/}).click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  await page.keyboard.press('Escape');
  const before=await storage(page);
  await page.evaluate(()=>{
    globalThis.__originalStorageSet=Storage.prototype.setItem;
    Storage.prototype.setItem=function(){throw new DOMException('quota','QuotaExceededError');};
  });
  await page.getByRole('button',{name:/セーブして選択画面へ/}).click();
  await expect(page.locator('.panel-pause .save-notice')).toContainText('保存できませんでした');
  expect((await hud(page)).paused).toBe(true);
  expect(await storage(page)).toEqual(before);
  await page.evaluate(()=>{Storage.prototype.setItem=globalThis.__originalStorageSet;});
  await page.getByRole('button',{name:/セーブして選択画面へ/}).click();
  await expect(page.getByRole('heading',{name:'セーブデータ選択',exact:true})).toBeVisible();
});

test('portrait saves remain usable and malformed slots are retained without being overwritten',async({page},info)=>{
  await page.setViewportSize({width:390,height:844});
  await page.addInitScript(()=>localStorage.setItem('hacknslash3d_save_slot_2','broken save'));
  await page.goto('/?mute=1');
  await expect(slot(page,1)).toBeDisabled();
  await expect(slot(page,1)).toContainText('読み込めません');
  for(const size of [{width:390,height:844},{width:320,height:640},{width:844,height:390}]){
    await page.setViewportSize(size);
    expect(await page.locator('.panel-title').evaluate(el=>el.scrollWidth<=el.clientWidth)).toBe(true);
    await slot(page,2).scrollIntoViewIfNeeded();
    const box=(await slot(page,2).boundingBox())!;
    expect(box.x).toBeGreaterThanOrEqual(0);expect(box.x+box.width).toBeLessThanOrEqual(size.width);
    expect(box.y+box.height).toBeLessThanOrEqual(size.height);
    await captureGameFrame(page,{path:info.outputPath(`save-select-${size.width}.png`)});
  }
  expect((await storage(page)).hacknslash3d_save_slot_2).toBe('broken save');
});
