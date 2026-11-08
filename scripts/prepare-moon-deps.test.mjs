import test from "node:test";
import assert from "node:assert/strict";
import {
  mkdtempSync,
  mkdirSync,
  writeFileSync,
  readFileSync,
  unlinkSync,
  rmSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { prepareMoonDeps } from "./prepare-moon-deps.mjs";

function fixture(t) {
  const root = mkdtempSync(join(tmpdir(), "kagura-prepare-"));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const dep = join(root, ".mooncakes/test/lib");
  mkdirSync(dep, { recursive: true });
  return { root, dep };
}
const ok = { status: 0, stdout: "", stderr: "" };

test("preparation leaves modern dependency packages and source unchanged", (t) => {
  const { root } = fixture(t);
  const dep = join(root, ".mooncakes/mizchi/differentiable_ecs");
  mkdirSync(join(dep, "src/optimizer"), { recursive: true });
  writeFileSync(
    join(dep, "moon.mod"),
    'name = "mizchi/differentiable_ecs"\nversion = "0.2.1"\n',
  );
  const pkg = 'import { "moonbitlang/core/math", }\n';
  const source = "// dependency source belongs to its publisher\n";
  writeFileSync(join(dep, "src/optimizer/moon.pkg"), pkg);
  writeFileSync(join(dep, "src/optimizer/source.mbt"), source);
  prepareMoonDeps(root, { run: () => ok });
  assert.equal(readFileSync(join(dep, "src/optimizer/moon.pkg"), "utf8"), pkg);
  assert.equal(readFileSync(join(dep, "src/optimizer/source.mbt"), "utf8"), source);
});

test("native-only dependencies are prepared with the plan's target", (t) => {
  const { root } = fixture(t);
  const calls = [];
  prepareMoonDeps(root, {
    target: "native",
    run: (_command, args) => {
      calls.push(args);
      return ok;
    },
  });
  assert.deepEqual(calls, [["check", "--dry-run", "--target", "native"]]);
});
test("discovers legacy cache manifests without parsing compiler diagnostic text", (t) => {
  const { root, dep } = fixture(t);
  writeFileSync(join(dep, "moon.mod.json"), "{}");
  const calls = [];
  prepareMoonDeps(root, {
    run(command, args) {
      calls.push(args);
      if (args[0] === "-C") {
        unlinkSync(join(dep, "moon.mod.json"));
        writeFileSync(join(dep, "moon.mod"), 'name = "test/lib"');
        return ok;
      }
      return calls.length === 1
        ? { status: 1, stderr: "diagnostic wording changed completely" }
        : ok;
    },
  });
  assert.deepEqual(calls, [
    ["check", "--dry-run"],
    ["-C", dep, "fmt"],
    ["check", "--dry-run"],
  ]);
});
test("migration failures and lack of progress are propagated", (t) => {
  const { root, dep } = fixture(t);
  writeFileSync(join(dep, "moon.mod.json"), "{}");
  assert.throws(
    () =>
      prepareMoonDeps(root, {
        run: () => ({ status: 1, stderr: "format failed" }),
      }),
    /format failed/,
  );
  assert.throws(
    () => prepareMoonDeps(root, { run: () => ok }),
    /already migrated/,
  );
});
test("project manifests are never migrated and unrelated failures are not hidden", (t) => {
  const { root } = fixture(t);
  writeFileSync(join(root, "moon.mod.json"), "{}");
  let calls = 0;
  assert.throws(
    () =>
      prepareMoonDeps(root, {
        run: () => {
          calls++;
          return { status: 1, stderr: "project failure" };
        },
      }),
    /project failure/,
  );
  assert.equal(calls, 1);
});
