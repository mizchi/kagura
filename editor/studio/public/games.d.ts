import type { Snapshot } from './contract.d.ts';
import type { PanePlugin } from './plugins.d.ts';
import type {
  SceneDocument,
  ActionDocument,
} from '../../../examples/games/iron_yard/editor/scene/contracts.ts';
export type { SceneDocument as IronYardScene, ActionDocument as IronYardAction };

/** Coordinates in the clear deployment area; yaw is in radians. */
export interface IronYardSettings {
  ai: boolean;
  spawnX: number;
  spawnZ: number;
  yaw: number;
}
export interface IronYardSnapshot {
  version: 1;
  phase: 'ready' | 'playing' | 'paused' | 'won' | 'lost';
  ai: boolean;
  elapsed: number;
  hp: number;
  wave: number;
  pilot: {
    position: [number, number, number];
    velocity: [number, number, number];
    yaw: number;
    pitch: number;
    grounded: boolean;
    boost: number;
    gait: number;
  };
  units: Array<{
    id: number;
    name: string;
    position: [number, number, number];
    yaw: number;
    hp: number;
    lock: number;
    mode: string;
    warning: number;
  }>;
  mission: { waves: number; total: number; timeLimit: number };
  shots: number;
  missiles: number;
  hits: number;
  kills: number;
}
/** Same-origin iframe API. Removing the iframe disposes its whole runtime. */
export interface IronYardRuntime {
  configure(settings: IronYardSettings): void;
  loadScene(document: SceneDocument, ai?: boolean): void;
  sceneDocument(): SceneDocument | null;
  play(): void;
  pause(): void;
  reset(): void;
  snapshot(): IronYardSnapshot;
}
export interface IronYardAuthoring {
  createIronYardPlugin(options?: {
    mount?: PanePlugin['mount'];
    inspect?: () => IronYardSnapshot | null;
    sessionId?: string;
    dispose?: () => void;
  }): PanePlugin;
  readSettings(snapshot: Snapshot): IronYardSettings;
  simulate(
    settings: IronYardSettings,
    input: { frames: number; forward: number; boost: boolean },
  ): Promise<IronYardSnapshot>;
}

/** Frozen game presentation used by the IRON YARD domain editor. Shares game assets and WGSL. */
export interface IronYardEditorRuntime {
  readonly renderer: 'kagura-webgpu';
  scene(document: SceneDocument, wave?: number): void;
  camera(eye: [number, number, number], target: [number, number, number]): void;
  selection(box?: { center: [number, number, number]; size: [number, number, number] }): void;
  active(value: boolean): void;
  attack(document: SceneDocument, time: number): void;
  snapshot(): IronYardSnapshot;
}
