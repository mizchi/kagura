import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);
const inventory=async page=>(await hud(page)).inventory_grid;
const item=async(page,source)=>(await inventory(page)).items.find(i=>i.source===source);
const center=async locator=>{const r=(await locator.boundingBox())!;return{x:r.x+r.width/2,y:r.y+r.height/2};};
const cell=(page,x,y)=>page.locator(`[data-cell-x="${x}"][data-cell-y="${y}"]`);
async function drag(page,source,target,rotate=false) {
  const a=await center(page.locator(`[data-inv-item="${source}"]`).locator('[data-item-cell]').first().or(page.locator(`[data-equip-slot][data-inv-item="${source}"]`)));
  const b=await center(target);
  await page.mouse.move(a.x,a.y);await page.mouse.down();
  await page.mouse.move(b.x,b.y,{steps:12});
  if(rotate)await page.keyboard.press('KeyR');
  await page.mouse.up();
}
async function start(page) {
  await page.goto('/?snapshot=playing&frames=0&seed=42&mute=1');
  await page.waitForFunction(()=>globalThis.__ashenHud?.mode==='playing');
  await page.keyboard.press('KeyI');
  await expect(page.locator('.inv-cell')).toHaveCount(48);
}

test('spatial bag equips, swaps, rotates, persists and keeps the game stopped',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await start(page);
  await expect(page.locator('[data-equip-slot]')).toHaveCount(8);
  expect((await inventory(page)).items).toHaveLength(6);
  expect((await item(page,1)).cells).toHaveLength(4); // L-shaped cleaver
  const frame=await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame);
  const stats=await inventory(page);
  await drag(page,0,page.locator('[data-equip-slot="0"]'));
  await expect.poll(async()=>(await inventory(page)).equipment[0].item?.glyph).toBe('spear');
  expect((await hud(page)).weapon_index).toBe(1);
  expect((await inventory(page)).atk).toBeGreaterThan(stats.atk);
  await drag(page,1,page.locator('[data-equip-slot="0"]'));
  await expect.poll(async()=>(await inventory(page)).equipment[0].item?.glyph).toBe('blade');
  expect((await item(page,1)).glyph).toBe('spear');
  await drag(page,1,cell(page,6,4),true); // rotate about top cell: anchor becomes (3,4)
  await expect.poll(async()=>(await item(page,1)).rotated).toBe(true);
  expect([(await item(page,1)).x,(await item(page,1)).y]).toEqual([3,4]);
  await drag(page,3,page.locator('[data-equip-slot="3"]'));
  await expect.poll(async()=>(await inventory(page)).equipment[3].item?.glyph).toBe('hat');
  expect(await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame)).toBe(frame);
  await captureGameFrame(page,{path:info.outputPath('inventory-desktop.png')});
  const saved=await inventory(page);
  await page.goto('/?seed=42&mute=1');
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  await page.keyboard.press('KeyI');
  await expect(page.locator('.inv-cell')).toHaveCount(48);
  expect((await inventory(page)).items).toEqual(saved.items);
  expect((await inventory(page)).equipment).toEqual(saved.equipment);
  expect(errors).toEqual([]);
});

test('wrong slots, multi-item collisions, panel whitespace and ESC cancel lose no items',async({page})=>{
  await start(page);
  const before=(await inventory(page)).items;
  await drag(page,0,page.locator('[data-equip-slot="3"]'));
  expect((await inventory(page)).items).toEqual(before);
  await drag(page,2,cell(page,0,0));
  expect((await inventory(page)).items).toEqual(before);
  const a=await center(page.locator('[data-inv-item="0"] [data-item-cell]').first());
  const b=await center(page.locator('[data-equip-slot="0"]'));
  await page.mouse.move(a.x,a.y);await page.mouse.down();await page.mouse.move(b.x,b.y,{steps:8});
  await expect(page.locator('.inv-drag-ghost')).toBeVisible();
  await page.keyboard.press('Escape');await page.mouse.up();
  await expect(page.locator('.inv-drag-ghost')).toHaveCount(0);
  expect((await hud(page)).menu).toBe('inventory');
  expect((await inventory(page)).items).toEqual(before);
  await drag(page,0,page.locator('.panel-inventory h2'));
  expect((await inventory(page)).items).toEqual(before);
  await page.keyboard.press('Escape');
  await expect.poll(async()=>(await hud(page)).menu).toBe('none');
});

