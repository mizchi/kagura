import {test,expect} from '@playwright/test';

test('HUD patches retain unchanged data and menus respond immediately after idle',async({page})=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/?snapshot=camp&seed=42&mute=1');
  await page.waitForFunction(()=>globalThis.__ashenHud?.mode==='playing');
  await page.keyboard.press('KeyP');
  await page.waitForFunction(()=>globalThis.__ashenHud?.paused);
  await page.waitForTimeout(500);
  await page.evaluate(()=>{
    globalThis.__retainedInventory=globalThis.__ashenHud.inventory;
    globalThis.__patchKeys=[];
    const original=globalThis.__ashenUI;
    globalThis.__ashenUI={...original,patch(p){globalThis.__patchKeys.push(Object.keys(p.set));original.patch(p);}};
  });
  await page.waitForTimeout(150);
  expect(await page.evaluate(()=>globalThis.__ashenHud.inventory===globalThis.__retainedInventory)).toBe(true);
  expect(await page.evaluate(()=>globalThis.__patchKeys.every(keys=>!keys.includes('inventory')))).toBe(true);
  await page.keyboard.press('Escape');
  await page.waitForFunction(()=>!globalThis.__ashenHud.paused);
  await page.keyboard.press('KeyI');
  await page.waitForFunction(()=>globalThis.__ashenHud.menu==='inventory');
  expect(await page.evaluate(()=>globalThis.__ashenHud.inventory_grid.items.length)).toBeGreaterThan(0);
  await page.keyboard.press('Escape');
  await page.waitForFunction(()=>globalThis.__ashenHud.menu==='none');
  expect(errors).toEqual([]);
});

test('inspection snapshot is lazy and remains available through the existing envelope',async({page})=>{
  await page.goto('/?snapshot=camp&seed=42&mute=1');
  await page.waitForFunction(()=>globalThis.__kaguraLazyUISnapshot?.dirty);
  const snapshot=await page.evaluate(()=>{
    const state=globalThis.__kaguraLazyUISnapshot;
    const before=state.value;
    const first=globalThis.__kaguraUISnapshot;
    const second=globalThis.__kaguraUISnapshot;
    return {deferred:before===undefined,same:first===second,dirty:state.dirty,parsed:JSON.parse(first.json),value:first.parsed};
  });
  expect(snapshot.deferred).toBe(true);
  expect(snapshot.same).toBe(true);
  expect(snapshot.dirty).toBe(false);
  expect(snapshot.parsed).toEqual(snapshot.value);
  expect(snapshot.value.nodes.length).toBeGreaterThan(0);
  await page.waitForFunction(()=>globalThis.__kaguraLazyUISnapshot.dirty);
});
