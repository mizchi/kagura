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

export interface GuestFrame {
  commands: DrawCommand[];
  wantsRedraw: boolean;
  serializeMs: number;
  updateMs: number;
  renderMs: number;
  deserializeMs: number;
  inputBytes: number;
}
export type GuestStatus = "starting" | "running" | "stopped" | "failed";

export interface GuestSession {
  status(): GuestStatus;
  init(env: InitEnv): GuestConfig;
  frame(input: InputLayoutSnapshot): GuestFrame;
  stop(): void;
}
export function assertGuestAbi(exports: object): void;
export function createGuestSession(
  exports: object,
  options?: { now?: () => number },
): GuestSession;
export function createEngineFrameSession(exports: object): {
  status(): GuestStatus;
  frame(): void;
  stop(): void;
};
