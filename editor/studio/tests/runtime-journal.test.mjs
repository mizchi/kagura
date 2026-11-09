import test from "node:test";
import assert from "node:assert/strict";
import { createRuntimeSession } from "../runtime/session.mjs";

function fixture() {
  let revision = 0,
    paused = false,
    state = { y: 12 };
  return createRuntimeSession({
    apiVersion: 1,
    game: "journal",
    schema: { id: "journal", version: 1 },
    read: () => ({ revision, paused, state }),
    pause: (value) => {
      paused = value;
      revision++;
    },
    step: () => {
      state.y++;
      revision++;
    },
    replace: (next) => {
      if (next.y < 0) throw Error("Invalid y");
      state = next;
      revision++;
    },
    inspector: {
      describe: (s) => [
        {
          id: "body",
          name: "Body",
          fields: [
            {
              id: "y",
              label: "Y",
              kind: "number",
              value: s.y,
              access: "runtime",
              unit: "px",
            },
          ],
        },
      ],
      reduce: (s, e) => ({ ...s, y: e.value }),
    },
  });
}
test("successful runtime mutations are recorded; undo uses the current runtime token", () => {
  const runtime = fixture();
  runtime.pause();
  const before = runtime.snapshot();
  runtime.edit({ subject: "body", field: "y", value: 80 }, before);
  assert.equal(runtime.history().at(-1).operation, "edit");
  assert.equal(runtime.history().at(-1).before, 12);
  assert.throws(() => runtime.undo(before), /conflict/);
  assert.equal(runtime.snapshot().state.y, 80);
  assert.equal(runtime.undo(runtime.snapshot()).state.y, 12);
  assert.equal(runtime.history().at(-1).operation, "undo");
  assert.throws(() => runtime.undo(runtime.snapshot()), /undo/i);
});
test("rejected edits leave history intact; advancing simulation invalidates undo", () => {
  const runtime = fixture();
  runtime.pause();
  const before = runtime.snapshot();
  const history = runtime.history();
  assert.throws(() => runtime.replace({ y: -1 }, before), /Invalid/);
  assert.deepEqual(runtime.history(), history);
  runtime.replace({ y: 80 }, before);
  runtime.step(runtime.snapshot());
  assert.throws(() => runtime.undo(runtime.snapshot()), /undo/i);
  assert.equal(runtime.snapshot().state.y, 81);
  runtime.history().length = 0;
  assert.ok(runtime.history().length > 0);
});
