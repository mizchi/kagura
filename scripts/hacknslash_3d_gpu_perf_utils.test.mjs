import test from "node:test";
import assert from "node:assert/strict";

import {
  buildBrowserLaunchArgs,
  buildScenarioUrl,
  getScenarioConfig,
  mapCdpPerformanceMetrics,
  summarizeChromeTraceEvents,
  summarizeBrowserMetrics,
  summarizeNumericSamples,
  summarizeProfilerSamples,
} from "./hacknslash_3d_gpu_perf_utils.mjs";

test("buildScenarioUrl encodes scenario toggles into query params", () => {
  const url = buildScenarioUrl("http://127.0.0.1:8123/", "all_effects");
  assert.equal(
    url,
    "http://127.0.0.1:8123/?snapshot=playing&frames=60&perf=1&fxaa=1&shadows=1&ssao=1",
  );
});

test("buildScenarioUrl encodes stress enemy scenario into query params", () => {
  const url = buildScenarioUrl("http://127.0.0.1:8123/", "stress_enemies");
  assert.equal(
    url,
    "http://127.0.0.1:8123/?snapshot=playing&frames=60&perf=1&stress_enemies=64",
  );
});

test("buildScenarioUrl encodes stress enemy 256 scenario into query params", () => {
  const url = buildScenarioUrl("http://127.0.0.1:8123/", "stress_enemies_256");
  assert.equal(
    url,
    "http://127.0.0.1:8123/?snapshot=playing&frames=60&perf=1&stress_enemies=256",
  );
});

test("getScenarioConfig returns default flags for default scenario", () => {
  assert.deepEqual(getScenarioConfig("default"), {
    name: "default",
    fxaa: false,
    shadows: false,
    ssao: false,
  });
});

test("getScenarioConfig returns stress enemy count for stress scenario", () => {
  assert.deepEqual(getScenarioConfig("stress_enemies"), {
    name: "stress_enemies",
    fxaa: false,
    shadows: false,
    ssao: false,
    stressEnemies: 64,
  });
});

test("getScenarioConfig returns stress enemy count for 256 stress scenario", () => {
  assert.deepEqual(getScenarioConfig("stress_enemies_256"), {
    name: "stress_enemies_256",
    fxaa: false,
    shadows: false,
    ssao: false,
    stressEnemies: 256,
  });
});

test("buildBrowserLaunchArgs enables unsafe WebGPU timing features", () => {
  const args = buildBrowserLaunchArgs();
  assert.ok(args.includes("--enable-webgpu-developer-features"));
  assert.ok(args.includes("--enable-dawn-features=allow_unsafe_apis"));
  assert.ok(args.includes("--use-gpu-in-tests"));
  assert.ok(args.includes("--disable-background-timer-throttling"));
  assert.ok(args.includes("--disable-renderer-backgrounding"));
  assert.ok(args.includes("--disable-backgrounding-occluded-windows"));
  assert.equal(args.includes("--use-gl=swiftshader"), false);
});

test("buildBrowserLaunchArgs can opt into swiftshader for headless fallback", () => {
  const args = buildBrowserLaunchArgs({ useSwiftShader: true });
  assert.ok(args.includes("--use-gl=swiftshader"));
  assert.ok(args.includes("--enable-unsafe-swiftshader"));
});

