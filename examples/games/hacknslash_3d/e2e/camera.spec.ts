import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

const scene='/?snapshot=site&site=ruins&peaceful=1&seed=42&mute=1';
const camera=page=>page.evaluate(()=>globalThis.__ashenHud?.camera);
const frame=page=>page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame);
async function setRange(page,label,value){
  await page.getByRole('slider',{name:label,exact:true}).evaluate((element,value)=>{const range=element as HTMLInputElement;range.value=String(value);range.dispatchEvent(new Event('input',{bubbles:true}));},value);
}

test('camera settings preview while paused, retain each mode and survive reload',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto(scene);
  await page.getByRole('button',{name:'カメラ設定',exact:true}).click();
  const panel=page.getByRole('dialog',{name:'カメラ設定',exact:true});
  await expect(panel).toBeVisible();
  const stopped=await frame(page);
  await setRange(page,'Tilt · 傾き',56);
  await setRange(page,'左右の位置',-.8);
  await expect.poll(async()=>(await camera(page)).tuning.side).toBe(-.8);
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.pitch)).toBeCloseTo(56*Math.PI/180,3);
  expect(await frame(page)).toBe(stopped);
  await captureGameFrame(page,{path:info.outputPath('quarter-camera-settings.png')});
  await panel.getByRole('button',{name:'TPS',exact:true}).click();
  await expect.poll(async()=>(await camera(page)).mode).toBe(1);
  await setRange(page,'カメラの距離',5.2);
  await setRange(page,'Tilt · 傾き',22);
  await expect.poll(async()=>(await camera(page)).tuning.tilt).toBe(22);
  await captureGameFrame(page,{path:info.outputPath('tps-camera-settings.png')});
  await panel.getByRole('button',{name:'クオータービュー',exact:true}).click();
  await expect.poll(async()=>(await camera(page)).tuning.tilt).toBe(56);
  expect((await camera(page)).tuning.side).toBe(-.8);
  await panel.getByRole('button',{name:'TPS',exact:true}).click();
  await expect.poll(async()=>(await camera(page)).tuning.distance).toBe(5.2);
  await page.keyboard.press('Escape');
  await expect(page.getByRole('dialog',{name:'一時停止メニュー',exact:true})).toBeVisible();
  expect(await frame(page)).toBe(stopped);
  await page.keyboard.press('Escape');
  await expect(panel).toHaveCount(0);
  await page.reload();
  await expect.poll(async()=>(await camera(page))?.mode).toBe(1);
  expect((await camera(page)).tuning.tilt).toBe(22);
  expect((await camera(page)).tuning.distance).toBe(5.2);
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.pitch)).toBeCloseTo(22*Math.PI/180,3);
  await page.mouse.move(550,390);
  await captureGameFrame(page,{path:info.outputPath('tps-playing.png')});
  expect(errors).toEqual([]);
});

test('physical Z switches TPS, right drag looks around, and WASD follows camera yaw',async({page})=>{
  await page.goto(scene);
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud?.mode)).toBe('playing');
  await page.evaluate(()=>{
    window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyZ',key:';',bubbles:true}));
    window.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyZ',key:';',bubbles:true}));
  });
  await expect.poll(async()=>(await camera(page)).mode).toBe(1);
  await page.mouse.move(640,370);
  const beforeQ=await page.evaluate(()=>globalThis.__ashenHunt.yaw);
  await page.keyboard.down('KeyQ');
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.yaw)).toBeGreaterThan(beforeQ+.05);
  await page.keyboard.up('KeyQ');
  const beforeE=await page.evaluate(()=>globalThis.__ashenHunt.yaw);
  await page.keyboard.down('KeyE');
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.yaw)).toBeLessThan(beforeE-.05);
  await page.keyboard.up('KeyE');
  const yaw=await page.evaluate(()=>globalThis.__ashenHunt.yaw);
  await page.mouse.down({button:'right'});
  await page.mouse.move(740,370,{steps:15});
  await page.mouse.up({button:'right'});
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.yaw)).toBeGreaterThan(yaw+.1);
  await expect(page.locator('#tps-crosshair')).toBeVisible();
  await page.keyboard.press('KeyJ');
  await expect.poll(async()=>(await camera(page)).crosshair).toBe(false);
  const before=await page.evaluate(()=>globalThis.__ashenHunt);
  await page.keyboard.down('KeyW');await page.waitForTimeout(250);await page.keyboard.up('KeyW');
  const after=await page.evaluate(()=>globalThis.__ashenHunt);
  expect((after.x-before.x)*-Math.sin(after.yaw)+(after.y-before.y)*-Math.cos(after.yaw)).toBeGreaterThan(0);
  await page.keyboard.press('KeyZ');
  await expect.poll(async()=>(await camera(page)).mode).toBe(0);
});

test.describe('mobile camera',()=>{
  test.use({viewport:{width:390,height:844},hasTouch:true,isMobile:true,deviceScaleFactor:1});
  test('portrait preview leaves the player visible and touch can orbit TPS',async({page},info)=>{
    await page.goto(scene);
    await page.getByRole('button',{name:'カメラ設定',exact:true}).tap();
    const panel=page.getByRole('dialog',{name:'カメラ設定',exact:true});
    await panel.getByRole('button',{name:'TPS',exact:true}).tap();
    await expect.poll(async()=>(await camera(page)).mode).toBe(1);
    const preview=(await page.locator('#app').boundingBox())!;
    const settings=(await panel.boundingBox())!;
    expect(preview.y+preview.height).toBeLessThanOrEqual(settings.y+1);
    expect(settings.x).toBeGreaterThanOrEqual(0);
    expect(settings.x+settings.width).toBeLessThanOrEqual(390);
    await captureGameFrame(page,{path:info.outputPath('mobile-camera-settings.png')});
    await panel.getByRole('button',{name:'狩りを再開する',exact:true}).tap();
    await expect(panel).toHaveCount(0);
    const yaw=await page.evaluate(()=>globalThis.__ashenHunt.yaw);
    const session=await page.context().newCDPSession(page);
    await session.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:190,y:330}]});
    for(let i=1;i<=8;i++){
      await session.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x:190+i*12,y:330}]});
      await page.waitForTimeout(25);
    }
    await session.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.yaw)).toBeGreaterThan(yaw+.3);
    expect((await camera(page)).crosshair).toBe(false);
    await captureGameFrame(page,{path:info.outputPath('mobile-tps-playing.png')});
  });
});
