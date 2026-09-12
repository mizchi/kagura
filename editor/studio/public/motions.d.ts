/** Renderer-independent v1 motion preview data. Positions use metres, rotations XYZW, times seconds. */
export interface MotionAsset {
  format: "kagura.motion";
  version: 1;
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
    defaultClip: string;
    parts: Array<{
      name: string;
      color: [number, number, number, number];
      /** Interleaved bind-pose position (3), normal (3), UV (2). */
      vertices: number[];
      indices: number[];
      /** Four joint indices and normalized weights per vertex. */
      joints: number[];
      weights: number[];
    }>;
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
  skeleton: boolean;
  transport: MotionTransport | null;
  models: Array<{ id: string; name: string }>;
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
    asset: MotionAsset,
    name?: string,
  ): Promise<MotionPreviewSnapshot>;
  snapshot(): MotionPreviewSnapshot;
  selectModel(id: string): void;
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
