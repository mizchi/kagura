import { readFile } from 'node:fs/promises';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { AgentError } from './errors.mjs';
import { validateDecision } from './contracts.mjs';

const MAX_CHOICES = 255;

/** Read only a literal assignment. The profile is never sourced or executed. */
export async function loadApiKey({ env = process.env, profilePath = join(homedir(), '.profile') } = {}) {
  const environmentKey = env.TYPESAFE_API_KEY || env.TYPESAFEAI_API_KEY;
  if (environmentKey?.trim()) return environmentKey.trim();
  let profile;
  try { profile = await readFile(profilePath, 'utf8'); }
  catch { throw new AgentError('missing_api_key', 'set TYPESAFE_API_KEY in the environment or ~/.profile'); }
  const assignments = [...profile.matchAll(/^\s*(?:export\s+)?TYPESAFE_API_KEY\s*=\s*(.*?)\s*$/gm)];
  const raw = assignments.at(-1)?.[1];
  if (!raw) throw new AgentError('missing_api_key', 'set TYPESAFE_API_KEY in the environment or ~/.profile');
  const match = raw.match(/^(?:"([^"\r\n]*)"|'([^'\r\n]*)'|([^\s#'"`]+))\s*(?:#.*)?$/);
  const key = match && (match[1] ?? match[2] ?? match[3]);
  if (!key || /[$`\\]/.test(key)) {
    throw new AgentError('invalid_api_key', 'TYPESAFE_API_KEY in ~/.profile must be a literal value');
  }
  return key.trim();
}

/** @param {import('./contracts.d.mts').Observation} observation */
export function makeJevRequest(observation, model = 'jev-latest', instructions = 'Choose a supplied action to complete the stated objective. Use only the current legal choice IDs.') {
  if (observation?.schemaVersion !== 2 || !Number.isInteger(observation.revision) ||
      !Array.isArray(observation.choices) || observation.terminal) {
    throw new AgentError('invalid_observation');
  }
  const ids = observation.choices.map(c => c.id);
  if (!ids.length || ids.length > MAX_CHOICES || new Set(ids).size !== ids.length ||
      observation.choices.some(c => typeof c.id !== 'string' || !c.id || typeof c.label !== 'string' || !c.action?.kind)) {
    throw new AgentError('invalid_choices');
  }
  const { choices, ...state } = observation;
  return {
    model,
    state,
    questions: {
      next_action: {
        type: 'choice',
        instructions,
        criteria: Object.fromEntries(choices.map(c => [c.id, { description: c.label, action: c.action }])),
      },
    },
  };
}

/** @param {unknown} response @param {import('./contracts.d.mts').Observation} observation */
function parseDecision(response, observation, elapsedMs, attempts) {
  const answer = response?.answers?.next_action;
  if (answer?.type !== 'choice') throw new AgentError('invalid_response');
  return validateDecision({
    choiceId: answer.choice, confidence: answer.confidence, probabilities: answer.probabilities,
    model: response.model, usage: { inputTokens: response.usage?.input_tokens, outputTokens: response.usage?.output_tokens },
    elapsedMs, attempts,
  }, observation);
}

/** Bounded retries and deadlines include response-body consumption. Credentials
 * stay in private fields and headers; errors never contain API response bodies. */
export class JevClient {
  #apiKey;
  #fetch;
  #requests = 0;
  constructor({ apiKey, model = 'jev-latest', timeoutMs = 20000, retries = 2, retryDelayMs = 250, fetchImpl = fetch, instructions, maxRequests = Infinity } = {}) {
    if (typeof apiKey !== 'string' || !apiKey.trim()) throw new AgentError('missing_api_key');
    if (typeof model !== 'string' || !model || !Number.isInteger(timeoutMs) || timeoutMs <= 0 ||
        !Number.isInteger(retries) || retries < 0 || retries > 5 || !Number.isFinite(retryDelayMs) || retryDelayMs < 0) {
      throw new AgentError('invalid_input', 'invalid Jev options');
    }
    if(maxRequests!==Infinity&&(!Number.isInteger(maxRequests)||maxRequests<1))throw new AgentError('invalid_input','invalid request budget');
    this.instructions=instructions;this.maxRequests=maxRequests;
    this.#apiKey = apiKey;
    this.#fetch = fetchImpl;
    this.model = model;
    this.timeoutMs = timeoutMs;
    this.retries = retries;
    this.retryDelayMs = retryDelayMs;
  }

  get requests() {return this.#requests;}

  /** @param {import('./contracts.d.mts').Observation} observation
   * @returns {Promise<import('./contracts.d.mts').Decision>} */
  async choose(observation, {signal,instructions=this.instructions} = {}) {
    const request = makeJevRequest(observation, this.model, instructions);
    const started = performance.now();
    for (let attempt = 0; attempt <= this.retries; attempt++) {
      if(signal?.aborted)throw new AgentError('interrupted');
      if(this.#requests>=this.maxRequests)throw new AgentError('request_limit');
      this.#requests++;
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), this.timeoutMs);
      try {
        const res = await this.#fetch('https://api.typesafe.ai/v1/systemone', {
          method: 'POST', redirect: 'error',
          headers: { authorization: `Bearer ${this.#apiKey}`, 'content-type': 'application/json' },
          body: JSON.stringify(request), signal: signal ? AbortSignal.any([signal,controller.signal]) : controller.signal,
        });
        if (!res.ok) {
          const retryable = res.status === 429 || res.status >= 500;
          await res.body?.cancel();
          throw new AgentError(retryable ? 'request_failed' : 'request_rejected', `HTTP ${res.status}`);
        }
        let body;
        try { body = await res.json(); }
        catch {
          throw new AgentError(controller.signal.aborted ? 'request_failed' : 'invalid_response');
        }
        return parseDecision(body, observation, Math.round(performance.now() - started), attempt + 1);
      } catch (error) {
        if(signal?.aborted)throw new AgentError('interrupted');
        const failure = error instanceof AgentError ? error : new AgentError('request_failed');
        if (failure.code !== 'request_failed' || attempt === this.retries) throw failure;
      } finally { clearTimeout(timer); }
      try {await delay(this.retryDelayMs * 2 ** attempt,undefined,{signal});}
      catch {throw new AgentError('interrupted');}
    }
    throw new AgentError('request_failed');
  }
}
