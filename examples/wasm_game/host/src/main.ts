import { initWebGPU } from "../../../../lib/web/kagura-init.js";
import {
  ensureGpuPipeline,
  renderGpu,
} from "../../../../lib/web/kagura-gfx.js";
import { createInputCollector } from "./input-collector";
import {
  serializeInput,
  deserializeDrawCommands,
  inputByteSize,
  writeInitEnv,
  readLegacyGameConfig,
  readSemanticGuestConfig,
} from "./host-protocol";
import { createPreviewShell } from "./preview-shell";

interface GameExports {
  kagura_init?: () => number;
  kagura_alloc?: (size: number) => number;
  kagura_update?: (ptr: number, len: number) => void;
  kagura_draw?: () => number;
  kagura_guest_init?: (ptr: number, len: number) => number;
  kagura_guest_update?: (ptr: number, len: number) => number;
  kagura_guest_render?: () => number;
  kagura_guest_shutdown?: () => void;
  memory: WebAssembly.Memory;
  _start?: () => void;
}

function hasSemanticAbi(
  exports: GameExports,
): exports is GameExports & {
  kagura_guest_init: (ptr: number, len: number) => number;
  kagura_guest_update: (ptr: number, len: number) => number;
  kagura_guest_render: () => number;
} {
  return (
    typeof exports.kagura_guest_init === "function" &&
    typeof exports.kagura_guest_update === "function" &&
    typeof exports.kagura_guest_render === "function"
  );
}

function alloc(exports: GameExports, size: number): number {
  if (!exports.kagura_alloc) {
    throw new Error("guest is missing kagura_alloc");
  }
  return exports.kagura_alloc(size);
}

async function loadHostAssets(
  paths: string[],
  onGuestLog: (message: string) => void,
): Promise<Map<string, Uint8Array>> {
  const assets = new Map<string, Uint8Array>();
  for (const path of paths) {
    try {
      const response = await fetch(path + `?asset=${Date.now()}`);
      if (!response.ok) {
        onGuestLog(`[host] asset miss ${path}`);
        continue;
      }
      const bytes = new Uint8Array(await response.arrayBuffer());
      assets.set(path, bytes);
      onGuestLog(`[host] asset cached ${path} (${bytes.length}b)`);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      onGuestLog(`[host] asset error ${path}: ${message}`);
    }
  }
  return assets;
}

async function loadWasm(
  url: string,
  onGuestLog: (message: string) => void,
): Promise<GameExports> {
  const response = await fetch(url);
  let currentMemory: WebAssembly.Memory | null = null;
  const assets = await loadHostAssets(["/guest-title.txt"], onGuestLog);
  const importObject = {
    kagura_host: {
      log_i32_utf8(level: number, ptr: number, len: number) {
        if (!currentMemory) {
          return;
        }
        const bytes = new Uint8Array(currentMemory.buffer, ptr, len);
        const message = new TextDecoder().decode(bytes);
        onGuestLog(`[guest:${level}] ${message}`);
        return 0;
      },
      read_asset_len_i32_utf8(ptr: number, len: number) {
        if (!currentMemory) {
          return -1;
        }
        const bytes = new Uint8Array(currentMemory.buffer, ptr, len);
        const path = new TextDecoder().decode(bytes);
        return assets.get(path)?.length ?? -1;
      },
      read_asset_copy_i32_utf8(pathPtr: number, pathLen: number, dstPtr: number) {
        if (!currentMemory) {
          return -1;
        }
        const pathBytes = new Uint8Array(currentMemory.buffer, pathPtr, pathLen);
        const path = new TextDecoder().decode(pathBytes);
        const asset = assets.get(path);
        if (!asset) {
          return -1;
        }
        new Uint8Array(currentMemory.buffer, dstPtr, asset.length).set(asset);
        return asset.length;
      },
    },
  };
  const { instance } = await WebAssembly.instantiateStreaming(response, importObject);
  const exports = instance.exports as unknown as GameExports;
  currentMemory = exports.memory;
  // MoonBit WASM exports _start for module initialization
  if (exports._start) {
    exports._start();
  }
  return exports;
}

function initGame(
  game: GameExports,
  canvas: HTMLCanvasElement,
): { width: number; height: number; title: string; targetTps: number } {
  if (hasSemanticAbi(game)) {
    const envPtr = alloc(game, 16);
    writeInitEnv(game.memory, envPtr, {
      width: canvas.clientWidth || canvas.width || 320,
      height: canvas.clientHeight || canvas.height || 240,
      devicePixelRatio: window.devicePixelRatio || 1,
      hotReloadEnabled: Boolean(import.meta.hot),
    });
    const configPtr = game.kagura_guest_init(envPtr, 16);
    return readSemanticGuestConfig(game.memory, configPtr);
  }
  if (!game.kagura_init) {
    throw new Error("guest is missing kagura_init");
  }
  const configPtr = game.kagura_init();
  return readLegacyGameConfig(game.memory, configPtr);
}

