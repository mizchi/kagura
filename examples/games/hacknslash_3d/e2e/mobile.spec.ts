import {test,expect} from '@playwright/test';
import {PNG} from 'pngjs';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

test.use({viewport:{width:390,height:844},hasTouch:true,isMobile:true,deviceScaleFactor:1});
const hero=page=>page.evaluate(()=>globalThis.__ashenHunt);
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
const center=async locator=>{const r=(await locator.boundingBox())!;return{x:r.x+r.width/2,y:r.y+r.height/2};};

test('portrait hunter moves and attacks with two fingers, cancels cleanly, and casts real skills',async({page,context},testInfo)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/?snapshot=playing&frames=0&mute=1&seed=42');
  await page.waitForFunction(()=>globalThis.__ashenHud?.mode==='playing');
  expect(await page.locator('canvas').boundingBox()).toEqual({x:0,y:0,width:390,height:844});
  const stick=await center(page.locator('.stick-ring'));
  const attack=await center(page.locator('#attack-button'));
  expect(stick.x).toBeLessThan(195);expect(stick.y).toBeGreaterThan(600);
  expect(attack.x).toBeGreaterThan(195);
  const session=await context.newCDPSession(page);
  const left={x:stick.x+34,y:stick.y-20,id:1};
  const right={...attack,id:2};
  const start=await hero(page);
  await session.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[left]});
  await expect.poll(async()=>{const s=await hero(page);return Math.hypot(s.x-start.x,s.y-start.y);}).toBeGreaterThan(5);
  await session.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[left,right]});
  await expect.poll(async()=>(await hero(page)).attacks).toBeGreaterThan(0);
  await session.send('Input.dispatchTouchEvent',{type:'touchCancel',touchPoints:[]});
  await expect.poll(async()=>(await hero(page)).animation).toBe('idle');
  const stopped=await hero(page);await page.waitForTimeout(160);
  expect([(await hero(page)).x,(await hero(page)).y]).toEqual([stopped.x,stopped.y]);
  const fire=await center(page.locator('[data-skill="2"]'));
  await page.touchscreen.tap(fire.x,fire.y);
  await expect.poll(async()=>(await hud(page)).skills[2].remaining).toBeGreaterThan(0);
  await expect(page.locator('[data-skill="2"]')).toBeDisabled();
  await expect(page.locator('[data-skill="2"] .skill-status')).toHaveText(/s$/);
  const dodge=await center(page.locator('#dodge-button'));
  await page.touchscreen.tap(dodge.x,dodge.y);
  await expect.poll(async()=>(await hero(page)).dodges).toBe(1);
  for(const selector of ['.vitals','.map-card','.utility','#move-stick','.action-dock']){
    const r=(await page.locator(selector).boundingBox())!;
    expect(r.x).toBeGreaterThanOrEqual(0);expect(r.y).toBeGreaterThanOrEqual(0);
    expect(r.x+r.width).toBeLessThanOrEqual(390);expect(r.y+r.height).toBeLessThanOrEqual(844);
  }
  const shot=PNG.sync.read(await captureGameFrame(page,{path:testInfo.outputPath('ashwood-mobile.png')}));
  expect([shot.width,shot.height]).toEqual([390,844]);
  await page.setViewportSize({width:844,height:390});
  await expect.poll(()=>page.locator('canvas').boundingBox()).toEqual({x:0,y:0,width:844,height:390});
  const r=(await page.locator('.action-dock').boundingBox())!;expect(r.y).toBeGreaterThanOrEqual(0);expect(r.y+r.height).toBeLessThanOrEqual(390);
  await captureGameFrame(page,{path:testInfo.outputPath('ashwood-mobile-landscape.png')});
  await page.setViewportSize({width:320,height:640});
  for(const selector of ['.vitals','.map-card','.utility','#move-stick','.action-dock']){
    const r=(await page.locator(selector).boundingBox())!;
    expect(r.x).toBeGreaterThanOrEqual(0);expect(r.y).toBeGreaterThanOrEqual(0);
    expect(r.x+r.width).toBeLessThanOrEqual(320);expect(r.y+r.height).toBeLessThanOrEqual(640);
  }
  const leftControl=(await page.locator('#move-stick').boundingBox())!;
  const rightControl=(await page.locator('.action-dock').boundingBox())!;
  expect(leftControl.x+leftControl.width).toBeLessThan(rightControl.x);
  expect(errors).toEqual([]);
});

test('mobile title, class selection, skill guide and inventory work without a keyboard',async({page,context},testInfo)=>{
  await page.goto('/?mute=1&seed=42');
  await page.getByRole('button',{name:/狩りを始める/}).tap();
  await page.getByRole('button',{name:/刃の狩人/}).tap();
  await page.waitForFunction(()=>globalThis.__ashenHud?.mode==='playing');
  await page.getByRole('button',{name:'技と成長',exact:true}).tap();
  await expect(page.getByRole('heading',{name:'技と成長',exact:true})).toBeVisible();
  await expect(page.locator('.skill-guide article')).toHaveCount(4);
  await expect(page.locator('.skill-guide')).toContainText('自分を中心に冷気');
  await captureGameFrame(page,{path:testInfo.outputPath('ashwood-mobile-skills.png')});
  const session=await context.newCDPSession(page);
  await session.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:185,y:665,id:4}]});
  for(const y of [610,550,480,400,320]){
    await session.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x:185,y,id:4}]});
  }
  await session.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  await expect.poll(()=>page.locator('.hunter-panel').evaluate(el=>el.scrollTop)).toBeGreaterThan(80);
  await page.getByRole('button',{name:'閉じる',exact:true}).tap();
  await page.getByRole('button',{name:'装備袋',exact:true}).tap();
  await expect(page.getByRole('heading',{name:'装備袋',exact:true})).toBeVisible();
  await page.getByRole('button',{name:'閉じる',exact:true}).tap();
  await expect.poll(async()=>(await hud(page)).menu).toBe('none');
});
