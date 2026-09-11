// Pure helpers for bench-gate: parse `moon bench` output, compare to baseline,
// and emit baseline JSON. Kept side-effect-free so the CLI driver and tests
// share the same logic.

const UNIT_MULTIPLIERS_US = {
  "ns": 1 / 1000,
  "us": 1,
  "µs": 1,
  "μs": 1,
  "ms": 1000,
  "s": 1_000_000,
};

const BENCH_LINE_RE = /^(\S+\/\S+)\s+([0-9]+(?:\.[0-9]+)?)\s+(ns|µs|μs|us|ms|s)\b/;

export function toMicroseconds(value, unit) {
  const mul = UNIT_MULTIPLIERS_US[unit];
  if (mul == null) {
    throw new Error(`Unknown bench unit: ${unit}`);
  }
  return value * mul;
}

export function parseBenchOutput(text) {
  const results = [];
  const seen = new Set();
  for (const rawLine of text.split(/\r?\n/)) {
    const line = rawLine.trimEnd();
    const m = BENCH_LINE_RE.exec(line);
    if (!m) continue;
    const [, name, meanStr, unit] = m;
    if (seen.has(name)) {
      throw new Error(`Duplicate bench name in output: ${name}`);
    }
    seen.add(name);
    results.push({ name, meanUs: toMicroseconds(Number(meanStr), unit) });
  }
  return results;
}

export function median(values) {
  if (values.length === 0) throw new Error("median of an empty list");
  const sorted = [...values].sort((a, b) => a - b);
  const mid = sorted.length >> 1;
  return sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
}

// Fold several `moon bench` runs of the same tree into one result per benchmark.
//
// A single run is a single sample, and some benchmarks are wider than the gate:
// `ecs/spawn_10000` measured 1.26/1.95/1.84/1.89/1.92 ms over five runs of
// identical code — a 1.55x spread against a 1.5x threshold. Recorded from one
// run, whichever end the baseline happened to catch decided whether the next
// commit was a regression.
//
// So each benchmark carries its median and the spread it was measured over, and
// `compareToBaseline` uses the spread to say which comparisons its threshold can
// actually resolve.
export function aggregateRuns(runs) {
  if (runs.length === 0) return [];
  const samples = new Map();
  const order = [];
  for (const run of runs) {
    for (const { name, meanUs } of run) {
      if (!samples.has(name)) {
        samples.set(name, []);
        order.push(name);
      }
      samples.get(name).push(meanUs);
    }
  }
  return order.map((name) => {
    const values = samples.get(name);
    const lo = Math.min(...values);
    const hi = Math.max(...values);
    return {
      name,
      meanUs: median(values),
      runs: values.length,
      spread: lo > 0 ? hi / lo : null,
    };
  });
}

export function formatBaseline(results, { target = null, generatedAt = null } = {}) {
  const entries = [...results].sort((a, b) => a.name.localeCompare(b.name));
  const benchmarks = {};
  const spreads = {};
  let runs = 1;
  for (const entry of entries) {
    benchmarks[entry.name] = Number(entry.meanUs.toFixed(2));
    if (entry.runs != null && entry.runs > runs) {
      runs = entry.runs;
    }
    if (entry.spread != null && entry.runs > 1) {
      spreads[entry.name] = Number(entry.spread.toFixed(3));
    }
  }
  const baseline = {
    version: 2,
    target: target ?? null,
    generatedAt: generatedAt ?? new Date().toISOString(),
    runs,
    benchmarks,
  };
  if (Object.keys(spreads).length > 0) {
    // What each recorded median was measured over. Read as: a comparison at a
    // threshold below this number cannot separate a change from a re-run.
    baseline.spreads = spreads;
  }
  return JSON.stringify(baseline, null, 2) + "\n";
}

export function parseBaseline(text) {
  const parsed = JSON.parse(text);
  // Support both the new {version, benchmarks: {name: us}} form and the
  // legacy flat {name: us} form so existing baseline files keep working.
  if (parsed && typeof parsed === "object" && parsed.benchmarks && typeof parsed.benchmarks === "object") {
    return {
      version: parsed.version ?? 1,
      target: parsed.target ?? null,
      generatedAt: parsed.generatedAt ?? null,
      runs: parsed.runs ?? 1,
      benchmarks: { ...parsed.benchmarks },
      spreads: parsed.spreads ? { ...parsed.spreads } : {},
    };
  }
  if (parsed && typeof parsed === "object") {
    return {
      version: 0,
      target: null,
      generatedAt: null,
      runs: 1,
      benchmarks: { ...parsed },
      spreads: {},
    };
  }
  throw new Error("Baseline JSON is not an object");
}

