import {test,expect} from '@playwright/test';
import {utimesSync} from 'node:fs';
import {fileURLToPath} from 'node:url';

test('MoonBit runtime source changes rebuild and reload the running game',async({page})=>{
  const errors:string[]=[];page.on('pageerror',error=>errors.push(error.message));
  await page.goto('/?snapshot=playing&frames=0&seed=42&mute=1');
  await page.waitForFunction(()=>globalThis.__ashenHud?.mode==='playing');
  const navigation=page.waitForEvent('framenavigated',{predicate:frame=>frame===page.mainFrame()});
  // Change metadata only: trigger the real watcher without editing source or
  // invoking a compiler from the test. The host must rebuild before reloading.
  const source=fileURLToPath(new URL('../../../../platform_js/web_core/ui_sync.mbt',import.meta.url));
  const now=new Date();utimesSync(source,now,now);
  await navigation;
  await page.waitForFunction(()=>globalThis.__ashenHud?.mode==='playing');
  await page.getByRole('button',{name:'装備袋',exact:true}).click();
  await expect(page.getByRole('heading',{name:'装備袋',exact:true})).toBeVisible();
  expect(errors).toEqual([]);
});
