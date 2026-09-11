#!/usr/bin/env node
// Run `moon bench` and compare results against a stored baseline.
// Replaces the previous bash version, which silently dropped FAILED=1 from
// the subshell pipeline and never failed CI on a regression.
//
// Usage:
//   node scripts/bench-gate.mjs [target]              # check against baseline
//   node scripts/bench-gate.mjs [target] --update     # save new baseline
//   node scripts/bench-gate.mjs [target] --runs 3     # median of 3 runs
//
// `--runs N` runs `moon bench` N times and records or compares the **median**
// per benchmark. One run is one sample, and some benchmarks are wider than the
// gate: `ecs/spawn_10000` spans 1.55x over five runs of identical code, against
// a 1.5x threshold. With repeated runs the recorded number stops depending on
// which end of its own spread the baseline happened to catch, and the spread is
// stored alongside so the comparison can say which verdicts it can resolve.

import { spawnSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import process from "node:process";

import {
  aggregateRuns,
  compareToBaseline,
  formatBaseline,
  formatCompareReport,
  parseBaseline,
  parseBenchOutput,
} from "./bench-gate-utils.mjs";

const BASELINE_PATH = "scripts/bench-baseline.json";
const REGRESSION_THRESHOLD = 1.5;

const argv = process.argv.slice(2);
const flags = argv.filter((a) => a.startsWith("--"));
const positional = argv.filter((a) => !a.startsWith("--"));
const targetArg = positional[0] ?? "js";
const update = flags.includes("--update");
const runsFlagIndex = argv.indexOf("--runs");
const runCount = runsFlagIndex >= 0 ? Number(argv[runsFlagIndex + 1]) : 1;
if (!Number.isInteger(runCount) || runCount < 1) {
  console.error("--runs takes a positive integer");
  process.exit(2);
}

const runs = [];
for (let run = 1; run <= runCount; run += 1) {
  console.log(
    runCount === 1
      ? `Running benchmarks (target=${targetArg})...`
      : `Running benchmarks (target=${targetArg}, run ${run}/${runCount})...`,
  );
  const moon = spawnSync("moon", ["bench", "--target", targetArg], {
    encoding: "utf8",
  });
  if (moon.status !== 0) {
    process.stderr.write(moon.stderr ?? "");
    process.stderr.write(moon.stdout ?? "");
    console.error(`\nmoon bench exited with status ${moon.status}`);
    process.exit(moon.status ?? 1);
  }
  const benchOutput = `${moon.stdout ?? ""}\n${moon.stderr ?? ""}`;
  if (run === 1) {
    process.stdout.write(moon.stdout ?? "");
  }
  const parsed = parseBenchOutput(benchOutput);
  if (parsed.length === 0) {
    console.error("\nNo benchmark lines parsed from `moon bench` output.");
    console.error("Expected lines like: `<name>/<bench>  123.45 µs ± ...`");
    process.exit(1);
  }
  runs.push(parsed);
}

const results = aggregateRuns(runs);

if (update) {
  const text = formatBaseline(results, { target: targetArg });
  writeFileSync(BASELINE_PATH, text);
  console.log(
    `\nBaseline saved to ${BASELINE_PATH} (${results.length} benchmarks, median of ${runCount} run${runCount === 1 ? "" : "s"}).`,
  );
  if (runCount === 1) {
    console.log(
      "Recorded from a single run. Benchmarks wider than the gate will fire on their own",
    );
    console.log("noise later; re-record with --runs 3 or more to pin the median.");
  }
  process.exit(0);
}

if (!existsSync(BASELINE_PATH)) {
  console.log(`\nNo baseline found at ${BASELINE_PATH}.`);
  console.log("Run with --update to create one. Skipping regression check.");
  process.exit(0);
}

const baseline = parseBaseline(readFileSync(BASELINE_PATH, "utf8"));
const report = compareToBaseline(results, baseline, { threshold: REGRESSION_THRESHOLD });
console.log("");
console.log(formatCompareReport(report));

if (report.hasRegression) {
  console.log("");
  console.log(
    `Benchmark regressions detected. Update baseline with: node scripts/bench-gate.mjs ${targetArg} --update`,
  );
  process.exit(1);
}

// A large speedup is either an optimisation worth banking or a benchmark whose
// workload collapsed — a fixture that stopped colliding, a constraint array left
// empty, a scene that fell asleep. The gate cannot tell them apart, so it stops
// and asks rather than silently accepting a benchmark that now measures nothing.
if (report.hasNoisy) {
  console.log("");
  console.log(
    "Benchmarks marked NOISY moved past the threshold, but their own spread across",
  );
  console.log(
    "repeated runs is at least as wide, so the gate cannot tell a change from a",
  );
  console.log("re-run. They do not fail the gate. Re-record with --runs to narrow them.");
}

if (report.hasSpeedup) {
  console.log("");
  console.log(
    "Large speedups detected. Confirm each one is a real optimisation and not a",
  );
  console.log(
    "benchmark whose workload collapsed (no pairs, no constraints, scene asleep).",
  );
  console.log(
    `Then bank it with: node scripts/bench-gate.mjs ${targetArg} --update`,
  );
  process.exit(1);
}

console.log("\nAll benchmarks within threshold.");
