import test from 'node:test';
import assert from 'node:assert/strict';
import {createExperienceProbe,auditReceipts} from './experience.mjs';
import {reviewExperience} from './review.mjs';

const party=[{hp:20,maxHp:24},{hp:20,maxHp:28}];
const before={mode:'battle',party,battle:{round:1,boss:false,phase:'planning',foes:[{hp:12,maxHp:12}]},effects:[]};
const after={...before,party:[{hp:18,maxHp:24},{hp:20,maxHp:28}],battle:{...before.battle,phase:'report',foes:[{hp:6,maxHp:12}]},effects:[
  {id:1,team:'party',target:0,kind:'hit',amount:8},
  {id:2,team:'party',target:0,kind:'heal',amount:6},
  {id:3,team:'enemy',target:0,kind:'hit',amount:6},
]};
test('feedback checks damage then healing even when the net HP change is small',()=>{
  assert.equal(auditReceipts(before,after).mismatches,0);
  const missing={...after,effects:after.effects.slice(1)};
  assert.equal(auditReceipts(before,missing).mismatches,1);
  const wrongTarget=structuredClone(after);wrongTarget.effects[0].target=1;
  assert.equal(auditReceipts(before,wrongTarget).mismatches,2);
});
test('challenge and recovery are measured at resolved rounds rather than decision count or wins',()=>{
  const probe=createExperienceProbe();
  probe.record(before,after);
  const metrics=probe.metrics();
  assert.equal(metrics.pressureRoundRate,1);assert.ok(metrics.recoveryShare>0);
  assert.equal(metrics.feedbackMismatchRate,0);
  assert.equal(metrics.resolvedRounds,1);
  probe.record(after,{...after,revision:3});
  assert.equal(probe.metrics().resolvedRounds,1);
});

test('a model review judges experience hypotheses and leaves unseen presentation unobserved',async()=>{
  const client={async choose(o,options){
    assert.match(options.instructions,/PLAYER EXPERIENCE/);assert.match(options.instructions,/Do not infer animation/);
    assert.equal(o.state.evidence.rendered,false);assert.ok(o.choices.some(c=>c.id==='unknown'));
    return {choiceId:'unknown',confidence:.6,probabilities:Object.fromEntries(o.choices.map(c=>[c.id,c.id==='unknown'?1:0])),model:'jev-test'};
  }};
  const review=await reviewExperience(client,{metrics:{pressureRoundRate:.5},experience:{rendered:false,highlights:[]}});
  assert.equal(review.kind,'model-hypothesis');assert.equal(review.judgments.challenge.rating,'unknown');
  assert.equal(review.renderedFeedback,'not-observed');assert.equal(review.humanExperience,'not-observed');
});
