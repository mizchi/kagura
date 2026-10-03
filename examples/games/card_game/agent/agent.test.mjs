import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createHeadlessSession } from './headless.mjs';
import { JevClient, makeJevRequest, loadApiKey } from './jev.mjs';
import { runAgent, replayRecords } from './runner.mjs';

const response = (body, status = 200) => new Response(JSON.stringify(body), { status });
function answerFor(request, choiceId = Object.keys(request.questions.next_action.criteria)[0]) {
  const ids = Object.keys(request.questions.next_action.criteria);
  return {
    model: 'jev-test', usage: { input_tokens: 123, output_tokens: 0 },
    answers: { next_action: { type: 'choice', choice: choiceId, confidence: 0.9,
      probabilities: Object.fromEntries(ids.map(id => [id, id === choiceId ? 1 : 0])) } },
  };
}
function firstAction(observation) {
  return { choiceId: observation.choices[0].id, model: 'scripted-test', confidence: 1,
    probabilities: Object.fromEntries(observation.choices.map(c => [c.id, c === observation.choices[0] ? 1 : 0])),
    usage: { inputTokens: 0, outputTokens: 0 }, elapsedMs: 0, attempts: 0 };
}

test('headless menus, immutable observations and revision rejection need no browser', () => {
  assert.equal(globalThis.document, undefined);
  const session = createHeadlessSession({ seed: 5 });
  const initial = session.observe();
  assert.equal(initial.phase, 'title');
  assert.deepEqual(initial.choices.map(c => c.id), ['begin']);
  assert.throws(() => { initial.revision = 44; }, TypeError);
  session.step({ revision: 0, choiceId: 'begin' });
  assert.equal(session.observe().phase, 'character_select');
  const before = session.observe();
  assert.throws(() => session.step({ revision: 0, choiceId: 'character:warden' }), /stale_revision/);
  assert.throws(() => session.step({ revision: 1, choiceId: 'play:0:0' }), /illegal_choice/);
  assert.deepEqual(session.observe(), before);
});

test('headless validates host values before MoonBit integer coercion', () => {
  for (const seed of [1.5, NaN, 2 ** 31, -(2 ** 31) - 1]) {
    assert.throws(() => createHeadlessSession({ seed }), /seed/);
  }
  assert.throws(() => createHeadlessSession({ character: 'unknown', stage: 'ascent' }), /character/);
  assert.throws(() => createHeadlessSession({ character: 'warden' }), /together/);
  const session = createHeadlessSession();
  for (const revision of [NaN, 0.5, -1, 2 ** 31]) {
    assert.throws(() => session.step({ revision, choiceId: 'begin' }), /revision/);
  }
  assert.equal(session.observe().revision, 0);
});

test('Jev request exposes exactly the offered actions and structured state', () => {
  const observation = createHeadlessSession({ character: 'warden', stage: 'ascent' }).observe();
  const request = makeJevRequest(observation, 'jev-latest');
  assert.equal(request.questions.next_action.type, 'choice');
  assert.deepEqual(Object.keys(request.questions.next_action.criteria), observation.choices.map(c => c.id));
  assert.equal(request.state.phase, 'map');
  assert.equal(request.state.run.hp, 96);
  assert.equal(request.state.run.gold, 99);
  assert.equal(request.state.run.map.nodes.length, 43);
  assert.equal(request.state.run.map.nodes.filter(n => n.available).length, 3);
  assert.equal(request.state.choices, undefined);
  assert.equal(request.state.run.battle, null);
  assert.equal(observation.schemaVersion, 2);
  assert.match(request.questions.next_action.instructions, /alive/);
});

test('Jev rejects terminal, duplicate and oversized choice sets before networking', () => {
  const original = createHeadlessSession().observe();
  assert.throws(() => makeJevRequest({ ...original, terminal: true }), /invalid_observation/);
  assert.throws(() => makeJevRequest({ ...original, choices: [] }), /invalid_choices/);
  assert.throws(() => makeJevRequest({ ...original, choices: [original.choices[0], original.choices[0]] }), /invalid_choices/);
  assert.throws(() => makeJevRequest({ ...original, choices: Array.from({ length: 256 }, (_, i) => ({ ...original.choices[0], id: `a${i}` })) }), /invalid_choices/);
});

