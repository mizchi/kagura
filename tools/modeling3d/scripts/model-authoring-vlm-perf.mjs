#!/usr/bin/env node

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { spawn, spawnSync } from "node:child_process";
import { createConnection } from "node:net";

import {
  buildLiveReviewPerfScenario,
  summarizePersistentProcess,
  summarizePerfRuns,
  summarizeTimingBreakdown,
} from "./model-authoring-vlm-perf-utils.mjs";

function usage() {
  console.error(
    [
      "Usage: node tools/modeling3d/scripts/model-authoring-vlm-perf.mjs \\",
      "  [--example frog_authoring] [--provider openrouter] [--iterations 8] [--warmup 1] \\",
      "  [--port 8230] [--out-dir output/playwright/perf-<example>] \\",
      "  [--renderer web|native|both] [--session-mode oneshot|persistent|daemon|both|all] [--binarize-review] [--execute] [--timeout-ms 30000]",
    ].join("\n"),
  );
}

function parseArgs(argv) {
  const options = {
    example: "frog_authoring",
    provider: "openrouter",
    iterations: 8,
    warmup: 1,
    port: 8230,
    renderer: "both",
    sessionMode: "oneshot",
    timeoutMs: 30_000,
    execute: false,
    binarize: false,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "--example":
        options.example = argv[i + 1];
        i += 1;
        break;
      case "--provider":
        options.provider = argv[i + 1];
        i += 1;
        break;
      case "--iterations":
        options.iterations = Number(argv[i + 1]);
        i += 1;
        break;
      case "--warmup":
        options.warmup = Number(argv[i + 1]);
        i += 1;
        break;
      case "--port":
        options.port = Number(argv[i + 1]);
        i += 1;
        break;
      case "--out-dir":
        options.outDir = argv[i + 1];
        i += 1;
        break;
      case "--renderer":
        options.renderer = argv[i + 1];
        i += 1;
        break;
      case "--timeout-ms":
        options.timeoutMs = Number(argv[i + 1]);
        i += 1;
        break;
      case "--session-mode":
        options.sessionMode = argv[i + 1];
        i += 1;
        break;
      case "--binarize-review":
        options.binarize = true;
        break;
      case "--execute":
        options.execute = true;
        break;
      default:
        throw new Error(`unknown argument: ${arg}`);
    }
  }
  if (!Number.isFinite(options.iterations) || options.iterations <= 0) {
    throw new Error("--iterations must be > 0");
  }
  if (!Number.isFinite(options.warmup) || options.warmup < 0) {
    throw new Error("--warmup must be >= 0");
  }
  if (!Number.isFinite(options.port) || options.port <= 0) {
    throw new Error("--port must be > 0");
  }
  return options;
}

function ensureParentDir(path) {
  mkdirSync(dirname(path), { recursive: true });
}

async function waitForHttp(url, timeoutMs) {
  const deadline = Date.now() + timeoutMs;
  let lastError = null;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(url);
      if (response.ok) {
        return;
      }
      lastError = new Error(`HTTP ${response.status}`);
    } catch (error) {
      lastError = error;
    }
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 250));
  }
  throw new Error(`timed out waiting for ${url}: ${String(lastError?.message ?? lastError)}`);
}

async function waitForTcp({ host, port, timeoutMs }) {
  const deadline = Date.now() + timeoutMs;
  let lastError = null;
  while (Date.now() < deadline) {
    try {
      await new Promise((resolvePromise, rejectPromise) => {
        const socket = createConnection({ host, port });
        socket.once("connect", () => {
          socket.end();
          resolvePromise();
        });
        socket.once("error", rejectPromise);
      });
      return;
    } catch (error) {
      lastError = error;
    }
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 100));
  }
  throw new Error(
    `timed out waiting for tcp://${host}:${port}: ${String(lastError?.message ?? lastError)}`,
  );
}

function resolveScenarios({ renderer, execute, binarize, sessionMode }) {
  const renderers =
    renderer === "both" ? ["web", "native"] : [renderer === "native" ? "native" : "web"];
  let sessionModes;
  if (sessionMode === "all") {
    sessionModes = ["oneshot", "persistent", "daemon"];
  } else if (sessionMode === "both") {
    sessionModes = ["oneshot", "persistent"];
  } else if (sessionMode === "persistent") {
    sessionModes = ["persistent"];
  } else if (sessionMode === "daemon") {
    sessionModes = ["daemon"];
  } else {
    sessionModes = ["oneshot"];
  }
  const scenarios = [];
  for (const currentRenderer of renderers) {
    for (const currentSessionMode of sessionModes) {
      if (currentRenderer === "native" && currentSessionMode === "daemon") {
        continue;
      }
      scenarios.push(
        buildLiveReviewPerfScenario({
          renderer: currentRenderer,
          execute,
          binarize,
          sessionMode: currentSessionMode,
        }),
      );
    }
  }
  return scenarios;
}

