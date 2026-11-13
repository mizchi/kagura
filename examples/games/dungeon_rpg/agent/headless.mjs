import * as core from '../_build/js/release/build/mizchi/dungeon_rpg/agent_host/agent_host.js';
import defaultMasterData from '../assets/master-data.json' with {type:'json'};
import {AgentError,int32} from '../../../../scripts/agents/errors.mjs';
export function freeze(value){if(value&&typeof value==='object'){for(const child of Object.values(value))freeze(child);Object.freeze(value);}return value;}
export function createHeadlessSession({seed=731,balance={},masterData=defaultMasterData}={}){
  int32(seed,'seed');let game;
  try{game=core.create_full(seed,JSON.stringify(balance),JSON.stringify(masterData));}
  catch{throw new AgentError('invalid_input','invalid balance profile or master data');}
  const observe=()=>freeze(JSON.parse(core.observe(game)));
  return Object.freeze({observe,masterData:()=>freeze(JSON.parse(core.master(game))),feedback:()=>freeze(JSON.parse(core.feedback(game))),experience(after=0){int32(after,'experience cursor');if(after<0)throw new AgentError('invalid_input','negative experience cursor');return freeze(JSON.parse(core.experience(game,after)));},step({revision,choiceId}){
    int32(revision,'revision');if(revision<0||typeof choiceId!=='string'||!choiceId)throw new AgentError('invalid_input');
    const result=core.step(game,revision,choiceId);
    if(result!=='applied')throw new AgentError(['stale_revision','illegal_choice','terminal'].find(code=>result.includes(code))??'game_failed');
    return observe();
  }});
}
