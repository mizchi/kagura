import defaultMasterData from '../../../examples/games/dungeon_rpg/assets/master-data.json' with {type:'json'};
import {masterDataAdapter} from '../../../examples/games/dungeon_rpg/assets/master-data-adapter.mjs';
import {parameterSpecs} from '../../../game/master-data/contract.mjs';
import {createHeadlessSession} from '../../../examples/games/dungeon_rpg/agent/headless.mjs';
import {policyDecision} from '../../../examples/games/dungeon_rpg/agent/policies.mjs';
import {runAgent} from '../../../examples/games/dungeon_rpg/agent/runner.mjs';
import {createExperienceProbe} from '../experience.mjs';
import {analyzeTrace} from '../../experience/adapters/dungeon-rpg.mjs';
import {projectMetrics} from '../../../game/experience/index.mjs';

export const experiment={
  schemaVersion:1,game:'dungeon_rpg',gameVersion:3,
  parameters:parameterSpecs(masterDataAdapter,defaultMasterData),
  policies:['tactical','attack'],seats:['solo'],
  trainSeeds:[19,42,137,256,512,731,997,1234],
  validationSeeds:[2027,3037,4001,5003,6007,7001,8009,9001],
  goals:[
    {axis:'challenge',cohort:'tactical',metric:'pressureRoundRate',min:.35,max:.85,scale:1,weight:3},
    {axis:'guardrail',cohort:'tactical',metric:'criticalRoundRate',min:0,max:.3,scale:1,weight:2},
    {axis:'pacing',cohort:'tactical',metric:'normalEncounterRounds',min:1.5,max:3.5,scale:3,weight:2},
    {axis:'pacing',cohort:'tactical',metric:'bossEncounterRounds',min:2,max:6,scale:4,weight:1},
    {axis:'agency',cohort:'tactical',metric:'recoveryShare',min:.1,max:.6,scale:1,weight:1},
    {axis:'agency',cohort:'tactical',metric:'hpRemaining',subtract:{cohort:'attack',metric:'hpRemaining'},min:.2,max:1,scale:1,weight:1},
    {axis:'guardrail',cohort:'tactical',metric:'winRate',min:.4,max:1,scale:1,weight:.5},
  ],
  guards:[{cohort:'tactical',metric:'feedbackMismatchRate',max:0},{cohort:'attack',metric:'feedbackMismatchRate',max:0}],
  review:[
    {id:'counterplay',question:'被弾への対処と回復が、次の判断や立て直しにつながるか',evidence:'trace'},
    {id:'feedback',question:'誰に何が起きたか、ダメージ・回復・防御の表示と音から理解できるか',evidence:'rendered'},
    {id:'challenge',question:'先を試したくなる手応えがあるか。面倒さや理不尽さになっていないか',evidence:'human'},
  ],
};

export function createAdapter({jevClient,maxDecisions=400,captureExperience=false,experienceMetrics,masterData=defaultMasterData}={}){
  masterData=structuredClone(masterData);
  const config={...structuredClone(experiment),parameters:parameterSpecs(masterDataAdapter,masterData)};
  return {experiment:config,async runTrial({params,seed,policy,signal}){
    const session=createHeadlessSession({seed,balance:params,masterData}),probe=createExperienceProbe(),trace=[];let previous=session.feedback();
    const result=await runAgent({session,seed,balance:params,signal,maxDecisions,maxSeconds:120,model:policy==='jev'?(jevClient.model??'jev-latest'):`policy:${policy}`,
      choose:(o,options)=>policy==='jev'?jevClient.choose(o,options):policyDecision(o,policy),
      onRecord:record=>{
        if(captureExperience||experienceMetrics)trace.push(record);
        if(record.type==='decision'){const next=session.feedback();probe.record(previous,next,{choiceId:record.choiceId});previous=next;}
      }});
    const o=result.observation,s=o.state;
    const loopArc=captureExperience||experienceMetrics?analyzeTrace(trace,{runId:`balance:${seed}:${policy}`}):undefined;
    const metrics={
      hpRemaining:result.status==='defeat'?0:s.party.reduce((sum,h)=>sum+h.hp,0)/s.party.reduce((sum,h)=>sum+h.maxHp,0),
      survivors:result.status==='defeat'?0:s.party.filter(h=>h.hp>0).length/6,
      progress:s.hasSeal?1:s.floor===2?.5:0,decisions:result.decisions,...probe.metrics(),
    };
    if(experienceMetrics){
      const projected=projectMetrics(loopArc,experienceMetrics);
      if(Object.keys(projected).some(name=>Object.hasOwn(metrics,name)))throw Error('Experience metric name conflicts with an existing metric');
      Object.assign(metrics,projected);
    }
    return {status:result.status,...(result.limitReason?{limitReason:result.limitReason}:{}),...(captureExperience?{experience:probe.evidence(),loopArc,trace}:{}),metrics};
  }};
}
