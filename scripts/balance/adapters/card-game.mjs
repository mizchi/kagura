import * as core from '../../../examples/games/card_game/_build/js/release/build/mizchi/card_game/agent_host/agent_host.js';
import {int32} from '../../agents/errors.mjs';
import {fail} from '../metrics.mjs';

export const experiment={
  schemaVersion:1,game:'card_game',gameVersion:1,
  parameters:[{name:'enemyHpScale',min:.5,max:3,step:.05,initial:1},{name:'playerHp',min:40,max:100,step:1,initial:80}],
  policies:['smart','aggressive','defensive'],seats:['solo'],
  trainSeeds:[19,42,137,256,512,731,997,1234],validationSeeds:[2027,3037,4001,5003,6007,7001,8009,9001],
  goals:[
    {axis:'pacing',cohort:'smart',metric:'turns',min:3,max:7,scale:5,weight:2},
    {axis:'agency',cohort:'smart',metric:'cardsPerTurn',min:2,max:4,scale:3,weight:1},
    {axis:'challenge',cohort:'smart',metric:'hpRemaining',min:.2,max:.75,scale:1,weight:2},
    {axis:'challenge',cohort:'aggressive',metric:'hpRemaining',min:.1,max:.8,scale:1,weight:1},
    {axis:'challenge',cohort:'defensive',metric:'hpRemaining',min:.1,max:.8,scale:1,weight:1},
    {axis:'pacing',cohort:'defensive',metric:'turns',min:3,max:10,scale:5,weight:2},
    {axis:'guardrail',cohort:'smart',metric:'winRate',min:.35,max:1,scale:1,weight:.5},
  ],
  review:[
    {id:'card-feedback',question:'攻撃と防御の結果を敵の予告と照らして理解できるか',evidence:'rendered'},
    {id:'card-choice',question:'毎ターン試す価値のある選択があり、消化作業になっていないか',evidence:'human'},
    {id:'defensive-pacing',question:'防御を選ぶ遊び方が長い消化戦を強いられていないか',evidence:'trace'},
  ],
};
export function createAdapter(){return {experiment:structuredClone(experiment),runTrial({params,seed,policy,signal}){
  int32(seed,'seed');if(signal?.aborted)fail('interrupted');
  if(!experiment.policies.includes(policy)||!Number.isFinite(params.enemyHpScale)||params.enemyHpScale<.5||params.enemyHpScale>3||!Number.isInteger(params.playerHp)||params.playerHp<40||params.playerHp>100)fail('invalid_parameter');
  const trial=JSON.parse(core.balance_trial(seed,policy,params.enemyHpScale,params.playerHp));
  trial.metrics.cardsPerTurn=trial.metrics.cardsPlayed/Math.max(1,trial.metrics.turns);
  return trial;
}};}
