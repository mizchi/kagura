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
  readSemanticGuestConfig,
} from "./host-protocol";
import { createPreviewShell } from "./preview-shell";

interface GameExports {
  kagura_alloc: (size: number) => number;
  kagura_guest_init: (ptr: number, len: number) => number;
  kagura_guest_update: (ptr: number, len: number) => number;
  kagura_guest_render: () => number;
  kagura_guest_shutdown: () => void;
  memory: WebAssembly.Memory;
  _start?: () => void;
}

function assertSemanticAbi(exports: Record<string, unknown>): asserts exports is Record<string, unknown> & GameExports {
  for (const name of ["kagura_alloc", "kagura_guest_init", "kagura_guest_update", "kagura_guest_render", "kagura_guest_shutdown"]) {
    if (typeof exports[name] !== "function") {
      throw new Error(`guest is missing required export: ${name}`);
    }
  }
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
  const exports = instance.exports as unknown as Record<string, unknown>;
  assertSemanticAbi(exports);
  currentMemory = exports.memory;
  if (exports._start) {
    exports._start();
  }
  return exports;
}

function initGame(
  game: GameExports,
  canvas: HTMLCanvasElement,
): { width: number; height: number; title: string; targetTps: number } {
  const envPtr = game.kagura_alloc(16);
  writeInitEnv(game.memory, envPtr, {
    width: canvas.clientWidth || canvas.width || 320,
    height: canvas.clientHeight || canvas.height || 240,
    devicePixelRatio: window.devicePixelRatio || 1,
    hotReloadEnabled: Boolean(import.meta.hot),
  });
  const configPtr = game.kagura_guest_init(envPtr, 16);
  return readSemanticGuestConfig(game.memory, configPtr);
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
    abiMode: "v0",
    logicalWidth: config.width,
    logicalHeight: config.height,
    targetTps: config.targetTps,
  });
  shell.setHmrState("ready");

  const input = createInputCollector(canvas);

  function frame() {
    // Pause/step support
    if (shell.isPaused() && !shell.consumeStep()) {
      requestAnimationFrame(frame);
      return;
    }

    const snap = input.snapshot();
    let wantsRedraw = false;
    let vertexCount = 0;
    let serializeMs = 0;
    let updateMs = 0;
    let renderMs = 0;
    let deserializeMs = 0;
    let inputBytes = 0;
    let drawBytes = 0;

    try {
      // Allocate + serialize input
      const inputSize = inputByteSize(snap);
      const inputPtr = game.kagura_alloc(inputSize);

      let t0 = performance.now();
      const bytesWritten = serializeInput(game.memory, inputPtr, snap);
      serializeMs = performance.now() - t0;
      inputBytes = bytesWritten;

      // Update game state (wasm boundary call)
      t0 = performance.now();
      wantsRedraw = game.kagura_guest_update(inputPtr, bytesWritten) !== 0;
      updateMs = performance.now() - t0;

      if (wantsRedraw) {
        // Render (wasm boundary call)
        t0 = performance.now();
        const drawPtr = game.kagura_guest_render();
        renderMs = performance.now() - t0;

        // Deserialize draw commands from shared memory
        t0 = performance.now();
        const commands = deserializeDrawCommands(game.memory, drawPtr);
        deserializeMs = performance.now() - t0;
        lastCommandCount = commands.length;

        // Count vertices and estimate draw data size
        for (const cmd of commands) {
          vertexCount += cmd.vertexData.length / 8;
          drawBytes += cmd.vertexData.byteLength + cmd.indices.byteLength;
        }

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
      vertexCount,
      redraw: wantsRedraw,
    });
    shell.setAbi({
      updateMs,
      renderMs,
      serializeMs,
      deserializeMs,
      inputBytes,
      drawBytes,
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
        game.kagura_guest_shutdown();
        game = await loadWasm("/game.wasm?t=" + Date.now(), (message) => {
          shell.pushLog(message);
        });
        const newConfig = initGame(game, canvas);
        canvas.width = newConfig.width;
        canvas.height = newConfig.height;
        shell.setMeta({
          title: newConfig.title,
          abiMode: "v0",
          logicalWidth: newConfig.width,
          logicalHeight: newConfig.height,
          targetTps: newConfig.targetTps,
        });
        shell.setError(null);
        shell.setHmrState("ready");
        shell.pushLog(`[host] hmr ready`);
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
