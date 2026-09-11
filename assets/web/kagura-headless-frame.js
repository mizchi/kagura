// Headless frame capture for kagura examples: render a real frame under plain
// `node`, with no browser, no GPU and no Playwright.
//
// The engine side lives in `engine/kagura_engine/headless_js.mbt`. When
// `globalThis.__kaguraHeadless` is set, `@engine.run` skips the canvas and the
// animation loop, drives `update` for N ticks, and rasterizes one `draw` on the
// CPU (`engine/kagura_engine/raster`). The PNG comes back on
// `globalThis.__kaguraHeadlessFrame`.
//
// What this module adds is the host half: a viewport stub standing in for the
// handful of DOM calls examples make (`document.querySelector("canvas")` for
// the CSS size), and the module-import dance that keeps repeated renders in one
// process independent.
//
// Browser-safe by construction: nothing here is imported by a page. It is a
// Node-side driver, so `node:` imports are fine.

import { existsSync } from "node:fs";
import { pathToFileURL } from "node:url";

/**
 * Minimal stand-in for the browser surface an example touches while rendering.
 * Deliberately small: every entry exists because some `extern "js"` in the repo
 * calls it, not because a browser has it.
 */
export function installHeadlessViewport({ width, height, devicePixelRatio = 1 } = {}) {
  const w = Number(width) > 0 ? Math.floor(width) : 320;
  const h = Number(height) > 0 ? Math.floor(height) : 240;
  const saved = new Map();
  const define = (key, value) => {
    saved.set(key, Object.hasOwn(globalThis, key) ? globalThis[key] : undefined);
    globalThis[key] = value;
  };

  // The engine publishes the viewport it actually resolved to, which is the
  // example's own size unless the request overrode it. Reading it live rather
  // than freezing the requested size is what keeps cursor scaling honest: an
  // example that divides by its CSS width would otherwise place every pointer
  // in the wrong spot.
  const viewport = () => {
    const published = globalThis.__kaguraHeadlessViewport;
    return {
      width: Number(published?.width) > 0 ? published.width : w,
      height: Number(published?.height) > 0 ? published.height : h,
    };
  };
  const rectOf = () => {
    const { width, height } = viewport();
    return { x: 0, y: 0, top: 0, left: 0, right: width, bottom: height, width, height };
  };
  const element = {
    get width() {
      return viewport().width;
    },
    get height() {
      return viewport().height;
    },
    get clientWidth() {
      return viewport().width;
    },
    get clientHeight() {
      return viewport().height;
    },
    style: {},
    getBoundingClientRect: () => {
      const rect = rectOf();
      return { ...rect, toJSON: () => ({ ...rect }) };
    },
    // A game asking for a rendering context headlessly gets nothing; the CPU
    // rasterizer is the renderer here, so handing back a fake context would
    // only let a draw path fail further from its cause.
    getContext: () => null,
    addEventListener: () => {},
    removeEventListener: () => {},
    appendChild: (child) => child,
    setAttribute: () => {},
    focus: () => {},
  };

  define("document", {
    querySelector: () => element,
    querySelectorAll: () => [element],
    getElementById: () => element,
    createElement: () => element,
    addEventListener: () => {},
    removeEventListener: () => {},
    body: element,
    documentElement: element,
  });
  define("window", globalThis);
  if (!Object.hasOwn(globalThis, "navigator")) {
    define("navigator", { userAgent: "kagura-headless" });
  }
  globalThis.innerWidth = w;
  globalThis.innerHeight = h;
  define("__kaguraHeadlessViewport", { width: w, height: h });
  globalThis.devicePixelRatio = devicePixelRatio;
  globalThis.addEventListener ??= () => {};
  globalThis.removeEventListener ??= () => {};
  // Never fires. The headless path returns before scheduling a frame; this is
  // only here so a stray call cannot throw, and a no-op is safer than a timer
  // that would keep the process alive.
  globalThis.requestAnimationFrame ??= () => 0;
  globalThis.cancelAnimationFrame ??= () => {};

  return function restoreHeadlessViewport() {
    for (const [key, value] of saved) {
      if (value === undefined) delete globalThis[key];
      else globalThis[key] = value;
    }
  };
}

/** The `globalThis.__kaguraHeadless` request object the engine reads. */
export function createHeadlessRequest({
  frames = 1,
  width,
  height,
  cursorX,
  cursorY,
  keys = [],
  inputs,
  initialState,
} = {}) {
  const request = { frames };
  if (initialState !== undefined) {
    if (typeof initialState !== 'string' || !/^[a-zA-Z0-9_-]{1,128}$/.test(initialState)) throw Error('Invalid initial state');
    request.initial_state = initialState;
  }
  if (Number(width) > 0) request.width = Math.floor(width);
  if (Number(height) > 0) request.height = Math.floor(height);
  if (Number.isFinite(cursorX)) request.cursor_x = cursorX;
  if (Number.isFinite(cursorY)) request.cursor_y = cursorY;
  if (keys.length > 0) request.keys = keys.join(",");
  if (inputs !== undefined) {
    if (!Array.isArray(inputs) || inputs.length > 10000) throw Error('Invalid input sequence');
    request.inputs = inputs.map(normalizeInputStep);
  }
  return request;
}

