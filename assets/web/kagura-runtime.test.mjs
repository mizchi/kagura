import test from 'node:test';
import assert from 'node:assert/strict';
import * as runtime from './kagura-runtime.generated.js';
import {readFileSync} from 'node:fs';

test('compiled ESM and its JS ABI declaration expose the same API',()=>{
  const declarations=readFileSync(new URL('./kagura-runtime.generated.d.ts',import.meta.url),'utf8');
  const names=[...declarations.matchAll(/^export function (\w+)\(/gm)].map(match=>match[1]).sort();
  assert.deepEqual(Object.keys(runtime).sort(),names);
});

test('compiled input preserves JS payload identity and safe integer pointer IDs', () => {
  const input=runtime.createControlInput({capacity:1});
  const payload={nested:new Map([[1,'value']])}; payload.self=payload;
  assert.equal(input.move(2**40,.5,0),true);
  assert.equal(input.move(0,1,0),false);
  assert.equal(input.tap(2**40,payload),true);
  assert.equal(input.tap(13),false);
  assert.equal(input.consumeCommand().payload,payload);
  assert.equal(input.consumeCommand(),null);
  input.release(2**40);
  assert.equal(input.snapshot().x,0);
  for (const capacity of [0,-1,1.5,Infinity,NaN]) assert.throws(()=>runtime.createControlInput({capacity}),RangeError);
});

test('compiled UI gate preserves Object.is and patch preserves enumerable symbol properties', () => {
  const gate=runtime.createDependencyGate();
  assert.equal(gate([NaN,0]),true);
  assert.equal(gate([NaN,0]),false);
  assert.equal(gate([NaN,-0]),true);
  const key=Symbol('metadata'), value={};
  const previous={[key]:value};
  const next=runtime.applyObjectPatch(previous,{full:false,set:{hp:2},remove:[]});
  assert.equal(next[key],value);
  assert.equal(previous.hp,undefined);
});

test('compiled frame summaries do not mutate input and work without browser globals', () => {
  const values=[30,10,20];
  assert.equal(runtime.percentile(values,.5),20);
  assert.deepEqual(values,[30,10,20]);
  assert.deepEqual(runtime.summarizeIntervals([]),{frames:0,elapsedMs:0,fps:0,p50IntervalMs:0,p95IntervalMs:0});
  assert.deepEqual(runtime.summarizeIntervals([0,10,20,30]),{frames:4,elapsedMs:30,fps:100,p50IntervalMs:10,p95IntervalMs:10});
});
