import test from 'node:test';
import assert from 'node:assert/strict';
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {mkdtemp, writeFile, rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHeadlessSession} from './headless.mjs';
import {runAgent} from './runner.mjs';
import {testPolicy} from './test-policy.mjs';

const script=fileURLToPath(new URL('../../../../scripts/dungeon-rpg-agent.mjs',import.meta.url));
const run=promisify(execFile);
test('CLI help and dry run require neither credentials nor a renderer',async()=>{
  assert.match((await run(process.execPath,[script,'--help'])).stdout,/--watch/);
  const {stdout,stderr}=await run(process.execPath,[script,'--no-build','--dry-run','--seed','19']);
  assert.equal(stderr,'');
  const {observation,request}=JSON.parse(stdout);
  assert.equal(observation.phase,'town');assert.equal(request.model,'jev-latest');
  assert.deepEqual(Object.keys(request.questions.next_action.criteria),observation.choices.map(c=>c.id));
});
test('CLI validates options before building or reading credentials',async()=>{
  for(const args of [['--unknown'],['--max-decisions','0'],['--max-requests','0'],['--max-seconds','NaN'],['--seed','2.5'],['--headless'],['--watch','--url','file:///tmp/private'],['--replay','x','--dry-run'],['--replay','x','--master-data','x']]){
    await assert.rejects(run(process.execPath,[script,...args]),error=>{
      assert.equal(error.code,1);assert.match(error.stderr,/invalid_input/);return true;
    });
  }
});
test('CLI verifies a trace without an API key, and rejects tampered evidence',async()=>{
  const dir=await mkdtemp(join(tmpdir(),'fathom-agent-'));
  try{
    const records=[];
    await runAgent({session:createHeadlessSession(),choose:testPolicy,maxDecisions:2,onRecord:r=>records.push(r)});
    const path=join(dir,'trace.jsonl');
    await writeFile(path,records.map(r=>JSON.stringify(r)).join('\n')+'\n');
    const env={...process.env,TYPESAFE_API_KEY:'',TYPESAFEAI_API_KEY:''};
    const result=JSON.parse((await run(process.execPath,[script,'--no-build','--replay',path,'--profile',join(dir,'missing')],{env})).stdout);
    assert.equal(result.status,'limit');assert.equal(result.replayed,true);
    const changed=structuredClone(records);changed[1].after.state.torch--;
    await writeFile(path,changed.map(r=>JSON.stringify(r)).join('\n')+'\n');
    await assert.rejects(run(process.execPath,[script,'--no-build','--replay',path]),error=>/replay_failed/.test(error.stderr));
  }finally{await rm(dir,{recursive:true,force:true});}
});
