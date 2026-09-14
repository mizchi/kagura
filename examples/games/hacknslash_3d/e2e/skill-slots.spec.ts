import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
const hero=page=>page.evaluate(()=>globalThis.__ashenHunt);
const slot=(page,i)=>page.getByLabel(`スキルスロット ${i+1}`,{exact:true});
const scene='/?snapshot=site&site=ruins&peaceful=1&seed=42&mute=1';

test('mouse buttons cast configured mage slots and confirmation never fires a basic attack',async({page})=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/?mute=1');await page.locator('[data-save-slot="0"]').click();
  await page.getByRole('button',{name:/魔法使い/}).click();
  await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  await page.evaluate(()=>{
    let value=globalThis.__ashenHunt;globalThis.__basicFrames=0;
    Object.defineProperty(globalThis,'__ashenHunt',{configurable:true,get:()=>value,set:next=>{value=next;if(next.attackFrame>=0)globalThis.__basicFrames++;}});
  });
  await page.mouse.click(540,400);
  await expect.poll(async()=>(await hud(page)).skills[0].remaining).toBeGreaterThan(0);
  expect(await page.evaluate(()=>globalThis.__basicFrames)).toBe(0);
  await expect.poll(async()=>(await hud(page)).weapon_locked).toBe(false);
  const yaw=(await hero(page)).yaw;
  await page.mouse.move(600,420);await page.mouse.down({button:'right'});
  await page.mouse.move(760,430,{steps:8});await page.mouse.up({button:'right'});
  await expect(page.locator('#target-surface')).toBeVisible();
  expect((await hero(page)).yaw).toBe(yaw);
  await page.locator('#target-surface').click({position:{x:760,y:430}});
  await expect.poll(async()=>(await hud(page)).skills[1].remaining).toBeGreaterThan(0);
  expect(await page.evaluate(()=>globalThis.__basicFrames)).toBe(0);
  expect(errors).toEqual([]);
});

test('slot editing swaps, persists, and relocated mouse and keyboard holds stop on release or pause',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto(scene);await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  await page.keyboard.press('KeyK');await expect(slot(page,0)).toHaveValue('74');
  await expect(page.locator('#hunter-panel')).not.toContainText('処刑の一撃');
  await expect(slot(page,0).locator('option[value="53"]')).toHaveAttribute('disabled','');
  await slot(page,0).selectOption('50');await expect(slot(page,1)).toHaveValue('74');
  await slot(page,1).selectOption('70');await expect(slot(page,3)).toHaveValue('74');
  await captureGameFrame(page,{path:info.outputPath('skill-slots-desktop.png')});
  const saved=(await hud(page)).skills.map(s=>s.key);
  await page.keyboard.press('Escape');
  await page.mouse.move(600,400);await page.mouse.down();
  await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
  await page.mouse.up();await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
  await expect.poll(async()=>(await hud(page)).attack_remaining).toBe(0);
  await page.mouse.down({button:'right'});await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(true);
  await page.mouse.up({button:'right'});await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(false);
  await page.keyboard.down('Digit1');await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
  await page.keyboard.press('Escape');await expect.poll(async()=>(await hud(page)).paused).toBe(true);
  await page.keyboard.up('Digit1');await page.keyboard.press('Escape');
  await expect.poll(async()=>(await hud(page)).paused).toBe(false);
  await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
  await page.goto('/?mute=1');await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).skills.map(s=>s.key)).toEqual(saved);
  await page.keyboard.down('Digit2');await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(true);
  await page.keyboard.up('Digit2');await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(false);
  expect(errors).toEqual([]);
});

test('quick left clicks and digit 1 both perform basic attack in the melee preset',async({page})=>{
  await page.goto(scene);await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  const before=(await hero(page)).attacks;
  await page.mouse.click(600,400);
  await expect.poll(async()=>(await hero(page)).attacks).toBeGreaterThan(before);
  await expect.poll(async()=>(await hud(page)).attack_remaining).toBe(0);
  const next=(await hero(page)).attacks;
  await page.keyboard.press('Digit1');
  await expect.poll(async()=>(await hero(page)).attacks).toBeGreaterThan(next);
});

test.describe('mobile slot editor',()=>{
  test.use({viewport:{width:390,height:844},isMobile:true,hasTouch:true});
  test('all four slots fit portrait and landscape, and reassigned touch hold releases',async({page,context},info)=>{
    await page.goto(scene);await page.getByRole('button',{name:'技と成長',exact:true}).tap();
    await slot(page,2).selectOption('50');await expect(slot(page,1)).toHaveValue('86');
    for(const viewport of [{width:390,height:844},{width:320,height:640},{width:844,height:390}]){
      await page.setViewportSize(viewport);
      for(let i=0;i<4;i++){
        await slot(page,i).scrollIntoViewIfNeeded();
        const box=(await slot(page,i).boundingBox())!;
        expect(box.x).toBeGreaterThanOrEqual(0);expect(box.x+box.width).toBeLessThanOrEqual(viewport.width);
        expect(box.height).toBeGreaterThanOrEqual(44);
      }
      await page.locator('.hunter-panel').evaluate(el=>el.scrollTop=0);
      await captureGameFrame(page,{path:info.outputPath(`skill-slots-${viewport.width}.png`)});
    }
    await page.setViewportSize({width:390,height:844});
    await page.getByRole('button',{name:'閉じる',exact:true}).tap();
    const button=page.locator('[data-skill="2"]'),box=(await button.boundingBox())!;
    const session=await context.newCDPSession(page);
    await session.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:box.x+box.width/2,y:box.y+box.height/2,id:1}]});
    await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
    await session.send('Input.dispatchTouchEvent',{type:'touchCancel',touchPoints:[]});
    await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
  });
});
