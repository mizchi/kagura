#!/usr/bin/env node
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {mkdir,open,readFile,writeFile} from 'node:fs/promises';
import {dirname,resolve,join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {AgentError,int32} from './agents/errors.mjs';

const root=fileURLToPath(new URL('../',import.meta.url));
const help=`Kagura game balance experiments — differentiable_ecs CMA-ES

just balance-tune [dungeon_rpg | card_game] [options]
  --game NAME          Game adapter (default: dungeon_rpg)
  --master-data FILE   FATHOM master JSON exported from the table editor
  --experiment FILE    Experiment JSON: parameters, policies, seats, seeds, goals
  --generations N      Search generations (default: 8, maximum: 1000)
  --max-trials N       Total game trials, including validation (default: 2000)
  --max-seconds N      Overall deadline (default: 120, maximum: 3600)
  --seed N             Optimizer seed (default: 731)
  --out DIRECTORY      New directory for JSONL, summary and accepted profile
  --jev-check N        Play/review FATHOM experience with Jev on N validation seeds
  --max-requests N     Jev API request budget including retries (default: 160)
  --dry-run            Print the experiment; no API key or game trials
  --no-build           Use existing MoonBit builds
  --quiet              Only print the final JSON summary
  --help               Show this help

Default search uses explicit deterministic policies, no API calls. Jev is only
used with --jev-check, keeping model audits separate from the search objective.
Profiles are candidates for review. Normal game defaults are not overwritten.
`;

function parseArgs(args){
  const o={game:'dungeon_rpg',generations:8,maxTrials:2000,maxSeconds:120,seed:731,jevCheck:0,maxRequests:160};
  const values=new Map([['--game','game'],['--master-data','masterPath'],['--experiment','experiment'],['--generations','generations'],['--max-trials','maxTrials'],['--max-seconds','maxSeconds'],['--seed','seed'],['--out','out'],['--jev-check','jevCheck'],['--max-requests','maxRequests']]);
  const flags=new Map([['--help','help'],['--dry-run','dryRun'],['--no-build','noBuild'],['--quiet','quiet']]);
  for(let i=0;i<args.length;i++){
    if(flags.has(args[i])){o[flags.get(args[i])]=true;continue;}
    const key=values.get(args[i]);if(!key||!args[i+1]||args[i+1].startsWith('--'))throw new AgentError('invalid_input','unknown or incomplete option');
    o[key]=['game','experiment','out','masterPath'].includes(key)?args[++i]:Number(args[++i]);
  }
  if(o.help)return o;
  if(o.masterPath&&o.game!=='dungeon_rpg')throw new AgentError('invalid_input','master data is supported by the FATHOM adapter');
  int32(o.seed,'seed');
  if(!['dungeon_rpg','card_game'].includes(o.game)||!Number.isInteger(o.generations)||o.generations<1||o.generations>1000||
    !Number.isInteger(o.maxTrials)||o.maxTrials<1||o.maxTrials>100000||!Number.isFinite(o.maxSeconds)||o.maxSeconds<=0||o.maxSeconds>3600||
    !Number.isInteger(o.jevCheck)||o.jevCheck<0||o.jevCheck>32||o.jevCheck&&o.game!=='dungeon_rpg'||o.maxTrials<=2*o.jevCheck||!Number.isInteger(o.maxRequests)||o.maxRequests<1||o.maxRequests>10000)throw new AgentError('invalid_input','invalid game or experiment budget');
  return o;
}

async function build(game){
  const exec=promisify(execFile);
  if(game==='dungeon_rpg')await exec(process.execPath,['examples/games/dungeon_rpg/scripts/generate-master-data.mjs'],{cwd:root,maxBuffer:4*1024*1024});
  for(const [directory,target] of [['game/balance','host'],[`examples/games/${game}`,'agent_host']]){
    await exec(process.execPath,['scripts/prepare-moon-deps.mjs',directory],{cwd:root,maxBuffer:4*1024*1024});
    await exec('moon',['-C',directory,'build',target,'--target','js','--release','--deny-warn'],{cwd:root,maxBuffer:4*1024*1024});
  }
}

async function main(){
  const o=parseArgs(process.argv.slice(2));if(o.help){process.stdout.write(help);return;}
  if(!o.noBuild)await build(o.game);
  const {tune}=await import('./balance/tune.mjs');
  const {validateExperiment,aggregate}=await import('./balance/metrics.mjs');
  const module=await import(`./balance/adapters/${o.game==='dungeon_rpg'?'dungeon-rpg':'card-game'}.mjs`);
  let masterData;
  if(o.masterPath){try{masterData=JSON.parse(await readFile(o.masterPath,'utf8'));}catch{throw new AgentError('invalid_input','cannot read master data');}}
  const adapter=module.createAdapter({masterData});
  if(o.experiment){
    let config;try{config=JSON.parse(await readFile(o.experiment,'utf8'));}catch{throw new AgentError('invalid_input','cannot read experiment JSON');}
    validateExperiment(config);
    if(config.game!==o.game||config.parameters.length!==adapter.experiment.parameters.length||config.parameters.some(p=>{
      const allowed=adapter.experiment.parameters.find(a=>a.name===p.name);
      return !allowed||p.min<allowed.min||p.max>allowed.max;
    })||config.seats.some(s=>!adapter.experiment.seats.includes(s))||config.policies.some(p=>!adapter.experiment.policies.includes(p)))throw new AgentError('invalid_input','experiment exceeds the game adapter contract');
    adapter.experiment=config;
  }
  validateExperiment(adapter.experiment);
  if(o.jevCheck>adapter.experiment.validationSeeds.length)throw new AgentError('invalid_input','not enough validation seeds');
  if(o.dryRun){process.stdout.write(`${JSON.stringify(adapter.experiment,null,2)}\n`);return;}
  const out=resolve(o.out??`output/balance/${o.game}-${new Date().toISOString().replaceAll(':','-')}`);
  await mkdir(dirname(out),{recursive:true});
  try{await mkdir(out);}catch{throw new AgentError('output_exists','choose a new output directory');}
  const file=await open(join(out,'experiment.jsonl'),'wx',0o600);
  const controller=new AbortController(),interrupt=()=>controller.abort();
  const timer=setTimeout(interrupt,o.maxSeconds*1000);process.on('SIGINT',interrupt);
  try{
    const onRecord=async record=>{
      await file.write(`${JSON.stringify(record)}\n`);
      if(!o.quiet&&record.type==='evaluation')process.stderr.write(`${record.split} ${record.candidate}: loss=${record.loss.toFixed(4)} ${JSON.stringify(record.params)}\n`);
    };
    const result=await tune({...o,...adapter,maxTrials:o.maxTrials-2*o.jevCheck,experiment:adapter.experiment,signal:controller.signal,onRecord});
    let audit;
    if(o.jevCheck&&['accepted','unchanged','rejected'].includes(result.status)){
      const {JevClient,loadApiKey}=await import('../examples/games/dungeon_rpg/agent/jev.mjs');
      const client=new JevClient({apiKey:await loadApiKey(),maxRequests:o.maxRequests});
      const {reviewExperience}=await import('./balance/review.mjs');
      const player=module.createAdapter({jevClient:client,captureExperience:true,masterData}),trials=[];
      try{
        for(const [candidate,params] of [['baseline',result.training.baseline.params],['selected',result.training.best.params]]){
          for(const seed of adapter.experiment.validationSeeds.slice(0,o.jevCheck)){
            if(controller.signal.aborted)throw new AgentError('interrupted');
            const {trace,...trial}=await player.runTrial({params,seed,policy:'jev',seat:'solo',signal:controller.signal});
            const tracePath=join(out,`audit-${candidate}-${seed}.jsonl`);
            await writeFile(tracePath,trace.map(r=>JSON.stringify(r)).join('\n')+'\n',{flag:'wx',mode:0o600});
            const record={type:'audit_trial',schemaVersion:1,candidate,params,seed,trace:tracePath,policy:'jev',seat:'solo',...trial};
            await onRecord(record);trials.push(record);
            if(trial.status==='limit')throw new AgentError('request_limit');
            const review=await reviewExperience(client,trial,{signal:controller.signal});
            await onRecord({type:'experience_review',schemaVersion:1,candidate,seed,...review});
          }
        }
        audit={status:'complete',trials:trials.length,requests:client.requests,baseline:aggregate(trials.filter(t=>t.candidate==='baseline')),selected:aggregate(trials.filter(t=>t.candidate==='selected'))};
      }catch(error){audit={status:'incomplete',trials:trials.length,requests:client.requests,reason:error instanceof AgentError?error.code:'audit_failed'};}
      await onRecord({type:'audit_end',schemaVersion:1,...audit});
    }
    if(result.profile)await writeFile(join(out,'profile.json'),`${JSON.stringify(result.profile,null,2)}\n`,{flag:'wx',mode:0o600});
    const summary={...result,totalTrials:result.trials+(audit?.trials??0),output:out,...(audit?{jevAudit:audit}:{})};
    await writeFile(join(out,'summary.json'),`${JSON.stringify(summary,null,2)}\n`,{flag:'wx',mode:0o600});
    process.stdout.write(`${JSON.stringify({status:result.status,accepted:result.accepted,meetsGoals:result.meetsGoals??false,trials:result.trials,elapsedMs:result.elapsedMs,profile:result.profile?join(out,'profile.json'):null,output:out,...(audit?{jevAudit:audit.status}:{})})}\n`);
  }finally{
    clearTimeout(timer);process.removeListener('SIGINT',interrupt);await file.close();
  }
}
main().catch(error=>{
  process.stderr.write(`${error instanceof AgentError?error.message:'experiment_failed: check the build or experiment evidence'}\n`);
  process.exitCode=1;
});
