import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
async function start(page){
  await page.goto('/?snapshot=playing&frames=0&seed=42&mute=1');
  await page.waitForFunction(()=>globalThis.__ashenHud?.mode==='playing');
  await page.keyboard.press('KeyI');
  await expect(page.locator('.inv-cell')).toHaveCount(48);
}
const center=async locator=>{const b=(await locator.boundingBox())!;return{x:b.x+b.width/2,y:b.y+b.height/2};};
async function assertFits(page,width,height){
  const panel=page.locator('.panel-inventory'),b=(await panel.boundingBox())!;
  expect(b.x).toBeGreaterThanOrEqual(16);
  expect(b.x+b.width).toBeLessThanOrEqual(width-16);
  expect(b.y).toBeGreaterThanOrEqual(10);
  expect(b.y+b.height).toBeLessThanOrEqual(height-48);
  const overflow=await panel.evaluate(el=>[el,...el.querySelectorAll('*')].filter(e=>e.clientHeight>0&&e.scrollHeight>e.clientHeight+1&&['auto','scroll'].includes(getComputedStyle(e).overflowY)).map(e=>e.className));
  expect(overflow).toEqual([]);
  expect(await panel.evaluate(el=>({h:el.scrollHeight-el.clientHeight,w:el.scrollWidth-el.clientWidth}))).toEqual({h:0,w:0});
  for(const selector of ['[data-equip-slot]','.inv-cell','.inv-detail-actions button','.close-panel'])for(const el of await page.locator(selector).all()){
    const r=(await el.boundingBox())!;
    expect(r.y).toBeGreaterThanOrEqual(b.y);
    expect(r.y+r.height).toBeLessThanOrEqual(b.y+b.height+1);
    expect(r.x).toBeGreaterThanOrEqual(b.x);
    expect(r.x+r.width).toBeLessThanOrEqual(b.x+b.width+1);
  }
}

test('inventory fits without scrolling and reserves a ground-drop margin at every viewport',async({page},info)=>{
  await start(page);
  await page.locator('[data-inv-item="0"] [data-item-cell]').first().click();
  for(const [width,height] of [[1280,900],[1366,768],[1024,600],[844,390],[390,844],[320,640]]){
    await page.setViewportSize({width,height});
    await assertFits(page,width,height);
    await captureGameFrame(page,{path:info.outputPath(`inventory-${width}x${height}.png`)});
  }
});

test('dragging into the margin discards the exact item, while ESC and panel whitespace cancel',async({page},info)=>{
  await start(page);
  const before=(await hud(page)).inventory_grid.items;
  const frame=await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame);
  const a=await center(page.locator('[data-inv-item="0"] [data-item-cell]').first());
  const margin={x:640,y:875};
  await page.mouse.move(a.x,a.y);await page.mouse.down();await page.mouse.move(margin.x,margin.y,{steps:8});
  await expect(page.locator('.inv-drop-zone')).toContainText('離して地面に捨てる');
  await page.keyboard.press('Escape');await page.mouse.up();
  expect((await hud(page)).inventory_grid.items).toEqual(before);
  await page.mouse.move(a.x,a.y);await page.mouse.down();
  const heading=await center(page.locator('.panel-inventory h2'));
  await page.mouse.move(heading.x,heading.y,{steps:8});await page.mouse.up();
  expect((await hud(page)).inventory_grid.items).toEqual(before);
  await page.mouse.move(a.x,a.y);await page.mouse.down();await page.mouse.move(margin.x,margin.y,{steps:8});
  await captureGameFrame(page,{path:info.outputPath('inventory-drop-preview.png')});
  await page.mouse.up();
  await expect.poll(async()=>(await hud(page)).inventory_grid.items.length).toBe(before.length-1);
  expect((await hud(page)).inventory_grid.items.some(i=>i.source===0)).toBe(false);
  expect((await hud(page)).menu).toBe('inventory');
  expect(await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame)).toBe(frame);
  await page.keyboard.press('Escape');
  await expect(page.getByRole('button',{name:before[0].name+'を拾う',exact:true})).toBeVisible();
});

test.describe('touch ground drop',()=>{
  test.use({viewport:{width:390,height:844},isMobile:true,hasTouch:true,deviceScaleFactor:1});
  test('touch cancellation preserves the item and releasing in the margin discards it',async({page,context})=>{
    await start(page);
    const a=await center(page.locator('[data-inv-item="0"] [data-item-cell]').first());
    const cdp=await context.newCDPSession(page);
    const send=(type,x=a.x,y=a.y)=>cdp.send('Input.dispatchTouchEvent',{type,touchPoints:['touchEnd','touchCancel'].includes(type)?[]:[{x,y,id:1}]});
    await send('touchStart');await send('touchMove',195,820);await send('touchCancel');
    expect((await hud(page)).inventory_grid.items).toHaveLength(6);
    await send('touchStart');await send('touchMove',195,820);await send('touchEnd');
    await expect.poll(async()=>(await hud(page)).inventory_grid.items.length).toBe(5);
  });
});

test('long names and ten modifiers remain accessible through comparison pages without scrolling',async({page},info)=>{
  await page.goto('/?mute=1');
  await page.evaluate(()=>{
    const item='夜を渡り続けた古い狩人の長い名の外套,3,1,1,1,1,1,古の~1~1~1~0.01~0.02~0.03~0.04~1~1~1,-,1,1,1';
    localStorage.setItem('hacknslash3d_save',`1|0|0|-|-|-|1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0|${item}|1|0|100|0||cleaver|tree-v1`);
  });
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  await page.keyboard.press('KeyI');
  await page.locator('[data-inv-item="0"] [data-item-cell]').first().click();
  for(const [width,height] of [[320,640],[844,390],[1280,900]]){
    await page.setViewportSize({width,height});
    await assertFits(page,width,height);
    await captureGameFrame(page,{path:info.outputPath(`comparison-${width}.png`)});
  }
  const rows:string[]=[];
  for(const index of [0,1,2]){
    rows.push(...await page.locator('.inv-detail tbody th').allTextContents());
    if(index<2){
      await page.getByRole('button',{name:'次の比較',exact:true}).focus();
      await page.keyboard.press('Enter');
      await expect(page.getByRole('button',{name:index===0?'次の比較':'前の比較',exact:true})).toBeFocused();
    }
  }
  expect(rows).toEqual(['攻撃力','防御力','最大体力','筋力','知力','敏捷','会心率 %','吸血 %','移動速度 %','再使用短縮 %']);
});
