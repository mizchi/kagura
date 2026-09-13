import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

for(const touch of [false,true]){
  test.describe(touch?'touch magic homing':'desktop magic homing',()=>{
    test.use(touch?{viewport:{width:390,height:844},isMobile:true,hasTouch:true}:{});
    test('focus and splitting fireball launch, render and report actual hits',async({page},info)=>{
      const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
      await page.goto('/?snapshot=arts&seed=42&mute=1');
      await page.waitForFunction(()=>globalThis.__ashenHunt&&globalThis.__ashenHud?.mode==='playing');
      const picker=page.locator('#player-weapon'),attack=page.locator('#attack-button');
      await picker.selectOption('3');
      await expect(attack).toHaveAttribute('title',/追う魔法弾/);
      if(touch)await attack.tap();else await attack.click();
      await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.projectiles)).toBeGreaterThan(0);
      await captureGameFrame(page,{path:info.outputPath('focus-homing.png')});
      await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.arts.feedback)).toMatch(/^[1-9]\d* HIT$/);
      await expect(page.locator('[data-skill="2"]')).toBeEnabled();
      // Let the previous impact feedback expire before checking the next cast.
      await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.arts.feedback)).toBe('');
      if(touch)await page.locator('[data-skill="2"]').tap();else await page.keyboard.press('Digit3');
      await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.projectiles)).toBeGreaterThan(0);
      await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.arts.feedback)).toMatch(/^[1-9]\d* HIT$/);
      await expect(page.locator('[data-skill="2"] .skill-tooltip')).toContainText('分裂した弾も追尾');
      await captureGameFrame(page,{path:info.outputPath('split-homing-hit.png')});
      await expect(picker).toBeEnabled();
      await picker.selectOption('4');
      await expect(attack).toHaveAttribute('title','');
      expect(errors).toEqual([]);
    });
  });
}
