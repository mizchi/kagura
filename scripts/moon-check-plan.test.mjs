import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  createCheckPlan,
  runCheckPlan,
  uncoveredModules,
} from "./moon-check-plan.mjs";

test("standalone and external checks execute the targets from their catalog", () => {
  const calls = [];
  const plan = [
    ...createCheckPlan("standalone"),
    ...createCheckPlan("external"),
  ];
  runCheckPlan(plan, {
    prepare: (dir, target) => calls.push(["prepare", dir, target]),
    run: (cmd, args) => {
      calls.push([cmd, ...args]);
      return { status: 0 };
    },
  });
  for (const entry of plan) {
    assert.equal(
      calls.filter((call) => call[0] === "prepare" && call[1] === entry.dir)
        .length,
      1,
    );
    assert.equal(
      calls.find((call) => call[0] === "prepare" && call[1] === entry.dir)[2],
      entry.targets[0],
    );
    for (const target of entry.targets)
      assert.ok(
        calls.some(
          (call) =>
            call[0] === "moon" &&
            call.includes(entry.dir) &&
            call.includes(target),
        ),
      );
  }
  assert.ok(
    calls
      .filter(
        (call) =>
          call.includes("examples/smoke/browser_headless") &&
          call[0] === "moon",
      )
      .every((call) => call.includes("--no-mbti")),
  );
});

test("new modules fail coverage until registered in the executable plan", (t) => {
  const root = mkdtempSync(join(tmpdir(), "kagura-check-plan-"));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  mkdirSync(join(root, "engine/new-module"), { recursive: true });
  writeFileSync(
    join(root, "engine/new-module/moon.mod"),
    'name = "test/new"\n',
  );
  assert.deepEqual(uncoveredModules(root, []), ["engine/new-module"]);
  assert.deepEqual(
    uncoveredModules(root, [{ dir: "engine/new-module", targets: ["js"] }]),
    [],
  );
});

test("failed checks stop the plan and invalid groups are rejected", () => {
  let runs = 0;
  assert.throws(
    () =>
      runCheckPlan([{ dir: ".", targets: ["js", "native"] }], {
        prepare: () => {},
        run: () => {
          runs++;
          return { status: 1 };
        },
      }),
    /check failed/,
  );
  assert.equal(runs, 1);
  assert.throws(() => createCheckPlan("typo"), /Unknown check group/);
});
