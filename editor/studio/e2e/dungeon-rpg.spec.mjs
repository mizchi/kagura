import {test,expect} from '@playwright/test';

test('FATHOM keyboard play and party artwork work inside the Studio game frame',async({page})=>{
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/');await page.getByLabel('Examples',{exact:true}).selectOption('dungeon_rpg');
  await expect(page.getByRole('status')).toContainText('Opened project');
  const controls=page.getByRole('group',{name:'Project controls',exact:true});
  await controls.getByRole('button',{name:'Play',exact:true}).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready','true',{timeout:40000});
  const frame=page.frameLocator('.game-frame');await expect(frame.locator('.adventurer-art')).toHaveCount(6);
  const artworkLoaded=await frame.locator('.adventurer-art').first().evaluate(el=>new Promise(resolve=>{
    const image=new Image();image.onload=()=>resolve(image.naturalWidth>0);image.onerror=()=>resolve(false);
    image.src=getComputedStyle(el).backgroundImage.slice(4,-1).replace(/^["']|["']$/g,'');
  }));
  expect(artworkLoaded).toBe(true);
  await frame.locator('#app').focus();await page.keyboard.press('Enter');
  await expect.poll(()=>page.evaluate(()=>kagura.runtime.observe().state.mode)).toBe('explore');
  for(const key of ['d','w','w','w','w','a','w','w','Enter','w','w','w','w'])await page.keyboard.press(key);
  await expect.poll(()=>page.evaluate(()=>kagura.runtime.observe().state.mode)).toBe('battle');
  await expect(frame.locator('.enemy')).toHaveCount(2);
  await page.keyboard.press('1');await page.keyboard.press('ArrowRight');await page.keyboard.press('Enter');
  expect((await page.evaluate(()=>kagura.runtime.observe().state)).battle.orders[0].target).toBe(1);
  const telemetry=await frame.locator('#fathom').evaluate(()=>fathom.experience.read());
  expect(telemetry.events.some(e=>e.type==='loop.start')).toBe(true);
  await controls.getByRole('button',{name:'Pause',exact:true}).click();
  const frozen=await page.evaluate(()=>kagura.runtime.observe().state);await page.waitForTimeout(150);
  expect(await page.evaluate(()=>kagura.runtime.observe().state)).toEqual(frozen);
  await controls.getByRole('button',{name:'Stop',exact:true}).click();
  await expect(page.locator('.game-frame')).toHaveCount(0);expect(errors).toEqual([]);
});
