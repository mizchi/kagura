import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

const state=page=>page.evaluate(()=>{
  const p=globalThis.__ashenHunt;
  return {...p,offsetX:(p.focusX-p.x)/16,offsetY:(p.focusY-p.y)/16};
});
async function frames(page,count=30){
  await page.evaluate(async count=>{for(let i=0;i<count;i++)await new Promise(requestAnimationFrame);},count);
}
async function start(page){
  await page.goto('/?snapshot=melee&seed=42');
  await page.waitForFunction(()=>globalThis.__ashenHunt?.aimMode);
  await page.locator('#player-weapon').selectOption('4');
  await page.waitForFunction(()=>globalThis.__ashenHunt.weapon==='bow');
}

test('mouse focus and strafe stay independent of movement, keyboard attack restores automatic focus',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await start(page);
  await page.mouse.move(130,340);
  await page.waitForFunction(()=>globalThis.__ashenHunt.aimMode==='mouse');
  await frames(page);
  const left=await state(page);
  expect(left.offsetX*Math.cos(left.yaw)-left.offsetY*Math.sin(left.yaw)).toBeLessThan(-.3);
  await page.keyboard.down('KeyW');
  await frames(page,12);
  await page.keyboard.up('KeyW');
  const moved=await state(page);
  expect(moved.aimMode).toBe('mouse');
  expect(Math.hypot(moved.x-left.x,moved.y-left.y)).toBeGreaterThan(1);
  expect(Math.cos(moved.facing)*Math.cos(moved.yaw)-Math.sin(moved.facing)*Math.sin(moved.yaw)).toBeLessThan(-.3);
  expect(moved.yaw).toBe(left.yaw);
  await frames(page,30);
  const settled=await state(page);
  await frames(page,30);
  const stable=await state(page);
  expect(Math.hypot(stable.offsetX-settled.offsetX,stable.offsetY-settled.offsetY)).toBeLessThan(.02);
  await captureGameFrame(page,{path:info.outputPath('mouse-focus.png')});
  await page.keyboard.down('KeyJ');
  await page.waitForFunction(()=>globalThis.__ashenHunt.aimMode==='auto');
  await page.keyboard.up('KeyJ');
  await frames(page);
  expect((await state(page)).offsetX).toBeGreaterThan(0);
  await page.mouse.move(1040,370);
  await page.waitForFunction(()=>globalThis.__ashenHunt.aimMode==='mouse');
  await frames(page);
  const right=await state(page);
  expect(right.offsetX*Math.cos(right.yaw)-right.offsetY*Math.sin(right.yaw)).toBeGreaterThan(.3);
  await page.locator('#player-weapon').hover();
  await page.waitForFunction(()=>globalThis.__ashenHunt.aimMode==='auto');
  expect(errors).toEqual([]);
});

test.describe('portrait focus',()=>{
  test.use({viewport:{width:390,height:844},isMobile:true,hasTouch:true});
  test('touch controls restore automatic targeting after a mouse and preserve a bounded focus',async({page,context},info)=>{
    await start(page);
    await page.mouse.move(35,350);
    await page.waitForFunction(()=>globalThis.__ashenHunt.aimMode==='mouse');
    const box=(await page.locator('#attack-button').boundingBox())!;
    const cdp=await context.newCDPSession(page);
    await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:box.x+box.width/2,y:box.y+box.height/2,id:1}]});
    await page.waitForFunction(()=>globalThis.__ashenHunt.aimMode==='auto');
    await frames(page,20);
    await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    const p=await state(page);
    expect(Math.hypot(p.offsetX,p.offsetY)).toBeLessThanOrEqual(1.25);
    expect(p.offsetX).toBeGreaterThan(0);
    await captureGameFrame(page,{path:info.outputPath('touch-focus.png')});
  });
});
