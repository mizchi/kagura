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
  read(): Pick<RuntimeSnapshot, 'revision' | 'paused' | 'state'>;
  pause(paused: boolean): void;
  /** One tick with neutral input. Renderer/resources must not be rebuilt. */
  step(): void;
  /** Validate the entire JSON state and copy it before mutation; throw on rejection. */
  replace(state: JsonValue): void;
}
export interface RuntimeDebugAPI {
  snapshot(): RuntimeSnapshot;
  pause(): RuntimeSnapshot;
  resume(token: RuntimeToken): RuntimeSnapshot;
  step(token: RuntimeToken): RuntimeSnapshot;
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
  children: SceneHierarchyNode[];
}
