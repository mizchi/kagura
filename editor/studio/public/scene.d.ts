import type { SceneDocument, JsonValue } from './contract.d.ts';
/** Stored as resource id/kind kagura.scene, version 1, inside the shared SceneDocument. Disk source may be a managed MoonBit declaration or JSON. */
export interface GameSceneBindings {
  game: string;
  bindings: Array<{ node: string; component: string; properties: Record<string, JsonValue> }>;
}
/** Shared browser/headless launch boundary. The game adapter owns and validates the recipe data. */
export interface CompiledGameScene<T = JsonValue> {
  apiVersion: 1;
  game: string;
  data: T;
}
export interface GameSceneAdapter<T = JsonValue> {
  compileScene(document: SceneDocument): CompiledGameScene<T>;
}
/** Portable recipes currently shared by Arena 3D and FPS Demo. */
export interface SceneEntity {
  id: string;
  kind: string;
  position: [number, number, number];
  scale: [number, number, number];
  color: number;
  /** Nonempty only for portal entities. Refers to a .kgrprj scene ID. */
  target: string;
}
export interface EntityScene {
  version: 1;
  entities: SceneEntity[];
}
export interface SceneProject<T = EntityScene> {
  /** Preview may start from the current editor scene instead of the project entryScene. */
  entry: string;
  scenes: Array<{ id: string; data: T }>;
}
export interface SceneComponentProfile {
  asset: 'primitive.box' | 'primitive.sphere' | 'primitive.cylinder';
  position: [number, number, number];
  scale: [number, number, number];
  color: number;
  fixedScale?: boolean;
}
export interface GameSceneProfile {
  game: string;
  title: string;
  spawnHeight: number;
  components: Record<string, SceneComponentProfile>;
}
