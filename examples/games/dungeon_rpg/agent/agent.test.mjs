import test from 'node:test';
import assert from 'node:assert/strict';
import {createHeadlessSession} from './headless.mjs';
import {JevClient,makeJevRequest} from './jev.mjs';

test('headless observation is detached, masked and rejects stale or fabricated IDs',()=>{
  assert.equal(globalThis.document,undefined);
  const session=createHeadlessSession(),before=session.observe();
  assert.equal(before.game,'dungeon_rpg');assert.throws(()=>before.revision=99,TypeError);
  assert.throws(()=>session.step({revision:0,choiceId:'go:7:7'}),/illegal_choice/);
  assert.deepEqual(session.observe(),before);
  session.step({revision:0,choiceId:'enter'});
  assert.throws(()=>session.step({revision:0,choiceId:'go:3:1'}),/stale_revision/);
  assert.equal(JSON.stringify(session.observe()).includes('"seed"'),false);
  for(const seed of [NaN,0.5,2**32])assert.throws(()=>createHeadlessSession({seed}),/seed/);
});
test('Jev uses exactly the offered choices and dungeon instructions',async()=>{
  const observation=createHeadlessSession().observe();let count=0;
  const client=new JevClient({apiKey:'private-test-key',maxRequests:1,fetchImpl:async(url,options)=>{
    count++;assert.equal(url,'https://api.typesafe.ai/v1/systemone');const r=JSON.parse(options.body);
    assert.match(r.questions.next_action.instructions,/seal HOME/);
    assert.deepEqual(Object.keys(r.questions.next_action.criteria),observation.choices.map(c=>c.id));
    assert.equal(JSON.stringify(r).includes('private-test-key'),false);
    return Response.json({model:'jev-test',answers:{next_action:{type:'choice',choice:'enter',confidence:.9,probabilities:Object.fromEntries(observation.choices.map(c=>[c.id,c.id==='enter'?1:0]))}},usage:{input_tokens:20,output_tokens:0}});
  }});
  assert.equal((await client.choose(observation)).choiceId,'enter');
  await assert.rejects(client.choose(observation),/request_limit/);assert.equal(count,1);
  assert.match(makeJevRequest(observation).questions.next_action.instructions,/unknown/);
});

import {runAgent,replayRecords} from './runner.mjs';
import {testPolicy} from './test-policy.mjs';
test('a time budget aborts an in-flight request without applying an extra action',async()=>{
  const session=createHeadlessSession(),before=session.observe(),records=[];
  const client=new JevClient({apiKey:'private-test-key',fetchImpl:(_url,{signal})=>new Promise((_resolve,reject)=>{
    signal.addEventListener('abort',()=>reject(signal.reason),{once:true});
  })});
  const result=await runAgent({session,maxSeconds:.03,choose:(observation,options)=>client.choose(observation,options),onRecord:r=>records.push(r)});
  assert.equal(result.status,'limit');assert.equal(result.limitReason,'time');
  assert.deepEqual(session.observe(),before);assert.equal(records.at(-1).status,'limit');
});
test('a complete expedition uses only observed choices and replays every state without a model',async()=>{
  const records=[];
  const result=await runAgent({session:createHeadlessSession(),choose:testPolicy,onRecord:r=>records.push(r),maxDecisions:300});
  assert.equal(result.status,'victory',JSON.stringify(result.observation));
  assert.equal((await replayRecords(records)).status,'victory');
  const changed=structuredClone(records);changed[2].after.state.torch--;
  await assert.rejects(replayRecords(changed),/replay_failed/);
  await assert.rejects(replayRecords(records.slice(0,-1)),/replay_failed/);
});
test('limits and provider failures preserve an incomplete final state',async()=>{
  const records=[];
  const r=await runAgent({session:createHeadlessSession(),choose:testPolicy,maxDecisions:1,onRecord:r=>records.push(r)});
  assert.equal(r.status,'limit');assert.equal((await replayRecords(records)).status,'limit');
  await assert.rejects(runAgent({session:createHeadlessSession(),choose:()=>{throw Error('private provider body');},onRecord:r=>{if(r.type==='run_end'){assert.equal(r.status,'error');assert.equal(JSON.stringify(r).includes('private provider body'),false);}}}),/private provider body/);
});

test('request budgets and interruption produce replayable incomplete evidence',async()=>{
  const records=[];
  const client=new JevClient({apiKey:'private-test-key',maxRequests:2,fetchImpl:async(_url,{body})=>{
    const request=JSON.parse(body),observation={...request.state,choices:Object.entries(request.questions.next_action.criteria).map(([id,c])=>({id,label:c.description,action:c.action}))};
    const decision=testPolicy(observation);
    return Response.json({model:'jev-test',answers:{next_action:{type:'choice',choice:decision.choiceId,confidence:1,probabilities:decision.probabilities}},usage:{input_tokens:20,output_tokens:0}});
  }});
  const result=await runAgent({session:createHeadlessSession(),choose:(o,options)=>client.choose(o,options),requestCount:()=>client.requests,onRecord:r=>records.push(r)});
  assert.equal(result.status,'limit');assert.equal(result.limitReason,'requests');assert.equal(result.usage.requests,2);
  assert.equal((await replayRecords(records)).status,'limit');
  const controller=new AbortController();controller.abort();
  await assert.rejects(replayRecords(records,{signal:controller.signal}),/interrupted/);
  const interrupted=await runAgent({session:createHeadlessSession(),choose:()=>assert.fail('cancelled runs must not call a provider'),signal:controller.signal});
  assert.equal(interrupted.limitReason,'interrupted');assert.equal(interrupted.decisions,0);
});
