import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
const hero=page=>page.evaluate(()=>globalThis.__ashenHunt);
async function start(page){
  await page.goto('/?snapshot=playing&frames=0&seed=42&mute=1');
  await page.waitForFunction(()=>globalThis.__ashenHunt&&globalThis.__ashenHud?.mode==='playing');
}
const center=async locator=>{const r=(await locator.boundingBox())!;return {x:r.x+r.width/2,y:r.y+r.height/2};};

test('holding physical 2 channels every equipped weapon, moves and stops on release',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await start(page);
  const picker=page.locator('#player-weapon'),button=page.locator('[data-hold="whirlwind"]');
  for(const [i,id] of ['cleaver_flintlock','spear','knuckles','focus','bow'].entries()){
    await picker.selectOption(String(i));
    await expect.poll(async()=>(await hero(page)).weapon).toBe(id);
    await expect(button).toBeEnabled();
    const before=await hero(page);
    // Deliberately mismatched character: only KeyboardEvent.code chooses the skill.
    await page.evaluate(()=>window.dispatchEvent(new KeyboardEvent('keydown',{code:'Digit2',key:'@',bubbles:true})));
    await expect.poll(async()=>(await hero(page)).animation).toBe('whirling');
    await expect(button).toBeEnabled();
    await expect(button).toHaveAttribute('aria-pressed','true');
    await expect(picker).toBeDisabled();
    await page.waitForTimeout(600); // More than one complete revolution.
    expect((await hud(page)).arts.whirling).toBe(true);
    expect((await hero(page)).weapon).toBe(id);
    expect((await hero(page)).yaw).toBe(before.yaw);
    if(i===0){
      await page.keyboard.down('KeyD');
      await expect.poll(async()=>{const h=await hero(page);return Math.hypot(h.x-before.x,h.y-before.y);}).toBeGreaterThan(5);
      await page.keyboard.up('KeyD');
      await captureGameFrame(page,{path:info.outputPath('whirlwind-desktop.png')});
    }
    await page.evaluate(()=>window.dispatchEvent(new KeyboardEvent('keyup',{code:'Digit2',key:'@',bubbles:true})));
    await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
    await expect.poll(async()=>(await hero(page)).animation).not.toBe('whirling');
    await expect(picker).toBeEnabled();
  }
  expect(errors).toEqual([]);
});

test('pause, inventory, dodge and focus loss cancel the channel without automatic restart',async({page})=>{
  await start(page);
  for(const cancel of ['Escape','KeyI','Space','blur']){
    await expect(page.locator('[data-hold="whirlwind"]')).toBeEnabled();
    await page.keyboard.down('Digit2');
    await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
    if(cancel==='blur')await page.evaluate(()=>window.dispatchEvent(new Event('blur')));
    else await page.keyboard.press(cancel);
    await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
    if(cancel==='Escape'||cancel==='KeyI'){
      // Menu rendering clears gameplay intents; wait for the actual dialog
      // before issuing its close command, just as the other pause E2Es do.
      await expect(page.locator('#hunter-panel [role="dialog"]')).toBeVisible();
      await page.keyboard.press('Escape');
      await expect(page.locator('#hunter-panel')).toBeHidden();
      expect((await hud(page)).paused).toBe(false);
    }
    await page.waitForTimeout(400);
    expect((await hud(page)).arts.whirling).toBe(false);
    await page.keyboard.up('Digit2');
  }
});

test('focused whirlwind button supports keyboard hold and release',async({page})=>{
  await start(page);
  await page.locator('[data-hold="whirlwind"]').focus();
  await page.keyboard.down('Space');
  await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
  await page.keyboard.up('Space');
  await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
});

test.describe('touch whirlwind',()=>{
  test.use({viewport:{width:390,height:844},isMobile:true,hasTouch:true,deviceScaleFactor:1});
  test('two fingers move and spin independently, pointer end and cancellation stop immediately',async({page,context},info)=>{
    await start(page);
    const session=await context.newCDPSession(page);
    const stick=await center(page.locator('.stick-ring'));
    const spin=await center(page.locator('[data-hold="whirlwind"]'));
    const left={x:stick.x+30,y:stick.y-12,id:1},right={...spin,id:2};
    const before=await hero(page);
    await session.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[left,right]});
    await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
    await expect.poll(async()=>{const h=await hero(page);return Math.hypot(h.x-before.x,h.y-before.y);}).toBeGreaterThan(8);
    await session.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[left]});
    await page.waitForTimeout(500);
    expect((await hud(page)).arts.whirling).toBe(true);
    const stationary=await hero(page);
    await page.waitForTimeout(150);
    expect([(await hero(page)).x,(await hero(page)).y]).toEqual([stationary.x,stationary.y]);
    await captureGameFrame(page,{path:info.outputPath('whirlwind-mobile.png')});
    await session.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
    await expect(page.locator('[data-hold="whirlwind"]')).toBeEnabled();
    await session.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[right]});
    await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
    await session.send('Input.dispatchTouchEvent',{type:'touchCancel',touchPoints:[]});
    await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
  });
});
