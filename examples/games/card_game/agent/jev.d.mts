import type { Decision, JevRequest, Observation } from './contracts.d.mts';
export interface JevOptions {
  apiKey: string; model?: string; timeoutMs?: number; retries?: number;
  retryDelayMs?: number; fetchImpl?: typeof fetch;
}
export function loadApiKey(options?: {
  env?: Record<string, string | undefined>; profilePath?: string;
}): Promise<string>;
export function makeJevRequest(observation: Observation, model?: string): JevRequest;
export class JevClient {
  constructor(options: JevOptions);
  readonly model: string;
  readonly timeoutMs: number;
  readonly retries: number;
  readonly retryDelayMs: number;
  choose(observation: Observation): Promise<Decision>;
}
