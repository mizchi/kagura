import test from 'node:test';
import assert from 'node:assert/strict';
import {createAdapter as dungeon} from './adapters/dungeon-rpg.mjs';
import {createAdapter as card} from './adapters/card-game.mjs';
import {aggregate,score} from './metrics.mjs';
import {createHeadlessSession} from '../../examples/games/dungeon_rpg/agent/headless.mjs';
import {replayRecords} from '../../examples/games/dungeon_rpg/agent/runner.mjs';

for(const [name,create] of [['dungeon_rpg',dungeon],['card_game',card]]){
  test(`${name}: actual game trials are deterministic and report all objective metrics`,async()=>{
    const a=create(),params=Object.fromEntries(a.experiment.parameters.map(p=>[p.name,p.initial])),trials=[];
    for(const policy of a.experiment.policies){
      const input={params,seed:731,policy,seat:'solo'};
      const trial=await a.runTrial(input);
      assert.deepEqual(await a.runTrial(input),trial);trials.push({...trial,policy,seat:'solo'});
    }
    assert.equal(aggregate(trials).valid,true);
    assert.ok(Number.isFinite(score(aggregate(trials),a.experiment.goals)));
  });
}
test('profiles reject invalid values before simulation and expose the applied rules',()=>{
  const s=createHeadlessSession({balance:{enemyHpScale:1.5,enemyDamageScale:2,encounterSteps:12}});
  const o=s.observe();assert.equal(o.state.balance.enemyHpScale,1.5);assert.equal(o.state.dangerMax,12);
  for(const balance of [{enemyHpScale:NaN},{enemyHpScale:.1},{encounterSteps:5.5},{unrecognized:1}])assert.throws(()=>createHeadlessSession({balance}),/invalid balance/);
});

test('experience captures retain replayable actions and keep rendered evidence unobserved',async()=>{
  const a=dungeon({captureExperience:true});
  const trial=await a.runTrial({params:{enemyHpScale:1.4,enemyDamageScale:1.45,encounterSteps:8},seed:2027,policy:'tactical',seat:'solo'});
  assert.equal(trial.experience.rendered,false);assert.ok(trial.experience.highlights.length>0);
  assert.equal((await replayRecords(trial.trace)).status,trial.status);
  assert.equal(trial.metrics.feedbackMismatchRate,0);
});
