export interface SceneTransition {
  from: string;
  event: string;
  to: string;
}
export interface SceneFlowDefinition {
  entry: string;
  scenes: string[];
  terminal: string[];
  transitions: SceneTransition[];
}
export type SceneFlowIssueCode =
  | 'invalid-scene' | 'duplicate-scene' | 'invalid-entry'
  | 'unknown-terminal' | 'duplicate-terminal' | 'unknown-source'
  | 'unknown-target' | 'invalid-event' | 'terminal-transition'
  | 'ambiguous-event' | 'unreachable-scene' | 'dead-end'
  | 'no-terminal-path' | 'dead-transition';
export interface SceneFlowIssue {
  code: SceneFlowIssueCode;
  severity: 'error' | 'warning';
  scene: string;
  /** Zero-based transition index; -1 for a scene-level issue. */
  transition: number;
}
export interface SceneFlowInspection {
  definition: SceneFlowDefinition;
  report: { valid: boolean; reachable: string[]; issues: SceneFlowIssue[] };
  mermaid: string;
}
/** Serialized {ok:true,...SceneFlowInspection} or {ok:false,error:string}. */
export function inspectJSON(source: string): string;
/** Serialized {entry,game,scenes:[{id,data:SceneDocument}]} -> same result. */
export function inspectDocumentsJSON(source: string): string;
