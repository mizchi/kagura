import {test,expect} from '@playwright/test';
async function boot(page){
  await page.addInitScript(()=>{Element.prototype.requestPointerLock=async()=>{throw Error('fallback')}});
  await page.goto('/');await expect(page.getByRole('button',{name:'出撃する',exact:true})).toBeEnabled();
}
test('deployment typography, controls, focus and pause follow the source UI',async({page})=>{
  await boot(page);
  const menu=page.getByRole('dialog',{name:'出撃メニュー'});
  await expect(menu).toBeVisible();await expect(menu.getByRole('heading',{name:'IRON YARD',exact:true})).toBeVisible();
  expect(await menu.evaluate(el=>getComputedStyle(el).fontFamily)).toContain('Helvetica Neue');
  await expect(menu.getByRole('slider',{name:'BGM音量'})).toHaveValue('0.23');
  await menu.getByRole('slider',{name:'BGM音量'}).fill('0.41');
  await menu.getByRole('slider',{name:'効果音音量'}).fill('0.32');
  await page.getByRole('button',{name:'出撃する',exact:true}).click();await expect(menu).not.toBeVisible();
  await expect(page.locator('#speed')).toHaveText('0.0');await expect(page.locator('#fallback-note')).toBeVisible();
  await page.keyboard.down('KeyW');await expect.poll(()=>page.locator('#speed').innerText()).not.toBe('0.0');await page.keyboard.up('KeyW');
  await page.keyboard.press('Escape');await expect(menu.getByRole('heading',{name:'SYSTEM PAUSED'})).toBeVisible();
  await expect(page.getByRole('button',{name:'操作を再開',exact:true})).toBeFocused();
  await expect(menu.getByRole('slider',{name:'BGM音量'})).toHaveValue('0.41');
  expect(await page.evaluate(()=>ironYard.rendererInfo().audioVolumes)).toEqual({music:.41,effects:.32,muted:false});
  await page.keyboard.press('Escape');await expect(menu).toBeVisible();
});
for(const viewport of [{width:390,height:640},{width:844,height:390}])test(`menu scrolls inside viewport ${viewport.width}x${viewport.height}`,async({page})=>{
  await page.setViewportSize(viewport);await boot(page);
  const dialog=page.getByRole('dialog',{name:'出撃メニュー'}),card=dialog.locator('.deployment-card');
  await dialog.locator('summary').click();
  expect(await card.evaluate(e=>e.scrollHeight)).toBeGreaterThan(await card.evaluate(e=>e.clientHeight));
  await dialog.getByRole('button',{name:'出撃する',exact:true}).scrollIntoViewIfNeeded();
  const bounds=await dialog.boundingBox();expect(bounds.x).toBeGreaterThanOrEqual(0);expect(bounds.y).toBeGreaterThanOrEqual(0);
  expect(bounds.x+bounds.width).toBeLessThanOrEqual(viewport.width+1);expect(bounds.y+bounds.height).toBeLessThanOrEqual(viewport.height+1);
  expect(await page.evaluate(()=>document.documentElement.scrollHeight)).toBe(viewport.height);
});