/** A complete input snapshot per tick. Omitted channels are released, not held. */
function normalizeInputStep(step) {
  if (!step || typeof step !== 'object' || Array.isArray(step)) throw Error('Invalid input step');
  const numbers = (values = [], integer = true) => {
    if (!Array.isArray(values) || values.some(v => !Number.isFinite(v) || (integer && (!Number.isInteger(v) || v < 0)))) {
      throw Error('Invalid input values');
    }
    return [...values];
  };
  const coordinate = value => {
    if (!Number.isFinite(value)) throw Error('Invalid input coordinate');
    return value;
  };
  const gamepads = step.gamepads ?? [];
  if (!Array.isArray(gamepads)) throw Error('Invalid input gamepads');
  const ids = new Set();
  return {
    cursor_x: coordinate(step.cursorX ?? -1),
    cursor_y: coordinate(step.cursorY ?? -1),
    keys: numbers(step.keys),
    mouse_buttons: numbers(step.mouseButtons),
    gamepads: gamepads.map(pad => {
      if (!pad || !Number.isInteger(pad.id) || pad.id < 0 || ids.has(pad.id)) throw Error('Invalid input gamepad ID');
      ids.add(pad.id);
      return { id: pad.id, axes: numbers(pad.axes, false), buttons: numbers(pad.buttons) };
    }),
  };
}

let importCounter = 0;
const importedBundles = new Set();

/**
 * Import a built example bundle and return its rendered frame.
 *
 * The bundle runs its `main` on import, so each render needs a fresh module
 * instance -- otherwise the second state in a matrix would silently reuse the
 * first one's game object. A unique query string defeats the ESM module cache.
 *
 * That trick only works on an ES module. A `.js` file that Node resolves as
 * CommonJS is cached by path with the query ignored, so it would run once and
 * every later state would come back empty. moon's js output is `.js` and the
 * repository's `package.json` declares `"type": "module"`, which is what makes
 * the built bundles ES modules; the repeat-import check below turns a silent
 * wrong answer into a named failure if that ever stops being true.
 */
export async function renderHeadlessFrame(bundlePath, options = {}) {
  if (!existsSync(bundlePath)) {
    throw new Error(`bundle not found: ${bundlePath}`);
  }
  const request = createHeadlessRequest(options);
  const restore = installHeadlessViewport({
    width: options.width,
    height: options.height,
    devicePixelRatio: options.devicePixelRatio,
  });
  const previousRequest = globalThis.__kaguraHeadless;
  globalThis.__kaguraHeadless = request;
  globalThis.__kaguraHeadlessFrame = undefined;
  globalThis.__kaguraHeadlessError = undefined;
  globalThis.__kaguraUISnapshot = undefined;
  // Source images the runtime hooks mirror out while the game loads its
  // assets. Cleared per render so one example's atlas cannot leak into the
  // next one's frame in a matrix run.
  globalThis.__kaguraSourceImages = undefined;
  importCounter += 1;
  const wasImportedBefore = importedBundles.has(bundlePath);
  importedBundles.add(bundlePath);
  try {
    const url = `${pathToFileURL(bundlePath).href}?kagura-headless=${importCounter}`;
    await import(url);
  } catch (error) {
    if (globalThis.__kaguraHeadlessError) throw Error(`headless render failed: ${globalThis.__kaguraHeadlessError}`);
    throw error;
  } finally {
    globalThis.__kaguraHeadless = previousRequest;
    restore();
  }

  const error = globalThis.__kaguraHeadlessError;
  if (error) throw new Error(`headless render failed: ${error}`);
  const frame = globalThis.__kaguraHeadlessFrame;
  if (frame == null) {
    throw new Error(
      wasImportedBefore
        ? `the bundle published no frame on a repeat render: ${bundlePath} was served from the ` +
          "module cache, so it is being resolved as CommonJS rather than as an ES module"
        : "the bundle did not publish a frame -- it may not call @engine.run / @engine.run_game",
    );
  }
  if ((frame.initial_state ?? null) !== (options.initialState ?? null)) throw Error('Requested initial state was not applied');
  const snapshot = globalThis.__kaguraUISnapshot;
  const textureCount = globalThis.__kaguraSourceImages?.length ?? 0;
  return {
    textureCount,
    initialState: frame.initial_state ?? null,
    png: Buffer.from(frame.png),
    width: frame.width,
    height: frame.height,
    frames: frame.frames,
    skippedCommands: frame.skipped_commands,
    drawnTriangles: frame.drawn_triangles,
    // Older bundles published a frame without this field; report 0 rather than
    // undefined so a caller can print it unconditionally.
    drawCommands: frame.draw_commands ?? 0,
    uiSnapshotJson: snapshot?.json ?? null,
    uiSnapshot: snapshot?.parsed ?? null,
  };
}
