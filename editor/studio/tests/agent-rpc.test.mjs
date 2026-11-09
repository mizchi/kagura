import { test } from "node:test";
import assert from "node:assert/strict";
import { createRpcHost, resolveRpc } from "../agent/rpc-host.mjs";

test("rpc host sends tool_call frames and resolves with the browser result", async () => {
  const sent = [];
  const pending = new Map();
  const host = createRpcHost((message) => sent.push(message), pending);
  const result = host.snapshot();
  assert.equal(sent[0].type, "tool_call");
  assert.equal(sent[0].name, "editor_snapshot");
  assert.equal(
    resolveRpc(pending, { id: sent[0].id, result: { revision: 3 } }),
    true,
  );
  assert.deepEqual(await result, { revision: 3 });
});

test("field RPC preserves scoped tokens and read-only observation requests", async () => {
  const sent = [],
    pending = new Map(),
    host = createRpcHost((message) => sent.push(message), pending);
  assert.equal(typeof host.runtime.fields?.edit, "function");
  const token = { session: "s1", revision: 7, scope: "training" };
  const response = host.runtime.fields.edit(
    { subject: "player", field: "position.y", value: 4 },
    token,
  );
  assert.equal(sent[0].name, "runtime_fields_edit");
  assert.deepEqual(sent[0].args, {
    subject: "player",
    field: "position.y",
    value: 4,
    ...token,
  });
  resolveRpc(pending, { id: sent[0].id, result: { ...token, revision: 8 } });
  assert.equal((await response).revision, 8);
  const observation = host.runtime.observe();
  assert.equal(sent[1].name, "runtime_observe");
  resolveRpc(pending, { id: sent[1].id, result: null });
  assert.equal(await observation, null);
});
