import {isDeepStrictEqual} from 'node:util';
import {AgentError, int32} from '../../../../scripts/agents/errors.mjs';
import {validateDecision} from '../../../../scripts/agents/contracts.mjs';
import {createHeadlessSession} from './headless.mjs';

const terminalStatuses = ['victory', 'defeat', 'returned'];
const automatic = observation => ({
  choiceId: observation.choices[0].id, confidence: 1,
  probabilities: {[observation.choices[0].id]: 1}, model: 'forced-action',
  usage: {inputTokens: 0, outputTokens: 0}, elapsedMs: 0, attempts: 0,
});

/** A single expedition using either the pure simulation or a browser session.
 * A chooser receives an AbortSignal covering the entire run, including retries. */
export async function runAgent({
  session, choose, seed = 731, balance = {}, maxDecisions = 300, maxSeconds = 180,
  model = 'jev-latest', onRecord = () => {}, requestCount = () => 0, signal,
}) {
  int32(seed, 'seed');
  if (!Number.isInteger(maxDecisions) || maxDecisions < 1 || maxDecisions > 10000 ||
      !Number.isFinite(maxSeconds) || maxSeconds <= 0 || maxSeconds > 3600) {
    throw new AgentError('invalid_input', 'invalid run limits');
  }
  let observation = await session.observe();
  const masterData=await session.masterData();
  const initialExperience=typeof session.experience==='function'?await session.experience(0):undefined;
  let experienceCursor=initialExperience?.lastSequence??0;
  if (!isDeepStrictEqual(observation, createHeadlessSession({seed,balance,masterData}).observe())) {
    throw new AgentError('invalid_input', 'session must start from the matching seed');
  }
  const started = performance.now(), usage = {inputTokens: 0, outputTokens: 0, requests: 0};
  let decisions = 0, modelDecisions = 0;
  await onRecord({type: 'run_start', schemaVersion: 1, game: 'dungeon_rpg', engineVersion: 3,
    seed, masterData, balance:observation.state.balance, model, startedAt: new Date().toISOString(), observation,
    ...(initialExperience?{experienceVersion:1,experience:initialExperience}:{})});
  const deadline = new AbortController();
  const timer = setTimeout(() => deadline.abort(), maxSeconds * 1000);
  const runSignal = signal ? AbortSignal.any([signal, deadline.signal]) : deadline.signal;
  const summary = (status, extra = {}) => ({
    type: 'run_end', schemaVersion: 1, status, decisions, modelDecisions, observation,
    usage: {...usage, requests: Math.max(usage.requests, requestCount())},
    elapsedMs: Math.round(performance.now() - started), ...extra,
  });
  try {
    while (!observation.terminal && decisions < maxDecisions && performance.now() - started < maxSeconds * 1000) {
      if (runSignal.aborted) throw new AgentError('interrupted');
      if (!observation.choices.length) throw new AgentError('no_legal_choices');
      const before = observation, forced = before.choices.length === 1;
      const decision = validateDecision(forced ? automatic(before) : await choose(before, {signal: runSignal}), before);
      if (runSignal.aborted) throw new AgentError('interrupted');
      observation = await session.step({revision: before.revision, choiceId: decision.choiceId});
      const experience=initialExperience?await session.experience(experienceCursor):undefined;
      if(experience)experienceCursor=experience.lastSequence;
      decisions++;
      if (!forced) modelDecisions++;
      usage.inputTokens += decision.usage.inputTokens;
      usage.outputTokens += decision.usage.outputTokens;
      usage.requests += decision.attempts;
      await onRecord({type: 'decision', schemaVersion: 1, index: decisions,
        source: forced ? 'automatic' : 'model', revision: before.revision,
        choiceId: decision.choiceId, decision, before, after: observation,...(experience?{experience}:{})});
    }
    const result = summary(observation.terminal ? observation.phase : 'limit',
      observation.terminal ? {} : {limitReason: decisions >= maxDecisions ? 'decisions' : 'time'});
    await onRecord(result);
    return result;
  } catch (error) {
    observation = await session.observe();
    const limited = error instanceof AgentError && ['request_limit', 'interrupted'].includes(error.code);
    const reason = deadline.signal.aborted ? 'time' : error?.code === 'request_limit' ? 'requests' : 'interrupted';
    const result = summary(limited ? 'limit' : 'error', limited ? {limitReason: reason} :
      {error: {code: error instanceof AgentError ? error.code : 'agent_failed'}});
    await onRecord(result);
    if (limited) return result;
    throw error;
  } finally {
    clearTimeout(timer);
  }
}

/** Compare every observation so changed rules or truncated traces fail closed. */
export async function replayRecords(records, {session, signal} = {}) {
  const header = records?.[0];
  if (!Array.isArray(records) || header?.type !== 'run_start' || header.schemaVersion !== 1 ||
      header.game !== 'dungeon_rpg' || header.engineVersion !== 3 || !header.masterData) {
    throw new AgentError('replay_failed', 'invalid header');
  }
  try { int32(header.seed, 'seed'); }
  catch { throw new AgentError('replay_failed', 'invalid seed'); }
  session ??= createHeadlessSession({seed: header.seed,balance:header.balance,masterData:header.masterData});
  if(!isDeepStrictEqual(await session.masterData(),header.masterData))throw new AgentError('replay_failed','master data differs');
  if (!isDeepStrictEqual(await session.observe(), header.observation)) {
    throw new AgentError('replay_failed', 'initial state differs');
  }
  let experienceCursor=0;
  if(header.experienceVersion!==undefined){
    if(header.experienceVersion!==1||typeof session.experience!=='function'||!isDeepStrictEqual(await session.experience(0),header.experience))throw new AgentError('replay_failed','initial experience differs');
    experienceCursor=header.experience.lastSequence;
  }
  let decisions = 0;
  for (const record of records.slice(1, -1)) {
    if (signal?.aborted) throw new AgentError('interrupted');
    const before = await session.observe();
    if (record?.type !== 'decision' || record.schemaVersion !== 1 || record.index !== decisions + 1 ||
        !isDeepStrictEqual(record.before, before) || record.revision !== before.revision ||
        record.choiceId !== record.decision?.choiceId) {
      throw new AgentError('replay_failed', 'invalid decision');
    }
    try { validateDecision(record.decision, before); }
    catch { throw new AgentError('replay_failed', 'invalid recorded choice'); }
    let after;
    try { after = await session.step({revision: record.revision, choiceId: record.choiceId}); }
    catch { throw new AgentError('replay_failed', 'illegal recorded action'); }
    if (!isDeepStrictEqual(record.after, after)) {
      throw new AgentError('replay_failed', `state differs at ${record.index}`);
    }
    if(header.experienceVersion===1){
      const experience=await session.experience(experienceCursor);
      if(!isDeepStrictEqual(experience,record.experience))throw new AgentError('replay_failed',`experience differs at ${record.index}`);
      experienceCursor=experience.lastSequence;
    }
    decisions++;
  }
  const end = records.at(-1), observation = await session.observe();
  if (end?.type !== 'run_end' || end.schemaVersion !== 1 || end.decisions !== decisions ||
      !isDeepStrictEqual(end.observation, observation) || (observation.terminal ?
        !terminalStatuses.includes(end.status) || end.status !== observation.phase :
        !['limit', 'error'].includes(end.status))) {
    throw new AgentError('replay_failed', 'missing or inconsistent ending');
  }
  return {...end, replayed: true};
}