async function runDaemonHandoff({
  example,
  provider,
  timeoutMs,
  execute,
  scenario,
  url,
  outDir,
  iterations,
}) {
  const daemonPort = 9000 + Math.floor(Math.random() * 1000);
  const daemonHost = "127.0.0.1";
  const args = [
    resolve(process.cwd(), "tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs"),
    "--example",
    example,
    "--live-review",
    "--provider",
    provider,
    "--out-dir",
    outDir,
    "--timeout-ms",
    String(timeoutMs),
    "--daemon",
    "--daemon-host",
    daemonHost,
    "--daemon-port",
    String(daemonPort),
  ];
  if (scenario.renderer === "native") {
    throw new Error("daemon mode is not supported for native renderer");
  }
  args.push("--url", url);
  if (scenario.binarize) {
    args.push("--binarize-review");
  }
  if (execute) {
    args.push("--execute");
  }

  const startedAt = Date.now();
  const child = spawn(process.execPath, args, {
    cwd: process.cwd(),
    env: {
      ...process.env,
      KAGURA_HANDOFF_PROCESS_STARTED_AT: String(startedAt),
    },
    stdio: ["pipe", "pipe", "pipe"],
  });

  const stdoutChunks = [];
  const stderrChunks = [];
  child.stderr.on("data", (chunk) => {
    stderrChunks.push(chunk.toString());
  });
  child.stdout.on("data", (chunk) => {
    stdoutChunks.push(chunk.toString());
  });

  const exitPromise = new Promise((resolvePromise) => {
    child.once("exit", (code) => {
      resolvePromise(code ?? 0);
    });
  });

  const requestDaemon = (command) =>
    new Promise((resolvePromise, rejectPromise) => {
      const socket = createConnection({ host: daemonHost, port: daemonPort });
      let buffer = "";
      socket.setEncoding("utf8");
      socket.once("connect", () => {
        socket.write(`${JSON.stringify(command)}\n`);
      });
      socket.on("data", (chunk) => {
        buffer += chunk;
        const newlineIndex = buffer.indexOf("\n");
        if (newlineIndex < 0) {
          return;
        }
        const line = buffer.slice(0, newlineIndex);
        try {
          resolvePromise(JSON.parse(line));
        } catch (error) {
          rejectPromise(error);
        }
        socket.end();
      });
      socket.once("error", rejectPromise);
    });

  const fail = async (message) => {
    child.kill("SIGTERM");
    await exitPromise;
    return {
      ok: false,
      exitCode: -1,
      processDurationMs: Date.now() - startedAt,
      error: message,
      stdout: stdoutChunks.join(""),
      stderr: stderrChunks.join(""),
    };
  };

  await waitForTcp({ host: daemonHost, port: daemonPort, timeoutMs });
  const results = [];
  for (let index = 0; index < iterations; index += 1) {
    const iteration = index + 1;
    const runOutDir = resolve(outDir, `run-${String(iteration).padStart(2, "0")}`);
    const event = await requestDaemon({
        op: "run",
        cycle: iteration,
        outDir: runOutDir,
        reviewBinarize: scenario.binarize,
      });
    if (event?.event !== "result") {
      return fail(`daemon run failed at iteration ${iteration}: ${JSON.stringify(event)}`);
    }
    results.push(event.result);
  }
  const shutdown = await requestDaemon({ op: "shutdown" });
  if (shutdown?.event !== "shutdown") {
    return fail(`daemon shutdown failed: ${JSON.stringify(shutdown)}`);
  }
  const exitCode = await exitPromise;
  if (exitCode !== 0) {
    return {
      ok: false,
      exitCode,
      processDurationMs: Date.now() - startedAt,
      error: stderrChunks.join("") || stdoutChunks.join("") || "daemon failed",
      stdout: stdoutChunks.join(""),
      stderr: stderrChunks.join(""),
    };
  }
  const stdoutText = stdoutChunks.join("").trim();
  let shutdownReport = null;
  if (stdoutText.length > 0) {
    try {
      shutdownReport = JSON.parse(stdoutText);
    } catch {
      shutdownReport = null;
    }
  }
  return {
    ok: true,
    exitCode: 0,
    processDurationMs: Date.now() - startedAt,
    stdout: stdoutText,
    stderr: stderrChunks.join(""),
    batch: {
      mode: "daemon",
      renderer: scenario.renderer,
      cycles: iterations,
      results,
      startup_timings: shutdownReport?.startup_timings ?? null,
      teardown_timings: shutdownReport?.teardown_timings ?? null,
    },
  };
}

