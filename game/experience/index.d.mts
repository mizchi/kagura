export type Json =
  | null
  | boolean
  | number
  | string
  | Json[]
  | { [key: string]: Json };
export type Source = "simulation" | "observation" | "rendered" | "human";
export interface LoopSpec {
  id: string;
  label: string;
  intent: string;
}
export interface ArcSpec extends LoopSpec {
  knowledgeKey: string;
  contentVersion: string;
}
export interface ExperienceSpec {
  apiVersion: 1;
  id: string;
  version: number;
  loops: LoopSpec[];
  arcs: ArcSpec[];
  relations?: Array<{
    from: string;
    to: string;
    kind: "contains" | "context" | "interrupts" | "parallel";
  }>;
}
export interface Run {
  id: string;
  subjectId: string;
  scope: string;
  cohort: string;
  context?: Record<string, null | boolean | number | string>;
}
export interface ExperienceEvent {
  version: 1;
  id: string;
  sequence: number;
  source: Source;
  revision: number;
  type:
    | "input.requested"
    | "input.accepted"
    | "input.rejected"
    | "loop.start"
    | "loop.resolved"
    | "loop.ready"
    | "loop.interrupted"
    | "loop.feedback"
    | "loop.understood"
    | "arc.reached"
    | "arc.exposed"
    | "arc.recognized"
    | "arc.understood";
  target?: string;
  instance?: string;
  causes?: string[];
  data?: Record<string, Json>;
  clock?: { id: string; ms: number };
  decisionIndex?: number;
}
export type Ledger = Array<{
  subjectId: string;
  scope: string;
  knowledgeKey: string;
  contentVersion: string;
  exposures: Array<{
    runId: string;
    eventId: string;
    source: "rendered" | "observation";
  }>;
}>;
export interface AnalysisInput {
  spec: ExperienceSpec;
  run: Run;
  events: ExperienceEvent[];
  termination: "completed" | "interrupted" | "censored";
  ledger?: Ledger;
}
export interface Recording extends AnalysisInput {
  format: "kagura.experience-recording";
  version: 1;
}
export interface Measure {
  targetId: string;
  id: string;
  value: number | null;
  unit: string;
  evidenceKind: "mechanical" | "rendered" | "human" | "exposure";
  sources: Source[];
  evidenceEventIds: string[];
  sampleCount: number;
  eligibleCount: number;
  status: "observed" | "not-instrumented" | "not-applicable" | "censored";
  numerator?: number;
  denominator?: number;
}
export interface Report {
  format: "kagura.experience-report";
  version: 1;
  spec: ExperienceSpec;
  run: Run;
  termination: AnalysisInput["termination"];
  valid: boolean;
  issues: Array<{ code: string; eventId: string; detail?: string }>;
  loops: Array<{
    targetId: string;
    instance: string;
    start: string;
    resolution: string | null;
    ready: string | null;
    interruption: string | null;
    commands: string[];
    feedback: string[];
    answers: string[];
    status: "completed" | "interrupted" | "censored";
  }>;
  arcs: Array<{
    targetId: string;
    instance: string;
    reached: string;
    exposed: string[];
    recognized: string[];
    understood: string[];
    exposure: "unknown" | "first" | "repeat";
  }>;
  measures: Measure[];
  ledger: Ledger;
}
export interface Comparison {
  format: "kagura.experience-comparison";
  version: 1;
  kind: "descriptive";
  before: string;
  after: string;
  valid: boolean;
  conditionsDiffer: string[];
  measures: Array<{
    targetId: string;
    id: string;
    unit: string;
    before: number | null;
    after: number | null;
    delta: number | null;
    beforeStatus: Measure["status"];
    afterStatus: Measure["status"];
    beforeSamples: number;
    afterSamples: number;
  }>;
}
export function validateSpec(input: unknown): ExperienceSpec;
export function validateReport(input: unknown): Report;
export function analyzeExperience(input: AnalysisInput | Recording): Report;
export function compareExperience(before: Report, after: Report): Comparison;
export function projectMetrics(
  report: Report,
  requests: Array<{
    targetId: string;
    metricId: string;
    as: string;
    minSamples: number;
  }>,
): Record<string, number>;
