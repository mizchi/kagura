import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createRpcHost, resolveRpc } from '../agent/rpc-host.mjs';

test('rpc host sends tool_call frames and resolves with the browser result', async () => {
  const sent = [];
  const pending = new Map();
  const host = createRpcHost((message) => sent.push(message), pending);
  const result = host.snapshot();
  assert.equal(sent[0].type, 'tool_call');
  assert.equal(sent[0].name, 'editor_snapshot');
  assert.equal(resolveRpc(pending, { id: sent[0].id, result: { revision: 3 } }), true);
  assert.deepEqual(await result, { revision: 3 });
});
