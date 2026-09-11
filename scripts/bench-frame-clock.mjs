#!/usr/bin/env node
// What does the Atomics frame-clock handshake cost per frame, and how far above
// 60Hz does it hold up?
//
// A `moonbitlang/async` guest blocks the thread it runs on, so a frame loop can
// only reach it through `event_bus/wait` (see CLAUDE.md). This drives the
// shipped wait -- `createFrameWait` from assets/web/kagura-wasm-worker.js -- at a
// range of rates and reports how many ticks the parked side services and how
// long each wake takes to arrive.
//
// Reporting only, deliberately: wake latency has occasional scheduler outliers,
// so gating on it would flake. Run it when the handshake changes.
//
// Usage:
//   node scripts/bench-frame-clock.mjs [--duration-ms 3000] [--warmup-wakes 10] [--json]

import { Worker } from "node:worker_threads";
import process from "node:process";

import { percentile } from "../assets/web/kagura-frame-stats.js";
import { CONTROL_LENGTH, FRAME_SLOT } from "../assets/web/kagura-wasm-worker.js";

// The control array the library defines, plus room for a tick timestamp the
// bench needs and the library has no business knowing about. i64 slot 1 keeps
// it clear of the i32 control slots in the first 8 bytes.
const STAMP_INDEX = 1;
const BUFFER_BYTES = 32;
const MAX_WAIT_MS = 50;

const argOf = (name, fallback) => {
  const at = process.argv.indexOf(name);
  return at >= 0 ? Number(process.argv[at + 1]) : fallback;
};
const DURATION_MS = argOf("--duration-ms", 3000);
const WARMUP_WAKES = argOf("--warmup-wakes", 10);
const AS_JSON = process.argv.includes("--json");

/** Sleep this thread accurately enough to hit a sub-millisecond period. */
const sleeper = new Int32Array(new SharedArrayBuffer(4));
const sleepMs = (ms) => {
  if (ms > 0) Atomics.wait(sleeper, 0, 0, ms);
};

async function measure({ hz, workMs }) {
  const buffer = new SharedArrayBuffer(BUFFER_BYTES);
  const control = new Int32Array(buffer, 0, CONTROL_LENGTH);
  const stamps = new BigInt64Array(buffer);

  const worker = new Worker(new URL("./bench-frame-clock-worker.mjs", import.meta.url), {
    workerData: {
      buffer,
      controlLength: CONTROL_LENGTH,
      stampIndex: STAMP_INDEX,
      durationMs: DURATION_MS,
      workMs,
      maxWaitMs: MAX_WAIT_MS,
      warmupWakes: WARMUP_WAKES,
    },
  });
  const finished = new Promise((resolve) => worker.on("message", resolve));

  const periodMs = 1000 / hz;
  const startedAt = process.hrtime.bigint();
  const endAt = startedAt + BigInt(DURATION_MS) * 1_000_000n;
  let dueAtMs = Number(startedAt) / 1e6;
  let ticks = 0;
  while (process.hrtime.bigint() < endAt) {
    dueAtMs += periodMs;
    sleepMs(dueAtMs - Number(process.hrtime.bigint()) / 1e6);
    // Stamp before the counter moves, so the waiter cannot observe a tick whose
    // timestamp has not landed yet.
    Atomics.store(stamps, STAMP_INDEX, process.hrtime.bigint());
    Atomics.add(control, FRAME_SLOT, 1);
    Atomics.notify(control, FRAME_SLOT);
    ticks += 1;
  }

  const { wakes, framesSeen, timeouts, wakeIntervalsMs, wakeLatenciesUs } = await finished;
  await worker.terminate();

  return {
    hz,
    workMs,
    budgetMs: +periodMs.toFixed(2),
    ticks,
    actualHz: +(ticks / (DURATION_MS / 1000)).toFixed(1),
    wakes,
    framesSeen,
    timeouts,
    servicedPct: +((framesSeen / ticks) * 100).toFixed(1),
    wakeP50Ms: +percentile(wakeIntervalsMs, 0.5).toFixed(2),
    wakeP95Ms: +percentile(wakeIntervalsMs, 0.95).toFixed(2),
    latencyP50Us: +percentile(wakeLatenciesUs, 0.5).toFixed(1),
    latencyP95Us: +percentile(wakeLatenciesUs, 0.95).toFixed(1),
    latencyP99Us: +percentile(wakeLatenciesUs, 0.99).toFixed(1),
  };
}

// Rates worth knowing: the two common display cadences, then two well past them
// to show the headroom; and the same with synchronous work filling most of the
// budget, which is the realistic shape.
const CASES = [
  { hz: 60, workMs: 0 },
  { hz: 120, workMs: 0 },
  { hz: 240, workMs: 0 },
  { hz: 480, workMs: 0 },
  { hz: 60, workMs: 12 },
  { hz: 120, workMs: 6 },
  { hz: 240, workMs: 3 },
];

const results = [];
for (const testCase of CASES) results.push(await measure(testCase));

if (AS_JSON) {
  console.log(JSON.stringify({ durationMs: DURATION_MS, results }, null, 2));
} else {
  console.log(`frame-clock handshake, ${DURATION_MS}ms per row\n`);
  console.log("driven  budget   actual  serviced   wake p50/p95     wake latency p50/p95/p99   work");
  for (const r of results) {
    console.log(
      `${String(r.hz).padStart(4)}Hz ${r.budgetMs.toFixed(2).padStart(6)}ms ${String(r.actualHz).padStart(7)} ` +
        `${String(r.servicedPct).padStart(7)}%  ${String(r.wakeP50Ms).padStart(5)}/${String(r.wakeP95Ms).padEnd(5)}ms ` +
        `${String(r.latencyP50Us).padStart(8)}/${String(r.latencyP95Us).padStart(6)}/${String(r.latencyP99Us).padStart(7)} us ` +
        `${String(r.workMs).padStart(5)}ms`,
    );
  }
  const at120 = results.find((r) => r.hz === 120 && r.workMs === 0);
  if (at120 != null) {
    console.log(
      `\n120Hz: the handshake takes ${at120.latencyP50Us}us of an ${at120.budgetMs}ms budget ` +
        `(${((at120.latencyP50Us / 1000 / at120.budgetMs) * 100).toFixed(1)}%), servicing ${at120.servicedPct}% of ticks.`,
    );
  }
}
