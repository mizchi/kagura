import test from "node:test";
import assert from "node:assert/strict";

import {
  buildLiveReviewPerfScenario,
  summarizePerfRuns,
  summarizePersistentProcess,
  summarizeTimingBreakdown,
} from "./model-authoring-vlm-perf-utils.mjs";

test("buildLiveReviewPerfScenario builds stable ids", () => {
  assert.deepEqual(
    buildLiveReviewPerfScenario(),
    {
      renderer: "web",
      execute: false,
      binarize: false,
      sessionMode: "oneshot",
      id: "web_live_atlas_dry_oneshot",
    },
  );
  assert.deepEqual(
    buildLiveReviewPerfScenario({
      renderer: "native",
      execute: true,
      binarize: true,
    }),
    {
      renderer: "native",
      execute: true,
      binarize: true,
      sessionMode: "oneshot",
      id: "native_live_atlas_binary_execute_oneshot",
    },
  );
  assert.deepEqual(
    buildLiveReviewPerfScenario({
      renderer: "web",
      sessionMode: "persistent",
    }),
    {
      renderer: "web",
      execute: false,
      binarize: false,
      sessionMode: "persistent",
      id: "web_live_atlas_dry_persistent",
    },
  );
  assert.deepEqual(
    buildLiveReviewPerfScenario({
      renderer: "web",
      sessionMode: "daemon",
    }),
    {
      renderer: "web",
      execute: false,
      binarize: false,
      sessionMode: "daemon",
      id: "web_live_atlas_dry_daemon",
    },
  );
});

test("summarizePerfRuns ignores warmup in summary stats", () => {
  const summary = summarizePerfRuns(
    [
      { iteration: 1, ok: true, durationMs: 1000 },
      { iteration: 2, ok: true, durationMs: 500 },
      { iteration: 3, ok: true, durationMs: 700 },
      { iteration: 4, ok: true, durationMs: 900 },
    ],
    { warmupCount: 1 },
  );

  assert.equal(summary.totalCount, 4);
  assert.equal(summary.successCount, 4);
  assert.equal(summary.failureCount, 0);
  assert.equal(summary.warmupCount, 1);
  assert.equal(summary.minMs, 700);
  assert.equal(summary.maxMs, 1000);
  assert.equal(summary.meanMs, 866.67);
  assert.equal(summary.p50Ms, 900);
  assert.equal(summary.p95Ms, 1000);
  assert.equal(summary.rawMeanMs, 775);
});

test("summarizePerfRuns reports failures without dropping success stats", () => {
  const summary = summarizePerfRuns([
    { iteration: 1, ok: false, durationMs: 0, exitCode: 1, error: "boom" },
    { iteration: 2, ok: true, durationMs: 300 },
    { iteration: 3, ok: true, durationMs: 500 },
  ]);

  assert.equal(summary.totalCount, 3);
  assert.equal(summary.successCount, 2);
  assert.equal(summary.failureCount, 1);
  assert.equal(summary.minMs, 300);
  assert.equal(summary.maxMs, 500);
  assert.equal(summary.meanMs, 400);
  assert.deepEqual(summary.failures, [
    { iteration: 1, exitCode: 1, error: "boom" },
  ]);
});

test("summarizeTimingBreakdown aggregates numeric fields after warmup", () => {
  const summary = summarizeTimingBreakdown(
    [
      { capture_ms: 100, bundle_ms: 40 },
      { capture_ms: 40, bundle_ms: 20, encode_ms: 10 },
      { capture_ms: 60, bundle_ms: 30, encode_ms: 20 },
    ],
    { warmupCount: 1 },
  );

  assert.deepEqual(summary, {
    bundle_ms: {
      meanMs: 25,
      p50Ms: 20,
      p95Ms: 30,
      maxMs: 30,
    },
    capture_ms: {
      meanMs: 50,
      p50Ms: 40,
      p95Ms: 60,
      maxMs: 60,
    },
    encode_ms: {
      meanMs: 15,
      p50Ms: 10,
      p95Ms: 20,
      maxMs: 20,
    },
  });
});

test("summarizePersistentProcess reports amortized process cost", () => {
  assert.deepEqual(
    summarizePersistentProcess({
      processDurationMs: 1200,
      cycleCount: 4,
      cycleDurations: [100, 150, 200, 250],
      startupTimings: {
        browser_launch_ms: 180,
        source_page_open_ms: 120,
      },
      teardownTimings: {
        browser_close_ms: 80,
      },
    }),
    {
      processDurationMs: 1200,
      amortizedProcessMs: 300,
      cycleDurationTotalMs: 700,
      nonCycleOverheadMs: 500,
      nonCycleOverheadAmortizedMs: 125,
      startupTotalMs: 300,
      startupAmortizedMs: 75,
      teardownTotalMs: 80,
      teardownAmortizedMs: 20,
      residualNonCycleOverheadMs: 120,
      residualNonCycleOverheadAmortizedMs: 30,
      startupBreakdown: {
        browser_launch_ms: {
          totalMs: 180,
          amortizedMs: 45,
        },
        source_page_open_ms: {
          totalMs: 120,
          amortizedMs: 30,
        },
      },
      teardownBreakdown: {
        browser_close_ms: {
          totalMs: 80,
          amortizedMs: 20,
        },
      },
      cycleCount: 4,
    },
  );
});

test("summarizePersistentProcess prefers explicit phase totals without double counting", () => {
  assert.deepEqual(
    summarizePersistentProcess({
      processDurationMs: 900,
      cycleCount: 3,
      cycleDurations: [100, 120, 130],
      startupTimings: {
        browser_launch_ms: 100,
        source_page_open_ms: 150,
        startup_total_ms: 260,
      },
      teardownTimings: {
        browser_close_ms: 40,
        teardown_total_ms: 50,
      },
    }),
    {
      processDurationMs: 900,
      amortizedProcessMs: 300,
      cycleDurationTotalMs: 350,
      nonCycleOverheadMs: 550,
      nonCycleOverheadAmortizedMs: 183.33,
      startupTotalMs: 260,
      startupAmortizedMs: 86.67,
      teardownTotalMs: 50,
      teardownAmortizedMs: 16.67,
      residualNonCycleOverheadMs: 240,
      residualNonCycleOverheadAmortizedMs: 80,
      startupBreakdown: {
        browser_launch_ms: {
          totalMs: 100,
          amortizedMs: 33.33,
        },
        source_page_open_ms: {
          totalMs: 150,
          amortizedMs: 50,
        },
      },
      teardownBreakdown: {
        browser_close_ms: {
          totalMs: 40,
          amortizedMs: 13.33,
        },
      },
      cycleCount: 3,
    },
  );
});
