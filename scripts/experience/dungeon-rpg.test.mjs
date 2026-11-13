import test from "node:test";
import assert from "node:assert/strict";
import { createHeadlessSession } from "../../examples/games/dungeon_rpg/agent/headless.mjs";
import {
  runAgent,
  replayRecords,
} from "../../examples/games/dungeon_rpg/agent/runner.mjs";
import { policyDecision } from "../../examples/games/dungeon_rpg/agent/policies.mjs";
import { recordingFromTrace, analyzeTrace } from "./adapters/dungeon-rpg.mjs";
import { analyzeExperience } from "../../game/experience/index.mjs";
import { createAdapter } from "../balance/adapters/dungeon-rpg.mjs";

test("an actual expedition yields causal rounds and policy exposures without leaking telemetry into choices", async () => {
  const records = [];
  const result = await runAgent({
    session: createHeadlessSession(),
    model: "policy:tactical",
    choose: (o) => {
      assert.equal(JSON.stringify(o).includes("loop.start"), false);
      return policyDecision(o, "tactical");
    },
    onRecord: (r) => records.push(r),
    maxDecisions: 400,
  });
  assert.equal(result.status, "victory");
  const report = analyzeTrace(records, { runId: "test-run" });
  assert.equal(report.valid, true, JSON.stringify(report.issues));
  assert.ok(report.loops.length > 0);
  assert.ok(report.loops.every((l) => l.status === "completed"));
  assert.equal(report.measures.find((m) => m.id === "causalCoverage").value, 1);
  assert.equal(report.arcs[0].exposure, "first");
  assert.equal(report.ledger[0].exposures[0].source, "observation");
  assert.equal(
    report.measures.find((m) => m.id === "recognitionRate").value,
    null,
  );
  assert.equal(
    report.measures.find((m) => m.id === "feedbackLatencyP95Ms").value,
    null,
  );
  const recording = recordingFromTrace(records, { runId: "test-run" });
  assert.deepEqual(
    analyzeExperience(JSON.parse(JSON.stringify(recording))),
    report,
  );
  await replayRecords(records);
  const changed = structuredClone(records);
  changed[2].experience.events[0].type = "input.rejected";
  await assert.rejects(replayRecords(changed), /experience differs/);
});

test("limited traces leave pending rounds censored and old traces cannot invent telemetry", async () => {
  const records = [];
  await runAgent({
    session: createHeadlessSession(),
    choose: (o) => policyDecision(o, "tactical"),
    maxDecisions: 12,
    onRecord: (r) => records.push(r),
  });
  const r = analyzeTrace(records, { runId: "limit" });
  assert.equal(r.termination, "censored");
  assert.ok(r.loops.some((l) => l.status === "censored"));
  delete records[0].experienceVersion;
  assert.throws(() => analyzeTrace(records, { runId: "old" }), /telemetry/);
});

test("balance trials explicitly project complete loop measurements and retain the report for review", async () => {
  const adapter = createAdapter({
    captureExperience: true,
    experienceMetrics: [
      {
        targetId: "combat-round",
        metricId: "causalCoverage",
        as: "loopCausalCoverage",
        minSamples: 1,
      },
    ],
  });
  const r = await adapter.runTrial({
    params: { enemyHpScale: 1, enemyDamageScale: 1, encounterSteps: 8 },
    seed: 731,
    policy: "tactical",
  });
  assert.equal(r.metrics.loopCausalCoverage, 1);
  assert.equal(r.loopArc.valid, true);
  assert.equal(r.loopArc.run.cohort, "policy:tactical");
  assert.equal(r.experience.kind, "mechanical-trace");
});
