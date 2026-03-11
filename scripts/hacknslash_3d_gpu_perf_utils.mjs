export const DEFAULT_SAMPLE_COUNT = 120;
export const DEFAULT_WARMUP_FRAMES = 30;
export const DEFAULT_TRACE_CATEGORIES = [
  "toplevel",
  "blink.user_timing",
  "devtools.timeline",
  "disabled-by-default-devtools.timeline",
  "disabled-by-default-devtools.timeline.frame",
  "cc",
  "gpu",
  "viz",
];
export const DEFAULT_SCENARIOS = [
  "default",
  "stress_enemies",
  "stress_enemies_256",
  "fxaa",
  "shadows",
  "ssao",
  "all_effects",
];

export function buildBrowserLaunchArgs(options = {}) {
  const args = [
    "--enable-unsafe-webgpu",
    "--enable-webgpu-developer-features",
    "--enable-dawn-features=allow_unsafe_apis",
    "--disable-background-timer-throttling",
    "--disable-renderer-backgrounding",
    "--disable-backgrounding-occluded-windows",
    "--use-gpu-in-tests",
    "--use-webgpu-power-preference=default-high-performance",
  ];
  if (options.useSwiftShader === true) {
    args.push(
      "--enable-unsafe-swiftshader",
      "--enable-webgl",
      "--use-gl=swiftshader",
    );
  }
  return args;
}

const SCENARIO_CONFIGS = {
  default: { name: "default", fxaa: false, shadows: false, ssao: false },
  stress_enemies: {
    name: "stress_enemies",
    fxaa: false,
    shadows: false,
    ssao: false,
    stressEnemies: 64,
  },
  stress_enemies_256: {
    name: "stress_enemies_256",
    fxaa: false,
    shadows: false,
    ssao: false,
    stressEnemies: 256,
  },
  fxaa: { name: "fxaa", fxaa: true, shadows: false, ssao: false },
  shadows: { name: "shadows", fxaa: false, shadows: true, ssao: false },
  ssao: { name: "ssao", fxaa: false, shadows: false, ssao: true },
  all_effects: { name: "all_effects", fxaa: true, shadows: true, ssao: true },
};

export function getScenarioConfig(name) {
  const scenario = SCENARIO_CONFIGS[name];
  if (scenario == null) {
    throw new Error(`Unknown scenario: ${name}`);
  }
  return scenario;
}

export function buildScenarioUrl(baseUrl, scenarioName, snapshotFrames = 60) {
  const scenario = getScenarioConfig(scenarioName);
  const url = new URL(baseUrl);
  url.searchParams.set("snapshot", "playing");
  url.searchParams.set("frames", String(snapshotFrames));
  url.searchParams.set("perf", "1");
  if (scenario.fxaa) url.searchParams.set("fxaa", "1");
  if (scenario.shadows) url.searchParams.set("shadows", "1");
  if (scenario.ssao) url.searchParams.set("ssao", "1");
  if (scenario.stressEnemies != null) {
    url.searchParams.set("stress_enemies", String(scenario.stressEnemies));
  }
  return url.toString();
}

function round2(value) {
  return Math.round(value * 100) / 100;
}

function percentile(sortedValues, ratio) {
  if (sortedValues.length === 0) return 0;
  const index = Math.min(
    sortedValues.length - 1,
    Math.max(0, Math.floor(sortedValues.length * ratio)),
  );
  return sortedValues[index];
}

