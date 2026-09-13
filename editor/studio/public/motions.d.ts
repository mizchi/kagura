/** Renderer-independent motion data. Positions use metres, rotations XYZW, times seconds. */
export interface MotionAsset {
  format: "kagura.motion";
  version: 2;
  name: string;
  skeleton: Array<{
    name: string;
    parent: number;
    position: [number, number, number];
    rotation: [number, number, number, number];
    scale: [number, number, number];
  }>;
  models: Array<{
    id: string;
    name: string;
    /** Body, clothing and armor only. Equipment selection is independent. */
    parts: MotionPart[];
  }>;
  weapons: Array<{
    id: string;
    name: string;
    /** Bind geometry using the shared skeleton, including hand and prop sockets. */
    parts: MotionPart[];
    clips: string[];
    defaultClip: string;
  }>;
  clips: Array<{
    id: string;
    name: string;
    duration: number;
    fps: number;
    events: Array<{ name: string; time: number }>;
    channels: Array<{
      joint: number;
      target: "translation" | "rotation" | "scale";
      interpolation: "linear" | "step";
      times: number[];
      values: number[];
    }>;
  }>;
}
export interface MotionPart {
  name: string;
  color: [number, number, number, number];
  /** Interleaved bind-pose position (3), normal (3), UV (2). */
  vertices: number[];
  indices: number[];
  /** Four joint indices and normalized weights per vertex. */
  joints: number[];
  weights: number[];
}
/** v1 imports retain embedded equipment; validation upgrades them to a v2 embedded set. */
export type LegacyMotionAsset = Omit<
  MotionAsset,
  "version" | "models" | "weapons"
> & {
  version: 1;
  models: Array<MotionAsset["models"][number] & { defaultClip: string }>;
};
export interface MotionTransport {
  clip: string;
  time: number;
  duration: number;
  fps: number;
  frame: number;
  playing: boolean;
  speed: number;
  loop: boolean;
}
export interface MotionPreviewSnapshot {
  path: string | null;
  state: "idle" | "loading" | "ready" | "error";
  model: string | null;
  weapon: string | null;
  skeleton: boolean;
  transport: MotionTransport | null;
  models: Array<{ id: string; name: string }>;
  weapons: Array<{
    id: string;
    name: string;
    clips: string[];
    defaultClip: string;
  }>;
  clips: Array<{
    id: string;
    name: string;
    duration: number;
    events: Array<{ name: string; time: number }>;
  }>;
}
export interface MotionAssetsAPI {
  list(): Promise<string[]>;
  preview(projectPath: string): Promise<MotionPreviewSnapshot>;
  importAsset(
    asset: MotionAsset | LegacyMotionAsset,
    name?: string,
  ): Promise<MotionPreviewSnapshot>;
  snapshot(): MotionPreviewSnapshot;
  selectModel(id: string): void;
  selectWeapon(id: string): void;
  selectClip(id: string): void;
  play(): void;
  pause(): void;
  seek(seconds: number): void;
  step(direction: -1 | 1): void;
  setSpeed(speed: number): void;
  setLoop(loop: boolean): void;
  showSkeleton(show: boolean): void;
  close(): void;
}
