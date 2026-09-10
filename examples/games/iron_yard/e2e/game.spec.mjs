import {test,expect} from '@playwright/test';
async function boot(page){
  await page.addInitScript(()=>{Element.prototype.requestPointerLock=async()=>{throw Error('RMB fallback test')}});
  await page.goto('/');await expect(page.getByRole('button',{name:'出撃する',exact:true})).toBeEnabled();
}
test('Kagura loads real models and textures, moves, boosts, jumps and pauses',async({page})=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));await boot(page);
  expect(await page.evaluate(()=>ironYard.renderer)).toBe('kagura-webgpu');
  expect(await page.evaluate(()=>ironYard.rendererInfo().images)).toBe(19);
  expect(await page.evaluate(()=>ironYard.rendererInfo().audioClips)).toBe(6);
  await page.locator('#mode').selectOption('training');await page.getByRole('button',{name:'出撃する',exact:true}).click();
  await page.keyboard.down('KeyW');await expect.poll(()=>page.evaluate(()=>ironYard.snapshot().pilot.position[2])).toBeGreaterThan(-35);
  await page.keyboard.down('ShiftLeft');await expect.poll(()=>page.evaluate(()=>ironYard.snapshot().pilot.boost)).toBeGreaterThan(.7);
  await page.keyboard.up('KeyW');await page.keyboard.up('ShiftLeft');
  await page.keyboard.down('Space');await expect.poll(()=>page.evaluate(()=>ironYard.snapshot().pilot.position[1])).toBeGreaterThan(2);await page.keyboard.up('Space');
  await page.keyboard.press('Escape');await expect(page.getByRole('button',{name:'操作を再開',exact:true})).toBeVisible();
  const before=await page.evaluate(()=>ironYard.snapshot());await page.waitForTimeout(200);expect(await page.evaluate(()=>ironYard.snapshot())).toEqual(before);
  await page.getByRole('button',{name:'出発地点へ戻す',exact:true}).click();expect((await page.evaluate(()=>ironYard.snapshot())).pilot.position).toEqual([0,0,-36]);
  expect(errors).toEqual([]);
});
test('rifle, missile locks, enemy AI and reset work through normal controls',async({page})=>{
  await boot(page);await page.locator('#mode').selectOption('training');await page.getByRole('button',{name:'出撃する',exact:true}).click();
  await page.mouse.move(640,400);await page.mouse.down();await expect.poll(()=>page.evaluate(()=>ironYard.snapshot().shots)).toBeGreaterThan(3);await page.mouse.up();
  await page.keyboard.down('KeyE');await expect.poll(()=>page.evaluate(()=>ironYard.snapshot().units.filter(e=>e.lock>=1).length)).toBeGreaterThan(0);await page.keyboard.up('KeyE');
  await expect.poll(()=>page.evaluate(()=>ironYard.snapshot().missiles)).toBeGreaterThan(0);
  await page.keyboard.press('Escape');await page.locator('#mode').selectOption('combat');await page.getByRole('button',{name:'出撃する',exact:true}).click();
  await expect.poll(()=>page.evaluate(()=>ironYard.snapshot().enemyShots),{timeout:25000}).toBeGreaterThan(0);
  await page.keyboard.press('Escape');await page.getByRole('button',{name:'出発地点へ戻す',exact:true}).click();
  expect((await page.evaluate(()=>ironYard.snapshot())).enemyShots).toBe(0);
});
