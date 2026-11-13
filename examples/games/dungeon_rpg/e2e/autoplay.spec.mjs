import {test,expect} from '@playwright/test';
import {createBrowserSession} from '../agent/browser.mjs';
import {createHeadlessSession} from '../agent/headless.mjs';
import {runAgent,replayRecords} from '../agent/runner.mjs';
import {testPolicy} from '../agent/test-policy.mjs';

test('browser and headless autoplay share rules, including stale choices and Studio pause',async({page})=>{
  const errors=[];page.on('pageerror',error=>errors.push(error.message));
  await page.goto('/');
  const balance={enemyHpScale:1.2,enemyDamageScale:1.3,encounterSteps:10};
  const browser=await createBrowserSession({page,seed:19,balance,stepMs:0});
  const headless=createHeadlessSession({seed:19,balance});
  for(let i=0;i<30;i++){
    const before=headless.observe();expect(await browser.observe()).toEqual(before);
    const command={revision:before.revision,choiceId:testPolicy(before).choiceId};
    expect(await browser.step(command)).toEqual(headless.step(command));
    expect(await browser.experience()).toEqual(headless.experience());
    if(i===0){
      const after=await browser.observe();
      await expect(browser.step(command)).rejects.toThrow(/stale_revision/);
      expect(await browser.observe()).toEqual(after);
      expect(await browser.experience()).toEqual(headless.experience());
      await page.evaluate(()=>globalThis.kaguraSceneRuntime.pause(true));
      const next={revision:after.revision,choiceId:after.choices[0].id};
      await expect(browser.step(next)).rejects.toThrow(/paused/);
      expect(await browser.observe()).toEqual(after);
      await page.evaluate(()=>globalThis.kaguraSceneRuntime.pause(false));
    }
  }
  expect(errors).toEqual([]);
});

test('a full recorded expedition replays on screen with the same victory state',async({page})=>{
  const records=[];
  const result=await runAgent({session:createHeadlessSession(),choose:testPolicy,onRecord:r=>records.push(r)});
  expect(result.status).toBe('victory');
  await page.goto('/');
  const session=await createBrowserSession({page,stepMs:0});
  expect((await replayRecords(records,{session})).status).toBe('victory');
  const view=await page.evaluate(()=>globalThis.fathom.read());
  expect(view.mode).toBe('cleared');expect(view.clears).toBe(1);
  await expect(page.locator('#objective')).toContainText('達成');
  await page.screenshot({path:'output/dungeon_rpg/autoplay-victory.png'});
});
