// Game-independent frame, browser and Chrome trace statistics.
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
