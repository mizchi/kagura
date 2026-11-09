import test from "node:test";
import assert from "node:assert/strict";
import { createRuntimeFieldSession } from "../runtime/field-session.mjs";

function fixture() {
  let revision = 0,
    paused = true,
    scope = "training",
    x = 3,
    calls = 0;
  const adapter = {
    apiVersion: 1,
    game: "arena3d",
    pause(value) {
      paused = value;
      revision++;
    },
    read: () => ({
      revision,
      paused,
      scope,
      subjects: [
        {
          id: "player",
          name: "Player",
          fields: [
            {
              id: "x",
              label: "X",
              kind: "number",
              value: x,
              unit: "m",
              access: "runtime",
            },
            {
              id: "grounded",
              label: "Grounded",
              kind: "boolean",
              value: true,
              unit: "",
              access: "readonly",
            },
          ],
        },
      ],
    }),
    edit(edit, token) {
      assert.equal(token.revision, revision);
      assert.equal(token.scope, scope);
      if (Math.abs(edit.value) > 10000) throw Error("Out of range");
      calls++;
      x = edit.value;
      revision++;
    },
  };
  return {
    runtime: createRuntimeFieldSession(adapter),
    adapter,
    calls: () => calls,
    advance() {
      revision++;
    },
    running() {
      paused = false;
      revision++;
    },
    transition() {
      scope = "second";
      revision++;
    },
  };
}

test("field sessions guard identity, revision and scope, and record only committed edits", () => {
  const { runtime, calls } = fixture();
  const before = runtime.inspect();
  const after = runtime.edit(
    { subject: "player", field: "x", value: 7 },
    before,
  );
  assert.equal(after.subjects[0].fields[0].value, 7);
  assert.equal(after.revision, before.revision + 1);
  assert.equal(runtime.history()[0].before, 3);
  assert.equal(runtime.history()[0].after, 7);
  assert.throws(
    () => runtime.edit({ subject: "player", field: "x", value: 8 }, before),
    /revision conflict/,
  );
  assert.throws(
    () =>
      runtime.edit(
        { subject: "player", field: "x", value: 8 },
        { ...after, session: "old" },
      ),
    /session conflict/,
  );
  assert.throws(
    () =>
      runtime.edit(
        { subject: "player", field: "x", value: 8 },
        { ...after, scope: "old" },
      ),
    /scope conflict/,
  );
  assert.equal(calls(), 1);
  runtime.inspect().subjects[0].fields[0].value = 999;
  assert.equal(runtime.inspect().subjects[0].fields[0].value, 7);
  assert.equal("replace" in runtime, false);
});

test("field controls pause and resume with the same guarded token contract", () => {
  const f = fixture();
  f.running();
  const paused = f.runtime.pause();
  assert.equal(paused.paused, true);
  assert.equal(f.runtime.resume(paused).paused, false);
  assert.throws(() => f.runtime.resume(paused), /conflict/);
  assert.deepEqual(
    f.runtime.history().map((entry) => entry.operation),
    ["pause", "resume"],
  );
});

test("read-only fields, invalid values, running state and stale contexts never mutate", () => {
  const f = fixture(),
    runtime = f.runtime;
  const token = runtime.inspect();
  for (const edit of [
    { subject: "player", field: "grounded", value: false },
    { subject: "player", field: "x", value: NaN },
    { subject: "unknown", field: "x", value: 1 },
    { subject: "player", field: "x", value: 10001 },
  ]) {
    assert.throws(() => runtime.edit(edit, token));
    assert.deepEqual(runtime.inspect(), token);
  }
  assert.deepEqual(runtime.history(), []);
  f.transition();
  assert.throws(
    () => runtime.edit({ subject: "player", field: "x", value: 7 }, token),
    /conflict/,
  );
  f.running();
  assert.throws(
    () =>
      runtime.edit(
        { subject: "player", field: "x", value: 7 },
        runtime.inspect(),
      ),
    /paused/,
  );
  assert.equal(f.calls(), 0);
  runtime.dispose();
  assert.throws(() => runtime.inspect(), /disposed/);
});
