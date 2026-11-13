import test from 'node:test';
import assert from 'node:assert/strict';
import {aggregate,score,validateExperiment} from './metrics.mjs';
import {tune} from './tune.mjs';

const spec={name:'pressure',min:0,max:2,step:.01,initial:1.8};
const experiment={schemaVersion:1,game:'test',parameters:[spec],policies:['careful','naive'],seats:['solo'],
  trainSeeds:[1,2,3,4],validationSeeds:[11,12,13,14],
  goals:[{cohort:'careful',metric:'margin',min:.4,max:.6,scale:1,weight:1}],
};
test('unfinished play is visible and cannot count as balanced wins',()=>{
  const trials=['victory','defeat','draw','limit'].map(status=>({policy:'careful',seat:'solo',seed:1,status,metrics:{margin:.5}}));
  const report=aggregate(trials);
  assert.equal(report.cohorts.careful.winRate,.25);assert.equal(report.cohorts.careful.drawRate,.25);
  assert.equal(report.cohorts.careful.completionRate,.75);assert.equal(report.valid,false);
  assert.ok(report.cohorts.careful.winInterval[0]<.25);assert.ok(report.cohorts.careful.winInterval[1]>.25);
  assert.throws(()=>aggregate([{...trials[0],metrics:{margin:NaN}}]),/invalid_trial/);
});
test('objectives use explicit ranges/scales, strategy gaps and complete metrics',()=>{
  const trials=['careful','naive'].map((policy,i)=>({policy,seat:'solo',seed:1,status:i?'defeat':'victory',metrics:{margin:.5}}));
  const report=aggregate(trials);
  assert.equal(score(report,experiment.goals),0);
  assert.equal(score(report,[{cohort:'careful',metric:'winRate',subtract:{cohort:'naive',metric:'winRate'},min:.2,max:.5,scale:1,weight:2}]),.5);
  assert.throws(()=>score(report,[{...experiment.goals[0],metric:'missing'}]),/missing_metric/);
  assert.throws(()=>validateExperiment({...experiment,validationSeeds:[1]}),/overlapping/);
  assert.throws(()=>validateExperiment({...experiment,parameters:[{...spec,min:2}]}),/parameter/);
});
test('real CMA ES searches only training seeds then validates on unused seeds',async()=>{
  const records=[],calls=[];
  const result=await tune({experiment,generations:12,maxTrials:2000,runTrial:async trial=>{
    calls.push(trial);return {status:'victory',metrics:{margin:1-trial.params.pressure/2}};
  },onRecord:r=>records.push(r)});
  assert.equal(result.accepted,true);assert.equal(result.meetsGoals,true);
  assert.ok(result.training.best.loss<result.training.baseline.loss);
  assert.equal(result.validation.best.loss,0);
  assert.equal(records.at(-1).type,'run_end');
  const firstValidation=records.findIndex(r=>r.type==='trial'&&r.split==='validation');
  assert.ok(firstValidation>0);
  assert.equal(records.slice(firstValidation).some(r=>r.type==='trial'&&r.split==='train'),false);
  assert.equal(calls.filter(c=>experiment.validationSeeds.includes(c.seed)).length,16);
  const repeat=await tune({experiment,generations:12,maxTrials:2000,runTrial:async trial=>({status:'victory',metrics:{margin:1-trial.params.pressure/2}})});
  assert.deepEqual(result.profile,repeat.profile);
});
test('validation regression and exhausted budgets never publish a tuned profile',async()=>{
  const result=await tune({experiment,generations:5,maxTrials:500,runTrial:async trial=>({status:'victory',metrics:{margin:experiment.validationSeeds.includes(trial.seed)?.5+(1.8-trial.params.pressure)/1.5:1-trial.params.pressure/2}})});
  assert.equal(result.accepted,false);assert.equal(result.status,'rejected');assert.equal(result.profile,null);
  const calls=[];
  const limited=await tune({experiment,generations:10,maxTrials:8,runTrial:async trial=>{calls.push(trial);return {status:'victory',metrics:{margin:.5}};}});
  assert.equal(limited.status,'limit');assert.equal(limited.profile,null);assert.ok(calls.length<=8);
});

test('seat cohorts detect first-player advantage even when pooled win rates are 50%',()=>{
  const report=aggregate(['first','second'].map(seat=>({seat,policy:'player',status:seat==='first'?'victory':'defeat',metrics:{margin:0}})));
  assert.equal(report.cohorts.player.winRate,.5);
  assert.equal(score(report,[{cohort:'player@first',metric:'winRate',subtract:{cohort:'player@second',metric:'winRate'},min:-.1,max:.1,scale:1,weight:1}]),.81);
});
test('correctness guards cannot be compensated by a good experience proxy score',async()=>{
  const r=await tune({experiment:{...experiment,guards:[{cohort:'careful',metric:'badFeedback',max:0}]},generations:1,maxTrials:200,
    runTrial:async()=>({status:'victory',metrics:{margin:.5,badFeedback:1}})});
  assert.equal(r.status,'incomplete');assert.equal(r.accepted,false);assert.equal(r.profile,null);
});
