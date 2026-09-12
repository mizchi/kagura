import test from 'node:test';
import assert from 'node:assert/strict';
import {summarizeCpuProfile, measureWebPage, cpuPerFrame} from './profile-web.mjs';

test('CPU samples weight time deltas and merge functions reached through different callers', () => {
  const frame={functionName:'upload',url:'gfx.js',lineNumber:12};
  const profile={nodes:[{id:1,callFrame:frame},{id:2,callFrame:frame},
    {id:3,callFrame:{...frame,functionName:'draw'}}],samples:[1,2,3],timeDeltas:[100,300,50]};
  const hot=summarizeCpuProfile(profile);
  assert.equal(hot[0].name,'upload');
  assert.equal(hot[0].selfMs,0.4);
  assert.equal(hot[1].selfMs,0.05);
  assert.equal(cpuPerFrame({TaskDuration:1}, {TaskDuration:1.2}, 20).TaskDuration.toFixed(1),'10.0');
  assert.throws(()=>cpuPerFrame({}, {}, 0), RangeError);
  assert.equal(cpuPerFrame({}, {}, 1).ScriptDuration,null);
});

test('frame metrics finish before CPU sampling begins; missing timings remain unavailable', async () => {
  const calls=[];
  let metrics=0;
  const session={async send(method) {
    calls.push(method);
    if (method==='Performance.getMetrics') return {metrics:[{name:'TaskDuration',value:metrics++}]};
    if (method==='Profiler.stop') return {profile:{nodes:[],samples:[],timeDeltas:[]}};
    return {};
  }};
  const page={async evaluate() {
    calls.push('frames');
    return {renderedFrames:2,samples:[{frame:1,rafMs:16,gpuFrameMs:null},{frame:2,rafMs:17,gpuFrameMs:null}]};
  },async waitForTimeout(){calls.push('cpu sampling wait')}};
  const result=await measureWebPage(page,session,{samples:2,profileMs:1});
  assert.ok(calls.lastIndexOf('Performance.getMetrics')<calls.indexOf('Profiler.start'));
  assert.equal(result.cpuMsPerFrame.TaskDuration,500);
  assert.equal(result.timings.gpuFrameMs,null);
  assert.equal(result.timings.rafMs.mean,16.5);
});
