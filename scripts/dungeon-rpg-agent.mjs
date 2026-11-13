#!/usr/bin/env node
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {mkdir,open,readFile} from 'node:fs/promises';
import {dirname,resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {AgentError,int32} from './agents/errors.mjs';

const root=fileURLToPath(new URL('../',import.meta.url));
const help=`FATHOM — Jev autoplay (Node 24+)

just dungeon-rpg-agent [options]
  --seed N             Signed 32-bit seed (default: 731)
  --model NAME         TypeSafe model (default: jev-latest)
  --max-decisions N    Choice limit (default: 300, maximum: 10000)
  --max-requests N     API request limit including retries (default: 120)
  --max-seconds N      Run deadline (default: 180, maximum: 3600)
  --out FILE           New JSONL trace (default: output/dungeon-rpg-agent/...)
  --profile FILE       Literal key assignment (default: ~/.profile)
  --master-data FILE   Master JSON exported from the table editor
  --balance FILE       Validated balance profile from balance-tune
  --watch              Play/replay in a separate Chromium window
  --url URL            Running FATHOM dev URL (default: http://localhost:5198)
  --step-ms N          Watch delay after each choice (default: 300)
  --headless           Hide the watch browser (CI; requires --watch)
  --dry-run            Show observation/request without credentials or API calls
  --replay FILE        Verify/replay JSONL without an API key
  --no-build           Use the existing agent_host build
  --quiet              Only print the final JSON summary
  --help               Show this help

Start 'just dungeon-rpg-dev' before using --watch. API keys stay in Node:
TYPESAFE_API_KEY / TYPESAFEAI_API_KEY or a literal TYPESAFE_API_KEY in ~/.profile.
Ctrl-C records an incomplete run. Limits/empty-handed returns are not victory.
`;

function parseArgs(args){
  const options={seed:731,model:'jev-latest',maxDecisions:300,maxRequests:120,maxSeconds:180,stepMs:300,url:'http://localhost:5198'};
  const values=new Map([['--seed','seed'],['--model','model'],['--max-decisions','maxDecisions'],['--max-requests','maxRequests'],['--max-seconds','maxSeconds'],['--out','out'],['--profile','profilePath'],['--master-data','masterPath'],['--balance','balancePath'],['--replay','replay'],['--url','url'],['--step-ms','stepMs']]);
  const numbers=['seed','maxDecisions','maxRequests','maxSeconds','stepMs'];
  const flags=new Map([['--watch','watch'],['--headless','headless'],['--dry-run','dryRun'],['--no-build','noBuild'],['--quiet','quiet'],['--help','help']]);
  for(let i=0;i<args.length;i++){
    if(flags.has(args[i])){options[flags.get(args[i])]=true;continue;}
    const key=values.get(args[i]);
    if(!key||!args[i+1]||args[i+1].startsWith('--'))throw new AgentError('invalid_input','unknown or incomplete option');
    options[key]=numbers.includes(key)?Number(args[++i]):args[++i];
  }
  if(options.help)return options;
  int32(options.seed,'seed');
  for(const key of ['maxDecisions','maxRequests'])if(!Number.isInteger(options[key])||options[key]<1||options[key]>10000)throw new AgentError('invalid_input',`${key} must be in [1,10000]`);
  if(!Number.isFinite(options.maxSeconds)||options.maxSeconds<=0||options.maxSeconds>3600||!Number.isInteger(options.stepMs)||options.stepMs<0||options.stepMs>10000)throw new AgentError('invalid_input','invalid time limit/delay');
  if(options.replay&&options.dryRun||options.headless&&!options.watch)throw new AgentError('invalid_input','incompatible options');
  if(options.replay&&(options.balancePath||options.masterPath))throw new AgentError('invalid_input','replay uses its recorded balance profile');
  let url;try{url=new URL(options.url);}catch{throw new AgentError('invalid_input','invalid watch URL');}
  if(!['http:','https:'].includes(url.protocol)||url.username||url.password)throw new AgentError('invalid_input','watch URL must be HTTP(S) without credentials');
  return options;
}

function summary(result,log){
  const state=result.observation.state;
  return {status:result.status,decisions:result.decisions,modelDecisions:result.modelDecisions,floor:state.floor,
    hp:state.party.map(h=>h.hp),usage:result.usage,elapsedMs:result.elapsedMs,log,
    ...(result.limitReason?{limitReason:result.limitReason}:{}),...(result.replayed?{replayed:true}:{})};
}

async function main(){
  const options=parseArgs(process.argv.slice(2));
  if(options.help){process.stdout.write(help);return;}
  if(!options.noBuild){
    const exec=promisify(execFile);
    await exec(process.execPath,['examples/games/dungeon_rpg/scripts/generate-master-data.mjs'],{cwd:root,maxBuffer:4*1024*1024});
    await exec(process.execPath,['scripts/prepare-moon-deps.mjs','examples/games/dungeon_rpg'],{cwd:root,maxBuffer:4*1024*1024});
    await exec('moon',['-C','examples/games/dungeon_rpg','build','agent_host','--target','js','--release'],{cwd:root,maxBuffer:4*1024*1024});
  }
  const {createHeadlessSession}=await import('../examples/games/dungeon_rpg/agent/headless.mjs');
  const {runAgent,replayRecords}=await import('../examples/games/dungeon_rpg/agent/runner.mjs');
  const {JevClient,makeJevRequest,loadApiKey}=await import('../examples/games/dungeon_rpg/agent/jev.mjs');
  if(options.masterPath){
    try{options.masterData=JSON.parse(await readFile(options.masterPath,'utf8'));}catch{throw new AgentError('invalid_input','cannot read master data');}
    createHeadlessSession(options);
  }
  if(options.balancePath){
    let profile;try{profile=JSON.parse(await readFile(options.balancePath,'utf8'));}catch{throw new AgentError('invalid_input','cannot read balance profile');}
    if(profile?.schemaVersion!==1||profile.game!=='dungeon_rpg'||!profile.parameters)throw new AgentError('invalid_input','invalid balance profile');
    options.balance=profile.parameters;createHeadlessSession(options);
  }
  if(options.dryRun){
    const observation=createHeadlessSession(options).observe();
    process.stdout.write(`${JSON.stringify({observation,request:makeJevRequest(observation,options.model)},null,2)}\n`);return;
  }
  let records;
  if(options.replay){
    try{records=(await readFile(options.replay,'utf8')).split('\n').filter(line=>line.trim()).map(line=>JSON.parse(line));}
    catch{throw new AgentError('replay_failed','cannot read JSONL trace');}
    // Validate the whole trace before opening a browser or displaying actions.
    await replayRecords(records);options.seed=records[0].seed;options.balance=records[0].balance;options.masterData=records[0].masterData;
  }
  const client=options.replay?null:new JevClient({apiKey:await loadApiKey({profilePath:options.profilePath}),model:options.model,maxRequests:options.maxRequests});
  let browser,file;
  const controller=new AbortController(),interrupt=()=>controller.abort();
  process.on('SIGINT',interrupt);
  try{
    let session;
    if(options.watch){
      const {chromium}=await import('@playwright/test');
      const {createBrowserSession}=await import('../examples/games/dungeon_rpg/agent/browser.mjs');
      browser=await chromium.launch({headless:!!options.headless,args:['--enable-unsafe-webgpu','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
      const context=await browser.newContext({viewport:{width:1280,height:800}});
      const page=await context.newPage();await page.goto(options.url);
      session=await createBrowserSession({page,seed:options.seed,balance:options.balance,masterData:options.masterData,stepMs:options.stepMs});
    }else session=createHeadlessSession(options);
    if(options.replay){
      const result=await replayRecords(records,{session,signal:controller.signal});
      process.stdout.write(`${JSON.stringify(summary(result,resolve(options.replay)))}\n`);return;
    }
    const log=resolve(options.out??`output/dungeon-rpg-agent/seed-${options.seed}-${new Date().toISOString().replaceAll(':','-')}.jsonl`);
    await mkdir(dirname(log),{recursive:true});
    try{file=await open(log,'wx',0o600);}catch{throw new AgentError('log_failed','cannot create a new trace; choose an unused --out path');}
    const result=await runAgent({...options,session,signal:controller.signal,requestCount:()=>client.requests,choose:(state,options)=>client.choose(state,options),onRecord:async record=>{
      await file.write(`${JSON.stringify(record)}\n`);
      if(!options.quiet&&record.type==='decision'){
        const choice=record.before.choices.find(c=>c.id===record.choiceId);
        process.stderr.write(`[${record.index}] B${record.before.state.floor} ${record.before.phase} ${choice.label} (${record.source}, ${record.decision.elapsedMs}ms)\n`);
      }
    }});
    process.stdout.write(`${JSON.stringify(summary(result,log))}\n`);
  }finally{
    process.removeListener('SIGINT',interrupt);
    try{await file?.close();}finally{await browser?.close();}
  }
}

main().catch(error=>{
  process.stderr.write(`${error instanceof AgentError?error.message:'agent_failed: check the build, dev server or decision log'}\n`);
  process.exitCode=1;
});
