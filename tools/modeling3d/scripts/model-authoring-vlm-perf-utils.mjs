export function buildLiveReviewPerfScenario({
  renderer = "web",
  execute = false,
  binarize = false,
  sessionMode = "oneshot",
} = {}) {
  const normalizedRenderer = renderer === "native" ? "native" : "web";
  const phase = execute ? "execute" : "dry";
  const suffix = binarize ? "_binary" : "";
  const normalizedSessionMode =
    sessionMode === "persistent"
      ? "persistent"
      : sessionMode === "daemon"
        ? "daemon"
        : "oneshot";
  return {
    renderer: normalizedRenderer,
    execute,
    binarize,
    sessionMode: normalizedSessionMode,
    id: `${normalizedRenderer}_live_atlas${suffix}_${phase}_${normalizedSessionMode}`,
  };
}

function percentile(sorted, ratio) {
  if (sorted.length === 0) {
    return 0;
  }
  if (sorted.length === 1) {
    return sorted[0];
  }
  const index = Math.min(
    sorted.length - 1,
    Math.max(0, Math.ceil(sorted.length * ratio) - 1),
  );
  return sorted[index];
}

function roundMs(value) {
  return Number(value.toFixed(2));
}

export function summarizePerfRuns(runs, { warmupCount = 0 } = {}) {
  const totalCount = runs.length;
  const successRuns = runs.filter((run) => run.ok);
  const failureRuns = runs.filter((run) => !run.ok);
  const durations = successRuns
    .map((run) => run.durationMs)
    .sort((lhs, rhs) => lhs - rhs);
  const effectiveWarmup = Math.min(warmupCount, durations.length);
  const warmDurations = durations.slice(effectiveWarmup);
  const measured = warmDurations.length > 0 ? warmDurations : durations;
  const sum = measured.reduce((acc, value) => acc + value, 0);
  const mean = measured.length > 0 ? sum / measured.length : 0;

  return {
    totalCount,
    successCount: successRuns.length,
    failureCount: failureRuns.length,
    warmupCount: effectiveWarmup,
    minMs: measured.length > 0 ? roundMs(measured[0]) : 0,
    maxMs: measured.length > 0 ? roundMs(measured[measured.length - 1]) : 0,
    meanMs: roundMs(mean),
    p50Ms: roundMs(percentile(measured, 0.5)),
    p95Ms: roundMs(percentile(measured, 0.95)),
    rawMeanMs:
      durations.length > 0
        ? roundMs(durations.reduce((acc, value) => acc + value, 0) / durations.length)
        : 0,
    failures: failureRuns.map((run) => ({
      iteration: run.iteration,
      exitCode: run.exitCode,
      error: run.error ?? null,
    })),
  };
}

export function summarizeTimingBreakdown(samples, { warmupCount = 0 } = {}) {
  const effectiveWarmup = Math.max(0, warmupCount);
  const grouped = new Map();
  for (const sample of samples.slice(effectiveWarmup)) {
    if (sample == null || typeof sample !== "object") {
      continue;
    }
    for (const [key, value] of Object.entries(sample)) {
      if (typeof value !== "number" || !Number.isFinite(value)) {
        continue;
      }
      if (!grouped.has(key)) {
        grouped.set(key, []);
      }
      grouped.get(key).push(value);
    }
  }
  const summary = {};
  for (const [key, values] of grouped.entries()) {
    const sorted = [...values].sort((lhs, rhs) => lhs - rhs);
    const mean =
      sorted.reduce((acc, value) => acc + value, 0) / sorted.length;
    summary[key] = {
      meanMs: roundMs(mean),
      p50Ms: roundMs(percentile(sorted, 0.5)),
      p95Ms: roundMs(percentile(sorted, 0.95)),
      maxMs: roundMs(sorted[sorted.length - 1]),
    };
  }
  return summary;
}

export function summarizePersistentProcess({
  processDurationMs,
  cycleCount,
  cycleDurations = [],
  startupTimings = null,
  teardownTimings = null,
}) {
  const safeCycleCount = cycleCount > 0 ? cycleCount : 1;
  const cycleDurationTotalMs = cycleDurations.reduce(
    (acc, value) => acc + (Number.isFinite(value) ? value : 0),
    0,
  );
  const nonCycleOverheadMs = Math.max(0, processDurationMs - cycleDurationTotalMs);
  const summarizePhaseBreakdown = (timings) => {
    const entries = Object.entries(timings ?? {}).filter(
      ([, value]) => typeof value === "number" && Number.isFinite(value),
    );
    const explicitTotalEntry = entries.find(([key]) => key.endsWith("_total_ms"));
    const detailEntries = entries.filter(([key]) => !key.endsWith("_total_ms"));
    const breakdown = {};
    let derivedTotalMs = 0;
    for (const [key, value] of detailEntries) {
      derivedTotalMs += value;
      breakdown[key] = {
        totalMs: roundMs(value),
        amortizedMs: roundMs(value / safeCycleCount),
      };
    }
    const totalMs = explicitTotalEntry?.[1] ?? derivedTotalMs;
    return {
      totalMs: roundMs(totalMs),
      amortizedMs: roundMs(totalMs / safeCycleCount),
      breakdown,
    };
  };
  const startup = summarizePhaseBreakdown(startupTimings);
  const teardown = summarizePhaseBreakdown(teardownTimings);
  const residualNonCycleOverheadMs = Math.max(
    0,
    nonCycleOverheadMs - startup.totalMs - teardown.totalMs,
  );
  return {
    processDurationMs: roundMs(processDurationMs),
    amortizedProcessMs: roundMs(processDurationMs / safeCycleCount),
    cycleDurationTotalMs: roundMs(cycleDurationTotalMs),
    nonCycleOverheadMs: roundMs(nonCycleOverheadMs),
    nonCycleOverheadAmortizedMs: roundMs(nonCycleOverheadMs / safeCycleCount),
    startupTotalMs: startup.totalMs,
    startupAmortizedMs: startup.amortizedMs,
    teardownTotalMs: teardown.totalMs,
    teardownAmortizedMs: teardown.amortizedMs,
    residualNonCycleOverheadMs: roundMs(residualNonCycleOverheadMs),
    residualNonCycleOverheadAmortizedMs: roundMs(
      residualNonCycleOverheadMs / safeCycleCount,
    ),
    startupBreakdown: startup.breakdown,
    teardownBreakdown: teardown.breakdown,
    cycleCount,
  };
}
