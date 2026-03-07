export {
  deserializeDrawCommands,
  inputByteSize,
  readLegacyGameConfig,
  readSemanticGuestConfig,
  serializeInput,
  writeInitEnv,
} from "../../protocol/shared-memory.js";

export type {
  DrawCommand,
  GuestConfig,
  InitEnv,
  InputLayoutSnapshot,
} from "../../protocol/shared-memory.js";
