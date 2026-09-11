import test from "node:test";
import assert from "node:assert/strict";

import {
  aggregateRuns,
  compareToBaseline,
  formatBaseline,
  formatCompareReport,
  parseBaseline,
  median,
  parseBenchOutput,
  toMicroseconds,
} from "./bench-gate-utils.mjs";

test("toMicroseconds converts known units", () => {
  assert.equal(toMicroseconds(1500, "ns"), 1.5);
  assert.equal(toMicroseconds(42, "µs"), 42);
  assert.equal(toMicroseconds(42, "us"), 42);
  assert.equal(toMicroseconds(2, "ms"), 2000);
  assert.equal(toMicroseconds(1, "s"), 1_000_000);
});

test("toMicroseconds rejects unknown units", () => {
  assert.throws(() => toMicroseconds(1, "min"), /Unknown bench unit/);
});

test("parseBenchOutput extracts bench lines and converts to microseconds", () => {
  const sample = [
    "Compiling kagura...",
    "ecs/spawn_10000  433.36 µs ± 12.4",
    "physics3d/world_substeps  1.24 ms ± 0.10",
    "text/glyph_warm  900 ns",
    "  (ignored noise line)",
    "scene3d/scene_step  3 s ± 1",
  ].join("\n");
  const results = parseBenchOutput(sample);
  assert.deepEqual(
    results.map((r) => [r.name, r.meanUs]),
    [
      ["ecs/spawn_10000", 433.36],
      ["physics3d/world_substeps", 1240],
      ["text/glyph_warm", 0.9],
      ["scene3d/scene_step", 3_000_000],
    ],
  );
});

test("parseBenchOutput rejects duplicate bench names", () => {
  const sample = [
    "ecs/spawn 100 µs",
    "ecs/spawn 200 µs",
  ].join("\n");
  assert.throws(() => parseBenchOutput(sample), /Duplicate bench name/);
});

test("formatBaseline emits stable sorted JSON with metadata", () => {
  const text = formatBaseline(
    [
      { name: "b", meanUs: 200.555 },
      { name: "a", meanUs: 100 },
    ],
    { target: "js", generatedAt: "2026-05-01T00:00:00.000Z" },
  );
  const parsed = JSON.parse(text);
  assert.equal(parsed.version, 2);
  assert.equal(parsed.target, "js");
  assert.equal(parsed.generatedAt, "2026-05-01T00:00:00.000Z");
  assert.equal(parsed.runs, 1);
  assert.equal(parsed.spreads, undefined, "a single run has no spread to record");
  assert.deepEqual(parsed.benchmarks, { a: 100, b: 200.56 });
  assert.equal(Object.keys(parsed.benchmarks)[0], "a", "keys must be alphabetically sorted");
});

test("formatBaseline records the run count and the observed spread", () => {
  const text = formatBaseline(
    [{ name: "a", meanUs: 100, runs: 3, spread: 1.552 }],
    { target: "js", generatedAt: "2026-05-01T00:00:00.000Z" },
  );
  const parsed = JSON.parse(text);
  assert.equal(parsed.runs, 3);
  assert.deepEqual(parsed.spreads, { a: 1.552 });
});

test("aggregateRuns takes the median per benchmark and records the spread", () => {
  const aggregated = aggregateRuns([
    [{ name: "a", meanUs: 1260 }, { name: "b", meanUs: 10 }],
    [{ name: "a", meanUs: 1950 }, { name: "b", meanUs: 11 }],
    [{ name: "a", meanUs: 1840 }, { name: "b", meanUs: 10.5 }],
  ]);
  assert.deepEqual(aggregated.map((e) => e.name), ["a", "b"]);
  assert.equal(aggregated[0].meanUs, 1840);
  assert.equal(aggregated[0].runs, 3);
  assert.equal(Number(aggregated[0].spread.toFixed(3)), 1.548);
  assert.equal(aggregated[1].meanUs, 10.5);
});

test("aggregateRuns keeps a benchmark that only some runs reported", () => {
  const aggregated = aggregateRuns([
    [{ name: "a", meanUs: 10 }],
    [{ name: "a", meanUs: 20 }, { name: "new", meanUs: 5 }],
  ]);
  assert.equal(aggregated.length, 2);
  assert.equal(aggregated[1].name, "new");
  assert.equal(aggregated[1].runs, 1);
  assert.equal(aggregated[1].spread, 1);
});

test("median handles even and odd sample counts", () => {
  assert.equal(median([3, 1, 2]), 2);
  assert.equal(median([4, 1, 3, 2]), 2.5);
  assert.throws(() => median([]), /empty/);
});

test("compareToBaseline downgrades a verdict its own spread cannot resolve", () => {
  const baseline = parseBaseline(
    JSON.stringify({
      version: 2,
      runs: 5,
      benchmarks: { "ecs/spawn_10000": 1260, "physics/step": 100 },
      spreads: { "ecs/spawn_10000": 1.55 },
    }),
  );
  const report = compareToBaseline(
    [
      { name: "ecs/spawn_10000", meanUs: 1990, runs: 1, spread: null },
      { name: "physics/step", meanUs: 200, runs: 1, spread: null },
    ],
    baseline,
  );
  const noisy = report.entries.find((e) => e.name === "ecs/spawn_10000");
  assert.equal(noisy.status, "noisy");
  assert.equal(noisy.suppressed, "regression");
  assert.equal(noisy.knownSpread, 1.55);
  assert.equal(report.entries.find((e) => e.name === "physics/step").status, "regression");
  assert.equal(report.hasNoisy, true);
  assert.equal(report.hasRegression, true, "the tight benchmark still fails the gate");
});

