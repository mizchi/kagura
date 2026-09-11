import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createRuntimeSession } from '../runtime/session.mjs';

function game() {
  let revision = 0,
    paused = false,
    state = { tick: 0 };
  return {
    apiVersion: 1,
    game: 'test',
    schema: { id: 'test.state', version: 1 },
    read: () => ({ revision, paused, state }),
    pause(value) {
      paused = value;
      revision++;
    },
    step() {
      state.tick++;
      revision++;
    },
    replace(next) {
      if (next.tick < 0) throw Error('Invalid tick');
      state = next;
      revision++;
    },
  };
}

test('runtime edits require paused state and a current session/revision, isolated from callers', () => {
  const raw = game(),
    runtime = createRuntimeSession(raw);
  const running = runtime.snapshot();
  assert.throws(() => runtime.replace({ tick: 5 }, running), /paused/);
  const paused = runtime.pause();
  const next = runtime.replace({ tick: 5 }, paused);
  assert.equal(next.state.tick, 5);
  next.state.tick = 900;
  assert.equal(runtime.snapshot().state.tick, 5);
  assert.throws(() => runtime.step(paused), /conflict/);
  assert.throws(() => runtime.replace({ tick: -1 }, runtime.snapshot()), /Invalid tick/);
  assert.equal(runtime.snapshot().state.tick, 5);
  const step = runtime.step(runtime.snapshot());
  assert.equal(step.state.tick, 6);
  assert.equal(step.paused, true);
  assert.equal(runtime.resume(step).paused, false);
  const restarted = createRuntimeSession(game());
  restarted.pause();
  assert.throws(() => restarted.replace({ tick: 1 }, paused), /session/);
  runtime.dispose();
  assert.throws(() => runtime.pause(), /disposed/);
});

test('WebMCP runtime tools use runtime tokens and do not change the scene revision', async () => {
  const { registerWebMCP } = await import('../web/webmcp.mjs');
  const runtime = createRuntimeSession(game()),
    registered = new Map();
  const editor = { snapshot: () => ({ revision: 37 }), capabilities: () => ({}), runtime };
  const publication = registerWebMCP(editor, {
    registerTool(tool) {
      registered.set(tool.name, tool);
    },
  });
  await publication.ready;
  const invoke = (name, args = {}) => registered.get('kagura.runtime_' + name).execute(args);
  const pause = await invoke('pause');
  assert.equal(pause.ok, true);
  const token = { session: pause.snapshot.session, revision: pause.snapshot.revision };
  const result = await invoke('replace', { token, state: { tick: 9 } });
  assert.equal(result.snapshot.state.tick, 9);
  assert.equal(editor.snapshot().revision, 37);
  assert.equal((await invoke('step', { token })).ok, false);
  assert.equal(registered.get('kagura.runtime_replace').annotations.readOnlyHint, false);
  assert.equal(registered.get('kagura.runtime_snapshot').annotations.readOnlyHint, true);
  publication.dispose();
  assert.equal((await invoke('pause')).ok, false);
});

test('runtime boundary rejects non-JSON state and oversized UTF-8 payloads before mutation', () => {
  const runtime = createRuntimeSession(game());
  const before = runtime.pause();
  for (const state of [{ tick: NaN }, { tick: undefined }, { tick: () => {} }])
    assert.throws(() => runtime.replace(state, before), /finite JSON/);
  assert.throws(() => runtime.replace({ tick: 'あ'.repeat(1500000) }, before), /4 MiB/);
  assert.deepEqual(runtime.snapshot(), before);
});
