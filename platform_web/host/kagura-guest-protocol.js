import { GUEST_WIRE } from "./kagura-guest-wire.generated.js";
const textDecoder = new TextDecoder();

export const INIT_ENV_SIZE = GUEST_WIRE.initEnvBytes;

export function serializeInput(memory, ptr, input) {
  const dv = new DataView(memory.buffer);
  dv.setFloat64(
    ptr + GUEST_WIRE.layouts.input.cursorX.offset,
    input.cursorX,
    true,
  );
  dv.setFloat64(
    ptr + GUEST_WIRE.layouts.input.cursorY.offset,
    input.cursorY,
    true,
  );
  dv.setFloat64(
    ptr + GUEST_WIRE.layouts.input.wheelX.offset,
    input.wheelX,
    true,
  );
  dv.setFloat64(
    ptr + GUEST_WIRE.layouts.input.wheelY.offset,
    input.wheelY,
    true,
  );

  const keyCount = input.keys.length;
  dv.setInt32(ptr + GUEST_WIRE.layouts.input.keyCount.offset, keyCount, true);
  for (let i = 0; i < keyCount; i++) {
    dv.setInt32(
      ptr + GUEST_WIRE.layouts.input.keys.offset + i * 4,
      input.keys[i],
      true,
    );
  }

  let offset = ptr + GUEST_WIRE.layouts.input.keys.offset + keyCount * 4;
  const mouseCount = input.mouseButtons.length;
  dv.setInt32(offset, mouseCount, true);
  offset += 4;
  for (let i = 0; i < mouseCount; i++) {
    dv.setInt32(offset + i * 4, input.mouseButtons[i], true);
  }
  offset += mouseCount * 4;

  dv.setInt32(offset, 0, true);
  offset += 4;
  dv.setInt32(offset, 0, true);
  offset += 4;

  return offset - ptr;
}

export function inputByteSize(input) {
  return (
    32 + 4 + input.keys.length * 4 + 4 + input.mouseButtons.length * 4 + 4 + 4
  );
}

export function writeInitEnv(
  memory,
  ptr,
  env = {
    width: 640,
    height: 480,
    devicePixelRatio: 1,
    hotReloadEnabled: true,
  },
) {
  const dv = new DataView(memory.buffer);
  dv.setInt32(ptr + GUEST_WIRE.layouts.initEnv.width.offset, env.width, true);
  dv.setInt32(ptr + GUEST_WIRE.layouts.initEnv.height.offset, env.height, true);
  dv.setFloat32(
    ptr + GUEST_WIRE.layouts.initEnv.devicePixelRatio.offset,
    env.devicePixelRatio,
    true,
  );
  dv.setInt32(
    ptr + GUEST_WIRE.layouts.initEnv.hotReloadEnabled.offset,
    env.hotReloadEnabled ? 1 : 0,
    true,
  );
  return INIT_ENV_SIZE;
}

export function readSemanticGuestConfig(memory, ptr) {
  const dv = new DataView(memory.buffer);
  const width = dv.getInt32(
    ptr + GUEST_WIRE.layouts.guestConfig.width.offset,
    true,
  );
  const height = dv.getInt32(
    ptr + GUEST_WIRE.layouts.guestConfig.height.offset,
    true,
  );
  const targetTps = dv.getInt32(
    ptr + GUEST_WIRE.layouts.guestConfig.targetTps.offset,
    true,
  );
  const titleLen = dv.getInt32(
    ptr + GUEST_WIRE.layouts.guestConfig.titleLength.offset,
    true,
  );
  const title = textDecoder.decode(
    new Uint8Array(
      memory.buffer,
      ptr + GUEST_WIRE.layouts.guestConfig.title.offset,
      titleLen,
    ),
  );
  return { width, height, targetTps, title };
}

export function deserializeDrawCommands(memory, ptr) {
  const dv = new DataView(memory.buffer);
  const cmdCount = dv.getInt32(ptr, true);
  const commands = [];
  let offset = ptr + 4;

  for (let i = 0; i < cmdCount; i++) {
    const vertexCount = dv.getInt32(offset, true);
    const indexCount = dv.getInt32(offset + 4, true);
    const srcImageId = dv.getInt32(offset + 8, true);
    const uniformR = dv.getInt32(offset + 12, true) / 255;
    const uniformG = dv.getInt32(offset + 16, true) / 255;
    const uniformB = dv.getInt32(offset + 20, true) / 255;
    const uniformA = dv.getInt32(offset + 24, true) / 255;

    const vertFloatCount = vertexCount * GUEST_WIRE.vertexComponents;
    const vertByteOffset = offset + GUEST_WIRE.drawHeaderBytes;
    const vertexData = new Float32Array(
      memory.buffer,
      vertByteOffset,
      vertFloatCount,
    );

    const idxByteOffset = vertByteOffset + vertFloatCount * 4;
    const indices = new Uint32Array(memory.buffer, idxByteOffset, indexCount);

    commands.push({
      vertexData: new Float32Array(vertexData),
      indices: new Uint32Array(indices),
      srcImageId,
      uniformR,
      uniformG,
      uniformB,
      uniformA,
    });

    offset = idxByteOffset + indexCount * 4;
  }

  return commands;
}

