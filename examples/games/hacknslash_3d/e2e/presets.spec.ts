import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
const primary=(page,index)=>page.locator(`[data-skill="${index}"]`);
async function mage(page){
  await page.goto('/?mute=1');
  await page.locator('[data-save-slot="0"]').click();
  await page.getByRole('button',{name:/魔法使い/}).click();
  await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
}

test('mage starts with lightning and ground blast, keyboard slots cast them and presets persist',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await mage(page);
  await expect(primary(page,0)).toContainText('連鎖雷撃');
  await expect(primary(page,1)).toContainText('星落とし');
  await expect(primary(page,1)).not.toHaveAttribute('data-hold');
  await expect(page.locator('#player-weapon')).toHaveValue('3');
  await expect(page.locator('#astral-button')).toBeHidden();
  await expect(page.locator('#learned-arts [data-key="53"]')).toHaveCount(0);
  await page.keyboard.press('Digit1');
  await expect.poll(async()=>(await hud(page)).skills[0].remaining).toBeGreaterThan(0);
  await expect(primary(page,1)).toBeEnabled();
  await page.keyboard.press('Digit2');
  await expect(page.locator('#target-surface')).toBeVisible();
  expect((await hud(page)).arts.whirling).toBe(false);
  await page.keyboard.press('Escape');
  await expect(page.locator('#target-surface')).toBeHidden();
  expect((await hud(page)).arts.ground_remaining).toBe(0);
  await page.keyboard.press('Digit2');
  await page.locator('#target-surface').click({position:{x:760,y:430}});
  await expect.poll(async()=>(await hud(page)).skills[1].remaining).toBeGreaterThan(0);
  await expect.poll(async()=>(await hud(page)).arts.action).toBe('none');
  await page.keyboard.press('Escape');
  const points=(await hud(page)).skill_points;
  await page.getByLabel('武器と技のプリセット',{exact:true}).selectOption('0');
  await expect.poll(async()=>(await hud(page)).preset).toBe(0);
  expect((await hud(page)).weapon_index).toBe(0);
  expect((await hud(page)).skill_points).toBe(points);
  await captureGameFrame(page,{path:info.outputPath('preset-menu.png')});
  await page.getByRole('button',{name:/セーブして選択画面へ/}).click();
  await page.reload();await page.locator('[data-save-slot="0"]').click();
  await expect(primary(page,1)).toContainText('ワールウィンド');
  expect((await hud(page)).preset).toBe(0);
  await page.keyboard.down('Digit2');
  await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
  await page.keyboard.up('Digit2');
  expect(await page.evaluate(()=>globalThis.__kaguraWebRuntime.pressedKeys)).not.toContain(50);
  await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
  expect(errors).toEqual([]);
});

test('mage pad uses triangle for lightning, R2 to aim, and cross to confirm',async({page})=>{
  await page.addInitScript(()=>{
    globalThis.__testPad={index:0,id:'Standard preset test',mapping:'standard',connected:true,axes:[0,0,0,0],buttons:Array.from({length:17},()=>({pressed:false,value:0}))};
    Object.defineProperty(navigator,'getGamepads',{value:()=>[globalThis.__testPad]});
  });
  const press=async button=>{
    await page.evaluate(i=>{globalThis.__testPad.buttons[i]={pressed:true,value:1};},button);
    await page.waitForTimeout(80);
    await page.evaluate(i=>{globalThis.__testPad.buttons[i]={pressed:false,value:0};},button);
    await page.waitForTimeout(80);
  };
  await mage(page);
  await expect(page.locator('#gamepad-connection')).toContainText('操作できます');
  await press(3);
  await expect.poll(async()=>(await hud(page)).skills[0].remaining).toBeGreaterThan(0);
  await expect(primary(page,1)).toBeEnabled();
  await press(7);
  await expect.poll(async()=>(await hud(page)).arts.targeting).toBe(true);
  expect((await hud(page)).arts.whirling).toBe(false);
  await expect.poll(async()=>(await hud(page)).arts.target_valid).toBe(true);
  await press(0);
  await expect.poll(async()=>(await hud(page)).arts.ground_remaining).toBeGreaterThan(0);
  expect((await hud(page)).arts.targeting).toBe(false);
});

test.describe('portrait mage preset',()=>{
  test.use({viewport:{width:390,height:844},hasTouch:true,isMobile:true});
  test('touch primary slots fit and aim the ground blast',async({page},info)=>{
    await mage(page);
    await primary(page,0).tap();
    await expect.poll(async()=>(await hud(page)).skills[0].remaining).toBeGreaterThan(0);
    await expect(primary(page,1)).toBeEnabled();
    await primary(page,1).tap();
    await expect(page.locator('#target-surface')).toBeVisible();
    await page.touchscreen.tap(230,390);
    await expect.poll(async()=>(await hud(page)).skills[1].remaining).toBeGreaterThan(0);
    for(const viewport of [{width:390,height:844},{width:320,height:640},{width:844,height:390}]){
      await page.setViewportSize(viewport);
      for(const selector of ['[data-skill="0"]','[data-skill="1"]','#player-weapon','#guard-button']){
        const box=(await page.locator(selector).boundingBox())!;
        expect(box.x).toBeGreaterThanOrEqual(0);expect(box.y).toBeGreaterThanOrEqual(0);
        expect(box.x+box.width).toBeLessThanOrEqual(viewport.width);expect(box.y+box.height).toBeLessThanOrEqual(viewport.height);
        expect(await page.locator(selector).evaluate(el=>{const r=el.getBoundingClientRect();return el.contains(document.elementFromPoint(r.x+r.width/2,r.y+r.height/2));})).toBe(true);
      }
      await captureGameFrame(page,{path:info.outputPath(`mage-${viewport.width}.png`)});
    }
  });
});