// A one-sided gate only catches code getting slower, which leaves the opposite
// failure invisible: a benchmark whose *workload* collapses. Stop generating
// contacts, leave a constraint array empty, let a fixture fall asleep, and the
// benchmark gets much faster and stays green forever while measuring nothing.
// This is the same trap as a frame-VRT baseline of 18 all-black frames.
//
// So large speedups are reported too. A real optimisation clears with one
// `--update`; a collapsed workload gets looked at instead of banked.
//
// The default is 3x faster rather than something tighter because this baseline is
// machine-specific: replaying it on slower hardware moves unrelated benchmarks by
// up to 2x in *both* directions, so a 2x gate would fire on CPU differences and
// train everyone to ignore it. Workload collapse is not that subtle — draining
// the contacts out of a 64-body physics fixture already costs 3.3x, and a pile
// that stops colliding entirely moves by an order of magnitude.
export function compareToBaseline(
  results,
  baseline,
  { threshold = 1.5, speedupThreshold = 1 / 3 } = {},
) {
  const baselineKeys = new Set(Object.keys(baseline.benchmarks));
  const baselineSpreads = baseline.spreads ?? {};
  const entries = [];
  for (const { name, meanUs, spread = null, runs = 1 } of results) {
    const base = baseline.benchmarks[name];
    if (base == null || base === 0) {
      entries.push({ name, meanUs, status: "new", baseline: null, ratio: null, spread, runs });
      continue;
    }
    baselineKeys.delete(name);
    const ratio = meanUs / base;
    // How wide this benchmark is known to be, from either side's repeated runs.
    // A benchmark whose own spread reaches the threshold cannot be gated at that
    // threshold: the same code re-run crosses it. Saying so beats failing on it
    // (which teaches everyone to ignore the gate) and beats passing silently
    // (which is how a real regression hides inside the noise).
    const knownSpread = Math.max(spread ?? 1, baselineSpreads[name] ?? 1);
    const verdict = ratio > threshold
      ? "regression"
      : ratio < speedupThreshold
      ? "speedup"
      : "ok";
    const status = verdict !== "ok" && knownSpread >= threshold ? "noisy" : verdict;
    entries.push({
      name,
      meanUs,
      status,
      baseline: base,
      ratio,
      spread,
      runs,
      knownSpread: knownSpread > 1 ? knownSpread : null,
      suppressed: status === "noisy" ? verdict : null,
    });
  }
  const removed = [...baselineKeys].sort().map((name) => ({
    name,
    baseline: baseline.benchmarks[name],
  }));
  const regressions = entries.filter((e) => e.status === "regression");
  const speedups = entries.filter((e) => e.status === "speedup");
  const noisy = entries.filter((e) => e.status === "noisy");
  return {
    threshold,
    speedupThreshold,
    entries,
    removed,
    hasRegression: regressions.length > 0,
    hasSpeedup: speedups.length > 0,
    hasNoisy: noisy.length > 0,
  };
}

export function formatCompareReport(report) {
  const lines = [];
  lines.push(
    `=== Benchmark Regression Check (slower than ${report.threshold}x, faster than ${
      report.speedupThreshold.toFixed(2)
    }x) ===`,
  );
  for (const entry of report.entries) {
    if (entry.status === "new") {
      lines.push(`  NEW: ${entry.name} = ${formatUs(entry.meanUs)} (no baseline)`);
      continue;
    }
    const ratioStr = entry.ratio.toFixed(3);
    if (entry.status === "regression") {
      lines.push(
        `  REGRESSION: ${entry.name} = ${formatUs(entry.meanUs)} vs baseline ${formatUs(entry.baseline)} (${ratioStr}x slower)`,
      );
    } else if (entry.status === "speedup") {
      lines.push(
        `  SPEEDUP: ${entry.name} = ${formatUs(entry.meanUs)} vs baseline ${formatUs(entry.baseline)} (${(1 / entry.ratio).toFixed(3)}x faster) — confirm the workload is still there`,
      );
    } else if (entry.status === "noisy") {
      lines.push(
        `  NOISY: ${entry.name} = ${formatUs(entry.meanUs)} vs baseline ${formatUs(entry.baseline)} (${ratioStr}x, would be a ${entry.suppressed}) — this benchmark's own spread is ${entry.knownSpread.toFixed(2)}x, wider than the ${report.threshold}x gate`,
      );
    } else {
      lines.push(
        `  OK: ${entry.name} = ${formatUs(entry.meanUs)} vs baseline ${formatUs(entry.baseline)} (${ratioStr}x)`,
      );
    }
  }
  for (const removed of report.removed) {
    lines.push(`  MISSING: ${removed.name} (baseline ${formatUs(removed.baseline)}, not in output)`);
  }
  return lines.join("\n");
}

function formatUs(value) {
  const rounded = Math.round(value * 100) / 100;
  return `${rounded}µs`;
}
