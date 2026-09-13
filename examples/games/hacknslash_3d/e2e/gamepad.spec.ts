import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const scene='/?snapshot=site&site=ruins&peaceful=1&seed=42&mute=1';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
const hero=page=>page.evaluate(()=>globalThis.__ashenHunt);
async function install(page){
  await page.addInitScript(()=>{
    globalThis.__pad={index:3,id:'Standard test pad',mapping:'standard',connected:true,axes:[0,0,0,0],buttons:Array.from({length:17},()=>({pressed:false,value:0}))};
    globalThis.__padMissing=false;globalThis.__padDenied=false;
    Object.defineProperty(navigator,'getGamepads',{configurable:true,value:()=>{if(globalThis.__padDenied)throw new DOMException('denied','SecurityError');return globalThis.__padMissing?[]:[null,null,null,globalThis.__pad];}});
  });
}
async function setPad(page,axes=[0,0,0,0],down=[]){await page.evaluate(({axes,down})=>{globalThis.__pad.axes=axes;globalThis.__pad.buttons=Array.from({length:17},(_,i)=>({pressed:down.includes(i),value:down.includes(i)?1:0}));},{axes,down});}
async function tap(page,button,modifier=[]){await setPad(page,[0,0,0,0],[...modifier,button]);await page.waitForTimeout(80);await setPad(page);await page.waitForTimeout(80);}

test('Victrix PS5 raw HID confirms, attacks with square, guards with R1, dodges with circle and channels with R2',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));await install(page);
  const neutral=[-.04,0,0,-1,-1,0,0,0,0,9/7];
  await page.addInitScript(()=>Object.assign(globalThis.__pad,{
    id:'Victrix Pro BFG Wired Controller for PS5 (Vendor: 0e6f Product: 0218)',index:0,mapping:'',
    axes:[-.04,0,0,-1,-1,0,0,0,0,9/7],
  }));
  const rawTap=async button=>{await setPad(page,neutral,[button]);await page.waitForTimeout(80);await setPad(page,neutral);await page.waitForTimeout(80);};
  await page.goto('/?mute=1');
  await expect.poll(async()=>(await hud(page))?.mode).toBe('title');
  await expect(page.locator('#gamepad-connection')).toContainText('操作できます');
  expect(await page.evaluate(()=>globalThis.__kaguraWebRuntime.gamepadFrame[0].axes[9])).toBeGreaterThan(1);
  await page.locator('#gamepad-status').click();
  await expect(page.locator('#gamepad-raw-input')).toContainText('Victrix Pro BFG PS5（Kagura補正）');
  await captureGameFrame(page,{path:info.outputPath('victrix-connected.png')});
  await rawTap(1);await expect.poll(async()=>(await hud(page)).mode).toBe('character_select');
  await rawTap(1);await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  await page.goto(scene);await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  const before=await hero(page);
  expect(await page.evaluate(()=>globalThis.__ashenControls.snapshot())).toMatchObject({x:0,y:0,attack:false,guard:false});
  await setPad(page,[.8,0,0,-1,-1,.8,0,0,0,9/7]);
  await expect.poll(async()=>{const h=await hero(page);return Math.hypot(h.x-before.x,h.y-before.y);}).toBeGreaterThan(1);
  expect(await page.evaluate(()=>globalThis.__ashenControls.stickAim().y)).toBeGreaterThan(.5);
  expect((await hero(page)).attacks).toBe(before.attacks);
  await setPad(page,neutral,[0]); // Raw square maps to standard X.
  await expect.poll(async()=>(await hero(page)).attacks).toBeGreaterThan(before.attacks);
  await setPad(page,neutral);await expect.poll(async()=>(await hud(page)).attack_remaining).toBe(0);
  await setPad(page,neutral,[5]);
  await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(true);
  await setPad(page,neutral);await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(false);
  await rawTap(2);await expect.poll(async()=>(await hero(page)).dodges).toBe(before.dodges+1);
  expect((await hud(page)).arts.whirling).toBe(false);
  await expect.poll(async()=>(await hud(page)).dodge).toBe(0);
  await setPad(page,[0,0,0,-1,1,0,0,0,0,9/7]); // Analog R2, without a digital button.
  await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
  expect(await page.evaluate(()=>globalThis.__ashenControls.snapshot().attack)).toBe(false);
  await setPad(page,neutral);await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
  await rawTap(11);await expect.poll(async()=>(await hud(page)).camera.mode).toBe(1);
  const yaw=(await hero(page)).yaw;
  await setPad(page,[0,0,.7,-1,-1,.3,0,0,0,9/7]);
  await expect.poll(async()=>(await hero(page)).yaw).toBeGreaterThan(yaw+.04);
  await setPad(page,neutral);await rawTap(9);await expect.poll(async()=>(await hud(page)).paused).toBe(true);
  await setPad(page,[0,0,0,-1,-1,0,0,0,0,1/7]);
  await expect(page.locator('.pause-actions [data-key="73"]')).toBeFocused();
  await setPad(page,neutral);await page.waitForTimeout(80);await rawTap(1);
  await expect(page.locator('.panel-inventory')).toBeVisible();
  await rawTap(2);await expect.poll(async()=>(await hud(page)).menu).toBe('none');
  await rawTap(9);await expect.poll(async()=>(await hud(page)).paused).toBe(false);
  expect(await page.evaluate(()=>globalThis.__ashenControls.snapshot())).toMatchObject({x:0,y:0,attack:false,guard:false});
  expect(errors).toEqual([]);
});