export function summarizeNumericSamples(values) {
  if (values.length === 0) {
    return {
      mean: 0,
      min: 0,
      p25: 0,
      p50: 0,
      p75: 0,
      p95: 0,
      max: 0,
      trimmedMean: 0,
      outlierCount: 0,
      upperFence: 0,
    };
  }
  const sorted = [...values].sort((a, b) => a - b);
  const total = values.reduce((sum, value) => sum + value, 0);
  const p25 = percentile(sorted, 0.25);
  const p50 = percentile(sorted, 0.5);
  const p75 = percentile(sorted, 0.75);
  const iqr = p75 - p25;
  const upperFence = p75 + iqr * 1.5;
  const lowerFence = p25 - iqr * 1.5;
  const trimmed = values.filter(
    (value) => value >= lowerFence && value <= upperFence,
  );
  const trimmedTotal = trimmed.reduce((sum, value) => sum + value, 0);
  return {
    mean: round2(total / values.length),
    min: round2(sorted[0]),
    p25: round2(p25),
    p50: round2(p50),
    p75: round2(p75),
    p95: round2(percentile(sorted, 0.95)),
    max: round2(sorted[sorted.length - 1]),
    trimmedMean: round2(
      trimmed.length > 0 ? trimmedTotal / trimmed.length : total / values.length,
    ),
    outlierCount: values.length - trimmed.length,
    upperFence: round2(upperFence),
  };
}

export function mapCdpPerformanceMetrics(metrics) {
  const out = {};
  for (const metric of metrics) {
    if (metric?.name == null) continue;
    out[metric.name] = metric.value;
  }
  return out;
}

export function summarizeBrowserMetrics(beforeMetrics = {}, afterMetrics = {}) {
  const deltaMs = (name) =>
    round2(Math.max(0, ((afterMetrics[name] ?? 0) - (beforeMetrics[name] ?? 0)) * 1000));
  const deltaCount = (name) =>
    Math.max(0, Math.round((afterMetrics[name] ?? 0) - (beforeMetrics[name] ?? 0)));
  const currentMb = (name) => round2((afterMetrics[name] ?? 0) / (1024 * 1024));
  return {
    taskDurationMs: deltaMs("TaskDuration"),
    scriptDurationMs: deltaMs("ScriptDuration"),
    layoutDurationMs: deltaMs("LayoutDuration"),
    recalcStyleDurationMs: deltaMs("RecalcStyleDuration"),
    layoutCountDelta: deltaCount("LayoutCount"),
    recalcStyleCountDelta: deltaCount("RecalcStyleCount"),
    jsHeapUsedSizeMb: currentMb("JSHeapUsedSize"),
    jsHeapTotalSizeMb: currentMb("JSHeapTotalSize"),
    nodes: Math.round(afterMetrics.Nodes ?? 0),
    documents: Math.round(afterMetrics.Documents ?? 0),
    frames: Math.round(afterMetrics.Frames ?? 0),
  };
}

export function summarizeChromeTraceEvents(events) {
  const processNames = new Map();
  const threadNames = new Map();
  for (const event of events) {
    if (event?.ph !== "M") continue;
    if (event.name === "process_name" && event.pid != null) {
      processNames.set(event.pid, event.args?.name ?? `pid:${event.pid}`);
    }
    if (event.name === "thread_name" && event.pid != null && event.tid != null) {
      threadNames.set(
        `${event.pid}:${event.tid}`,
        event.args?.name ?? `tid:${event.tid}`,
      );
    }
  }
  const totals = new Map();
  const threadTotals = new Map();
  const processTotals = new Map();
  let completeEventCount = 0;
  for (const event of events) {
    if (event?.ph !== "X" || typeof event?.dur !== "number") continue;
    completeEventCount += 1;
    const durationMs = event.dur / 1000;
    const next = totals.get(event.name) ?? { totalMs: 0, count: 0 };
    next.totalMs += durationMs;
    next.count += 1;
    totals.set(event.name, next);
    if (event.pid != null && event.tid != null) {
      const processName = processNames.get(event.pid) ?? `pid:${event.pid}`;
      const threadName =
        threadNames.get(`${event.pid}:${event.tid}`) ?? `tid:${event.tid}`;
      const threadLabel = `${processName}:${threadName}`;
      const threadNext = threadTotals.get(threadLabel) ?? {
        label: threadLabel,
        processName,
        threadName,
        totalMs: 0,
        count: 0,
      };
      threadNext.totalMs += durationMs;
      threadNext.count += 1;
      threadTotals.set(threadLabel, threadNext);

      const processNext = processTotals.get(processName) ?? {
        label: processName,
        totalMs: 0,
        count: 0,
      };
      processNext.totalMs += durationMs;
      processNext.count += 1;
      processTotals.set(processName, processNext);
    }
  }
  const topDurationEvents = [...totals.entries()]
    .map(([name, value]) => ({
      name,
      totalMs: round2(value.totalMs),
      count: value.count,
    }))
    .sort((a, b) => b.totalMs - a.totalMs)
    .slice(0, 12);
  const topThreadGroups = [...threadTotals.values()]
    .map((value) => ({
      ...value,
      totalMs: round2(value.totalMs),
    }))
    .sort((a, b) => b.totalMs - a.totalMs)
    .slice(0, 12);
  const topProcessGroups = [...processTotals.values()]
    .map((value) => ({
      ...value,
      totalMs: round2(value.totalMs),
    }))
    .sort((a, b) => b.totalMs - a.totalMs)
    .slice(0, 12);
  return {
    totalEvents: events.length,
    completeEventCount,
    topDurationEvents,
    topThreadGroups,
    topProcessGroups,
  };
}