test('Jev authenticates and returns only a validated offered choice', async () => {
  const observation = createHeadlessSession().observe();
  let calls = 0;
  const client = new JevClient({ apiKey: 'secret-fixture', fetchImpl: async (url, init) => {
    calls++;
    assert.equal(url, 'https://api.typesafe.ai/v1/systemone');
    assert.equal(init.headers.authorization, 'Bearer secret-fixture');
    assert.equal(init.method, 'POST');
    const request = JSON.parse(init.body);
    assert.equal(JSON.stringify(request).includes('secret-fixture'), false);
    return response(answerFor(request));
  } });
  const decision = await client.choose(observation);
  assert.equal(decision.choiceId, 'begin');
  assert.equal(decision.confidence, 0.9);
  assert.equal(decision.usage.inputTokens, 123);
  assert.equal(calls, 1);
  assert.equal(JSON.stringify(decision).includes('secret-fixture'), false);
});

test('unknown choices, malformed probabilities and nonfinite confidence fail without a move', async () => {
  const session = createHeadlessSession();
  const before = session.observe();
  for (const mutate of [
    a => { a.answers.next_action.choice = 'invented'; },
    a => { a.answers.next_action.type = 'noul'; },
    a => { a.answers.next_action.confidence = 2; },
    a => { a.answers.next_action.probabilities = { invented: 1 }; },
    a => { a.answers.next_action.probabilities.begin = -1; },
    a => { a.usage.input_tokens = -5; },
  ]) {
    const client = new JevClient({ apiKey: 'key', fetchImpl: async (_url, init) => {
      const body = answerFor(JSON.parse(init.body)); mutate(body); return response(body);
    } });
    await assert.rejects(client.choose(before), /invalid_response/);
    assert.deepEqual(session.observe(), before);
  }
});

test('Jev retries transient failures but does not retry authentication failures or expose their body', async () => {
  let calls = 0;
  const client = new JevClient({ apiKey: 'secret-fixture', retryDelayMs: 0, fetchImpl: async (_url, init) => {
    calls++;
    if (calls === 1) return response({ secret: 'secret-fixture' }, 503);
    return response(answerFor(JSON.parse(init.body)));
  } });
  assert.equal((await client.choose(createHeadlessSession().observe())).attempts, 2);
  const denied = new JevClient({ apiKey: 'secret-fixture', fetchImpl: async () => response({ secret: 'secret-fixture' }, 401) });
  await assert.rejects(denied.choose(createHeadlessSession().observe()), error => {
    assert.match(error.message, /HTTP 401/);
    assert.equal(error.message.includes('secret-fixture'), false);
    return true;
  });
});

test('Jev deadline also covers a stalled response body', async () => {
  const client = new JevClient({ apiKey: 'key', timeoutMs: 15, retries: 0, fetchImpl: async (_url, { signal }) => ({
    ok: true, status: 200,
    json: () => new Promise((_resolve, reject) => signal.addEventListener('abort', () => reject(Error('aborted')), { once: true })),
  }) });
  await assert.rejects(client.choose(createHeadlessSession().observe()), /request_failed/);
});

test('profile reads literal API keys without evaluating shell commands', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'kagura-jev-'));
  const profilePath = join(directory, 'profile');
  try {
    await writeFile(profilePath, '# comment\nexport TYPESAFE_API_KEY="profile-fixture"\n');
    assert.equal(await loadApiKey({ env: {}, profilePath }), 'profile-fixture');
    assert.equal(await loadApiKey({ env: { TYPESAFE_API_KEY: 'env-fixture' }, profilePath }), 'env-fixture');
    await writeFile(profilePath, "TYPESAFE_API_KEY='single-fixture' # comment\n");
    assert.equal(await loadApiKey({ env: {}, profilePath }), 'single-fixture');
    await writeFile(profilePath, 'export TYPESAFE_API_KEY="$(touch should-never-exist)"\n');
    await assert.rejects(loadApiKey({ env: {}, profilePath }), /literal/);
    await writeFile(profilePath, '# missing\n');
    await assert.rejects(loadApiKey({ env: {}, profilePath }), /TYPESAFE_API_KEY/);
  } finally { await rm(directory, { recursive: true, force: true }); }
});