test('title exposes connection diagnosis before a pad is detected and distinguishes denied or missing API',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));await install(page);
  await page.addInitScript(()=>{globalThis.__padMissing=true;});
  await page.goto('/?mute=1');
  await expect.poll(async()=>(await hud(page))?.mode).toBe('title');
  await expect(page.locator('#gamepad-status')).toBeVisible();
  await page.locator('#gamepad-status').click();
  await expect(page.locator('#gamepad-connection')).toContainText('未検出');
  await expect(page.locator('#gamepad-raw-input')).toContainText('機器: 0');
  await captureGameFrame(page,{path:info.outputPath('gamepad-not-detected.png')});
  await page.evaluate(()=>{globalThis.__padMissing=false;globalThis.__pad.mapping='';});
  await expect(page.locator('#gamepad-connection')).toContainText('標準配置');
  await expect(page.locator('#gamepad-raw-input')).toContainText('Standard test pad');
  await page.evaluate(()=>{globalThis.__padDenied=true;});
  await expect(page.locator('#gamepad-connection')).toContainText('許可');
  await page.evaluate(()=>Object.defineProperty(navigator,'getGamepads',{configurable:true,value:undefined}));
  await expect(page.locator('#gamepad-connection')).toContainText('非対応');
  expect(errors).toEqual([]);
});

test('pad starts the game, moves and aims independently, attacks and releases held skills',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));await install(page);
  await page.goto('/?mute=1');
  await expect.poll(async()=>(await hud(page))?.mode).toBe('title');
  await tap(page,0);await expect.poll(async()=>(await hud(page)).mode).toBe('character_select');
  await tap(page,0);await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  await page.goto(scene);await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  await expect(page.locator('#gamepad-status')).toContainText('接続中');
  const before=await hero(page);
  await tap(page,0);expect((await hero(page)).attacks).toBe(before.attacks);
  await expect(page.locator('#attack-button kbd')).toHaveText('X / □');
  await expect(page.locator('#guard-status')).toHaveText('RB / R1 長押し');
  await expect(page.locator('#dodge-status')).toHaveText('B / ○');
  await expect(page.locator('[data-skill="0"] kbd')).toHaveText('Y / △');
  await expect(page.locator('[data-skill="1"] kbd')).toHaveText('RT / R2');
  await expect(page.locator('[data-skill="2"] kbd')).toHaveText('LB / L1');
  await expect(page.locator('[data-skill="3"] kbd')).toHaveText('LT / L2 + ↓');
  await setPad(page,[.7,0,-.8,0],[2]);
  await expect.poll(async()=>(await hero(page)).attacks).toBeGreaterThan(before.attacks);
  await expect.poll(async()=>{const h=await hero(page);return Math.hypot(h.x-before.x,h.y-before.y);}).toBeGreaterThan(1);
  const aimed=await hero(page);expect(Math.cos(aimed.facing)*Math.cos(aimed.yaw)-Math.sin(aimed.facing)*Math.sin(aimed.yaw)).toBeLessThan(-.8);
  await setPad(page);await expect.poll(() => page.evaluate(()=>globalThis.__ashenControls.snapshot().attack)).toBe(false);
  await expect.poll(async()=>(await hud(page)).attack_remaining).toBe(0);
  await setPad(page,[0,0,0,0],[5]);await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(true);
  await setPad(page);await expect.poll(async()=>(await hud(page)).arts.guarding).toBe(false);
  await tap(page,1);await expect.poll(async()=>(await hero(page)).dodges).toBe(before.dodges+1);
  expect((await hud(page)).arts.whirling).toBe(false);
  await expect.poll(async()=>(await hud(page)).dodge).toBe(0);
  await setPad(page,[0,0,0,0],[7]);await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(true);
  await captureGameFrame(page,{path:info.outputPath('gamepad-whirlwind.png')});
  await setPad(page);await expect.poll(async()=>(await hud(page)).arts.whirling).toBe(false);
  await page.mouse.move(450,360);await expect.poll(()=>page.evaluate(()=>globalThis.__ashenControls.gamepadActive())).toBe(false);
  await setPad(page,[.1,.08,0,0]);await page.waitForTimeout(100);expect(await page.evaluate(()=>globalThis.__ashenControls.gamepadActive())).toBe(false);
  expect(errors).toEqual([]);
});

