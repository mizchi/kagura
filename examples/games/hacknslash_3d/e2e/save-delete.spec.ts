import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

const keys=['hacknslash3d_save','hacknslash3d_save_slot_2','hacknslash3d_save_slot_3'];
const storage=page=>page.evaluate(()=>Object.fromEntries(Object.entries(localStorage)));
const remove=(page,slot)=>page.getByRole('button',{name:`セーブ ${slot+1} を削除`,exact:true});
const confirm=page=>page.getByRole('button',{name:'削除する',exact:true});
async function setup(page){
  await page.goto('/?snapshot=playing&frames=0&mute=1');
  await page.keyboard.press('Escape');
  await page.getByRole('button',{name:/セーブして選択画面へ/}).click();
  await expect(page.locator('[data-save-slot="0"]')).toContainText('続ける');
  await page.evaluate(()=>{
    localStorage.setItem('hacknslash3d_save_slot_2',localStorage.getItem('hacknslash3d_save'));
    localStorage.setItem('hacknslash3d_save_slot_3','broken save');
    localStorage.setItem('save-delete-unrelated-setting','keep');
  });
  await page.goto('/?mute=1');
}

test('delete confirmation cancels by default, removes only its slot, and permits a fresh character',async({page},info)=>{
  await setup(page);
  const before=await storage(page);
  await remove(page,0).click();
  await expect(page.getByRole('heading',{name:'セーブ 1 を削除しますか？'})).toBeVisible();
  await expect(page.getByRole('button',{name:'キャンセル',exact:true})).toBeFocused();
  expect(await storage(page)).toEqual(before);
  await page.keyboard.press('Enter');
  await expect(page.getByRole('heading',{name:'セーブデータ選択'})).toBeVisible();
  await remove(page,0).click();await expect(confirm(page)).toBeVisible();
  await page.keyboard.press('Escape');
  await expect(page.getByRole('heading',{name:'セーブデータ選択'})).toBeVisible();
  expect(await storage(page)).toEqual(before);
  await remove(page,0).click();
  await expect(confirm(page)).toBeVisible();
  await captureGameFrame(page,{path:info.outputPath('delete-confirm.png')});
  await confirm(page).click();
  await expect(page.locator('[data-save-slot="0"]')).toContainText('新しく始める');
  await expect(remove(page,0)).toHaveCount(0);
  const {hacknslash3d_save:deleted,...remaining}=before;
  expect(deleted).toBeTruthy();expect(await storage(page)).toEqual(remaining);
  await page.reload();
  await expect(remove(page,0)).toHaveCount(0);
  await page.locator('[data-save-slot="0"]').click();
  await page.getByRole('button',{name:/魔法使い/}).click();
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud?.mode)).toBe('playing');
  expect((await storage(page))[keys[0]].split('|')[19]).toBe('mage');
  expect((await storage(page))[keys[1]]).toBe(before[keys[1]]);
});

test('failed deletion can retry and a changed save requires a fresh confirmation',async({page})=>{
  await setup(page);
  const before=await storage(page);
  await remove(page,1).click();
  await page.evaluate(()=>{
    globalThis.__originalRemove=Storage.prototype.removeItem;
    Storage.prototype.removeItem=function(){throw new DOMException('denied','SecurityError');};
  });
  await confirm(page).click();
  await expect(page.locator('.save-notice')).toContainText('削除できませんでした');
  expect(await storage(page)).toEqual(before);
  await page.evaluate(()=>{Storage.prototype.removeItem=globalThis.__originalRemove;});
  await confirm(page).click();
  await expect(remove(page,1)).toHaveCount(0);
  await remove(page,0).click();
  await expect(confirm(page)).toBeVisible();
  await page.evaluate(()=>{
    const parts=localStorage.getItem('hacknslash3d_save').split('|');parts[1]='999';
    localStorage.setItem('hacknslash3d_save',parts.join('|'));
  });
  await confirm(page).click();
  await expect(page.locator('.save-notice')).toContainText('更新されました');
  await expect(page.locator('[data-save-slot="0"]')).toContainText('999');
  expect((await storage(page))[keys[0]]).toBeTruthy();
  await remove(page,0).click();await confirm(page).click();
  await expect(remove(page,0)).toHaveCount(0);
});

test.describe('mobile save deletion',()=>{
  test.use({viewport:{width:390,height:844},hasTouch:true,isMobile:true});
  test('invalid saves can be deleted with touch and pad confirm/cancel in narrow screens',async({page},info)=>{
    await page.addInitScript(()=>{
      globalThis.__deletePad={index:0,id:'Standard delete test',mapping:'standard',connected:true,axes:[0,0,0,0],buttons:Array.from({length:17},()=>({pressed:false,value:0}))};
      Object.defineProperty(navigator,'getGamepads',{value:()=>[globalThis.__deletePad]});
    });
    const press=async i=>{
      await page.evaluate(i=>{globalThis.__deletePad.buttons[i]={pressed:true,value:1};},i);
      await page.waitForTimeout(80);
      await page.evaluate(i=>{globalThis.__deletePad.buttons[i]={pressed:false,value:0};},i);
      await page.waitForTimeout(80);
    };
    await setup(page);
    await expect(page.locator('[data-save-slot="2"]')).toBeDisabled();
    for(const size of [{width:390,height:844},{width:320,height:640},{width:844,height:390}]){
      await page.setViewportSize(size);
      await remove(page,2).tap();
      await expect(confirm(page)).toBeVisible();
      for(const button of await page.locator('.save-delete-actions button').all()){
        const b=(await button.boundingBox())!;
        expect(b.x).toBeGreaterThanOrEqual(0);expect(b.x+b.width).toBeLessThanOrEqual(size.width);
        expect(b.y).toBeGreaterThanOrEqual(0);expect(b.y+b.height).toBeLessThanOrEqual(size.height);
      }
      await captureGameFrame(page,{path:info.outputPath(`delete-${size.width}.png`)});
      await press(1);
      await expect(remove(page,2)).toBeVisible();
      expect((await storage(page))[keys[2]]).toBe('broken save');
    }
    await remove(page,2).tap();
    await expect(page.getByRole('button',{name:'キャンセル',exact:true})).toBeFocused();
    await press(15);await expect(confirm(page)).toBeFocused();
    await press(0);
    await expect(page.locator('[data-save-slot="2"]')).toBeEnabled();
    expect((await storage(page))[keys[2]]).toBeUndefined();
  });
});
