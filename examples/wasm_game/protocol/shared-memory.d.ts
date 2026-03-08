export interface InitEnv {
  width: number;
  height: number;
  devicePixelRatio: number;
  hotReloadEnabled: boolean;
}

export interface GuestConfig {
  width: number;
  height: number;
  targetTps: number;
  title: string;
}

export interface InputLayoutSnapshot {
  cursorX: number;
  cursorY: number;
  wheelX: number;
  wheelY: number;
  keys: number[];
  mouseButtons: number[];
}

export interface DrawCommand {
  vertexData: Float32Array;
  indices: Uint32Array;
  srcImageId: number;
  uniformR: number;
  uniformG: number;
  uniformB: number;
  uniformA: number;
}

export const INIT_ENV_SIZE: 16;

export function serializeInput(
  memory: WebAssembly.Memory,
  ptr: number,
  input: InputLayoutSnapshot,
): number;

export function inputByteSize(input: InputLayoutSnapshot): number;

export function writeInitEnv(
  memory: WebAssembly.Memory,
  ptr: number,
  env: InitEnv,
): number;

export function readSemanticGuestConfig(
  memory: WebAssembly.Memory,
  ptr: number,
): GuestConfig;

export function deserializeDrawCommands(
  memory: WebAssembly.Memory,
  ptr: number,
): DrawCommand[];
