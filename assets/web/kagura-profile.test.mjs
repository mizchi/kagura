import test from 'node:test';
import assert from 'node:assert/strict';
import {installFrameProfiler} from './kagura-profile.js';

test('profiler reads any runtime, owns its snapshots and distinguishes unavailable timings', () => {
  const host = {};
  const profiler = installFrameProfiler(host);
  assert.equal(profiler.version, 1);
  assert.equal(profiler.snapshot(), null);
  host.__kaguraWebRuntime = {webgpu:{
    _submittedFrameCount:12, _lastRenderCpuMs:2,
    commands:[{indices:[0,1,2], instanceCount:4, sharedGeometry:true}],
  }, frameProfile:{updateMs:1, drawCallbackMs:3, renderCommandsMs:4}};
  const first = profiler.snapshot();
  assert.equal(first.frame, 12);
  assert.equal(first.updateMs, 1);
  assert.equal(first.renderCpuMs, 2);
  assert.equal(first.gpuFrameMs, null);
  assert.equal(first.drawCalls, 1);
  assert.equal(first.instanceCount, 4);
  assert.equal(first.indexCount, 3);
  assert.equal(first.sharedGeometryDraws, 1);
  host.__kaguraWebRuntime.frameProfile.updateMs = 9;
  assert.equal(first.updateMs, 1);
  assert.equal(profiler.snapshot().updateMs, 9);
  // Replacing the GPU/runtime must not read an old game's counters.
  host.__kaguraWebRuntime = {webgpu:{_submittedFrameCount:1}};
  assert.equal(profiler.snapshot().frame, 1);
  assert.equal(profiler.snapshot().updateMs, null);
  assert.equal(installFrameProfiler(host), host.__kaguraProfiler);
});

test('GPU timestamps and queue completion retain their measurement method', () => {
  const gpu = {_submittedFrameCount:2, _lastTimestampFrameMs:1.25, _gpuTimingMethod:'timestamp-query'};
  const host = {__kaguraWebRuntime:{webgpu:gpu}};
  const profiler = installFrameProfiler(host);
  assert.equal(profiler.snapshot().gpuFrameMs, 1.25);
  assert.equal(profiler.snapshot().gpuTimingMethod, 'timestamp-query');
  gpu._gpuTimingMethod = 'queue-completion';
  gpu._lastCompletedFrameMs = 2.5;
  assert.equal(profiler.snapshot().gpuTimingMethod, 'queue-completion');
  assert.equal(profiler.snapshot().gpuFrameMs, 2.5);
});
