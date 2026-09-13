import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
async function start(page){await page.goto('/?snapshot=arts&seed=42&mute=1');await page.waitForFunction(()=>globalThis.__ashenHunt&&globalThis.__ashenHud?.mode==='playing');}

test('physical guard, lightning gesture and dash strike run in game',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await start(page);
  await page.keyboard.down('KeyF');
  await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(true);
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.animation)).toBe('guarding');
  await expect(page.locator('#astral-button')).toBeDisabled();
  await captureGameFrame(page,{path:info.outputPath('shield-guard.png')});
  await page.keyboard.up('KeyF');
  await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(false);
  await page.keyboard.press('Digit5');
  await expect.poll(async()=>(await hud(page)).arts.action).toBe('lightning');
  await expect.poll(async()=>(await hud(page)).extra_skills.find(s=>s.key===53).remaining).toBeGreaterThan(0);
  await captureGameFrame(page,{path:info.outputPath('chain-lightning.png')});
  await expect(page.locator('#dash-strike-button')).toBeEnabled();
  const before=await page.evaluate(()=>globalThis.__ashenHunt);
  await page.keyboard.press('KeyV');
  await expect.poll(async()=>(await hud(page)).arts.dash_remaining).toBeGreaterThan(0);
  await expect.poll(async()=>{const a=await page.evaluate(()=>globalThis.__ashenHunt);return Math.hypot(a.x-before.x,a.y-before.y);}).toBeGreaterThan(10);
  await expect.poll(async()=>(await hud(page)).arts.action).toBe('none');
  expect(errors).toEqual([]);
});

test('ground targeting cancels without cost and confirms a delayed circular impact',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await start(page);
  await page.keyboard.press('KeyT');
  await expect(page.locator('#target-surface')).toBeVisible();
  await page.mouse.move(760,430);
  await expect.poll(async()=>(await hud(page)).arts.target_valid).toBe(true);
  await captureGameFrame(page,{path:info.outputPath('astral-target.png')});
  await page.keyboard.press('Escape');
  await expect(page.locator('#target-surface')).toBeHidden();
  expect((await hud(page)).paused).toBe(false);
  expect((await hud(page)).arts.ground_remaining).toBe(0);
  await page.keyboard.press('KeyT');
  await page.locator('#target-surface').click({position:{x:760,y:430}});
  await expect.poll(async()=>(await hud(page)).arts.impact_pending).toBe(true);
  await expect.poll(async()=>(await hud(page)).arts.impact_pending).toBe(false);
  await captureGameFrame(page,{path:info.outputPath('astral-impact.png')});
  expect((await hud(page)).arts.ground_remaining).toBeGreaterThan(0);
  expect(errors).toEqual([]);
});

test.describe('touch arts',()=>{
  test.use({viewport:{width:390,height:844},isMobile:true,hasTouch:true,deviceScaleFactor:1});
  test('holding shield releases on touch cancellation and ground tap aims without firing basic attack',async({page,context},info)=>{
    await start(page);
    const session=await context.newCDPSession(page);
    const box=(await page.locator('#guard-button').boundingBox())!;
    await session.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:box.x+box.width/2,y:box.y+box.height/2,id:1}]});
    await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(true);
    await session.send('Input.dispatchTouchEvent',{type:'touchCancel',touchPoints:[]});
    await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(false);
    const attacks=await page.evaluate(()=>globalThis.__ashenHunt.attacks);
    await page.locator('#astral-button').tap();
    await page.touchscreen.tap(230,390);
    await expect.poll(async()=>(await hud(page)).arts.ground_remaining).toBeGreaterThan(0);
    expect(await page.evaluate(()=>globalThis.__ashenHunt.attacks)).toBe(attacks);
    for(const viewport of [{width:390,height:844},{width:320,height:640},{width:844,height:390},{width:640,height:320}]){
      await page.setViewportSize(viewport);
      for(const selector of ['#guard-button','#astral-button','#dash-strike-button','#player-weapon']){
        const b=(await page.locator(selector).boundingBox())!;
        expect(b.x).toBeGreaterThanOrEqual(0);expect(b.y).toBeGreaterThanOrEqual(0);
        expect(b.x+b.width).toBeLessThanOrEqual(viewport.width);expect(b.y+b.height).toBeLessThanOrEqual(viewport.height);
        expect(await page.locator(selector).evaluate(el=>{const r=el.getBoundingClientRect();return el.contains(document.elementFromPoint(r.x+r.width/2,r.y+r.height/2));})).toBe(true);
      }
      await captureGameFrame(page,{path:info.outputPath(`arts-mobile-${viewport.width}.png`)});
    }
  });
});

test('flame cast releases a readable projectile and confirms real explosion hits',async({page},info)=>{
  await start(page);
  await page.keyboard.press('Digit3');
  await expect.poll(async()=>(await hud(page)).arts.action).toBe('flame');
  await page.waitForFunction(()=>globalThis.__ashenHud.arts.feedback.endsWith('HIT'));
  expect((await hud(page)).arts.feedback).toMatch(/^[1-9]\d* HIT$/);
  await captureGameFrame(page,{path:info.outputPath('fire-hit.png')});
  await expect(page.locator('[data-skill="2"]')).toBeDisabled();
});
