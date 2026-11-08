import {assertGuestAbi} from "../../../assets/web/kagura-guest-protocol.js";
import {createWasmHost} from "../../../assets/web/kagura-wasm-host.js";
import { access, readFile } from "node:fs/promises";
import {
  deserializeDrawCommands,
  inputByteSize,
  readSemanticGuestConfig,
  serializeInput,
  writeInitEnv,
} from "./protocol/shared-memory.js";

export {TARGETS} from "./guest-paths.mjs";
import {TARGETS} from "./guest-paths.mjs";

export const HOST_ASSET_TITLE = "Flappy Bird via Host Asset";

const textEncoder = new TextEncoder();
const textDecoder = new TextDecoder();

export function assert(condition, message) {
  if (!condition) {
    throw new Error(`Assertion failed: ${message}`);
  }
}

export async function fileExists(path) {
  try {
    await access(path);
    return true;
  } catch {
    return false;
  }
}

export function resolveTargets(arg) {
  const targets = [];
  if (arg === "all" || arg === "moonbit") targets.push(TARGETS.moonbit);
  if (arg === "all" || arg === "rust") targets.push(TARGETS.rust);
  if (arg === "all" || arg === "zig") targets.push(TARGETS.zig);
  return targets;
}

export function assertSemanticAbi(exports, label = "guest") {
  try { assertGuestAbi(exports); } catch(error) { throw new Error(`${label}: ${error.message}`); }
}

export function allocGuest(exports, size) {
  return exports.kagura_alloc(size);
}

export {
  deserializeDrawCommands,
  inputByteSize,
  readSemanticGuestConfig,
  serializeInput,
  writeInitEnv,
};

export async function instantiateGuest(path, options = {}) {
  const { assets = { "/guest-title.txt": HOST_ASSET_TITLE } } = options;
  const wasm = await readFile(path);
  const hostLogs = [];
  const assetRequests = [];
  const assetBytes = new Map(
    Object.entries(assets).map(([assetPath, value]) => [
      assetPath,
      typeof value === "string" ? textEncoder.encode(value) : value,
    ]),
  );

  let currentMemory = null;
  const host = createWasmHost(wasm, {write: text => hostLogs.push({level: 2, message: text})});
  const imports = {
    ...host.imports,
    kagura_host: {
      log_i32_utf8(level, ptr, len) {
        if (!currentMemory) {
          throw new Error("host log called before memory was ready");
        }
        const bytes = new Uint8Array(currentMemory.buffer, ptr, len);
        const message = textDecoder.decode(bytes);
        hostLogs.push({ level, message });
        return 0;
      },
      read_asset_len_i32_utf8(ptr, len) {
        if (!currentMemory) {
          throw new Error("asset read called before memory was ready");
        }
        const bytes = new Uint8Array(currentMemory.buffer, ptr, len);
        const path = textDecoder.decode(bytes);
        assetRequests.push(path);
        return assetBytes.get(path)?.length ?? -1;
      },
      read_asset_copy_i32_utf8(pathPtr, pathLen, dstPtr) {
        if (!currentMemory) {
          throw new Error("asset copy called before memory was ready");
        }
        const pathBytes = new Uint8Array(currentMemory.buffer, pathPtr, pathLen);
        const path = textDecoder.decode(pathBytes);
        assetRequests.push(path);
        const asset = assetBytes.get(path);
        if (!asset) {
          return -1;
        }
        new Uint8Array(currentMemory.buffer, dstPtr, asset.length).set(asset);
        return asset.length;
      },
    },
  };

  const { instance } = await WebAssembly.instantiate(wasm, imports);
  host.bind(instance);
  const exports = instance.exports;
  currentMemory = exports.memory;
  if (exports._start) {
    exports._start();
  }

  return {
    instance,
    exports,
    memory: exports.memory,
    hostLogs,
    assetRequests,
  };
}
