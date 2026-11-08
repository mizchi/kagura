import test from "node:test";
import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { resolve, join } from "node:path";
import {
  createCheckPlan,
  uncoveredModules,
  sourceModules,
} from "./moon-check-plan.mjs";

const root = resolve(import.meta.dirname, "..");
test("every source-owned MoonBit module has an executable validation route", () => {
  assert.deepEqual(
    uncoveredModules(root, createCheckPlan("all", { target: "native" })),
    [],
  );
});

test("source-owned modules no longer contain legacy JSON manifests", () => {
  assert.deepEqual(
    sourceModules(root).filter((path) =>
      existsSync(join(root, path, "moon.mod.json")),
    ),
    [],
  );
});
