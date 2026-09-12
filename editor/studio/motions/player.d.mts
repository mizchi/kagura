import type { MotionAsset, MotionTransport } from "../public/motions.d.ts";
export interface MotionPlayer {
  snapshot(): MotionTransport;
  selectClip(id: string): void;
  play(): void;
  pause(): void;
  seek(seconds: number): void;
  step(direction: -1 | 1): void;
  setSpeed(speed: number): void;
  setLoop(loop: boolean): void;
  tick(deltaSeconds: number): void;
}
export function createMotionPlayer(asset: MotionAsset): MotionPlayer;
