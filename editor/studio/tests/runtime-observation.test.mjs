import test from "node:test";
import assert from "node:assert/strict";
import { readRuntimeObservation } from "../runtime/observation.mjs";

test("atomic observations publish detached, explicitly read-only subjects", () => {
  const payload = {
    state: { x: 3 },
    inspection: {
      scope: "training",
      subjects: [
        {
          id: "player",
          name: "Player",
          fields: [
            {
              id: "x",
              label: "X",
              kind: "number",
              value: 3,
              unit: "m",
              access: "readonly",
            },
          ],
        },
      ],
    },
  };
  const realm = {
    kaguraSceneRuntime: {
      apiVersion: 1,
      game: "arena3d",
      observe: () => payload,
      snapshot() {
        throw Error("An atomic observation must not make a second read");
      },
    },
  };
  const result = readRuntimeObservation(realm, "arena3d");
  assert.equal(result.inspection.scope, "training");
  assert.equal(result.inspection.subjects[0].fields[0].value, result.state.x);
  result.state.x = 99;
  result.inspection.subjects[0].fields[0].value = 100;
  assert.equal(payload.state.x, 3);
  assert.equal(payload.inspection.subjects[0].fields[0].value, 3);
});

test("observation descriptors cannot grant edits or bypass descriptor validation", () => {
  const field = {
    id: "x",
    label: "X",
    kind: "number",
    value: 3,
    unit: "m",
    access: "runtime",
  };
  const payload = {
    state: {},
    inspection: {
      scope: "training",
      subjects: [{ id: "player", name: "Player", fields: [field] }],
    },
  };
  const realm = {
    kaguraSceneRuntime: {
      apiVersion: 1,
      game: "arena3d",
      observe: () => payload,
    },
  };
  assert.throws(() => readRuntimeObservation(realm, "arena3d"), /read.only/i);
  field.access = "readonly";
  field.value = Infinity;
  assert.throws(
    () => readRuntimeObservation(realm, "arena3d"),
    /number|field/i,
  );
  field.value = 3;
  payload.inspection.scope = "";
  assert.throws(() => readRuntimeObservation(realm, "arena3d"), /scope/i);
});

test("atomic observations require state and share the size limit with field metadata", () => {
  const payload = { state: undefined };
  const realm = {
    kaguraSceneRuntime: {
      apiVersion: 1,
      game: "arena3d",
      observe: () => payload,
    },
  };
  assert.throws(() => readRuntimeObservation(realm, "arena3d"), /state/);
  payload.state = {};
  payload.inspection = {
    scope: "training",
    subjects: [
      {
        id: "player",
        name: "Player",
        fields: [
          {
            id: "text",
            label: "Text",
            unit: "",
            kind: "string",
            access: "readonly",
            value: "x".repeat(4 * 1024 * 1024),
          },
        ],
      },
    ],
  };
  assert.throws(() => readRuntimeObservation(realm, "arena3d"), /4 MiB/);
});
test("other games expose explicit, detached read-only scene or UI observations", () => {
  const state = { player: { x: 3 } };
  const scene = readRuntimeObservation(
    {
      kaguraSceneRuntime: {
        apiVersion: 1,
        game: "arena3d",
        snapshot: () => state,
      },
    },
    "arena3d",
  );
  assert.equal(scene.source, "scene");
  assert.equal(scene.readonly, true);
  scene.state.player.x = 99;
  assert.equal(state.player.x, 3);
  assert.equal(
    readRuntimeObservation(
      { __kaguraUISnapshot: { parsed: { frame: 12, nodes: [] } } },
      "card_game",
    ).source,
    "ui",
  );
  assert.equal(readRuntimeObservation({}, "unknown"), null);
  assert.equal(
    readRuntimeObservation(
      { kaguraGame: { snapshot: () => ({ phase: "playing" }) } },
      "iron_yard",
    ).source,
    "game",
  );
  assert.equal(
    readRuntimeObservation(
      { __kaguraGfx: { lastRenderCpuMs: () => 2 } },
      "emberwing",
    ).source,
    "renderer",
  );
  assert.throws(
    () =>
      readRuntimeObservation(
        {
          kaguraSceneRuntime: {
            apiVersion: 1,
            game: "wrong",
            snapshot: () => state,
          },
        },
        "arena3d",
      ),
    /mismatch/,
  );
});
