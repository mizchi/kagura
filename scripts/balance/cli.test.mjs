import test from 'node:test';
import assert from 'node:assert/strict';
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {mkdtemp,readFile,writeFile,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
const run=promisify(execFile), script=fileURLToPath(new URL('../balance-tune.mjs',import.meta.url));
test('balance CLI help and dry-run expose the experiment without an API key',async()=>{
  assert.match((await run(process.execPath,[script,'--help'])).stdout,/--max-trials/);
  const {stdout}=await run(process.execPath,[script,'--game','dungeon_rpg','--no-build','--dry-run']);
  const e=JSON.parse(stdout);assert.equal(e.game,'dungeon_rpg');assert.equal(e.policies.length,2);
});
test('balance CLI rejects incompatible or unbounded options before build',async()=>{
  for(const args of [['--game','unknown'],['--generations','0'],['--max-trials','NaN'],['--seed','1.5'],['--game','card_game','--jev-check','1']]){
    await assert.rejects(run(process.execPath,[script,...args]),e=>e.code===1&&/invalid_input/.test(e.stderr));
  }
});
test('bounded CLI writes experiment evidence and never overwrites it',async()=>{
  const dir=await mkdtemp(join(tmpdir(),'kagura-balance-')),out=join(dir,'run');
  try{
    const args=[script,'--game','card_game','--no-build','--generations','1','--max-trials','8','--out',out,'--quiet'];
    const {stdout}=await run(process.execPath,args);
    const r=JSON.parse(stdout);assert.equal(r.status,'limit');assert.equal(r.profile,null);
    const records=(await readFile(join(out,'experiment.jsonl'),'utf8')).trim().split('\n').map(JSON.parse);
    assert.equal(records[0].type,'run_start');assert.equal(records.at(-1).status,'limit');
    await assert.rejects(run(process.execPath,args),e=>/output_exists/.test(e.stderr));
  }finally{await rm(dir,{recursive:true,force:true});}
});

test('table exports supply the tuning baseline without discarding enemy edits',async()=>{
  const dir=await mkdtemp(join(tmpdir(),'kagura-master-'));
  try{
    const data=JSON.parse(await readFile(new URL('../../examples/games/dungeon_rpg/assets/master-data.json',import.meta.url),'utf8'));
    data.tables.rules[0].encounter_steps=12;data.tables.enemies[0].hp=30;
    const path=join(dir,'master.json');await writeFile(path,JSON.stringify(data));
    const {stdout}=await run(process.execPath,[script,'--no-build','--dry-run','--master-data',path]);
    assert.equal(JSON.parse(stdout).parameters.find(p=>p.name==='encounterSteps').initial,12);
    data.tables.encounters[0].enemy1='missing';await writeFile(path,JSON.stringify(data));
    await assert.rejects(run(process.execPath,[script,'--no-build','--dry-run','--master-data',path]));
  }finally{await rm(dir,{recursive:true,force:true});}
});
