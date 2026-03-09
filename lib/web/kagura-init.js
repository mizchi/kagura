// Shared WebGPU initialization for JS-target game engine examples

export async function initWebGPU(canvasSelector) {
  const canvas = document.querySelector(canvasSelector);
  if (!canvas || !navigator.gpu) {
    return null;
  }
  try {
    const adapter = await navigator.gpu.requestAdapter();
    if (!adapter) return null;
    const device = await adapter.requestDevice();
    const format = navigator.gpu.getPreferredCanvasFormat();
    const context = canvas.getContext("webgpu");
    if (!context) return null;
    context.configure({ device, format, alphaMode: "opaque" });
    return { canvas, device, format, context };
  } catch (e) {
    console.warn("WebGPU init failed:", e);
    return null;
  }
}

export function showStartupError(canvasSelector, message, detail = "") {
  const canvas = document.querySelector(canvasSelector);
  if (canvas) {
    const ctx = canvas.getContext("2d");
    if (ctx) {
      const lines = [
        "Kagura startup error",
        ...wrapCanvasText(String(message), 34),
        ...wrapCanvasText(String(detail), 34),
      ].slice(0, 8);
      ctx.save();
      ctx.fillStyle = "#0f1020";
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = "#ff6b6b";
      ctx.font = "bold 12px monospace";
      let y = 18;
      for (const [index, line] of lines.entries()) {
        if (index === 1) {
          ctx.fillStyle = "#f0f0f0";
          ctx.font = "11px monospace";
        } else if (index >= 2) {
          ctx.fillStyle = "#b8b8b8";
        }
        ctx.fillText(line, 8, y);
        y += index === 0 ? 20 : 14;
      }
      ctx.restore();
    }
  }
  console.error("[kagura] startup error:", message, detail);
}

function wrapCanvasText(text, maxChars) {
  if (!text) {
    return [];
  }
  const words = text.split(/\s+/).filter(Boolean);
  if (words.length === 0) {
    return [text.slice(0, maxChars)];
  }
  const lines = [];
  let current = "";
  for (const word of words) {
    const next = current ? `${current} ${word}` : word;
    if (next.length > maxChars && current) {
      lines.push(current);
      current = word;
    } else {
      current = next;
    }
  }
  if (current) {
    lines.push(current);
  }
  return lines;
}

export function setupGlobalState(canvas, device, format, context) {
  const state = globalThis.__kaguraWebRuntime ?? (globalThis.__kaguraWebRuntime = {
    nextSurfaceId: 100,
    selector: "#app",
    canvas: null,
    surfaceId: 0,
    width: canvas.width,
    height: canvas.height,
    dpr: 1,
    webgpu: {
      context: null, device: null, format: "bgra8unorm",
      pending: null, _pipeline: null, _pipelineFormat: "",
      _uniformBGL: null, _texBGL: null,
      _defaultTexture: null, _defaultTexView: null, _defaultSampler: null,
      _drawResourceCache: null, _currentDraw: null, _pendingTexture: null,
      presentScheduled: false,
      clear: [0, 0, 0, 1], commands: [], textures: null, lastError: "",
    },
  });
  state.fonts = state.fonts || {};
  state.canvas = canvas;
  state.surfaceId = state.nextSurfaceId++;
  canvas.__kaguraSurfaceId = state.surfaceId;
  state.webgpu.context = context;
  state.webgpu.device = device;
  state.webgpu.format = format;
  return state;
}

export async function loadFonts(entries) {
  const state = globalThis.__kaguraWebRuntime;
  if (!state) return;
  state.fonts = state.fonts || {};
  await Promise.all(
    entries.map(async ([key, url]) => {
      try {
        const res = await fetch(url);
        if (!res.ok) return;
        const buf = await res.arrayBuffer();
        state.fonts[key] = new Uint8Array(buf);
      } catch (e) {
        console.warn(`Failed to load font "${key}" from ${url}:`, e);
      }
    })
  );
}

export function loadGameScript(scriptPath) {
  return new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = scriptPath;
    script.onload = resolve;
    script.onerror = reject;
    document.head.appendChild(script);
  });
}
