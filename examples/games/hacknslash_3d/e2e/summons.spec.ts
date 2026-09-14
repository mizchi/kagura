import {test,expect} from '@playwright/test';
import {PNG} from 'pngjs';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
const quiet='/?snapshot=summons&peaceful=1&seed=42&mute=1';
const waitReady=page=>expect.poll(async()=>(await hud(page))?.weapon_locked).toBe(false);

test('new summoner oath exposes learned skills, slot assignments and a persistent preset',async({page},info)=>{
  await page.goto('/?mute=1');
  await page.locator('[data-save-slot="0"]').click();
  await page.getByRole('button',{name:/召喚師/}).click();
  await expect.poll(async()=>(await hud(page))?.preset_name).toBe('召喚師');
  expect((await hud(page)).skills.map(s=>s.key)).toEqual([57,48,52,86]);
  await page.keyboard.press('KeyK');
  await expect(page.getByLabel('スキルスロット 1',{exact:true})).toHaveValue('57');
  await expect(page.getByLabel('スキルスロット 2',{exact:true})).toHaveValue('48');
  await expect(page.locator('[data-tree-node="17"]')).toContainText('ゾンビ召喚');
  await expect(page.locator('[data-tree-node="18"]')).toContainText('炎の頭蓋');
  await captureGameFrame(page,{path:info.outputPath('summoner-tree.png')});
  await page.keyboard.press('Escape');
  await expect.poll(async()=>(await hud(page)).menu).toBe('none');
  await page.getByRole('button',{name:'一時停止メニュー',exact:true}).click();
  await expect.poll(async()=>(await hud(page)).paused).toBe(true);
  await page.getByRole('button',{name:/セーブして選択画面へ/}).click();
  await page.locator('[data-save-slot="0"]').click();
  expect((await hud(page)).skills.map(s=>s.key)).toEqual([57,48,52,86]);
});

test('mouse raises a zombie and holds a capped skull swarm; pause freezes it and release expires it',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto(quiet);await waitReady(page);
  await page.mouse.click(580,400,{button:'right'});
  await expect.poll(async()=>(await hud(page)).summons.zombies.length).toBe(1);
  await waitReady(page);
  await page.mouse.move(580,400);await page.mouse.down();
  await expect.poll(async()=>(await hud(page)).summons.skulls.length,{timeout:12000}).toBe(8);
  expect(await page.evaluate(()=>globalThis.__ashenControls.snapshot().attack)).toBe(false);
  await page.mouse.up();
  const bytes=await captureGameFrame(page,{path:info.outputPath('skull-swarm-desktop.png')});
  const png=PNG.sync.read(bytes);let flame=0;
  for(let y=200;y<png.height-280;y++)for(let x=180;x<png.width-250;x++){
    const p=(y*png.width+x)*4,[r,g,b]=png.data.subarray(p,p+3);
    if(r>170&&g>65&&g<210&&b<100&&r>g*1.15)flame++;
  }
  expect(flame,'visible orange 3D flames in the play area').toBeGreaterThan(70);
  await page.keyboard.press('Escape');
  await expect.poll(async()=>(await hud(page)).paused).toBe(true);
  const before=(await hud(page)).summons;
  await page.waitForTimeout(450);
  expect((await hud(page)).summons).toEqual(before);
  await page.keyboard.press('Escape');
  await expect.poll(async()=>(await hud(page)).summons.skulls.length,{timeout:12000}).toBe(0);
  expect((await hud(page)).summons.zombies.length).toBe(1);
  expect(errors).toEqual([]);
});

test('allied zombies tank attacks while spirits autonomously damage and kill enemies',async({page},info)=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/?snapshot=summons&seed=42&mute=1');await waitReady(page);
  const hp=(await hud(page)).hp;
  await page.keyboard.press('Digit2');
  await expect.poll(async()=>(await hud(page)).summons.zombies.length).toBe(1);
  await waitReady(page);await page.keyboard.down('Digit1');
  await expect.poll(async()=>(await hud(page)).summons.zombies.some(z=>z.hp<z.max_hp),{timeout:15000}).toBe(true);
  expect((await hud(page)).hp).toBe(hp);
  await captureGameFrame(page,{path:info.outputPath('summoner-combat.png')});
  await expect.poll(async()=>(await hud(page)).remaining,{timeout:20000}).toBeLessThan(3);
  await page.keyboard.up('Digit1');
  expect(errors).toEqual([]);
});

test('portrait touch button holds skull summoning and stays within the viewport',async({browser},info)=>{
  const context=await browser.newContext({viewport:{width:390,height:844},hasTouch:true,isMobile:true});
  const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto(quiet);await waitReady(page);
  const zombie=page.locator('[data-skill="1"]');await zombie.tap();
  await expect.poll(async()=>(await hud(page)).summons.zombies.length).toBe(1);await waitReady(page);
  const button=page.locator('[data-skill="0"]');const rect=await button.boundingBox();
  const cdp=await context.newCDPSession(page);
  await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:rect.x+rect.width/2,y:rect.y+rect.height/2}]});
  await expect.poll(async()=>(await hud(page)).summons.skulls.length,{timeout:8000}).toBeGreaterThanOrEqual(4);
  await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  expect(await page.evaluate(()=>globalThis.__ashenControls.isHeld('skull'))).toBe(false);
  const status=await page.locator('#summon-status').boundingBox();
  expect(status.x).toBeGreaterThanOrEqual(0);expect(status.x+status.width).toBeLessThanOrEqual(390);
  expect(await page.evaluate(()=>document.documentElement.scrollWidth)).toBe(390);
  await captureGameFrame(page,{path:info.outputPath('summoner-mobile.png')});
  expect(errors).toEqual([]);await context.close();
});

test('gamepad triangle holds skulls and R2 summons a zombie',async({page})=>{
  await page.addInitScript(()=>{
    globalThis.__pad={index:0,id:'Standard test pad',mapping:'standard',connected:true,axes:[0,0,0,0],buttons:Array.from({length:17},()=>({pressed:false,value:0}))};
    Object.defineProperty(navigator,'getGamepads',{configurable:true,value:()=>[globalThis.__pad]});
  });
  const set=down=>page.evaluate(down=>{globalThis.__pad.buttons=Array.from({length:17},(_,i)=>({pressed:down.includes(i),value:down.includes(i)?1:0}));},down);
  await page.goto(quiet);await waitReady(page);
  await set([7]);await expect.poll(async()=>(await hud(page)).summons.zombies.length).toBe(1);
  await set([]);await waitReady(page);await set([3]);
  await expect.poll(async()=>(await hud(page)).summons.skulls.length,{timeout:8000}).toBeGreaterThanOrEqual(3);
  await set([]);await expect.poll(()=>page.evaluate(()=>globalThis.__ashenControls.isHeld('skull'))).toBe(false);
});
