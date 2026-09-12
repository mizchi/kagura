import {summarizeNumericSamples} from './web-performance-utils.mjs';
export {summarizeNumericSamples, mapCdpPerformanceMetrics, summarizeBrowserMetrics, summarizeChromeTraceEvents} from './web-performance-utils.mjs';

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
