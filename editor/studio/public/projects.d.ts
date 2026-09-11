import type { RuntimeSession, SceneHierarchyNode } from './runtime.d.ts';
import type { StudioAPI, PaneAPI } from './contract.d.ts';
export interface SchemaVersion {
  id: string;
  version: number;
}
export interface ProjectRuntimeSettings {
  /** Absent for legacy projects: display names are never used to invent persistent IDs. */
  id?: string;
  game?: string;
  save?: { namespace: string; version: number };
  sceneSchema?: SchemaVersion;
  /** Initial canvas size in CSS pixels. Responsive renderers may resize to the viewport. */
  display: { width: number; height: number };
}
export type ProjectRuntime = { apiVersion: number; targets: ('js' | 'native')[] } & (
  | { kind: 'script'; /** Classic JavaScript bundle, not an ESM module. */ entry: string }
  | { kind: 'extension' | 'native'; entry?: never }
);
/** Identity is either explicit and complete, or absent in a legacy project. */
export type ProjectIdentity =
  | { id: string; game: string; save?: { namespace: string; version: number } }
  | { id?: never; game?: never; save?: never };
interface ProjectMetadata {
  sceneSchema?: SchemaVersion;
  runtime?: ProjectRuntime;
  /** package accepts "." for the flat MoonBit root; scenePackage defaults to "scenes". */
  build?: {
    package: string;
    artifact?: string;
    scenePackage?: string;
    editorMode?: 'debug' | 'release';
  };
  display?: ProjectRuntimeSettings['display'];
  format: 'kagura.project';
  version: 1;
  name: string;
  editor?: {
    id: string;
    apiVersion?: number;
    /** Optional pre-bundled ESM entry, relative to this manifest. */ entry?: string;
  };
  resources: Record<string, string>;
}
/** Legacy single scene or a named scene table with an explicit entry. */
export type ProjectManifest = ProjectMetadata &
  ProjectIdentity &
  (
    | { scene: string; scenes?: never; entryScene?: never }
    | { scene?: string; scenes: Record<string, string>; entryScene: string }
  );
export interface ProjectResources {
  readonly manifest: ProjectManifest & { scene: string };
  readonly writable: boolean;
  read(path: string): Promise<Blob>;
  resource(id: string): Promise<Blob>;
  list(): Promise<string[]>;
  url(path: string, mime?: string): Promise<string>;
  readScene(id?: string): Promise<unknown>;
  encodeScene(document: unknown, id?: string): Promise<{ path: string; blob: Blob }>;
  saveScene(document: unknown, id?: string): Promise<void>;
  reopen(): Promise<ProjectResources>;
  dispose(): void;
}
export interface GameEditor {
  /** Optional runtime capability. The shell owns the Edit / Play / Stop controls. */
  play?(): void | Promise<void>;
  stop?(): void | Promise<void>;
  playing?(): boolean;
  canPlay?(): boolean;
  /** Game-owned live debugger; absent until the runtime is ready. */
  debug?(): RuntimeSession | undefined;
  hierarchy?(): SceneHierarchyNode[] | undefined;
  open(): void | Promise<void>;
  active(): boolean;
  frame(): void;
  view(name: string): void;
  importScene(document: unknown, expectedRevision: number): Promise<void>;
  readDocument(): unknown;
  exportScene(): void;
  closeView?(): void;
  dispose(): void;
}
export interface GameEditorContext {
  editor: StudioAPI;
  panes: PaneAPI;
  base: GameEditor;
  project?: ProjectResources;
  getSceneId?(): string | undefined;
  getSceneDocument?(id: string): Promise<unknown>;
  setStatus(message: string): void;
  /** Notify the shell after runtime transitions, including iframe-driven exits. */
  notifyState?(): void;
  viewport?: { setActive(value: boolean): void; frame(id: string): void; view(name: string): void };
  /** Optional deployment URL for the bundled runtime. Project resources are passed separately. */
  runtimeURL?: string;
}
export interface GameEditorExtension {
  apiVersion: 1;
  id: string;
  game?: string;
  sceneSchema?: SchemaVersion;
  /** Omit to use Studio's generic scene contract. */
  validateDocument?(document: unknown, manifest?: ProjectManifest): unknown;
  /** Only dispose is mandatory. Unspecified operations inherit the built-in editor. */
  activate(
    context: GameEditorContext,
  ):
    | (Partial<GameEditor> & Pick<GameEditor, 'dispose'>)
    | Promise<Partial<GameEditor> & Pick<GameEditor, 'dispose'>>;
}