test('TPS look and ground targeting work on raised terrain, with explicit confirm and cancel',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));await install(page);
  await page.goto('/?snapshot=terrain&terrain=perlin&seed=42&mute=1');
  await expect.poll(async()=>(await hud(page))?.terrain.player_height).toBeGreaterThan(0);
  await tap(page,11);await expect.poll(async()=>(await hud(page)).camera.mode).toBe(1);
  const before=await hero(page);await setPad(page,[0,0,.7,.3]);
  await expect.poll(async()=>(await hero(page)).yaw).toBeGreaterThan(before.yaw+.08);
  await expect(page.locator('#tps-crosshair')).toBeVisible();await setPad(page);
  await tap(page,13);await expect.poll(async()=>(await hud(page)).arts.targeting).toBe(true);
  const initial=(await hud(page)).arts;await setPad(page,[0,0,.6,0]);
  await expect.poll(async()=>(await hud(page)).arts.target_x).not.toBe(initial.target_x);
  await tap(page,1);await expect.poll(async()=>(await hud(page)).arts.targeting).toBe(false);
  expect((await hud(page)).arts.ground_remaining).toBe(0);
  await tap(page,13);await expect.poll(async()=>(await hud(page)).arts.target_valid).toBe(true);
  await tap(page,7);expect((await hud(page)).arts.targeting).toBe(true);
  expect((await hud(page)).arts.ground_remaining).toBe(0);
  await captureGameFrame(page,{path:info.outputPath('gamepad-target.png')});
  await tap(page,0);await expect.poll(async()=>(await hud(page)).arts.ground_remaining).toBeGreaterThan(0);
  expect(errors).toEqual([]);
});

test('pad menus retain focus, change camera settings and resume without held attacks; disconnect pauses',async({page})=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));await install(page);await page.goto(scene);
  await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  await tap(page,9);await expect.poll(async()=>(await hud(page)).paused).toBe(true);
  const stopped=await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame);
  for(let i=0;i<4;i++)await tap(page,13);
  await expect(page.getByRole('button',{name:'カメラ設定 O',exact:true})).toBeFocused();
  await tap(page,0);await expect(page.getByRole('dialog',{name:'カメラ設定',exact:true})).toBeVisible();
  const range=page.getByRole('slider',{name:'Tilt · 傾き',exact:true});await range.focus();
  const tilt=(await hud(page)).camera.tuning.tilt;
  await tap(page,15);await expect.poll(async()=>(await hud(page)).camera.tuning.tilt).toBeGreaterThan(tilt);
  expect(await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame)).toBe(stopped);
  await tap(page,1);await setPad(page,[0,0,0,0],[2,9]);await page.waitForTimeout(100);await setPad(page,[0,0,0,0],[2]);
  await expect.poll(async()=>(await hud(page)).paused).toBe(false);
  expect(await page.evaluate(()=>globalThis.__ashenControls.snapshot().attack)).toBe(false);
  await setPad(page);await page.waitForTimeout(80);await setPad(page,[.8,0,0,0],[2]);
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenControls.snapshot().attack)).toBe(true);
  await page.evaluate(()=>{globalThis.__padMissing=true;});
  await expect.poll(async()=>(await hud(page)).paused).toBe(true);
  expect(await page.evaluate(()=>globalThis.__ashenControls.snapshot())).toMatchObject({x:0,y:0,attack:false});
  await page.evaluate(()=>{globalThis.__padMissing=false;});await page.waitForTimeout(150);
  expect(await page.evaluate(()=>globalThis.__ashenControls.snapshot().attack)).toBe(false);
  await setPad(page);await page.waitForTimeout(80);await tap(page,9);
  await expect.poll(async()=>(await hud(page)).paused).toBe(false);
  await page.evaluate(()=>{globalThis.__padDenied=true;});await page.waitForTimeout(100);expect(errors).toEqual([]);
});

test('unmapped pad cannot issue actions, while mobile pad guide and inventory stay usable',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.setViewportSize({width:390,height:844});await install(page);await page.goto(scene);
  await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  await page.evaluate(()=>{globalThis.__pad.mapping='';});await setPad(page,[1,0,0,0],[2]);
  await expect(page.locator('#gamepad-status')).toContainText('認識されていません');
  expect(await page.evaluate(()=>globalThis.__ashenControls.snapshot().attack)).toBe(false);
  await setPad(page);await page.evaluate(()=>{globalThis.__pad.mapping='standard';});await page.waitForTimeout(100);
  await tap(page,14);await page.locator('#gamepad-status').click();
  await captureGameFrame(page,{path:info.outputPath('gamepad-mobile-guide.png')});
  await tap(page,8);await expect(page.locator('.panel-inventory')).toBeVisible();
  await tap(page,13);await tap(page,0);await tap(page,1);
  await expect(page.locator('.panel-inventory')).toBeHidden();
  await expect.poll(async()=>(await hud(page)).menu).toBe('none');
  expect(errors).toEqual([]);
});
