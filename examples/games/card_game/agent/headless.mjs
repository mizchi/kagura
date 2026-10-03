import * as core from '../_build/js/release/build/mizchi/card_game/agent_host/agent_host.js';
import { AgentError, int32 } from './errors.mjs';

/** @typedef {import('./contracts.d.mts').HeadlessSession} HeadlessSession */
/** @typedef {import('./contracts.d.mts').Observation} Observation */

function freeze(value) {
  if (value && typeof value === 'object') {
    for (const entry of Object.values(value)) freeze(entry);
    Object.freeze(value);
  }
  return value;
}

/** @param {import('./contracts.d.mts').SessionOptions} [options]
 * @returns {HeadlessSession} A private run owner with detached, frozen observations. */
export function createHeadlessSession({ seed = 42, character, stage } = {}) {
  int32(seed, 'seed');
  if ((character === undefined) !== (stage === undefined)) {
    throw new AgentError('invalid_input', 'character and stage must be supplied together');
  }
  if (character !== undefined && !['ironclad', 'warden'].includes(character)) {
    throw new AgentError('invalid_input', 'unknown character');
  }
  if (stage !== undefined && !['ascent', 'act_two', 'guardian_trial'].includes(stage)) {
    throw new AgentError('invalid_input', 'unknown stage');
  }
  const instance = character === undefined ? core.create(seed) : core.create_run(seed, character, stage);
  if (instance == null) throw new AgentError('invalid_input', 'unknown adventure');
  const observe = () => freeze(JSON.parse(core.observe(instance)));
  return Object.freeze({
    observe,
    step({ revision, choiceId }) {
      int32(revision, 'revision');
      if (revision < 0 || typeof choiceId !== 'string' || !choiceId) {
        throw new AgentError('invalid_input', 'revision and choiceId are required');
      }
      const result = core.step(instance, revision, choiceId);
      if (result !== 'applied') throw new AgentError(result);
      return observe();
    },
  });
}
