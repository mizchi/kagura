import type { JsonValue } from './contract.d.ts';
/** Independent from authoring document revisions. A new Play owns a new session. */
export interface RuntimeToken {
  session: string;
  revision: number;
}
export interface RuntimeSnapshot extends RuntimeToken {
  apiVersion: 1;
  game: string;
  schema: { id: string; version: number };
  paused: boolean;
  state: JsonValue;
}
/** All methods are synchronous. The game must validate before mutating and increment
 * revision on every simulation tick or successful debugger mutation. */
export interface RuntimeDebugAdapter {
  apiVersion: 1;
  game: string;
  schema: { id: string; version: number };
  inspector?: RuntimeInspectorAdapter;
  read(): Pick<RuntimeSnapshot, 'revision' | 'paused' | 'state'>;
  pause(paused: boolean): void;
  /** One tick with neutral input. Renderer/resources must not be rebuilt. */
  step(): void;
  /** Validate the entire JSON state and copy it before mutation; throw on rejection. */
  replace(state: JsonValue): void;
}
/** Edits affect only the current game's logical state. They do not save source,
 * initial scene documents or project files. Checkpoint export is a separate action.
 * Guarded calls throw on a stale session/revision or when the game is running.
 * Use this host API for UI/WebMCP edits, not the raw RuntimeDebugAdapter. */
export interface RuntimeDebugAPI {
  /** Read current observations and a token; allowed while running or paused. */
  inspect(): RuntimeInspection;
  /** Requires Pause and a current token. Pure reduce -> game validation/commit.
   * Returns the committed snapshot synchronously; rendering occurs separately.
   * Rejected edits must leave game state and revision unchanged. */
  edit(edit: RuntimeFieldEdit, token: RuntimeToken): RuntimeSnapshot;
  snapshot(): RuntimeSnapshot;
  pause(): RuntimeSnapshot;
  /** Requires Pause and a current token. */
  resume(token: RuntimeToken): RuntimeSnapshot;
  /** Requires Pause and a current token; advances one tick with neutral input. */
  step(token: RuntimeToken): RuntimeSnapshot;
  /** Requires Pause and a current token; the game validates and commits atomically. */
  replace(state: JsonValue, token: RuntimeToken): RuntimeSnapshot;
}
export interface RuntimeSession extends RuntimeDebugAPI {
  dispose(): void;
}
export interface RuntimeCheckpoint {
  format: 'kagura.checkpoint';
  version: 1;
  game: string;
  schema: RuntimeSnapshot['schema'];
  state: JsonValue;
}
declare global {
  var kaguraDebugAdapter: RuntimeDebugAdapter | undefined;
}

/** Paths derive from sibling keys. Unkeyed 2D nodes use positional @N segments. */
export interface SceneHierarchyNode {
  id: string;
  name: string;
  kind: string;
  generated: boolean;
  /** Game-owned identity matching InspectionSubject.id, independent of the render path.
   * Several visuals may share it; children do not inherit it. Absent or unmatched
   * subjects expose no fields when selected; the editor never infers one from id/name. */
  subject?: string | null;
  children: SceneHierarchyNode[];
}

/** Version 1 inspector extension: primitive values, runtime edits and read-only observations. */
export type InspectionField = {
  id: string;
  label: string;
  access: 'runtime' | 'readonly';
  unit: string;
} & (
  | { kind: 'number'; value: number }
  | { kind: 'boolean'; value: boolean }
  | { kind: 'string'; value: string }
);
export interface InspectionSubject {
  id: string;
  name: string;
  fields: InspectionField[];
}
export interface RuntimeInspection extends RuntimeToken {
  paused: boolean;
  subjects: InspectionSubject[];
}
export interface RuntimeFieldEdit {
  /** Logical game identity, not SceneHierarchyNode.id or a render key. */
  subject: string;
  /** Declared field ID within the subject, not a JSON path or display label. */
  field: string;
  value: number | boolean | string;
}
export interface RuntimeInspectorAdapter {
  /** Pure projection of the provided snapshot; no live reads or GPU allocations. */
  describe(state: JsonValue): InspectionSubject[];
  /** Pure reducer; return a candidate logical state. replace() validates and commits it. */
  reduce(state: JsonValue, edit: RuntimeFieldEdit): JsonValue;
}