test('L-shaped holes accept a different item and physical E equips the selected item',async({page},info)=>{
  await start(page);
  const cleaver=await item(page,1);
  const hole=cell(page,cleaver.x+1,cleaver.y+1);
  const p=await center(hole);
  expect(await page.evaluate(({x,y})=>document.elementFromPoint(x,y)?.closest('[data-cell-x]')?.getAttribute('data-cell-x'),p)).toBe(String(cleaver.x+1));
  await page.locator('[data-inv-item="5"] [data-item-cell]').first().click();
  await hole.click();
  await expect.poll(async()=>(await item(page,5)).x).toBe(cleaver.x+1);
  expect((await item(page,5)).y).toBe(cleaver.y+1);
  expect(await item(page,1)).toEqual(cleaver);
  await captureGameFrame(page,{path:info.outputPath('inventory-shaped-items.png')});
  await page.keyboard.press('KeyE');
  await expect.poll(async()=>(await inventory(page)).equipment[2].item?.glyph).toBe('ring');
  expect((await inventory(page)).equipment[0].item.name).toBe('狩人の鉈');
});

test('older overflowing bags retain every item and can recover through equipment',async({page})=>{
  await page.goto('/?mute=1');
  await page.evaluate(()=>localStorage.setItem('hacknslash3d_save',`1|0|0|-|-|-|1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0|${Array.from({length:20},(_,i)=>`古い外套${i},0,1,0,1,0,1`).join(';')}|1|0|100|0||cleaver|tree-v1`));
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  await page.keyboard.press('KeyI');
  await page.getByRole('button',{name:'保管待ち 12',exact:true}).click();
  await expect(page.locator('.inv-overflow [data-inv-item]')).toHaveCount(3);
  await page.getByRole('button',{name:'次の保管待ち',exact:true}).click();
  await expect(page.locator('.inv-overflow [data-inv-item]').first()).toContainText('古い外套11');
  await page.getByRole('button',{name:'前の保管待ち',exact:true}).click();
  expect((await inventory(page)).items).toHaveLength(20);
  await page.locator('.inv-overflow [data-inv-item]').first().click();
  await page.getByRole('button',{name:'装備する',exact:true}).click();
  await expect.poll(async()=>(await inventory(page)).equipment[1].item?.name).toBe('古い外套8');
  await page.getByRole('button',{name:'バッグへ外す',exact:true}).click();
  await expect(page.locator('.inv-notice')).toContainText('空きがありません');
  expect((await inventory(page)).items).toHaveLength(19);
  await page.reload();
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  await page.keyboard.press('KeyI');
  await page.getByRole('button',{name:'保管待ち 11',exact:true}).click();
  await expect(page.locator('.inv-overflow [data-inv-item]')).toHaveCount(3);
  expect((await inventory(page)).equipment[1].item.name).toBe('古い外套8');
});

test.describe('touch inventory',()=>{
  test.use({viewport:{width:390,height:844},isMobile:true,hasTouch:true,deviceScaleFactor:1});
  test('tap equipment, touch drag, cancellation and narrow layouts',async({page,context},info)=>{
    const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
    await start(page);
    await page.locator('[data-inv-item="0"] [data-item-cell]').first().tap();
    await page.getByRole('button',{name:'装備する',exact:true}).tap();
    await expect.poll(async()=>(await inventory(page)).equipment[0].item?.glyph).toBe('spear');
    await page.getByRole('button',{name:'バッグへ外す',exact:true}).tap();
    await expect.poll(async()=>(await inventory(page)).equipment[0].item).toBeUndefined();
    const source=(await inventory(page)).items.find(i=>i.glyph==='spear').source;
    await page.locator(`[data-inv-item="${source}"] [data-item-cell]`).first().tap();
    await page.getByRole('button',{name:/↻ 回転/}).tap();
    await cell(page,3,5).tap();
    await expect.poll(async()=>(await item(page,source)).rotated).toBe(true);
    await page.locator('.inv-bag').scrollIntoViewIfNeeded();
    const a=await center(page.locator(`[data-inv-item="${source}"] [data-item-cell]`).first());
    const b=await center(cell(page,3,4));
    const cdp=await context.newCDPSession(page);
    const touch=(type,x=a.x,y=a.y)=>cdp.send('Input.dispatchTouchEvent',{type,touchPoints:type==='touchEnd'||type==='touchCancel'?[]:[{x,y,id:1}]});
    await touch('touchStart');await touch('touchMove',b.x,b.y);await touch('touchCancel');
    expect((await item(page,source)).y).toBe(5);
    await touch('touchStart');await touch('touchMove',b.x,b.y);await touch('touchEnd');
    await expect.poll(async()=>(await item(page,source)).y).toBe(4);
    for(const viewport of [{width:390,height:844},{width:844,height:390},{width:320,height:640}]){
      await page.setViewportSize(viewport);
      await page.locator('.inv-bag').scrollIntoViewIfNeeded();
      const bag=(await page.locator('.inv-bag').boundingBox())!;
      expect(bag.x).toBeGreaterThanOrEqual(0);expect(bag.x+bag.width).toBeLessThanOrEqual(viewport.width);
      expect(await page.locator('.hunter-panel').evaluate(e=>e.scrollWidth<=e.clientWidth)).toBe(true);
      await captureGameFrame(page,{path:info.outputPath(`inventory-${viewport.width}.png`)});
    }
    await page.getByRole('button',{name:'閉じる',exact:true}).tap();
    await expect.poll(async()=>(await hud(page)).menu).toBe('none');
    expect(errors).toEqual([]);
  });
});

