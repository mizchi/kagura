// Pull-based engine telemetry: no history buffers or work on unsampled frames.
const timing = value => Number.isFinite(value) && value >= 0 ? value : null;

/**
 * Version 1 snapshot. Times are milliseconds; unavailable measurements are null.
 * frame counts successful GPU submissions, independent of simulation pauses.
 * Engine phase times describe the latest CPU frame; GPU time describes the
 * latest completed sample and keeps its timestamp/queue-completion method.
 * @param {typeof globalThis} host
 */
export function readFrameProfile(host = globalThis) {
  const runtime = host.__kaguraWebRuntime;
  const gpu = runtime?.webgpu;
  if (!gpu) return null;
  const phases = runtime.frameProfile;
  let indexCount = 0, instanceCount = 0, sharedGeometryDraws = 0;
  const commands = gpu.commands ?? [];
  for (const command of commands) {
    indexCount += command.indices?.length ?? 0;
    instanceCount += Math.max(1, command.instanceCount ?? 1);
    if (command.sharedGeometry) sharedGeometryDraws++;
  }
  const gpuTimingMethod = gpu._gpuTimingMethod ?? null;
  return Object.freeze({
    version:1,
    frame:gpu._submittedFrameCount ?? 0,
    updateMs:timing(phases?.updateMs),
    drawCallbackMs:timing(phases?.drawCallbackMs),
    renderCommandsMs:timing(phases?.renderCommandsMs),
    renderCpuMs:timing(gpu._lastRenderCpuMs),
    renderUploadCpuMs:timing(gpu._lastRenderUploadCpuMs),
    renderBindGroupCpuMs:timing(gpu._lastRenderBindGroupCpuMs),
    renderEncodeCpuMs:timing(gpu._lastRenderEncodeCpuMs),
    renderSubmitCpuMs:timing(gpu._lastRenderSubmitCpuMs),
    gpuFrameMs:gpuTimingMethod === null ? null : timing(gpuTimingMethod === 'timestamp-query'
      ? gpu._lastTimestampFrameMs : gpu._lastCompletedFrameMs),
    gpuTimingMethod,
    drawCalls:commands.length, indexCount, instanceCount, sharedGeometryDraws,
    residentGeometryBuffers:gpu._sharedGeometryBuffers?.resident.size ?? 0,
  });
}

/** Installs the common contract even for games that own their animation loop. */
export function installFrameProfiler(host = globalThis) {
  const profiler = Object.freeze({version:1, snapshot:() => readFrameProfile(host)});
  host.__kaguraProfiler = profiler;
  return profiler;
}