test("summarizeProfilerSamples computes numeric rollups and final flags", () => {
  const summary = summarizeProfilerSamples(
    "fxaa",
    [
      {
        fps: 60,
        frameTimeMs: 16,
        updateMs: 2,
        drawMs: 3,
        drawCallbackMs: 5,
        renderCommandsMs: 7,
        renderUploadCpuMs: 1.5,
        renderBindGroupCpuMs: 2.5,
        renderPassEncodeCpuMs: 3.5,
        renderAcquireCpuMs: 1,
        renderPassSetupCpuMs: 2,
        renderDrawEncodeCpuMs: 3,
        renderCleanupCpuMs: 0.5,
        renderEncodeCpuMs: 6,
        renderSubmitCpuMs: 1,
        gpuFrameMs: 4,
        gpuTimingMethod: "timestamp-query",
        longTaskCount: 0,
        longTaskMs: 0,
        drawCalls: 10,
        vertexCount: 100,
        assetInflight: 0,
        worldFrame: 120,
        fxaaEnabled: true,
        shadowsEnabled: false,
        ssaoEnabled: false,
      },
      {
        fps: 50,
        frameTimeMs: 20,
        updateMs: 4,
        drawMs: 5,
        drawCallbackMs: 9,
        renderCommandsMs: 11,
        renderUploadCpuMs: 2.5,
        renderBindGroupCpuMs: 3.5,
        renderPassEncodeCpuMs: 4.5,
        renderAcquireCpuMs: 3,
        renderPassSetupCpuMs: 4,
        renderDrawEncodeCpuMs: 5,
        renderCleanupCpuMs: 1.5,
        renderEncodeCpuMs: 10,
        renderSubmitCpuMs: 1,
        gpuFrameMs: 8,
        gpuTimingMethod: "timestamp-query",
        longTaskCount: 2,
        longTaskMs: 51,
        drawCalls: 12,
        vertexCount: 120,
        assetInflight: 1,
        worldFrame: 121,
        fxaaEnabled: true,
        shadowsEnabled: false,
        ssaoEnabled: false,
      },
    ],
    {
      browserMetrics: {
        taskDurationMs: 16,
        scriptDurationMs: 8,
        layoutDurationMs: 2,
        recalcStyleDurationMs: 1,
        layoutCountDelta: 2,
        recalcStyleCountDelta: 1,
        jsHeapUsedSizeMb: 6,
        jsHeapTotalSizeMb: 12,
        nodes: 144,
        documents: 2,
        frames: 1,
      },
    },
  );

  assert.equal(summary.name, "fxaa");
  assert.equal(summary.sampleCount, 2);
  assert.equal(summary.flags.fxaaEnabled, true);
  assert.equal(summary.flags.shadowsEnabled, false);
  assert.equal(summary.frameTimeMs.mean, 18);
  assert.equal(summary.drawCallbackMs.mean, 7);
  assert.equal(summary.renderCommandsMs.mean, 9);
  assert.equal(summary.renderUploadCpuMs.mean, 2);
  assert.equal(summary.renderBindGroupCpuMs.mean, 3);
  assert.equal(summary.renderPassEncodeCpuMs.mean, 4);
  assert.equal(summary.renderAcquireCpuMs.mean, 2);
  assert.equal(summary.renderPassSetupCpuMs.mean, 3);
  assert.equal(summary.renderDrawEncodeCpuMs.mean, 4);
  assert.equal(summary.renderCleanupCpuMs.mean, 1);
  assert.equal(summary.renderEncodeCpuMs.mean, 8);
  assert.equal(summary.renderSubmitCpuMs.mean, 1);
  assert.equal(summary.gpuFrameMs.max, 8);
  assert.equal(summary.longTaskCount.mean, 1);
  assert.equal(summary.longTaskMs.mean, 25.5);
  assert.equal(summary.idleMs.mean, 11);
  assert.equal(summary.gpuTimingMethod, "timestamp-query");
  assert.equal(summary.drawCalls.p95, 12);
  assert.equal(summary.lastWorldFrame, 121);
  assert.equal(summary.browserMetrics.taskDurationMs, 16);
});

test("summarizeNumericSamples handles browser pacing baseline samples", () => {
  const summary = summarizeNumericSamples([16.7, 33.4, 50.1]);
  assert.equal(summary.mean, 33.4);
  assert.equal(summary.min, 16.7);
  assert.equal(summary.max, 50.1);
  assert.equal(summary.trimmedMean, 33.4);
  assert.equal(summary.outlierCount, 0);
});

test("summarizeNumericSamples reports trimmed mean when a large outlier exists", () => {
  const summary = summarizeNumericSamples([8.1, 8.4, 8.5, 8.7, 9.0, 205.2]);
  assert.equal(summary.p50, 8.7);
  assert.equal(summary.trimmedMean, 8.54);
  assert.equal(summary.outlierCount, 1);
  assert.equal(summary.upperFence, 9.9);
});

