import type { MotionAsset } from "../public/motions.d.ts";
export function motionFormat(path: unknown): boolean;
export function validateMotionAsset(input: unknown): MotionAsset;
export function prepareMotionAsset(
  resources: { read(path: string): Promise<Blob> },
  path: string,
): Promise<MotionAsset>;
