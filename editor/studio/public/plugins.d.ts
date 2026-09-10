import type { Command, JsonValue, PaneContext, Snapshot, StudioAPI } from './contract.d.ts';

/** JSON Schema draft-07; no remote schema loading, coercion or async validators. */
export type JSONSchema = boolean | { [keyword: string]: JsonValue };
export interface PaneToolDeclaration {
  /** 1-32 ASCII letters/digits/_/-. Parent adds kagura.pane.<pane-id>. */
  name: string;
  description: string;
  effect: 'read' | 'transaction';
  inputSchema: { [keyword: string]: JsonValue };
  outputSchema?: JSONSchema;
}
export interface PanePluginManifest {
  apiVersion: 1;
  id: string;
  title: string;
  tools: PaneToolDeclaration[];
}
export interface PluginRequest {
  apiVersion: 1;
  tool: string;
  arguments: { [key: string]: JsonValue };
  /** Detached snapshot captured once at the start of invocation. */
  snapshot: Snapshot;
}
export interface PluginResponse {
  result: JsonValue;
  /** Forbidden for read tools. Required (1-100 commands) for transaction tools. */
  commands?: Command[];
}
export interface PluginCallOptions { signal?: AbortSignal; expectedRevision?: number }
export type PluginReply = { ok: true; result: JsonValue; revision: number } |
  { ok: false; error: { code: string; message: string }; revision?: number };
export interface JSONPluginTransport {
  invoke(requestJSON: string, options: { signal: AbortSignal }): string | Promise<string>;
  dispose?(): void | Promise<void>;
}
export interface PanePlugin {
  manifest: PanePluginManifest;
  transport: JSONPluginTransport;
  /** Optional browser view; omitted means a generated tool pane. Independent of tool lifetime. */
  mount?(context: PaneContext): void | (() => void);
}
export interface JSONPluginModule {
  manifest(): string;
  invoke(requestJSON: string, options?: { signal: AbortSignal }): string | Promise<string>;
  dispose?(): void | Promise<void>;
}
export interface PublishedPaneTool {
  name: string;
  description: string;
  inputSchema: { [keyword: string]: JsonValue };
  annotations: { readOnlyHint: boolean; untrustedContentHint: boolean };
  execute(input: { arguments: { [key: string]: JsonValue }; expectedRevision?: number }, options?: { signal?: AbortSignal }): Promise<PluginReply>;
}
export interface PluginSDK {
  defineJSPlugin(definition: {
    manifest: PanePluginManifest;
    invoke(request: PluginRequest, options: { signal: AbortSignal }): PluginResponse | Promise<PluginResponse>;
    mount?: PanePlugin['mount'];
    dispose?(): void | Promise<void>;
  }): PanePlugin;
  fromJSONModule(module: JSONPluginModule, options?: { mount?: PanePlugin['mount'] }): PanePlugin;
  fromWasm(bytesOrModule: BufferSource | WebAssembly.Module, options?: { mount?: PanePlugin['mount'] }): Promise<PanePlugin>;
}
export interface PluginHost {
  register(plugin: PanePlugin): PanePluginManifest;
  unregister(id: string): void;
  has(id: string): boolean;
  list(): PanePluginManifest[];
  tools(): PublishedPaneTool[];
  subscribe(listener: () => void): () => void;
  invoke(id: string, name: string, args: { [key: string]: JsonValue }, options?: PluginCallOptions): Promise<PluginReply>;
  dispose(): void;
}