test("mapCdpPerformanceMetrics converts metric array into a name map", () => {
  const mapped = mapCdpPerformanceMetrics([
    { name: "TaskDuration", value: 1.25 },
    { name: "LayoutCount", value: 12 },
    { name: "JSHeapUsedSize", value: 4 * 1024 * 1024 },
  ]);
  assert.deepEqual(mapped, {
    TaskDuration: 1.25,
    LayoutCount: 12,
    JSHeapUsedSize: 4 * 1024 * 1024,
  });
});

test("summarizeBrowserMetrics reports deltas and ending heap snapshot", () => {
  const summary = summarizeBrowserMetrics(
    {
      TaskDuration: 1.0,
      ScriptDuration: 0.25,
      LayoutDuration: 0.05,
      RecalcStyleDuration: 0.02,
      LayoutCount: 10,
      RecalcStyleCount: 4,
      JSHeapUsedSize: 4 * 1024 * 1024,
      JSHeapTotalSize: 8 * 1024 * 1024,
      Nodes: 120,
      Documents: 2,
      Frames: 1,
    },
    {
      TaskDuration: 1.6,
      ScriptDuration: 0.5,
      LayoutDuration: 0.08,
      RecalcStyleDuration: 0.04,
      LayoutCount: 15,
      RecalcStyleCount: 7,
      JSHeapUsedSize: 6 * 1024 * 1024,
      JSHeapTotalSize: 10 * 1024 * 1024,
      Nodes: 144,
      Documents: 2,
      Frames: 1,
    },
  );
  assert.deepEqual(summary, {
    taskDurationMs: 600,
    scriptDurationMs: 250,
    layoutDurationMs: 30,
    recalcStyleDurationMs: 20,
    layoutCountDelta: 5,
    recalcStyleCountDelta: 3,
    jsHeapUsedSizeMb: 6,
    jsHeapTotalSizeMb: 10,
    nodes: 144,
    documents: 2,
    frames: 1,
  });
});

test("summarizeChromeTraceEvents aggregates complete event durations", () => {
  const summary = summarizeChromeTraceEvents([
    {
      ph: "M",
      name: "process_name",
      pid: 10,
      tid: 0,
      args: { name: "Renderer" },
    },
    {
      ph: "M",
      name: "thread_name",
      pid: 10,
      tid: 11,
      args: { name: "CrRendererMain" },
    },
    {
      ph: "M",
      name: "process_name",
      pid: 20,
      tid: 0,
      args: { name: "GPU Process" },
    },
    {
      ph: "M",
      name: "thread_name",
      pid: 20,
      tid: 21,
      args: { name: "CrGpuMain" },
    },
    { ph: "X", name: "RunTask", dur: 5_000 },
    { ph: "X", name: "RunTask", dur: 7_000 },
    { ph: "X", name: "DrawFrame", dur: 3_000, pid: 10, tid: 11 },
    { ph: "X", name: "WebGPU", dur: 4_000, pid: 20, tid: 21 },
    { ph: "i", name: "IgnoredInstant", dur: 99_000 },
  ]);
  assert.equal(summary.totalEvents, 9);
  assert.equal(summary.completeEventCount, 4);
  assert.deepEqual(summary.topDurationEvents, [
    { name: "RunTask", totalMs: 12, count: 2 },
    { name: "WebGPU", totalMs: 4, count: 1 },
    { name: "DrawFrame", totalMs: 3, count: 1 },
  ]);
  assert.deepEqual(summary.topThreadGroups, [
    {
      label: "GPU Process:CrGpuMain",
      processName: "GPU Process",
      threadName: "CrGpuMain",
      totalMs: 4,
      count: 1,
    },
    {
      label: "Renderer:CrRendererMain",
      processName: "Renderer",
      threadName: "CrRendererMain",
      totalMs: 3,
      count: 1,
    },
  ]);
  assert.deepEqual(summary.topProcessGroups, [
    { label: "GPU Process", totalMs: 4, count: 1 },
    { label: "Renderer", totalMs: 3, count: 1 },
  ]);
});