function logStep(message) {
  console.error(`[perf] ${message}`);
}

function runHandoff({
  example,
  provider,
  timeoutMs,
  execute,
  scenario,
  url,
  outDir,
}) {
  const args = [
    resolve(process.cwd(), "tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs"),
    "--example",
    example,
    "--live-review",
    "--provider",
    provider,
    "--out-dir",
    outDir,
    "--timeout-ms",
    String(timeoutMs),
  ];
  if (scenario.renderer === "native") {
    args.push("--renderer", "native");
  } else {
    args.push("--url", url);
  }
  if (scenario.binarize) {
    args.push("--binarize-review");
  }
  if (execute) {
    args.push("--execute");
  }

  const startedAt = Date.now();
  const result = spawnSync(process.execPath, args, {
    cwd: process.cwd(),
    encoding: "utf8",
    env: {
      ...process.env,
      KAGURA_HANDOFF_PROCESS_STARTED_AT: String(startedAt),
    },
  });
  const finishedAt = Date.now();
  const durationMs = finishedAt - startedAt;
  if (result.status !== 0) {
    return {
      ok: false,
      exitCode: result.status ?? -1,
      durationMs,
      error: result.stderr || result.stdout || "handoff failed",
      stdout: result.stdout,
      stderr: result.stderr,
    };
  }
  return {
    ok: true,
    exitCode: 0,
    durationMs,
    stdout: result.stdout,
    stderr: result.stderr,
    report: JSON.parse(result.stdout),
  };
}

function runPersistentHandoff({
  example,
  provider,
  timeoutMs,
  execute,
  scenario,
  url,
  outDir,
  iterations,
}) {
  const args = [
    resolve(process.cwd(), "tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs"),
    "--example",
    example,
    "--live-review",
    "--provider",
    provider,
    "--out-dir",
    outDir,
    "--timeout-ms",
    String(timeoutMs),
    "--cycles",
    String(iterations),
  ];
  if (scenario.renderer === "native") {
    args.push("--renderer", "native");
  } else {
    args.push("--url", url);
  }
  if (scenario.binarize) {
    args.push("--binarize-review");
  }
  if (execute) {
    args.push("--execute");
  }

  const startedAt = Date.now();
  const result = spawnSync(process.execPath, args, {
    cwd: process.cwd(),
    encoding: "utf8",
    env: {
      ...process.env,
      KAGURA_HANDOFF_PROCESS_STARTED_AT: String(startedAt),
    },
  });
  const finishedAt = Date.now();
  const processDurationMs = finishedAt - startedAt;
  if (result.status !== 0) {
    return {
      ok: false,
      exitCode: result.status ?? -1,
      processDurationMs,
      error: result.stderr || result.stdout || "handoff failed",
      stdout: result.stdout,
      stderr: result.stderr,
    };
  }
  return {
    ok: true,
    exitCode: 0,
    processDurationMs,
    stdout: result.stdout,
    stderr: result.stderr,
    batch: JSON.parse(result.stdout),
  };
}

