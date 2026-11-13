import {test,expect} from '@playwright/test';
import {createBrowserSession} from '../agent/browser.mjs';
import {policyDecision} from '../agent/policies.mjs';
import {auditReceipts} from '../../../../scripts/balance/experience.mjs';

for(const [name,viewport] of [['desktop',{width:1280,height:800}],['phone',{width:390,height:844}]]){
  test(`${name}: a tuned round presents the resolved amount at the correct target`,async({page})=>{
    await page.setViewportSize(viewport);await page.goto('/');
    const session=await createBrowserSession({page,stepMs:0,balance:{enemyHpScale:1.4,enemyDamageScale:1.45,encounterSteps:8}});
    await page.waitForFunction(()=>globalThis.__kaguraGfx?.lastRenderCpuMs?.()>0);
    for(let i=0;i<80;i++){
      const observation=await session.observe();
      const before=await page.evaluate(()=>fathom.read());
      const command={revision:observation.revision,choiceId:policyDecision(observation,'tactical').choiceId};
      const result=await page.evaluate(command=>{
        fathom.agent.step(command);
        return {state:fathom.read(),numbers:[...document.querySelectorAll('.damage-number')].map(el=>({target:el.dataset.target,text:el.textContent}))};
      },command);
      if(before.battle?.phase!=='planning'||!['report','won'].includes(result.state.battle?.phase))continue;
      const audit=auditReceipts(before,result.state);expect(audit.mismatches).toBe(0);expect(audit.cues.length).toBeGreaterThan(0);
      const expected=audit.cues.map(c=>({target:`${c.team}:${c.target}`,text:`${c.kind==='heal'?'+':'−'}${c.amount}${c.kind==='guard'?'GUARD':''}`}));
      expect(result.numbers).toEqual(expected);
      const fixed=await session.observe();
      await page.evaluate(()=>new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(resolve))));
      const boxes=await page.locator('.damage-number').evaluateAll(elements=>elements.map(el=>{
        const r=el.getBoundingClientRect();return {target:el.dataset.target,left:r.left,right:r.right,top:r.top,bottom:r.bottom};
      }));
      for(let a=0;a<boxes.length;a++)for(let b=a+1;b<boxes.length;b++)if(boxes[a].target===boxes[b].target){
        const x=boxes[a],y=boxes[b];
        expect(x.right<=y.left||y.right<=x.left||x.bottom<=y.top||y.bottom<=x.top).toBe(true);
      }
      await page.screenshot({path:`output/dungeon_rpg/experience-feedback-${name}.png`});
      await expect.poll(()=>page.evaluate(()=>fathom.presentation().active)).toBe(0);
      await expect(page.locator('.damage-number')).toHaveCount(0);
      expect(await session.observe()).toEqual(fixed);
      return;
    }
    throw Error('no resolved round observed');
  });
}