test('headless autonomous run terminates and its decisions replay exactly', async () => {
  const records = [];
  const result = await runAgent({ session: createHeadlessSession({ seed: 42, character: 'warden', stage: 'guardian_trial' }),
    choose: firstAction, maxDecisions: 1000, seed: 42, character: 'warden', stage: 'guardian_trial',
    onRecord: record => records.push(record) });
  assert.ok(['victory', 'defeat'].includes(result.status));
  assert.ok(result.decisions > 2);
  assert.equal(result.observation.terminal, true);
  const replay = replayRecords(records);
  assert.deepEqual(replay.observation, result.observation);
  assert.equal(replay.decisions, result.decisions);
  const tampered = structuredClone(records);
  tampered[1].choiceId = 'invented';
  assert.throws(() => replayRecords(tampered), /replay/);
});

test('a decision limit is recorded as incomplete and an API error preserves the last state', async () => {
  const records = [];
  const limited = await runAgent({ session: createHeadlessSession(), choose: firstAction, maxDecisions: 1,
    seed: 42, onRecord: record => records.push(record) });
  assert.equal(limited.status, 'limit');
  assert.equal(limited.observation.terminal, false);
  assert.equal(replayRecords(records).status, 'limit');
  const failed = [];
  await assert.rejects(runAgent({ session: createHeadlessSession(), maxDecisions: 3, seed: 42,
    choose: async () => { throw Error('secret-fixture'); }, onRecord: record => failed.push(record) }));
  assert.equal(failed.at(-1).status, 'error');
  assert.equal(failed.at(-1).observation.revision, 0);
  assert.equal(JSON.stringify(failed).includes('secret-fixture'), false);
  assert.throws(() => replayRecords(records.slice(0, -1)), /replay/);
});

test('runner validates decisions before mutation and keeps private provider extras out of evidence', async () => {
  const session = createHeadlessSession();
  const records = [];
  await assert.rejects(runAgent({ session, seed: 42, maxDecisions: 1,
    choose: observation => ({ ...firstAction(observation), usage: { inputTokens: NaN, outputTokens: 0 } }),
    onRecord: record => records.push(record) }), /invalid_response/);
  assert.equal(session.observe().revision, 0);
  const safe = [];
  await runAgent({ session: createHeadlessSession(), seed: 42, maxDecisions: 1,
    choose: observation => ({ ...firstAction(observation), privateProviderData: 'secret-fixture' }),
    onRecord: record => safe.push(record) });
  assert.equal(JSON.stringify(safe).includes('secret-fixture'), false);
});


test('headless map IDs cannot jump ahead and old log schema is rejected', () => {
  const session = createHeadlessSession({ character: 'warden', stage: 'ascent' });
  const map = session.observe();
  assert.deepEqual(map.choices.map(c => c.id), ['node:0', 'node:1', 'node:2']);
  assert.throws(() => session.step({ revision: 0, choiceId: 'node:43' }), /illegal_choice/);
  assert.deepEqual(session.observe(), map);
  const battle = session.step({ revision: 0, choiceId: 'node:1' });
  assert.equal(battle.phase, 'battle');
  assert.equal(battle.run.room, 'BATTLE');
  assert.equal(battle.run.map.current, 1);
  assert.equal(battle.run.battle.player.block, 10);
  assert.equal(battle.run.battle.drawPile.count, 5);
  assert.equal(battle.run.map.nodes.filter(n => n.visited).length, 1);
  assert.throws(() => replayRecords([{ type: 'run_start', schemaVersion: 1 }]), /replay_failed/);
  assert.throws(() => makeJevRequest({ ...map, schemaVersion: 1 }), /invalid_observation/);
});
