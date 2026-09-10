import {test} from 'node:test';import assert from 'node:assert/strict';import {readFile} from 'node:fs/promises';
import * as api from '../_build/js/release/build/mizchi/iron_yard/headless/headless.js';
const reference=JSON.parse(await readFile(new URL('./movement-reference.json',import.meta.url)));
for(const scenario of reference.scenarios)test(`MoonBit matches source simulation: ${scenario.name}`,()=>{
  const game=api.create(false);api.start_playing(game);
  for(const step of scenario.steps){const i={forward:0,strafe:0,boost:false,jump:false,yaw:0,pitch:.25,...step};for(let n=0;n<step.frames;n++)api.step(game,i.forward,i.strafe,i.boost,i.jump,false,false,i.yaw,i.pitch,i.dt);}
  const actual=JSON.parse(api.snapshot(game)).pilot;
  for(const key of ['position','velocity'])for(let i=0;i<3;i++)assert.ok(Math.abs(actual[key][i]-scenario.expected[key][i])<1e-8,`${key}[${i}]: ${actual[key][i]} != ${scenario.expected[key][i]}`);
  assert.ok(Math.abs(actual.gait-scenario.expected.gaitTime)<1e-8);
  assert.equal(actual.grounded,scenario.expected.grounded);
});
test('Kagura samples exported animation and aims actual weapon bone in headless mode',async()=>{
  const info=JSON.parse(api.rig_check(await readFile(new URL('../assets/generated/strix.json',import.meta.url),'utf8')));
  assert.equal(info.ok,true);assert.equal(info.bones,28);assert.equal(info.batches,103);
  assert.ok(info.rifle.every(Number.isFinite));assert.ok(info.rifle[1]>1&&info.rifle[1]<4);
  for(const i of [10,13,16,19])assert.ok(Math.abs(info.world[i][1]-.16)<1e-6,'idle feet stay on ground');
});
