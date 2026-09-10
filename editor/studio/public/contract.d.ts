import type { PanePlugin, PluginCallOptions, PluginReply, PublishedPaneTool, PluginSDK } from './plugins.d.ts';
import type { BrowserStorage } from './storage.d.ts';
/** Kagura Studio v1. Runtime validation is owned by src/core, not this declaration. */
export type Vec3 = [number, number, number];
export type AssetId = 'primitive.box' | 'primitive.sphere' | 'primitive.cylinder' | 'group';
export interface SceneNode {
  /** Unique, 1-80 ASCII letters/digits/dots/dashes/underscores. */
  id: string;
  name: string;
  asset: AssetId;
  /** Empty string means root. Reparenting preserves the local transform. */
  parent: string;
  /** Local metres, Euler radians (XYZ), positive scale. */
  position: Vec3;
  rotation: Vec3;
  scale: Vec3;
  /** RGB integer, 0x000000 through 0xffffff. */
  color: number;
}
export interface Action {
  /** Node ID; empty string means unbound. */
  target: string;
  /** Seconds, (0, 60]. */
  duration: number;
  /** Seconds, [0, duration]. */
  flashDuration: number;
  /** Seconds, (0, duration]. */
  recoilDuration: number;
  /** Metres along the target's parent-space -Z axis, [0, 10]. */
  recoilStrength: number;
}
export type JsonValue = null | boolean | number | string | JsonValue[] | { [key: string]: JsonValue };
/** Game-owned data: 128 resources, 256K characters total, nesting depth <=32. */
export interface Resource {
  id: string;
  kind: string;
  /** Positive 32-bit integer. */
  version: number;
  data: { [key: string]: JsonValue };
}
export interface SceneDocument {
  version: 1;
  name: string;
  units: 'meters';
  up: 'Y';
  forward: '+Z';
  nodes: SceneNode[];
  action: Action;
  /** Missing resources in older imported v1 documents normalize to []. */
  resources: Resource[];
}
export type Command =
  | { op: 'node.add'; id: string; name: string; asset: AssetId; parent?: string }
  | { op: 'node.remove'; id: string }
  | { op: 'node.rename'; id: string; name: string }
  | { op: 'node.reparent'; id: string; parent: string }
  | { op: 'node.transform'; id: string; position: Vec3; rotation: Vec3; scale: Vec3 }
  | { op: 'node.material'; id: string; color: number }
  | { op: 'action.set'; action: Action }
  | { op: 'document.replace'; document: SceneDocument }
  | { op: 'resource.put'; resource: Resource }
  | { op: 'resource.remove'; id: string };
export interface Transaction { expectedRevision: number; commands: Command[] }
export interface Snapshot {
  apiVersion: 1;
  revision: number;
  document: SceneDocument;
  selection: string;
  preview: { time: number; flash: boolean; offset: number };
  canUndo: boolean;
  canRedo: boolean;
  layout: 'scene' | 'action';
}
export type Reply = { ok: true; snapshot: Snapshot } |
  { ok: false; error: { code: 'invalid' | 'conflict'; message: string }; revision?: number };
export interface StudioAPI {
  snapshot(): Snapshot;
  dispatch(transaction: Transaction): Reply;
  undo(expectedRevision: number): Reply;
  redo(expectedRevision: number): Reply;
  select(id: string): Reply;
  seek(time: number): Reply;
  subscribe(listener: (snapshot: Snapshot) => void): () => void;
  capabilities(): {
    apiVersion: 1;
    coordinates: { units: 'meters'; up: 'Y'; forward: '+Z'; angles: 'radians'; time: 'seconds' };
    assets: AssetId[];
    commands: Command['op'][];
    limits: { nodes: number; batch: number; history: number };
    contract: string;
  };
}
export interface PaneContext {
  element: HTMLElement;
  editor: StudioAPI;
  /** Aborted when hidden, replaced, unregistered or the editor is disposed. */
  signal: AbortSignal;
  /** No initial callback. Automatically unsubscribed with the pane. */
  subscribe(listener: (snapshot: Snapshot) => void): () => void;
}
export interface PaneDefinition {
  /** IDs console, creator and prefix form. are reserved. Registration replaces an existing ID. */
  id: string;
  title: string;
  /** Synchronous. Start async work using signal; return cleanup for non-DOM resources. */
  mount(context: PaneContext): void | (() => void);
}
export type FormField = { key: string; label: string } & (
  | { type: 'text' | 'boolean' }
  | { type: 'number'; min?: number; max?: number; step?: number }
  | { type: 'select'; options: string[] }
);
export interface FormDefinition {
  id: string;
  gameId: string;
  title: string;
  fields: FormField[];
  values: Record<string, string | number | boolean>;
}
export interface PaneAPI {
  registerPlugin(plugin: PanePlugin): void;
  invokeTool(id: string, name: string, args: { [key: string]: JsonValue }, options?: PluginCallOptions): Promise<PluginReply>;
  tools(): PublishedPaneTool[];
  subscribeTools(listener: () => void): () => void;
  register(definition: PaneDefinition): void;
  unregister(id: string): void;
  open(id: string): void;
  /** Unmounts the active pane; registration and document data remain. */
  close(id: string): void;
  list(): { id: string; title: string; active: boolean }[];
  /** Validates a descriptor (throws on invalid), upserts a resource and opens form.<id>. */
  registerForm(definition: FormDefinition, expectedRevision?: number): Reply;
}
export interface WebMCPStatus {
  pluginErrors: { name: string; message: string }[];
  state: 'registering' | 'ready' | 'unsupported' | 'error' | 'disposed';
  message: string;
  tools: string[];
}
export interface BrowserStudioAPI extends StudioAPI {
  plugins: PluginSDK;
  storage: BrowserStorage;
  panes: PaneAPI;
  webmcp: { ready: Promise<void>; settled(): Promise<void>; status(): WebMCPStatus };
}
declare global { var kagura: BrowserStudioAPI; }
