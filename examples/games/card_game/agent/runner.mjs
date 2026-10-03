import { isDeepStrictEqual } from 'node:util';
import { createHeadlessSession } from './headless.mjs';
import { AgentError, int32 } from './errors.mjs';
import { validateDecision } from './contracts.mjs';

/** @param {{ session: import('./contracts.d.mts').HeadlessSession,
 * choose: (state: import('./contracts.d.mts').Observation) => import('./contracts.d.mts').Decision | Promise<import('./contracts.d.mts').Decision>,
 * maxDecisions?: number, seed: number, character?: import('./contracts.d.mts').Character,
 * stage?: import('./contracts.d.mts').Stage, model?: string,
 * onRecord?: (record: object) => void | Promise<void> }} options */
export async function runAgent({ session, choose, maxDecisions = 500, seed, character, stage, model = 'jev-latest', onRecord = () => {} }) {
  if (!Number.isInteger(maxDecisions) || maxDecisions < 1 || maxDecisions > 10000) {
    throw new AgentError('invalid_input', 'maxDecisions must be in [1, 10000]');
  }
  const started = performance.now();
  let observation = session.observe();
  int32(seed, 'seed');
  if (!isDeepStrictEqual(observation, createHeadlessSession({ seed, character, stage }).observe())) {
    throw new AgentError('invalid_input', 'session must be a fresh run matching the replay metadata');
  }
  let decisions = 0;
  const usage = { inputTokens: 0, outputTokens: 0, requests: 0 };
  await onRecord({ type: 'run_start', schemaVersion: 2, seed, character: character ?? null, stage: stage ?? null,
    model, startedAt: new Date().toISOString(), observation });
  const summary = (status, error) => ({ type: 'run_end', schemaVersion: 2, status, decisions, observation,
    usage: { ...usage }, elapsedMs: Math.round(performance.now() - started), ...(error ? { error } : {}) });
  try {
    while (!observation.terminal && decisions < maxDecisions) {
      const before = observation;
      const decision = validateDecision(await choose(before), before);
      observation = session.step({ revision: before.revision, choiceId: decision.choiceId });
      decisions++;
      usage.inputTokens += decision.usage.inputTokens;
      usage.outputTokens += decision.usage.outputTokens;
      usage.requests += decision.attempts;
      await onRecord({ type: 'decision', schemaVersion: 2, index: decisions, revision: before.revision,
        choiceId: decision.choiceId, decision, before, after: observation });
    }
    const result = summary(observation.terminal ? observation.phase : 'limit');
    await onRecord(result);
    return result;
  } catch (error) {
    // Preserve the current state even when a writer or model failed. Never put
    // arbitrary exception messages (which can contain credentials) in a log.
    observation = session.observe();
    await onRecord(summary('error', { code: error instanceof AgentError ? error.code : 'agent_failed' }));
    throw error;
  }
}

/** Re-execute recorded semantic actions against a fresh run. No model or key.
 * Reject a truncated log or any divergence before/after a decision. */
export function replayRecords(records) {
  const header = records[0];
  if (header?.type !== 'run_start' || header.schemaVersion !== 2) throw new AgentError('replay_failed', 'missing run_start');
  try { int32(header.seed, 'seed'); }
  catch { throw new AgentError('replay_failed', 'invalid seed'); }
  const session = createHeadlessSession({ seed: header.seed,
    ...(header.character !== null ? { character: header.character, stage: header.stage } : {}) });
  if (!isDeepStrictEqual(header.observation, session.observe())) throw new AgentError('replay_failed', 'initial observation differs');
  let decisions = 0;
  for (const record of records.slice(1, -1)) {
    if (record.type !== 'decision' || record.schemaVersion !== 2 || record.index !== decisions + 1 ||
        !isDeepStrictEqual(record.before, session.observe()) || record.revision !== record.before.revision ||
        record.choiceId !== record.decision?.choiceId) {
      throw new AgentError('replay_failed', `invalid decision ${decisions + 1}`);
    }
    let after;
    try { after = session.step({ revision: record.revision, choiceId: record.choiceId }); }
    catch { throw new AgentError('replay_failed', `illegal decision ${decisions + 1}`); }
    if (!isDeepStrictEqual(record.after, after)) throw new AgentError('replay_failed', `state differs at decision ${decisions + 1}`);
    decisions++;
  }
  const end = records.at(-1);
  const observation = session.observe();
  if (end?.type !== 'run_end' || end.schemaVersion !== 2 || end.decisions !== decisions ||
      !isDeepStrictEqual(end.observation, observation) ||
      !['victory', 'defeat', 'limit', 'error'].includes(end.status) ||
      (observation.terminal ? end.status !== observation.phase : !['limit', 'error'].includes(end.status))) {
    throw new AgentError('replay_failed', 'missing or inconsistent run_end');
  }
  return { ...end, replayed: true };
}