test('hover compares with the matching equipped item without changing the current selection',async({page},info)=>{
  await start(page);
  await drag(page,0,page.locator('[data-equip-slot="0"]'));
  await expect.poll(async()=>(await inventory(page)).equipment[0].item?.glyph).toBe('spear');
  const equipped=(await inventory(page)).equipment[0].item;
  await page.locator('[data-inv-item="3"] [data-item-cell]').first().click();
  const selected=await page.locator('.inv-detail h3').textContent();
  await page.locator('[data-inv-item="1"] [data-item-cell]').first().hover();
  const tooltip=page.getByRole('tooltip',{name:'装備との比較'});
  await expect(tooltip).toBeVisible();
  await expect(tooltip).toContainText(equipped.name);
  await expect(tooltip.locator('h3')).toHaveText((await item(page,1)).name);
  await expect(tooltip.locator('tbody tr').filter({hasText:'攻撃力'}).locator('th,td')).toHaveText(['攻撃力','1','1','0']);
  await expect(page.locator('.inv-detail h3')).toHaveText(selected!);
  await captureGameFrame(page,{path:info.outputPath('inventory-hover-comparison.png')});
  await page.locator('.panel-inventory h2').hover();
  await expect(tooltip).toBeHidden();
});

test('discarded equipment is visible at the feet, survives saving and is not immediately picked up',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await start(page);
  const dropped=await item(page,0);
  await page.locator('[data-inv-item="0"] [data-item-cell]').first().click();
  await page.getByRole('button',{name:'地面に捨てる',exact:true}).click();
  await expect.poll(async()=>(await inventory(page)).items.length).toBe(5);
  await expect(page.locator('.inv-notice')).toContainText('足元に捨てました');
  await page.keyboard.press('Escape');
  await expect.poll(async()=>(await hud(page)).menu).toBe('none');
  const label=page.locator('.ground-loot-label').filter({hasText:dropped.name});
  await expect(label).toBeVisible();
  await expect(label).toHaveAttribute('data-blocked','true');
  await page.waitForTimeout(300);
  await expect(label).toBeVisible();
  await captureGameFrame(page,{path:info.outputPath('discarded-ground-loot.png')});
  await page.goto('/?seed=42&mute=1');
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  await expect(label).toBeVisible();
  await expect(label).toHaveAttribute('data-blocked','true');
  await page.keyboard.press('KeyI');
  await expect.poll(async()=>(await inventory(page))?.items.length).toBe(5);
  expect(errors).toEqual([]);
});

test('clicking a ground label picks that exact drop, keeps combat idle and persists the pickup',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await start(page);
  const spear=await item(page,0),hat=await item(page,3);
  for(const source of [0,3]){
    await page.locator(`[data-inv-item="${source}"] [data-item-cell]`).first().click();
    await page.getByRole('button',{name:'地面に捨てる',exact:true}).click();
    await expect.poll(async()=>(await item(page,source))??null).toBeNull();
  }
  await page.keyboard.press('Escape');
  await expect.poll(async()=>(await hud(page)).menu).toBe('none');
  const attacks=await page.evaluate(()=>globalThis.__ashenHunt.attacks);
  await captureGameFrame(page,{path:info.outputPath('clickable-ground-loot.png')});
  await page.getByRole('button',{name:hat.name+'を拾う',exact:true}).click();
  await expect.poll(async()=>(await hud(page)).loot.map(i=>i.name)).toEqual([spear.name]);
  expect(await page.evaluate(()=>globalThis.__ashenHunt.attacks)).toBe(attacks);
  expect(await page.evaluate(()=>globalThis.__ashenControls.snapshot().attack)).toBe(false);
  await page.goto('/?seed=42&mute=1');
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async()=>(await hud(page)).mode).toBe('playing');
  await expect.poll(async()=>(await hud(page)).loot.map(i=>i.name)).toEqual([spear.name]);
  await page.getByRole('button',{name:spear.name+'を拾う',exact:true}).click();
  await expect.poll(async()=>(await hud(page)).loot.length).toBe(0);
  await page.keyboard.press('KeyI');
  await expect.poll(async()=>(await inventory(page))?.items.length).toBe(6);
  expect((await inventory(page)).items.some(i=>i.name===hat.name)).toBe(true);
  expect(errors).toEqual([]);
});
