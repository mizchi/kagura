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

export function formatBaseline(results, { target = null, generatedAt = null } = {}) {
  const entries = [...results].sort((a, b) => a.name.localeCompare(b.name));
  const benchmarks = {};
  for (const { name, meanUs } of entries) {
    benchmarks[name] = Number(meanUs.toFixed(2));
  }
  const baseline = {
    version: 1,
    target: target ?? null,
    generatedAt: generatedAt ?? new Date().toISOString(),
    benchmarks,
  };
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
      benchmarks: { ...parsed.benchmarks },
    };
  }
  if (parsed && typeof parsed === "object") {
    return {
      version: 0,
      target: null,
      generatedAt: null,
      benchmarks: { ...parsed },
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
  const entries = [];
  for (const { name, meanUs } of results) {
    const base = baseline.benchmarks[name];
    if (base == null || base === 0) {
      entries.push({ name, meanUs, status: "new", baseline: null, ratio: null });
      continue;
    }
    baselineKeys.delete(name);
    const ratio = meanUs / base;
    const status = ratio > threshold
      ? "regression"
      : ratio < speedupThreshold
      ? "speedup"
      : "ok";
    entries.push({ name, meanUs, status, baseline: base, ratio });
  }
  const removed = [...baselineKeys].sort().map((name) => ({
    name,
    baseline: baseline.benchmarks[name],
  }));
  const regressions = entries.filter((e) => e.status === "regression");
  const speedups = entries.filter((e) => e.status === "speedup");
  return {
    threshold,
    speedupThreshold,
    entries,
    removed,
    hasRegression: regressions.length > 0,
    hasSpeedup: speedups.length > 0,
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
