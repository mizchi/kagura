import test from "node:test";
import assert from "node:assert/strict";
import {
  analyzeExperience,
  compareExperience,
  projectMetrics,
  validateSpec,
} from "./index.mjs";

const spec = {
  apiVersion: 1,
  id: "sample",
  version: 1,
  loops: [{ id: "turn", label: "一手", intent: "結果を読んで次を選ぶ" }],
  arcs: [
    {
      id: "room",
      label: "部屋",
      intent: "discovery",
      knowledgeKey: "room:b2",
      contentVersion: "map:1",
    },
  ],
  relations: [{ from: "room", to: "turn", kind: "context" }],
};
const run = {
  id: "run-1",
  subjectId: "person-1",
  scope: "campaign",
  cohort: "human",
  context: { input: "keyboard" },
};
function events(rows) {
  return rows.map((row, i) => ({
    version: 1,
    id: `e${i + 1}`,
    sequence: i + 1,
    source: "simulation",
    revision: i,
    ...row,
  }));
}
const loopEvents = () =>
  events([
    { type: "loop.start", target: "turn", instance: "t1" },
    { type: "input.requested", target: "turn", instance: "t1" },
    {
      type: "input.accepted",
      target: "turn",
      instance: "t1",
      causes: ["e2"],
      data: { action: "guard" },
    },
    { type: "input.requested", target: "turn", instance: "t1" },
    {
      type: "loop.resolved",
      target: "turn",
      instance: "t1",
      causes: ["e2", "e4"],
    },
    {
      type: "input.accepted",
      target: "turn",
      instance: "t1",
      causes: ["e4"],
      data: { action: "resolve" },
    },
    { type: "loop.ready", target: "turn", instance: "t1" },
  ]);
const analyze = (es, extra = {}) =>
  analyzeExperience({
    spec,
    run,
    events: es,
    termination: "completed",
    ...extra,
  });
const metric = (r, id, targetId = "turn") =>
  r.measures.find((m) => m.id === id && m.targetId === targetId);

