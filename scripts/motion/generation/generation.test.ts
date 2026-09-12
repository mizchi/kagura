import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { validateGeneration, apiInput, mediaUrl } from './contract.ts';
import { FalMotionClient } from './fal.ts';
import { submitJob, collectJob } from './jobs.ts';

const input={version:1,prompt:'A person walks forward.',duration:3,seed:42,guidanceScale:5};
const json=value=>new Response(JSON.stringify(value),{headers:{'Content-Type':'application/json'}});
test('generation input validates before any API interaction',()=>{
  assert.equal(apiInput(validateGeneration(input)).output_format,'fbx');
  for(const update of [{duration:13},{duration:NaN},{seed:1.1},{prompt:''},{guidanceScale:-1},{version:2},{unknown:1}])assert.throws(()=>validateGeneration({...input,...update}));
});
test('fal queue operations isolate credentials from CDN and reject redirects/unsafe URLs',async()=>{
  const calls=[];
  const client=new FalMotionClient('test-secret',async(url,init)=>{
    calls.push({url:String(url),init});
    if(init.method==='POST')return json({request_id:'job-1'});
    if(String(url).endsWith('/status'))return json({status:'COMPLETED',request_id:'job-1'});
    return json({seed:42,fbx_file:{url:'https://v3.fal.media/files/test.fbx'}});
  });
  assert.equal(await client.submit(input),'job-1');assert.equal(await client.status('job-1'),'COMPLETED');
  assert.equal((await client.result('job-1')).seed,42);
  assert.ok(calls.every(c=>c.init.headers.Authorization==='Key test-secret'&&c.init.redirect==='error'));
  await assert.rejects(()=>client.status('../leak'));
  const bad=new FalMotionClient('secret',async()=>json({seed:42,fbx_file:{url:'https://evil.test/x'}}));
  await assert.rejects(()=>bad.result('job-1'));
  const failed=new FalMotionClient('secret',async()=>json({status:'COMPLETED',error:'private detail secret'}));
  await assert.rejects(()=>failed.status('job-1'),e=>!e.message.includes('secret')&&!e.message.includes('private detail'));
});
test('submit requires explicit execution, reserves output before spending and never resubmits',async()=>{
  const dir=await mkdtemp(join(tmpdir(),'motion-generation-'));let submits=0;
  const client={submit:async()=>{submits++;return 'job-1';}};
  try{
    await assert.rejects(()=>submitJob(input,join(dir,'run'),false,client));assert.equal(submits,0);
    await submitJob(input,join(dir,'run'),true,client);assert.equal(submits,1);
    const receipt=JSON.parse(await readFile(join(dir,'run','job.json'),'utf8'));assert.equal(receipt.requestId,'job-1');
    assert.equal((await readFile(join(dir,'run','request.json'),'utf8')).includes('secret'),false);
    await assert.rejects(()=>submitJob(input,join(dir,'run'),true,client));assert.equal(submits,1);
  }finally{await rm(dir,{recursive:true});}
});
test('collect resumes without submitting and writes an FBX once without overwriting',async()=>{
  const dir=await mkdtemp(join(tmpdir(),'motion-collect-'));let downloads=0,state='IN_QUEUE';
  const client={submit:async()=> 'job-1',status:async()=>state,result:async()=>({seed:42,url:'https://v3.fal.media/files/test.fbx'}),download:async()=>{downloads++;return new TextEncoder().encode('; FBX 7.4.0 project file\nObjects: {}');}};
  try{
    const run=join(dir,'run');await submitJob(input,run,true,client);
    assert.equal((await collectJob(run,client)).status,'IN_QUEUE');assert.equal(downloads,0);
    state='COMPLETED';assert.equal((await collectJob(run,client)).status,'SAVED');assert.equal(downloads,1);
    const bytes=await readFile(join(run,'motion.fbx'));assert.ok(bytes.length>0);
    assert.equal((await collectJob(run,client)).status,'SAVED');assert.equal(downloads,1);
    assert.deepEqual(await readFile(join(run,'motion.fbx')),bytes);
  }finally{await rm(dir,{recursive:true});}
});
test('CLI plan needs no key or network and submit without execution is rejected',async()=>{
  const dir=await mkdtemp(join(tmpdir(),'motion-cli-'));
  try{
    const file=join(dir,'input.json');await writeFile(file,JSON.stringify(input));
    const run=args=>spawnSync(process.execPath,['scripts/motion/generation/cli.ts',...args],{encoding:'utf8',env:{PATH:process.env.PATH}});
    const plan=run(['plan','--input',file]);assert.equal(plan.status,0,plan.stderr);assert.equal(JSON.parse(plan.stdout).input.duration,3);
    const denied=run(['submit','--input',file,'--out',join(dir,'run')]);assert.notEqual(denied.status,0);assert.match(denied.stderr,/execute/);
  }finally{await rm(dir,{recursive:true});}
});

test('downloads are bounded, unauthenticated and validate FBX content',async()=>{
  const bytes=new TextEncoder().encode('; FBX 7.4.0 project file\nObjects: {}');let options;
  const client=new FalMotionClient('secret',async(url,init)=>{options=init;return new Response(bytes);});
  assert.deepEqual(await client.download('https://v3.fal.media/files/x.fbx'),bytes);
  assert.equal(options.headers,undefined);assert.equal(options.redirect,'error');
  for(const url of ['http://v3.fal.media/x','https://fal.media.evil.test/x','https://user:pass@fal.media/x','https://127.0.0.1/x','file:///tmp/x'])assert.throws(()=>mediaUrl(url));
  for(const response of [new Response('<html>wrong result</html>'),new Response('x',{headers:{'content-length':String(33*1024*1024)}}),new Response(null,{status:302,headers:{location:'https://evil.test'}})]){
    await assert.rejects(()=>new FalMotionClient('secret',async()=>response).download('https://v3.fal.media/x'));
  }
});

test('ambiguous POST errors never retry, keep intent and do not log credentials',async()=>{
  const dir=await mkdtemp(join(tmpdir(),'motion-ambiguous-'));let calls=0;
  const client=new FalMotionClient('secret',async()=>{calls++;throw new Error('network secret detail');});
  try{
    const run=join(dir,'run');await assert.rejects(()=>submitJob(input,run,true,client),e=>!e.message.includes('secret'));
    assert.equal(calls,1);assert.equal(JSON.parse(await readFile(join(run,'request.json'),'utf8')).seed,42);
    await assert.rejects(()=>submitJob(input,run,true,client));assert.equal(calls,1);
  }finally{await rm(dir,{recursive:true});}
});

test('different existing output and tampered saved FBX are never overwritten',async()=>{
  const dir=await mkdtemp(join(tmpdir(),'motion-existing-'));
  const client={submit:async()=> 'job-1',status:async()=> 'COMPLETED',result:async()=>({seed:42,url:'https://v3.fal.media/x'}),download:async()=>new TextEncoder().encode('new output')};
  try{
    const run=join(dir,'run');await submitJob(input,run,true,client);await writeFile(join(run,'motion.fbx'),'user content');
    await assert.rejects(()=>collectJob(run,client),/上書き/);assert.equal(await readFile(join(run,'motion.fbx'),'utf8'),'user content');
    const other=join(dir,'other');await submitJob(input,other,true,client);await collectJob(other,client);
    await writeFile(join(other,'motion.fbx'),'changed');await assert.rejects(()=>collectJob(other,client),/検証/);
    assert.equal(await readFile(join(other,'motion.fbx'),'utf8'),'changed');
  }finally{await rm(dir,{recursive:true});}
});
