import {AgentError,int32} from '../../../../scripts/agents/errors.mjs';
import {freeze} from './headless.mjs';

/** The caller owns a separate Playwright page/context, never the user's save. */
export async function createBrowserSession({page,seed=731,balance={},masterData,stepMs=300}){
  int32(seed,'seed');if(!Number.isFinite(stepMs)||stepMs<0||stepMs>10000)throw new AgentError('invalid_input','invalid browser delay');
  await page.waitForFunction(()=>globalThis.fathom?.agent?.version===1);
  await page.evaluate(({seed,balance,masterData})=>globalThis.fathom.agent.reset(seed,balance,masterData),{seed,balance,masterData});
  const observe=async()=>freeze(await page.evaluate(()=>globalThis.fathom.agent.observe()));
  return Object.freeze({observe,experience:async(after=0)=>{int32(after,'experience cursor');if(after<0)throw new AgentError('invalid_input');return freeze(await page.evaluate(cursor=>globalThis.fathom.experience.read(cursor),after));},masterData:async()=>freeze(await page.evaluate(()=>globalThis.fathom.agent.masterData())),async step({revision,choiceId}){
    int32(revision,'revision');if(revision<0||typeof choiceId!=='string'||!choiceId)throw new AgentError('invalid_input');
    let result;
    try{result=await page.evaluate(command=>globalThis.fathom.agent.step(command),{revision,choiceId});}
    catch(error){throw new AgentError(['stale_revision','illegal_choice','terminal','paused'].find(code=>error.message.includes(code))??'browser_failed');}
    if(stepMs)await page.waitForTimeout(stepMs);
    return freeze(result);
  }});
}