/** Validate the raw v0 ABI before allocating memory or calling guest init. */
export function assertGuestAbi(exports) {
  if (typeof exports.kagura_guest_abi_version !== "function")
    throw new Error("Guest ABI version export is missing");
  const version = exports.kagura_guest_abi_version();
  if (version !== GUEST_WIRE.abiVersion)
    throw new Error(
      `Guest ABI version ${version} is unsupported; expected ${GUEST_WIRE.abiVersion}`,
    );
  for (const name of GUEST_WIRE.requiredExports)
    if (typeof exports[name] !== "function")
      throw new Error(`Guest is missing required export: ${name}`);
  if (!(exports.memory instanceof WebAssembly.Memory))
    throw new Error("Guest memory export is missing");
}

const emptyFrame = () => ({
  commands: [],
  wantsRedraw: false,
  serializeMs: 0,
  updateMs: 0,
  renderMs: 0,
  deserializeMs: 0,
  inputBytes: 0,
});

/** Owned adapter for a semantic raw guest. The host owns rendering and time. */
export function createGuestSession(
  exports,
  { now = () => globalThis.performance?.now?.() ?? Date.now() } = {},
) {
  assertGuestAbi(exports);
  let state = "starting",
    shutdown = false;
  const release = () => {
    if (!shutdown) {
      shutdown = true;
      exports.kagura_guest_shutdown();
    }
  };
  const attempt = (operation) => {
    try {
      return operation();
    } catch (error) {
      state = "failed";
      try {
        release();
      } catch {}
      throw error;
    }
  };
  return {
    status: () => state,
    init(env) {
      if (state !== "starting")
        throw new Error(
          "Guest session has already been initialized or stopped",
        );
      return attempt(() => {
        const ptr = exports.kagura_alloc(INIT_ENV_SIZE);
        writeInitEnv(exports.memory, ptr, env);
        const config = readSemanticGuestConfig(
          exports.memory,
          exports.kagura_guest_init(ptr, INIT_ENV_SIZE),
        );
        state = "running";
        return config;
      });
    },
    frame(input) {
      if (state === "starting")
        throw new Error(
          "Guest session must be initialized before driving frames",
        );
      if (state !== "running") return emptyFrame();
      return attempt(() => {
        const result = emptyFrame(),
          size = inputByteSize(input),
          ptr = exports.kagura_alloc(size);
        let start = now();
        result.inputBytes = serializeInput(exports.memory, ptr, input);
        result.serializeMs = now() - start;
        start = now();
        result.wantsRedraw =
          exports.kagura_guest_update(ptr, result.inputBytes) !== 0;
        result.updateMs = now() - start;
        if (result.wantsRedraw) {
          start = now();
          const commands = exports.kagura_guest_render();
          result.renderMs = now() - start;
          start = now();
          result.commands = deserializeDrawCommands(exports.memory, commands);
          result.deserializeMs = now() - start;
        }
        return result;
      });
    },
    stop() {
      if (state === "stopped" || state === "failed") return;
      state = "stopped";
      release();
    },
  };
}

/** Adapter for the engine library's host-driven loop, not the semantic ABI. */
export function createEngineFrameSession(exports) {
  for (const name of ["kagura_frame", "kagura_stop", "kagura_session_status"]) {
    if (typeof exports[name] !== "function")
      throw new Error(`Engine frame export is missing: ${name}`);
  }
  const readStatus = () => {
    const code = exports.kagura_session_status();
    const states = ["starting", "running", "stopped", "failed"];
    if (!Number.isInteger(code) || code < 0 || code >= states.length)
      throw new Error(`Invalid engine session status: ${code}`);
    return states[code];
  };
  let state = readStatus(),
    released = false;
  const release = () => {
    if (!released) {
      released = true;
      exports.kagura_stop();
    }
  };
  if (state === "failed") {
    release();
    throw new Error("Engine session failed during startup");
  }
  return {
    status: () => state,
    frame() {
      if (state !== "starting" && state !== "running") return;
      try {
        exports.kagura_frame();
        state = readStatus();
        if (state === "failed")
          throw new Error("Engine session failed; see guest diagnostics");
        if (state === "stopped") release();
      } catch (error) {
        state = "failed";
        try {
          release();
        } catch {}
        throw error;
      }
    },
    stop() {
      if (state === "stopped" || state === "failed") return;
      state = "stopped";
      release();
    },
  };
}
