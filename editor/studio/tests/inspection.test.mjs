import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createRuntimeSession } from '../runtime/session.mjs';

function fixture() {
  let state = { y: 12, velocity: 3 },
    revision = 0,
    paused = false;
  const adapter = {
    apiVersion: 1,
    game: 'inspection',
    schema: { id: 'test.state', version: 1 },
    read: () => ({ state, revision, paused }),
    pause: (value) => {
      paused = value;
      revision++;
    },
    step: () => {
      state.y += state.velocity;
      revision++;
    },
    replace: (value) => {
      if (Math.abs(value.y) > 100) throw Error('Invalid game position');
      state = value;
      revision++;
    },
    inspector: {
      describe: (state) => [
        {
          id: 'bird',
          name: 'Bird',
          fields: [
            { id: 'y', label: 'Y', kind: 'number', value: state.y, access: 'runtime', unit: 'px' },
            {
              id: 'speed',
              label: 'Speed',
              kind: 'number',
              value: Math.abs(state.velocity),
              access: 'readonly',
              unit: 'px/tick',
            },
          ],
        },
      ],
      reduce: (state, edit) => ({ ...state, y: edit.value }),
    },
  };
  return { adapter, runtime: createRuntimeSession(adapter) };
}

test('logical subjects expose typed values and edit through game validation with runtime tokens', () => {
  const { runtime } = fixture();
  const running = runtime.inspect();
  assert.equal(running.subjects[0].fields[0].value, 12);
  assert.throws(() => runtime.edit({ subject: 'bird', field: 'y', value: 20 }, running), /paused/);
  runtime.pause();
  const initial = runtime.inspect();
  const edited = runtime.edit({ subject: 'bird', field: 'y', value: 20 }, initial);
  assert.equal(edited.state.y, 20);
  assert.equal(edited.state.velocity, 3);
  assert.throws(
    () => runtime.edit({ subject: 'bird', field: 'y', value: 30 }, initial),
    /conflict/,
  );
  assert.equal(runtime.inspect().subjects[0].fields[0].value, 20);
});

test('readonly, unknown, invalid and rejected edits leave the live state and revision intact', () => {
  const { runtime } = fixture();
  const before = runtime.pause();
  for (const edit of [
    { subject: 'bird', field: 'speed', value: 10 },
    { subject: 'missing', field: 'y', value: 10 },
    { subject: 'bird', field: 'y', value: '10' },
    { subject: 'bird', field: 'y', value: 1000 },
    { subject: 'bird', field: 'y', value: 10, source: true },
  ]) {
    assert.throws(() => runtime.edit(edit, before));
    assert.deepEqual(runtime.snapshot(), before);
  }
  const result = runtime.inspect();
  result.subjects[0].fields[0].value = 99;
  assert.equal(runtime.inspect().subjects[0].fields[0].value, 12);
  runtime.dispose();
  assert.throws(() => runtime.inspect(), /disposed/);
});

test('unsupported adapters remain usable and malformed descriptors cannot authorize edits', () => {
  const { adapter } = fixture();
  delete adapter.inspector;
  const legacy = createRuntimeSession(adapter);
  assert.equal(legacy.inspect().subjects.length, 0);
  assert.throws(
    () => legacy.edit({ subject: 'bird', field: 'y', value: 20 }, legacy.pause()),
    /not available/,
  );
  const { adapter: invalid, runtime } = fixture();
  invalid.inspector.describe = () => [
    {
      id: 'bird',
      name: 'Bird',
      fields: [
        { id: 'x', label: 'X', kind: 'number', value: 'invalid', access: 'runtime', unit: 'px' },
      ],
    },
  ];
  const before = runtime.pause();
  assert.throws(() => runtime.inspect(), /inspection/);
  assert.throws(() => runtime.edit({ subject: 'bird', field: 'x', value: 1 }, before));
  assert.deepEqual(runtime.snapshot(), before);
});

test('WebMCP exposes the same field descriptors, mutations and rejection semantics', async () => {
  const { registerWebMCP } = await import('../web/webmcp.mjs');
  const { runtime } = fixture();
  const tools = new Map();
  const publication = registerWebMCP(
    { runtime, snapshot: () => ({ revision: 4 }), capabilities: () => ({}) },
    { registerTool: (tool) => tools.set(tool.name, tool) },
  );
  await publication.ready;
  runtime.pause();
  const read = await tools.get('kagura.runtime_inspect').execute({});
  assert.equal(read.inspection.subjects[0].id, 'bird');
  const write = tools.get('kagura.runtime_edit');
  assert.equal(write.annotations.readOnlyHint, false);
  const token = { session: read.inspection.session, revision: read.inspection.revision };
  assert.equal(
    (await write.execute({ token, edit: { subject: 'bird', field: 'y', value: 22 } })).snapshot
      .state.y,
    22,
  );
  assert.equal(
    (await write.execute({ token, edit: { subject: 'bird', field: 'y', value: 23 } })).ok,
    false,
  );
  publication.dispose();
});

test('duplicate identities and invalid descriptor types are rejected before a reducer runs', () => {
  const { adapter, runtime } = fixture();
  const before = runtime.pause();
  const valid = adapter.inspector.describe(before.state);
  adapter.inspector.reduce = () => { assert.fail('invalid descriptors must not reach the reducer'); };
  for (const subjects of [
    [valid[0], valid[0]],
    [{ ...valid[0], fields: [valid[0].fields[0], valid[0].fields[0]] }],
    [{ ...valid[0], fields: [{ ...valid[0].fields[0], access: 'source' }] }],
  ]) {
    adapter.inspector.describe = () => subjects;
    assert.throws(() => runtime.edit({ subject: 'bird', field: 'y', value: 10 }, before), /inspection/);
    assert.deepEqual(runtime.snapshot(), before);
  }
});
