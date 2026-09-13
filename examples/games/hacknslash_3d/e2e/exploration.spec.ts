import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

for(const [site,name] of [['ruins','街道の宿場跡'],['camp','灰狼の野営地'],['chapel','崩れた礼拝堂'],['outpost','盗賊の野営地']]){
  test(`${name} has visible structures, a treasure marker and a road connection`,async({page},info)=>{
    const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
    await page.goto(`/?snapshot=site&site=${site}&overview=1&seed=42&mute=1`);
    await page.waitForFunction(()=>globalThis.__ashenHud?.exploration);
    await expect(page.locator('#site-label')).toHaveText(name);
    expect(await page.evaluate(()=>globalThis.__ashenHud.exploration.wolves)).toBeGreaterThanOrEqual(6);
    await expect(page.locator('#minimap-sites g')).toHaveCount(4);
    await captureGameFrame(page,{path:info.outputPath(`${site}.png`)});
    expect(errors).toEqual([]);
  });
}

for(const mobile of [false,true]){
  test.describe(mobile?'portrait treasure':'desktop treasure',()=>{
    test.use(mobile?{viewport:{width:390,height:844},isMobile:true,hasTouch:true}:{});
    test('opens a chest once and retains the empty chest after reloading',async({page},info)=>{
      const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
      await page.goto('/?snapshot=site&site=camp&peaceful=1&seed=42&mute=1');
      const button=page.getByRole('button',{name:'宝箱を開ける'});
      await expect(button).toBeVisible();
      await captureGameFrame(page,{path:info.outputPath('chest-closed.png')});
      if(mobile) await button.tap(); else await page.keyboard.press('KeyB');
      await page.waitForFunction(()=>globalThis.__ashenHud.exploration.chests[1].opened);
      await expect(button).toBeHidden();
      await page.evaluate(async()=>{for(let i=0;i<24;i++)await new Promise(requestAnimationFrame)});
      await captureGameFrame(page,{path:info.outputPath('chest-open.png')});
      await page.goto('/?seed=42&mute=1');
      await page.getByRole('button',{name:/狩りを始める/}).click();
      await page.waitForFunction(()=>globalThis.__ashenHud?.mode==='playing');
      expect(await page.evaluate(()=>globalThis.__ashenHud.exploration.chests[1].opened)).toBe(true);
      await expect(button).toBeHidden();
      expect(errors).toEqual([]);
    });
  });
}
