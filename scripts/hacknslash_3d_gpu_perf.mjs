import { mkdirSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { spawn } from "node:child_process";
import { chromium } from "@playwright/test";

import {
  buildBrowserLaunchArgs,
  DEFAULT_SAMPLE_COUNT,
  DEFAULT_SCENARIOS,
  DEFAULT_TRACE_CATEGORIES,
  DEFAULT_WARMUP_FRAMES,
  buildScenarioUrl,
  mapCdpPerformanceMetrics,
  summarizeChromeTraceEvents,
  summarizeBrowserMetrics,
  summarizeNumericSamples,
  summarizeProfilerSamples,
} from "./hacknslash_3d_gpu_perf_utils.mjs";

function parseArgs(argv) {
  const out = {
    port: 8080,
    serve: false,
    headed: false,
    swiftshader: false,
    channel: "",
    samples: DEFAULT_SAMPLE_COUNT,
    warmup: DEFAULT_WARMUP_FRAMES,
    snapshotFrames: 60,
    scenarios: DEFAULT_SCENARIOS,
    outDir: `output/playwright/hacknslash_3d_gpu_perf-${Date.now()}`,
    url: "",
    trace: false,
  };
  for (let i = 2; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = argv[i + 1];
    if (arg === "--serve") out.serve = true;
    else if (arg === "--headed") out.headed = true;
    else if (arg === "--swiftshader") out.swiftshader = true;
    else if (arg === "--port" && next != null) {
      out.port = Number(next);
      i += 1;
    } else if (arg === "--samples" && next != null) {
      out.samples = Number(next);
      i += 1;
    } else if (arg === "--channel" && next != null) {
      out.channel = next;
      i += 1;
    } else if (arg === "--warmup" && next != null) {
      out.warmup = Number(next);
      i += 1;
    } else if (arg === "--frames" && next != null) {
      out.snapshotFrames = Number(next);
      i += 1;
    } else if (arg === "--scenarios" && next != null) {
      out.scenarios = next.split(",").map((item) => item.trim()).filter(Boolean);
      i += 1;
    } else if (arg === "--out-dir" && next != null) {
      out.outDir = next;
      i += 1;
    } else if (arg === "--url" && next != null) {
      out.url = next;
      i += 1;
    } else if (arg === "--trace") {
      out.trace = true;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return out;
}

async function waitForServer(url, timeoutMs = 120_000) {
  const startedAt = Date.now();
  while (Date.now() - startedAt < timeoutMs) {
    try {
      const response = await fetch(url);
      if (response.ok) return;
    } catch (_) {}
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  throw new Error(`Timed out waiting for server: ${url}`);
}

async function waitForProfile(page) {
  try {
    await page.waitForFunction(() => {
      const profile = globalThis.__hacknslash3dProfile;
      return profile != null && profile.worldFrame > 0;
    });
  } catch (error) {
    const bodyText = await page.evaluate(() => document.body.innerText ?? "");
    if (bodyText.includes("WebGPU only")) {
      throw new Error(
        "hacknslash_3d did not start because this browser session has no WebGPU adapter. Retry with --headed on a local GPU-enabled Chrome/Chromium session.",
      );
    }
    throw error;
  }
}

async function collectSamples(page, warmupFrames, sampleCount, timeoutMs) {
  return await page.evaluate(
    async ({ warmupFrames, sampleCount, timeoutMs }) => {
      return await new Promise((resolve) => {
        const samples = [];
        let remainingWarmup = warmupFrames;
        let lastFrame = -1;
        const timeoutId = setTimeout(() => {
          resolve({ timedOut: true, samples });
        }, timeoutMs);
        function tick() {
          const profile = globalThis.__hacknslash3dProfile;
          if (profile != null && profile.worldFrame !== lastFrame) {
            lastFrame = profile.worldFrame;
            if (remainingWarmup > 0) {
              remainingWarmup -= 1;
            } else {
              samples.push({ ...profile });
              if (samples.length >= sampleCount) {
                clearTimeout(timeoutId);
                resolve({ timedOut: false, samples });
                return;
              }
            }
          }
          requestAnimationFrame(tick);
        }
        tick();
      });
    },
    { warmupFrames, sampleCount, timeoutMs },
  );
}

async function collectRafBaseline(page, warmupFrames, sampleCount, timeoutMs) {
  await page.setContent(
    "<!doctype html><meta charset='utf-8'><title>raf baseline</title><body style='margin:0;background:#111'></body>",
  );
  return await page.evaluate(
    async ({ warmupFrames, sampleCount, timeoutMs }) => {
      return await new Promise((resolve) => {
        const samples = [];
        let remainingWarmup = warmupFrames;
        let previousNow = null;
        const timeoutId = setTimeout(() => {
          resolve({ timedOut: true, samples });
        }, timeoutMs);
        function tick(now) {
          if (previousNow != null) {
            if (remainingWarmup > 0) {
              remainingWarmup -= 1;
            } else {
              samples.push(now - previousNow);
              if (samples.length >= sampleCount) {
                clearTimeout(timeoutId);
                resolve({ timedOut: false, samples });
                return;
              }
            }
          }
          previousNow = now;
          requestAnimationFrame(tick);
        }
        requestAnimationFrame(tick);
      });
    },
    { warmupFrames, sampleCount, timeoutMs },
  );
}

async function createPerformanceSession(context, page) {
  const session = await context.newCDPSession(page);
  await session.send("Performance.enable");
  return session;
}

async function collectBrowserMetrics(session) {
  const response = await session.send("Performance.getMetrics");
  return mapCdpPerformanceMetrics(response.metrics ?? []);
}

async function collectChromeTrace(session, run) {
  const events = [];
  const onDataCollected = (payload) => {
    for (const event of payload.value ?? []) {
      events.push(event);
    }
  };
  const completePromise = new Promise((resolve) => {
    session.once("Tracing.tracingComplete", resolve);
  });
  session.on("Tracing.dataCollected", onDataCollected);
  try {
    await session.send("Tracing.start", {
      categories: DEFAULT_TRACE_CATEGORIES.join(","),
      transferMode: "ReportEvents",
    });
    const result = await run();
    await session.send("Tracing.end");
    await completePromise;
    return { traceEvents: events, result };
  } finally {
    session.off("Tracing.dataCollected", onDataCollected);
  }
}

async function main() {
  const args = parseArgs(process.argv);
  mkdirSync(args.outDir, { recursive: true });
  const baseUrl = args.url || `http://127.0.0.1:${args.port}/`;
  let serverProcess = null;
  if (args.serve) {
    serverProcess = spawn(
      process.execPath,
      ["scripts/dev-server.mjs", "hacknslash_3d"],
      {
        cwd: process.cwd(),
        env: { ...process.env, PORT: String(args.port) },
        stdio: "inherit",
      },
    );
    await waitForServer(baseUrl);
  }

  const browser = await chromium.launch({
    headless: !args.headed,
    channel: args.channel || undefined,
    args: buildBrowserLaunchArgs({ useSwiftShader: args.swiftshader }),
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
  });
  const page = await context.newPage();
  await page.bringToFront();
  const performanceSession = await createPerformanceSession(context, page);
  const scenarioSummaries = [];
  try {
    const baseline = await collectRafBaseline(page, args.warmup, args.samples, 30_000);
    if (baseline.timedOut) {
      throw new Error(
        `Timed out collecting requestAnimationFrame baseline after capturing ${baseline.samples.length} frames`,
      );
    }
    for (const scenario of args.scenarios) {
      console.log(`[hacknslash_3d_gpu_perf] scenario=${scenario}`);
      const url = buildScenarioUrl(baseUrl, scenario, args.snapshotFrames);
      await page.goto(url);
      await page.bringToFront();
      await waitForProfile(page);
      const beforeBrowserMetrics = await collectBrowserMetrics(performanceSession);
      const collected = args.trace
        ? await collectChromeTrace(performanceSession, async () => {
            return await collectSamples(page, args.warmup, args.samples, 30_000);
          })
        : {
            traceEvents: null,
            result: await collectSamples(page, args.warmup, args.samples, 30_000),
          };
      const { traceEvents, result } = collected;
      const samples = result.samples;
      const timedOut = result.timedOut;
      if (timedOut) {
        throw new Error(
          `Timed out collecting samples for scenario=${scenario} after capturing ${samples.length} frames`,
        );
      }
      const afterBrowserMetrics = await collectBrowserMetrics(performanceSession);
      const browserMetrics = summarizeBrowserMetrics(
        beforeBrowserMetrics,
        afterBrowserMetrics,
      );
      const traceSummary = traceEvents == null
        ? null
        : summarizeChromeTraceEvents(traceEvents);
      const summary = summarizeProfilerSamples(scenario, samples, {
        browserMetrics,
        traceSummary,
      });
      scenarioSummaries.push(summary);
      await page.screenshot({
        path: resolve(args.outDir, `${scenario}.png`),
      });
      writeFileSync(
        resolve(args.outDir, `${scenario}.samples.json`),
        JSON.stringify(samples, null, 2),
      );
      writeFileSync(
        resolve(args.outDir, `${scenario}.browser-metrics.json`),
        JSON.stringify(
          {
            before: beforeBrowserMetrics,
            after: afterBrowserMetrics,
            summary: browserMetrics,
          },
          null,
          2,
        ),
      );
      if (traceEvents != null) {
        writeFileSync(
          resolve(args.outDir, `${scenario}.trace.json`),
          JSON.stringify({ traceEvents }, null, 2),
        );
      }
    }
    const warnings = [];
    if (scenarioSummaries.every((summary) => summary.gpuFrameMs.max === 0)) {
      warnings.push(
        "GPU completion timing stayed at 0ms in every scenario. This usually means WebGPU timestamping is unavailable in this browser session. Retry with --headed and optionally --channel chrome on a local GPU-enabled machine.",
      );
    }
    const summary = {
      baseUrl,
      sampleCount: args.samples,
      warmupFrames: args.warmup,
      snapshotFrames: args.snapshotFrames,
      rafBaselineMs: summarizeNumericSamples(baseline.samples),
      warnings,
      scenarios: scenarioSummaries,
    };
    writeFileSync(
      resolve(args.outDir, "summary.json"),
      JSON.stringify(summary, null, 2),
    );
    console.log(JSON.stringify(summary, null, 2));
  } finally {
    await page.close().catch(() => {});
    await context.close().catch(() => {});
    await browser.close().catch(() => {});
    if (serverProcess != null) {
      serverProcess.kill("SIGTERM");
    }
  }
}

await main();
