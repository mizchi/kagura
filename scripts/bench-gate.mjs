#!/usr/bin/env node
// Run `moon bench` and compare results against a stored baseline.
// Replaces the previous bash version, which silently dropped FAILED=1 from
// the subshell pipeline and never failed CI on a regression.
//
// Usage:
//   node scripts/bench-gate.mjs [target]            # check against baseline
//   node scripts/bench-gate.mjs [target] --update   # save new baseline

import { spawnSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import process from "node:process";

import {
  compareToBaseline,
  formatBaseline,
  formatCompareReport,
  parseBaseline,
  parseBenchOutput,
} from "./bench-gate-utils.mjs";

const BASELINE_PATH = "scripts/bench-baseline.json";
const REGRESSION_THRESHOLD = 1.5;

const [, , targetArg = "js", modeArg] = process.argv;
const update = modeArg === "--update";

console.log(`Running benchmarks (target=${targetArg})...`);
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
process.stdout.write(moon.stdout ?? "");

const results = parseBenchOutput(benchOutput);
if (results.length === 0) {
  console.error("\nNo benchmark lines parsed from `moon bench` output.");
  console.error("Expected lines like: `<name>/<bench>  123.45 µs ± ...`");
  process.exit(1);
}

if (update) {
  const text = formatBaseline(results, { target: targetArg });
  writeFileSync(BASELINE_PATH, text);
  console.log(`\nBaseline saved to ${BASELINE_PATH} (${results.length} benchmarks).`);
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

console.log("\nAll benchmarks within threshold.");