async function main() {
  let options;
  try {
    options = parseArgs(process.argv.slice(2));
  } catch (error) {
    usage();
    console.error(String(error.message ?? error));
    process.exit(1);
  }

  const startedAt = new Date().toISOString().replaceAll(":", "").replaceAll("-", "");
  const outDir = resolve(
    process.cwd(),
    options.outDir ?? `output/playwright/perf-${options.example}-${startedAt}`,
  );
  mkdirSync(outDir, { recursive: true });

  const scenarios = resolveScenarios(options);
  let devServer = null;
  const baseUrl = `http://127.0.0.1:${options.port}/`;

  try {
    if (scenarios.some((scenario) => scenario.renderer === "web")) {
      logStep(`starting dev server for ${options.example} on ${baseUrl}`);
      devServer = spawn("just", ["dev", options.example], {
        cwd: process.cwd(),
        env: {
          ...process.env,
          PORT: String(options.port),
        },
        stdio: ["ignore", "pipe", "pipe"],
      });
      ensureParentDir(resolve(outDir, "perf-stdout.log"));
      let stdoutLog = "";
      let stderrLog = "";
      devServer.stdout.on("data", (chunk) => {
        stdoutLog += chunk.toString();
      });
      devServer.stderr.on("data", (chunk) => {
        stderrLog += chunk.toString();
      });
      process.on("exit", () => {
        writeFileSync(resolve(outDir, "perf-stdout.log"), stdoutLog);
        writeFileSync(resolve(outDir, "perf-stderr.log"), stderrLog);
      });
      await waitForHttp(baseUrl, options.timeoutMs);
    }

    const scenarioSummaries = [];
    for (const scenario of scenarios) {
      logStep(`running ${scenario.id} x${options.iterations}`);
      const runs = [];
      let processSummary = null;
      if (scenario.sessionMode === "persistent" || scenario.sessionMode === "daemon") {
        const runOutDir = resolve(outDir, scenario.id);
        const result =
          scenario.sessionMode === "daemon"
            ? await runDaemonHandoff({
                example: options.example,
                provider: options.provider,
                timeoutMs: options.timeoutMs,
                execute: options.execute,
                scenario,
                url: baseUrl,
                outDir: runOutDir,
                iterations: options.iterations,
              })
            : runPersistentHandoff({
                example: options.example,
                provider: options.provider,
                timeoutMs: options.timeoutMs,
                execute: options.execute,
                scenario,
                url: baseUrl,
                outDir: runOutDir,
                iterations: options.iterations,
              });
        if (!result.ok) {
          throw new Error(`${scenario.id} failed: ${result.error}`);
        }
        for (const item of result.batch.results) {
          runs.push({
            iteration: item.cycle,
            ok: true,
            exitCode: 0,
            durationMs: item.timings?.total_cycle_ms ?? 0,
            error: null,
            reportPath: item.parsed,
            timings: item.timings ?? null,
            captureMetrics: item.capture_metrics ?? null,
          });
        }
        processSummary = summarizePersistentProcess({
          processDurationMs: result.processDurationMs,
          cycleCount: options.iterations,
          cycleDurations: runs.map((run) => run.durationMs),
          startupTimings: result.batch.startup_timings ?? null,
          teardownTimings: result.batch.teardown_timings ?? null,
        });
      } else {
        for (let index = 0; index < options.iterations; index += 1) {
          const iteration = index + 1;
          const runOutDir = resolve(outDir, scenario.id, `run-${String(iteration).padStart(2, "0")}`);
          const result = runHandoff({
            example: options.example,
            provider: options.provider,
            timeoutMs: options.timeoutMs,
            execute: options.execute,
            scenario,
            url: baseUrl,
            outDir: runOutDir,
          });
          runs.push({
            iteration,
            ok: result.ok,
            exitCode: result.exitCode,
            durationMs: result.durationMs,
            error: result.ok ? null : result.error,
            reportPath: result.ok ? resolve(runOutDir, result.report?.parsed ?? "") : null,
            timings: result.ok ? result.report?.timings ?? null : null,
            captureMetrics: result.ok ? result.report?.capture_metrics ?? null : null,
            startupTimings: result.ok ? result.report?.startup_timings ?? null : null,
            teardownTimings: result.ok ? result.report?.teardown_timings ?? null : null,
          });
          if (!result.ok) {
            throw new Error(
              `${scenario.id} iteration ${iteration} failed: ${result.error}`,
            );
          }
        }
      }
      scenarioSummaries.push({
        scenario,
        runs,
        summary: summarizePerfRuns(runs, { warmupCount: options.warmup }),
        processSummary,
        timingBreakdown: summarizeTimingBreakdown(
          runs.map((run) => run.timings),
          { warmupCount: options.warmup },
        ),
        startupBreakdown:
          scenario.sessionMode === "persistent" || scenario.sessionMode === "daemon"
            ? processSummary?.startupBreakdown ?? {}
            : summarizeTimingBreakdown(
                runs.map((run) => run.startupTimings),
                { warmupCount: options.warmup },
              ),
        teardownBreakdown:
          scenario.sessionMode === "persistent" || scenario.sessionMode === "daemon"
            ? processSummary?.teardownBreakdown ?? {}
            : summarizeTimingBreakdown(
                runs.map((run) => run.teardownTimings),
                { warmupCount: options.warmup },
              ),
        captureBreakdown: summarizeTimingBreakdown(
          runs.map((run) => run.captureMetrics),
          { warmupCount: options.warmup },
        ),
      });
    }

    const output = {
      example: options.example,
      provider: options.provider,
      execute: options.execute,
      binarize: options.binarize,
      iterations: options.iterations,
      warmup: options.warmup,
      outDir,
      generatedAt: new Date().toISOString(),
      scenarios: scenarioSummaries,
    };
    writeFileSync(resolve(outDir, "summary.json"), JSON.stringify(output, null, 2));
    console.log(JSON.stringify(output, null, 2));
  } finally {
    if (devServer != null && !devServer.killed) {
      devServer.kill("SIGTERM");
    }
  }
}

main().catch((error) => {
  console.error(String(error.stack ?? error));
  process.exit(1);
});