function updateGame(game: GameExports, inputPtr: number, inputSize: number): boolean {
  if (hasSemanticAbi(game)) {
    return game.kagura_guest_update(inputPtr, inputSize) !== 0;
  }
  if (!game.kagura_update) {
    throw new Error("guest is missing kagura_update");
  }
  game.kagura_update(inputPtr, inputSize);
  return true;
}

function renderGame(game: GameExports): number {
  if (hasSemanticAbi(game)) {
    return game.kagura_guest_render();
  }
  if (!game.kagura_draw) {
    throw new Error("guest is missing kagura_draw");
  }
  return game.kagura_draw();
}

function gameAbiMode(game: GameExports): "semantic" | "legacy" {
  return hasSemanticAbi(game) ? "semantic" : "legacy";
}

async function main() {
  const gpuResult = await initWebGPU("#app");
  if (!gpuResult) {
    document.body.textContent = "WebGPU not supported";
    return;
  }
  const { canvas, device, format, context } = gpuResult;
  const shell = createPreviewShell(canvas);

  // GPU state object (matches kagura-gfx.js expectations)
  const gpu: Record<string, unknown> = {
    _pipeline: null,
    _pipelineFormat: "",
    _uniformBGL: null,
    _texBGL: null,
    _defaultTexture: null,
    _defaultTexView: null,
    _defaultSampler: null,
    _drawResourceCache: null,
    _pendingTexture: null,
    _currentDraw: null,
    commands: [] as unknown[],
    textures: new Map(),
  };

  ensureGpuPipeline(gpu, device, format);

  let game = await loadWasm("/game.wasm", (message) => {
    shell.pushLog(message);
  });
  let frameNumber = 0;
  let fpsWindowFrames = 0;
  let fpsWindowStart = performance.now();
  let lastFps = 0;
  let lastCommandCount = 0;

  // Initialize game
  const config = initGame(game, canvas);
  canvas.width = config.width;
  canvas.height = config.height;
  document.title = config.title;
  shell.setMeta({
    title: config.title,
    abiMode: gameAbiMode(game),
    logicalWidth: config.width,
    logicalHeight: config.height,
    targetTps: config.targetTps,
  });
  shell.setHmrState("ready");

  const input = createInputCollector(canvas);

  function frame() {
    const snap = input.snapshot();
    let wantsRedraw = false;

    try {
      // Allocate space for input in WASM memory
      const inputSize = inputByteSize(snap);
      const inputPtr = alloc(game, inputSize);

      // Write input to WASM memory
      const bytesWritten = serializeInput(game.memory, inputPtr, snap);

      // Update game state
      wantsRedraw = updateGame(game, inputPtr, bytesWritten);

      if (wantsRedraw) {
        const drawPtr = renderGame(game);
        const commands = deserializeDrawCommands(game.memory, drawPtr);
        lastCommandCount = commands.length;

        // Convert to kagura-gfx format and render
        gpu.commands = commands;
        renderGpu(gpu, device, context, [0, 0, 0, 1], format);
      }
      shell.setError(null);
    } catch (error) {
      const message = error instanceof Error ? error.stack ?? error.message : String(error);
      shell.setError(message);
    }

    frameNumber += 1;
    fpsWindowFrames += 1;
    const now = performance.now();
    const elapsed = now - fpsWindowStart;
    if (elapsed >= 500) {
      lastFps = (fpsWindowFrames * 1000) / elapsed;
      fpsWindowFrames = 0;
      fpsWindowStart = now;
    }
    shell.setFrame({
      fps: lastFps,
      frame: frameNumber,
      commandCount: lastCommandCount,
      redraw: wantsRedraw,
    });

    requestAnimationFrame(frame);
  }

  requestAnimationFrame(frame);

  // HMR: reload WASM on changes
  if (import.meta.hot) {
    import.meta.hot.on("wasm-update", async () => {
      console.log("[HMR] Reloading game.wasm...");
      shell.pushLog("[host] hmr reload requested");
      shell.setHmrState("reloading");
      try {
        game.kagura_guest_shutdown?.();
        game = await loadWasm("/game.wasm?t=" + Date.now(), (message) => {
          shell.pushLog(message);
        });
        const newConfig = initGame(game, canvas);
        canvas.width = newConfig.width;
        canvas.height = newConfig.height;
        shell.setMeta({
          title: newConfig.title,
          abiMode: gameAbiMode(game),
          logicalWidth: newConfig.width,
          logicalHeight: newConfig.height,
          targetTps: newConfig.targetTps,
        });
        shell.setError(null);
        shell.setHmrState("ready");
        shell.pushLog(`[host] hmr ready (${gameAbiMode(game)})`);
        console.log("[HMR] Game reloaded:", newConfig.title, `@${newConfig.targetTps} TPS`);
      } catch (e) {
        const message = e instanceof Error ? e.stack ?? e.message : String(e);
        shell.setError("[HMR] " + message);
        console.error("[HMR] Failed to reload:", e);
      }
    });
  }
}

main().catch(console.error);
