import test from 'node:test';
import assert from 'node:assert/strict';
import {planPresentation} from '../assets/host.mjs';
const state=(extra={})=>({mode:'explore',generation:1,floor:0,x:1,z:1,facing:1,event:'',effects:[],battle:null,...extra});
test('simultaneous hits retain distinct positions for each target, including more than three hits',()=>{
  const effects=Array.from({length:6},(_,i)=>({id:i+1,team:'enemy',target:0,kind:'hit',amount:12}));
  const plan=planPresentation(state(),state({mode:'battle',effects}));
  assert.deepEqual(plan.cues.map(c=>c.groupSize),[6,6,6,6,6,6]);
  assert.deepEqual(plan.cues.map(c=>c.stack),[0,1,2,3,4,5]);
});
test('all receipts from a resolved round play exactly once, including damage followed by healing',()=>{
  const before=state({mode:'battle'});
  const after=state({mode:'battle',effects:[{id:7,kind:'hit',team:'party',target:0,amount:6},{id:8,kind:'heal',team:'party',target:0,amount:6}]});
  const plan=planPresentation(before,after,{lastCueId:6});
  assert.equal(plan.cues.length,2);assert.equal(plan.lastCueId,8);
  assert.equal(planPresentation(after,after,{lastCueId:8}).cues.length,0);
  assert.ok(plan.duration<=1000);
});
test('scene transitions prioritize return, stairs and battle instead of playing them for menu selection',()=>{
  assert.equal(planPresentation(state({mode:'town'}),state()).transition.kind,'enter');
  assert.equal(planPresentation(state(),state({floor:1})).transition.kind,'stairs');
  assert.equal(planPresentation(state(),state({mode:'battle'})).transition.kind,'battle');
  assert.equal(planPresentation(state(),state({mode:'cleared'})).transition.kind,'return');
  assert.equal(planPresentation(state({mode:'battle'}),state({mode:'battle'})).transition,null);
});
test('reduced motion preserves numeric feedback with no shake and a short fade',()=>{
  const plan=planPresentation(state(),state({mode:'battle',effects:[{id:1,kind:'hit',team:'party',target:0,amount:4}]}),{reducedMotion:true});
  assert.equal(plan.shake,false);assert.ok(plan.duration<=200);assert.ok(plan.transition.duration<=100);assert.equal(plan.cues[0].amount,4);
});