test("compareToBaseline reads the spread off the new run too", () => {
  const baseline = parseBaseline(JSON.stringify({ version: 2, benchmarks: { wide: 100 } }));
  const report = compareToBaseline(
    [{ name: "wide", meanUs: 160, runs: 3, spread: 1.8 }],
    baseline,
  );
  assert.equal(report.entries[0].status, "noisy");
  assert.equal(report.hasRegression, false);
});

test("formatCompareReport explains a noisy verdict", () => {
  const baseline = parseBaseline(
    JSON.stringify({ version: 2, benchmarks: { wide: 100 }, spreads: { wide: 1.6 } }),
  );
  const text = formatCompareReport(
    compareToBaseline([{ name: "wide", meanUs: 160 }], baseline),
  );
  assert.match(text, /NOISY: wide/);
  assert.match(text, /would be a regression/);
  assert.match(text, /1\.60x, wider than the 1\.5x gate/);
});

test("parseBaseline accepts the legacy flat schema", () => {
  const legacy = parseBaseline(JSON.stringify({ "ecs/spawn": 12.34, "physics/step": 56 }));
  assert.equal(legacy.version, 0);
  assert.deepEqual(legacy.benchmarks, { "ecs/spawn": 12.34, "physics/step": 56 });
});

test("compareToBaseline classifies ok / regression / new / missing", () => {
  const baseline = parseBaseline(
    JSON.stringify({
      version: 1,
      target: "js",
      benchmarks: {
        "ecs/spawn": 100,
        "physics/step": 200,
        "deleted/bench": 50,
      },
    }),
  );
  const report = compareToBaseline(
    [
      { name: "ecs/spawn", meanUs: 110 }, // 1.1x → ok
      { name: "physics/step", meanUs: 350 }, // 1.75x → regression
      { name: "new/bench", meanUs: 42 }, // not in baseline
    ],
    baseline,
    { threshold: 1.5 },
  );
  assert.equal(report.hasRegression, true);
  const byName = Object.fromEntries(report.entries.map((e) => [e.name, e.status]));
  assert.deepEqual(byName, {
    "ecs/spawn": "ok",
    "physics/step": "regression",
    "new/bench": "new",
  });
  assert.deepEqual(report.removed.map((r) => r.name), ["deleted/bench"]);
});

test("compareToBaseline treats zero baseline as new", () => {
  const baseline = parseBaseline(JSON.stringify({ "ecs/spawn": 0 }));
  const report = compareToBaseline(
    [{ name: "ecs/spawn", meanUs: 5 }],
    baseline,
    { threshold: 1.5 },
  );
  assert.equal(report.hasRegression, false);
  assert.equal(report.entries[0].status, "new");
});

test("formatCompareReport surfaces regressions, new entries, and missing", () => {
  const baseline = parseBaseline(
    JSON.stringify({ "physics/step": 200, "stale/bench": 10 }),
  );
  const report = compareToBaseline(
    [
      { name: "physics/step", meanUs: 350 },
      { name: "new/bench", meanUs: 42 },
    ],
    baseline,
    { threshold: 1.5 },
  );
  const text = formatCompareReport(report);
  assert.match(text, /slower than 1\.5x/);
  assert.match(text, /REGRESSION: physics\/step/);
  assert.match(text, /NEW: new\/bench/);
  assert.match(text, /MISSING: stale\/bench/);
});

test("compareToBaseline flags a collapsed workload as a speedup", () => {
  const report = compareToBaseline(
    [
      { name: "physics2d/step_pile_256", meanUs: 100 },
      { name: "physics2d/step_pile_64", meanUs: 900 },
    ],
    {
      version: 1,
      benchmarks: {
        "physics2d/step_pile_256": 5000,
        "physics2d/step_pile_64": 1000,
      },
    },
  );
  const byName = Object.fromEntries(report.entries.map((e) => [e.name, e]));
  // 50x faster: almost certainly a fixture that stopped producing contacts.
  assert.equal(byName["physics2d/step_pile_256"].status, "speedup");
  // 1.11x faster: ordinary noise, not a signal.
  assert.equal(byName["physics2d/step_pile_64"].status, "ok");
  // 2x faster sits inside cross-machine variance and must stay quiet.
  assert.equal(
    compareToBaseline([{ name: "a/b", meanUs: 500 }], {
      version: 1,
      benchmarks: { "a/b": 1000 },
    }).entries[0].status,
    "ok",
  );
  assert.equal(report.hasSpeedup, true);
  assert.equal(report.hasRegression, false);
});

test("compareToBaseline honours a custom speedup threshold", () => {
  const results = [{ name: "a/b", meanUs: 700 }];
  const baseline = { version: 1, benchmarks: { "a/b": 1000 } };
  assert.equal(compareToBaseline(results, baseline).entries[0].status, "ok");
  assert.equal(
    compareToBaseline(results, baseline, { speedupThreshold: 0.8 })
      .entries[0].status,
    "speedup",
  );
});

test("formatCompareReport surfaces speedups with the faster-by ratio", () => {
  const report = compareToBaseline([{ name: "a/b", meanUs: 250 }], {
    version: 1,
    benchmarks: { "a/b": 1000 },
  });
  const text = formatCompareReport(report);
  assert.match(text, /SPEEDUP: a\/b/);
  assert.match(text, /4\.000x faster/);
  assert.match(text, /confirm the workload is still there/);
  assert.match(text, /faster than 0\.33x/);
});