test("typed definitions reject duplicate IDs, dangling relations and unknown contracts", () => {
  assert.equal(validateSpec(spec).id, "sample");
  assert.throws(
    () => validateSpec({ ...spec, loops: [...spec.loops, ...spec.loops] }),
    /spec/,
  );
  assert.throws(
    () =>
      validateSpec({
        ...spec,
        relations: [{ from: "missing", to: "turn", kind: "context" }],
      }),
    /relation/,
  );
  assert.throws(() => validateSpec({ ...spec, unexpected: true }), /spec/);
});
test("multi-command resolution joins causes even when acceptance follows synchronous resolution", () => {
  const r = analyze(loopEvents());
  assert.equal(r.valid, true);
  assert.equal(r.loops[0].status, "completed");
  assert.equal(metric(r, "commandsPerResolution").value, 2);
  assert.equal(metric(r, "causalCoverage").value, 1);
  assert.equal(metric(r, "feedbackLatencyP95Ms").value, null);
  assert.equal(metric(r, "feedbackLatencyP95Ms").status, "not-instrumented");
  assert.equal(metric(r, "understandingRate").value, null);
  assert.equal(r.ledger.length, 0);
  assert.throws(() => r.loops.push({}), TypeError);
  const missing = loopEvents();
  missing[4].causes = ["e4"];
  assert.equal(metric(analyze(missing), "causalCoverage").value, 0);
});
test("cancellation, rejection, interruption and censored rounds remain distinct", () => {
  const r = analyze(
    events([
      { type: "loop.start", target: "turn", instance: "a" },
      { type: "input.requested", target: "turn", instance: "a" },
      { type: "input.rejected", target: "turn", instance: "a", causes: ["e2"] },
      { type: "input.requested", target: "turn", instance: "a" },
      {
        type: "input.accepted",
        target: "turn",
        instance: "a",
        causes: ["e4"],
        data: { action: "undo" },
      },
      {
        type: "loop.interrupted",
        target: "turn",
        instance: "a",
        data: { reason: "escape" },
      },
      { type: "loop.start", target: "turn", instance: "b" },
    ]),
    { termination: "censored" },
  );
  assert.deepEqual(
    r.loops.map((l) => l.status),
    ["interrupted", "censored"],
  );
  assert.equal(r.loops[0].commands.length, 1);
  assert.equal(metric(r, "undoCommands").value, 1);
  assert.equal(metric(r, "commandsPerResolution").status, "not-applicable");
});
test("matching presentation clocks measure feedback independently from wall/API time", () => {
  const es = loopEvents();
  es[4].clock = { id: "visible:1", ms: 100 };
  es.push({
    version: 1,
    id: "e8",
    sequence: 8,
    source: "rendered",
    revision: 8,
    type: "loop.feedback",
    target: "turn",
    instance: "t1",
    causes: ["e5"],
    clock: { id: "visible:1", ms: 140 },
  });
  assert.equal(metric(analyze(es), "feedbackLatencyP95Ms").value, 40);
  es[7].clock.id = "another-window";
  assert.equal(metric(analyze(es), "feedbackLatencyP95Ms").value, null);
});
test("reaching an arc does not imply presentation, and exposure history survives game resets", () => {
  const reached = { type: "arc.reached", target: "room", instance: "r1" };
  const first = analyze(events([reached]));
  assert.equal(metric(first, "exposedCount", "room").value, null);
  assert.equal(first.ledger.length, 0);
  const firstExposure = analyze(
    events([
      reached,
      {
        type: "arc.exposed",
        target: "room",
        instance: "r1",
        source: "rendered",
        causes: ["e1"],
      },
    ]),
  );
  assert.equal(firstExposure.arcs[0].exposure, "first");
  const second = analyze(
    events([
      reached,
      {
        type: "arc.exposed",
        target: "room",
        instance: "r1",
        source: "rendered",
        causes: ["e1"],
      },
    ]),
    { run: { ...run, id: "run-2" }, ledger: firstExposure.ledger },
  );
  assert.equal(second.arcs[0].exposure, "repeat");
  assert.equal(second.ledger[0].exposures.length, 2);
  assert.equal(
    metric(second, "recognitionRate", "room").status,
    "not-instrumented",
  );
  const changed = analyzeExperience({
    spec: { ...spec, arcs: [{ ...spec.arcs[0], contentVersion: "map:2" }] },
    run: { ...run, id: "run-3" },
    events: events([
      reached,
      {
        type: "arc.exposed",
        target: "room",
        instance: "r1",
        source: "observation",
      },
    ]),
    ledger: second.ledger,
    termination: "completed",
  });
  assert.equal(changed.arcs[0].exposure, "first");
});
test("human answers use actual answered counts and cannot be fabricated by simulation", () => {
  const es = events([
    { type: "arc.reached", target: "room", instance: "r1" },
    { type: "arc.exposed", target: "room", instance: "r1", source: "rendered" },
    {
      type: "arc.recognized",
      target: "room",
      instance: "r1",
      source: "human",
      data: { value: false },
    },
  ]);
  const m = metric(analyze(es), "recognitionRate", "room");
  assert.equal(m.value, 0);
  assert.equal(m.denominator, 1);
  assert.equal(m.evidenceKind, "human");
  es[2].source = "simulation";
  assert.throws(() => analyze(es), /source/);
});
test("missing events and orphan boundaries are diagnosed instead of looking like perfect feedback", () => {
  const es = loopEvents();
  es.splice(1, 1);
  const r = analyze(es);
  assert.equal(r.valid, false);
  assert.ok(r.issues.some((i) => i.code === "sequence-gap"));
  assert.throws(
    () =>
      projectMetrics(r, [
        {
          targetId: "turn",
          metricId: "causalCoverage",
          as: "coverage",
          minSamples: 1,
        },
      ]),
    /invalid/i,
  );
  const orphan = analyze(
    events([{ type: "loop.resolved", target: "turn", instance: "absent" }]),
  );
  assert.equal(orphan.valid, false);
});
test("comparison preserves missing values and tuning only accepts explicit observed projections", () => {
  const a = analyze(loopEvents()),
    b = analyze(loopEvents(), {
      run: { ...run, id: "run-2", context: { input: "bulk" } },
    });
  const c = compareExperience(a, b);
  assert.equal(c.kind, "descriptive");
  assert.ok(c.conditionsDiffer.includes("input"));
  assert.equal(
    c.measures.find(
      (m) => m.id === "feedbackLatencyP95Ms" && m.targetId === "turn",
    ).delta,
    null,
  );
  assert.deepEqual(
    projectMetrics(a, [
      {
        targetId: "turn",
        metricId: "commandsPerResolution",
        as: "commands",
        minSamples: 1,
      },
    ]),
    { commands: 2 },
  );
  assert.throws(
    () =>
      projectMetrics(a, [
        {
          targetId: "turn",
          metricId: "feedbackLatencyP95Ms",
          as: "latency",
          minSamples: 1,
        },
      ]),
    /observed/,
  );
  assert.throws(
    () =>
      projectMetrics(a, [
        {
          targetId: "turn",
          metricId: "commandsPerResolution",
          as: "commands",
          minSamples: 2,
        },
      ]),
    /samples/,
  );
  assert.throws(
    () =>
      projectMetrics({ ...a, termination: "censored" }, [
        {
          targetId: "turn",
          metricId: "commandsPerResolution",
          as: "commands",
          minSamples: 1,
        },
      ]),
    /Incomplete/,
  );
  assert.doesNotThrow(() =>
    compareExperience(a, {
      ...b,
      spec: Object.fromEntries(Object.entries(b.spec).reverse()),
    }),
  );
});

