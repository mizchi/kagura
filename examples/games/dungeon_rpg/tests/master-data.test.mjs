import test from "node:test";
import assert from "node:assert/strict";
import data from "../assets/master-data.json" with { type: "json" };
import { masterDataAdapter } from "../assets/master-data-adapter.mjs";
import {
  validateDocument,
  parameterSpecs,
} from "../../../../game/master-data/contract.mjs";
import { createHeadlessSession } from "../agent/headless.mjs";
import { runAgent, replayRecords } from "../agent/runner.mjs";
import { testPolicy } from "../agent/test-policy.mjs";

test("the editor schema and runtime decoder agree on invalid master data", () => {
  const changes = [
    (d) => (d.tables.enemies[0].hp = 0),
    (d) => (d.tables.enemies[0].kind = 4),
    (d) => (d.tables.encounters[0].enemy1 = "missing"),
    (d) => (d.tables.encounters[0].context = "b2"),
    (d) => (d.tables.rules[0].enemy_hp_scale = 1.01),
    (d) => (d.tables.rules[0].sweep_damage = 0),
    (d) => (d.tables.enemies[0].unexpected = 1),
    (d) => (d.version = 2),
  ];
  for (const change of changes) {
    const d = structuredClone(data);
    change(d);
    assert.ok(validateDocument(masterDataAdapter, d).length > 0);
    assert.throws(() => createHeadlessSession({ masterData: d }), /invalid/);
  }
  assert.equal(parameterSpecs(masterDataAdapter, data).length, 3);
});
test("autoplay freezes edited master data in its trace and replays independently of current files", async () => {
  const masterData = structuredClone(data);
  masterData.tables.enemies[4].name = "編集した守護者";
  masterData.tables.enemies[4].hp = 60;
  const records = [];
  const result = await runAgent({
    session: createHeadlessSession({ masterData }),
    choose: testPolicy,
    onRecord: (r) => records.push(r),
  });
  assert.equal(records[0].masterData.tables.enemies[4].name, "編集した守護者");
  assert.equal((await replayRecords(records)).status, result.status);
  assert.equal(
    JSON.stringify(records[0].observation).includes("編集した守護者"),
    false,
  );
  await assert.rejects(
    replayRecords(records, { session: createHeadlessSession() }),
    /master data differs/,
  );
});
