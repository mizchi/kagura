import test from "node:test";
import assert from "node:assert/strict";
import { readRuntimeControl } from "../runtime/control.mjs";

test("pause-only controls require an explicit matching game contract", () => {
  let paused = false;
  const realm = {
    kaguraSceneRuntime: {
      apiVersion: 1,
      game: "arena3d",
      pause(value) {
        paused = value;
      },
      paused: () => paused,
    },
  };
  const control = readRuntimeControl(realm, "arena3d");
  control.pause();
  assert.equal(control.paused(), true);
  control.resume();
  assert.equal(control.paused(), false);
  assert.equal(readRuntimeControl({}, "arena3d"), null);
  assert.equal(
    readRuntimeControl(
      { kaguraSceneRuntime: { apiVersion: 1, game: "arena3d", snapshot() {} } },
      "arena3d",
    ),
    null,
  );
  assert.throws(() => readRuntimeControl(realm, "other"), /mismatch/);
  assert.equal("replace" in control, false);
});
