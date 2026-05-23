import test from "node:test";
import assert from "node:assert/strict";

import {
  compareToBaseline,
  formatBaseline,
  formatCompareReport,
  parseBaseline,
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
  assert.equal(parsed.version, 1);
  assert.equal(parsed.target, "js");
  assert.equal(parsed.generatedAt, "2026-05-01T00:00:00.000Z");
  assert.deepEqual(parsed.benchmarks, { a: 100, b: 200.56 });
  assert.equal(Object.keys(parsed.benchmarks)[0], "a", "keys must be alphabetically sorted");
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
  assert.match(text, /threshold: 1.5x/);
  assert.match(text, /REGRESSION: physics\/step/);
  assert.match(text, /NEW: new\/bench/);
  assert.match(text, /MISSING: stale\/bench/);
});
