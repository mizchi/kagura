import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const appearance=page=>page.evaluate(()=>globalThis.__ashenHunt);
async function openBag(page){
  await page.keyboard.press('KeyI');
  await expect(page.locator('.inv-cell')).toHaveCount(48);
}

for(const touch of [false,true]){
  test.describe(touch?'touch appearance':'desktop appearance',()=>{
    test.use(touch?{viewport:{width:390,height:844},isMobile:true,hasTouch:true}:{});
    test('helmet drag, removal and reload update the paused character',async({page},info)=>{
      const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
      await page.goto('/?snapshot=wardrobe&outfit=worn&seed=42&mute=1');
      await page.waitForFunction(()=>globalThis.__ashenHunt&&globalThis.__ashenHud?.mode==='playing');
      const before=await appearance(page);
      const frame=await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame);
      await captureGameFrame(page,{path:info.outputPath('worn.png')});
      await openBag(page);
      const helmet=page.locator('[data-inv-item="3"] [data-item-cell]').first();
      if(touch){
        await helmet.tap();
        await page.getByRole('button',{name:'装備する',exact:true}).tap();
      }else{
        const a=(await helmet.boundingBox())!,b=(await page.locator('[data-equip-slot="3"]').boundingBox())!;
        await page.mouse.move(a.x+a.width/2,a.y+a.height/2);await page.mouse.down();
        await page.mouse.move(b.x+b.width/2,b.y+b.height/2,{steps:12});await page.mouse.up();
      }
      await expect.poll(async()=>(await appearance(page)).appearanceKey).not.toBe(before.appearanceKey);
      const equipped=await appearance(page);
      await page.getByRole('button',{name:'閉じる',exact:true}).click();
      await expect(page.locator('.panel-inventory')).toBeHidden();
      await captureGameFrame(page,{path:info.outputPath('plate-helmet.png')});
      await openBag(page);
      await page.locator('[data-equip-slot="3"]').click();
      await page.getByRole('button',{name:'バッグへ外す',exact:true}).click();
      await expect.poll(async()=>(await appearance(page)).appearanceKey).not.toBe(equipped.appearanceKey);
      const bare=await appearance(page);
      expect(bare.materials).toBeLessThan(equipped.materials);
      expect(await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame)).toBe(frame);
      await page.getByRole('button',{name:'閉じる',exact:true}).click();
      await expect(page.locator('.panel-inventory')).toBeHidden();
      await captureGameFrame(page,{path:info.outputPath('no-helmet.png')});
      // Loading equipment must keep an explicitly empty slot empty.
      await page.goto('/?seed=42&mute=1');
      await page.locator('[data-save-slot="0"]').click();
      await expect.poll(async()=>(await appearance(page)).appearanceKey).toBe(bare.appearanceKey);
      await openBag(page);
      expect(await page.evaluate(()=>globalThis.__ashenHud.inventory_grid.equipment[3].item)).toBeUndefined();
      const builds=(await appearance(page)).appearanceBuilds;
      await page.evaluate(async()=>{for(let i=0;i<12;i++)await new Promise(requestAnimationFrame)});
      expect((await appearance(page)).appearanceBuilds).toBe(builds);
      expect(errors).toEqual([]);
    });
  });
}

test('all species render the shared outfit with their own head',async({page},info)=>{
  test.setTimeout(120_000);
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  for(const species of ['human','goblin','kobold','skeleton']){
    for(const outfit of ['none','worn','plate','occult']){
      await page.goto(`/?snapshot=wardrobe&species=${species}&outfit=${outfit}&seed=42&mute=1`);
      await page.waitForFunction(()=>globalThis.__ashenHunt&&globalThis.__ashenHud?.mode==='playing');
      expect((await appearance(page)).species).toBe(species);
      expect((await appearance(page)).bones).toBe(17);
      await captureGameFrame(page,{path:info.outputPath(`${species}-${outfit}.png`)});
    }
  }
  expect(errors).toEqual([]);
});
