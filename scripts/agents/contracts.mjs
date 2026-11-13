import { AgentError } from './errors.mjs';

export const validProbability = value => typeof value === 'number' && Number.isFinite(value) && value >= 0 && value <= 1;
export const validCount = value => Number.isSafeInteger(value) && value >= 0;

/** Validate before state mutation and retain only the public decision contract.
 * Provider-specific extras never cross into the game or its evidence logs.
 * @param {import('./contracts.d.mts').Decision} decision
 * @param {import('./contracts.d.mts').Observation} observation
 * @returns {import('./contracts.d.mts').Decision} */
export function validateDecision(decision, observation) {
  const ids = observation.choices.map(c => c.id);
  const p = decision?.probabilities;
  if (!ids.includes(decision?.choiceId) || !validProbability(decision.confidence) ||
      !p || typeof p !== 'object' || Array.isArray(p) || Object.keys(p).length !== ids.length ||
      ids.some(id => !validProbability(p[id])) || Math.abs(Object.values(p).reduce((sum, n) => sum + n, 0) - 1) > 0.05 ||
      typeof decision.model !== 'string' || !decision.model ||
      !validCount(decision.usage?.inputTokens) || !validCount(decision.usage?.outputTokens) ||
      !validCount(decision.elapsedMs) || !validCount(decision.attempts) || decision.attempts > 6) {
    throw new AgentError('invalid_response');
  }
  return { choiceId: decision.choiceId, confidence: decision.confidence,
    probabilities: Object.fromEntries(ids.map(id => [id, p[id]])), model: decision.model,
    usage: { inputTokens: decision.usage.inputTokens, outputTokens: decision.usage.outputTokens },
    elapsedMs: decision.elapsedMs, attempts: decision.attempts };
}