export function summarizeProfilerSamples(name, samples, options = {}) {
  const browserMetrics = options.browserMetrics ?? null;
  const traceSummary = options.traceSummary ?? null;
  const last = samples.at(-1) ?? {
    worldFrame: 0,
    fxaaEnabled: false,
    shadowsEnabled: false,
    ssaoEnabled: false,
    gpuTimingMethod: "unknown",
  };
  return {
    name,
    sampleCount: samples.length,
    lastWorldFrame: last.worldFrame,
    gpuTimingMethod: last.gpuTimingMethod ?? "unknown",
    flags: {
      fxaaEnabled: Boolean(last.fxaaEnabled),
      shadowsEnabled: Boolean(last.shadowsEnabled),
      ssaoEnabled: Boolean(last.ssaoEnabled),
    },
    fps: summarizeNumericSamples(samples.map((sample) => sample.fps)),
    frameTimeMs: summarizeNumericSamples(
      samples.map((sample) => sample.frameTimeMs),
    ),
    updateMs: summarizeNumericSamples(samples.map((sample) => sample.updateMs)),
    drawMs: summarizeNumericSamples(samples.map((sample) => sample.drawMs)),
    drawCallbackMs: summarizeNumericSamples(
      samples.map((sample) => sample.drawCallbackMs ?? 0),
    ),
    renderCommandsMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderCommandsMs ?? 0),
    ),
    renderUploadCpuMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderUploadCpuMs ?? 0),
    ),
    renderBindGroupCpuMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderBindGroupCpuMs ?? 0),
    ),
    renderPassEncodeCpuMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderPassEncodeCpuMs ?? 0),
    ),
    renderAcquireCpuMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderAcquireCpuMs ?? 0),
    ),
    renderPassSetupCpuMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderPassSetupCpuMs ?? 0),
    ),
    renderDrawEncodeCpuMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderDrawEncodeCpuMs ?? 0),
    ),
    renderCleanupCpuMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderCleanupCpuMs ?? 0),
    ),
    renderEncodeCpuMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderEncodeCpuMs ?? 0),
    ),
    renderSubmitCpuMs: summarizeNumericSamples(
      samples.map((sample) => sample.renderSubmitCpuMs ?? 0),
    ),
    longTaskCount: summarizeNumericSamples(
      samples.map((sample) => sample.longTaskCount ?? 0),
    ),
    longTaskMs: summarizeNumericSamples(
      samples.map((sample) => sample.longTaskMs ?? 0),
    ),
    idleMs: summarizeNumericSamples(
      samples.map((sample) =>
        Math.max(
          0,
          (sample.frameTimeMs ?? 0) - (sample.updateMs ?? 0) - (sample.drawMs ?? 0),
        )),
    ),
    gpuFrameMs: summarizeNumericSamples(
      samples.map((sample) => sample.gpuFrameMs),
    ),
    drawCalls: summarizeNumericSamples(
      samples.map((sample) => sample.drawCalls),
    ),
    vertexCount: summarizeNumericSamples(
      samples.map((sample) => sample.vertexCount),
    ),
    browserMetrics,
    traceSummary,
  };
}