test("re-analyzing multiple exposures with its exported ledger is idempotent", () => {
  const es = events([
    { type: "arc.reached", target: "room", instance: "r1" },
    { type: "arc.exposed", target: "room", instance: "r1", source: "rendered" },
    { type: "arc.reached", target: "room", instance: "r2" },
    { type: "arc.exposed", target: "room", instance: "r2", source: "rendered" },
  ]);
  const first = analyze(es),
    second = analyze(es, { ledger: first.ledger });
  assert.deepEqual(second, first);
});

test("invalid serialized payloads and duplicate acceptance cannot inflate observed measurements", () => {
  const es = loopEvents();
  es[2].data.extra = NaN;
  assert.throws(() => analyze(es), /JSON/);
  delete es[2].data.extra;
  es.push({ ...es[2], id: "e8", sequence: 8 });
  assert.equal(analyze(es).valid, false);
  assert.throws(
    () =>
      analyzeExperience({
        format: "kagura.experience-recording",
        version: 99,
        spec,
        run,
        events: [],
        termination: "completed",
      }),
    /recording/,
  );
});

test("partial human samples cannot be silently projected as complete tuning evidence", () => {
  const es = events([
    { type: "arc.reached", target: "room", instance: "r1" },
    { type: "arc.exposed", target: "room", instance: "r1", source: "rendered" },
    {
      type: "arc.recognized",
      target: "room",
      instance: "r1",
      source: "human",
      data: { value: true },
    },
    { type: "arc.reached", target: "room", instance: "r2" },
    { type: "arc.exposed", target: "room", instance: "r2", source: "rendered" },
  ]);
  const r = analyze(es);
  assert.equal(metric(r, "recognitionRate", "room").value, 1);
  assert.throws(
    () =>
      projectMetrics(r, [
        {
          targetId: "room",
          metricId: "recognitionRate",
          as: "recognition",
          minSamples: 1,
        },
      ]),
    /coverage/,
  );
  const invalid = structuredClone(r);
  invalid.measures[0].value = "bad";
  assert.throws(() => compareExperience(invalid, r), /report/);
});
