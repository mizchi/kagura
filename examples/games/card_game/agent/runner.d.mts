import type { AgentRecord, Character, Decision, HeadlessSession, Observation, Stage, Summary } from './contracts.d.mts';
export interface RunOptions {
  session: HeadlessSession;
  choose: (observation: Observation) => Decision | Promise<Decision>;
  seed: number; character?: Character; stage?: Stage; model?: string; maxDecisions?: number;
  onRecord?: (record: AgentRecord) => void | Promise<void>;
}
export function runAgent(options: RunOptions): Promise<Summary>;
export function replayRecords(records: AgentRecord[]): Summary & { replayed: true };
