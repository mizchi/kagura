import { access, readFile } from "node:fs/promises";

export const TARGETS = {
  moonbit: {
    label: "MoonBit",
    path: "examples/wasm_game/guest/moonbit/_build/wasm/debug/build/wasm_game_guest.wasm",
  },
  rust: {
    label: "Rust",
    path: "examples/wasm_game/guest/rust/target/wasm32-unknown-unknown/release/kagura_wasm_guest_rust.wasm",
  },
  zig: {
    label: "Zig",
    path: "examples/wasm_game/guest/zig/zig-out/lib/kagura_wasm_guest_zig.wasm",
  },
};

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

export function hasSemanticAbi(exports) {
  return (
    typeof exports.kagura_guest_init === "function" &&
    typeof exports.kagura_guest_update === "function" &&
    typeof exports.kagura_guest_render === "function"
  );
}

export function allocGuest(exports, size) {
  assert(typeof exports.kagura_alloc === "function", "guest allocator export is required");
  return exports.kagura_alloc(size);
}

export function writeInitEnv(
  memory,
  ptr,
  env = { width: 640, height: 480, devicePixelRatio: 1, hotReloadEnabled: 1 },
) {
  const dv = new DataView(memory.buffer);
  dv.setInt32(ptr, env.width, true);
  dv.setInt32(ptr + 4, env.height, true);
  dv.setFloat32(ptr + 8, env.devicePixelRatio, true);
  dv.setInt32(ptr + 12, env.hotReloadEnabled ? 1 : 0, true);
  return 16;
}

export function writeInput(
  memory,
  ptr,
  input = {
    cursorX: 0,
    cursorY: 0,
    wheelX: 0,
    wheelY: 0,
    keys: [],
    mouseButtons: [],
  },
) {
  const dv = new DataView(memory.buffer);
  const {
    cursorX = 0,
    cursorY = 0,
    wheelX = 0,
    wheelY = 0,
    keys = [],
    mouseButtons = [],
  } = input;

  dv.setFloat64(ptr, cursorX, true);
  dv.setFloat64(ptr + 8, cursorY, true);
  dv.setFloat64(ptr + 16, wheelX, true);
  dv.setFloat64(ptr + 24, wheelY, true);

  dv.setInt32(ptr + 32, keys.length, true);
  for (let i = 0; i < keys.length; i++) {
    dv.setInt32(ptr + 36 + i * 4, keys[i], true);
  }

  let offset = ptr + 36 + keys.length * 4;
  dv.setInt32(offset, mouseButtons.length, true);
  offset += 4;
  for (let i = 0; i < mouseButtons.length; i++) {
    dv.setInt32(offset + i * 4, mouseButtons[i], true);
  }
  offset += mouseButtons.length * 4;

  dv.setInt32(offset, 0, true);
  offset += 4;
  dv.setInt32(offset, 0, true);
  offset += 4;

  return offset - ptr;
}

export function readLegacyConfig(memory, ptr) {
  const dv = new DataView(memory.buffer);
  const width = dv.getInt32(ptr, true);
  const height = dv.getInt32(ptr + 4, true);
  const titleLen = dv.getInt32(ptr + 8, true);
  const title = textDecoder.decode(new Uint8Array(memory.buffer, ptr + 12, titleLen));
  return { width, height, targetTps: 60, title };
}

export function readSemanticConfig(memory, ptr) {
  const dv = new DataView(memory.buffer);
  const width = dv.getInt32(ptr, true);
  const height = dv.getInt32(ptr + 4, true);
  const targetTps = dv.getInt32(ptr + 8, true);
  const titleLen = dv.getInt32(ptr + 12, true);
  const title = textDecoder.decode(new Uint8Array(memory.buffer, ptr + 16, titleLen));
  return { width, height, targetTps, title };
}

export function readDrawCommands(memory, ptr) {
  const dv = new DataView(memory.buffer);
  const commandCount = dv.getInt32(ptr, true);
  const commands = [];
  let offset = ptr + 4;

  for (let i = 0; i < commandCount; i++) {
    const vertexCount = dv.getInt32(offset, true);
    const indexCount = dv.getInt32(offset + 4, true);
    const srcImageId = dv.getInt32(offset + 8, true);
    const color = {
      r: dv.getInt32(offset + 12, true),
      g: dv.getInt32(offset + 16, true),
      b: dv.getInt32(offset + 20, true),
      a: dv.getInt32(offset + 24, true),
    };
    commands.push({ vertexCount, indexCount, srcImageId, color });
    offset += 28 + vertexCount * 16 + indexCount * 4;
  }

  return commands;
}

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
  const imports = {
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
