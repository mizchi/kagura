/**
 * Pure helpers for `render-frame.mjs` -- argument parsing, path derivation and
 * artifact naming. Kept separate so they can be tested without building a
 * MoonBit example or touching the filesystem.
 */

import { join } from "node:path";

export const DEFAULT_STATE = "default";

/**
 * A rendered state: which tick to capture and what input is held while getting
 * there. Named so the artifacts of a state matrix stay tellable apart.
 */
export function normalizeState(state = {}) {
  return {
    name: state.name ?? DEFAULT_STATE,
    frames: Number.isFinite(state.frames) ? Math.max(0, Math.floor(state.frames)) : 1,
    width: Number.isFinite(state.width) && state.width > 0 ? Math.floor(state.width) : null,
    height: Number.isFinite(state.height) && state.height > 0 ? Math.floor(state.height) : null,
    cursorX: Number.isFinite(state.cursorX) ? state.cursorX : null,
    cursorY: Number.isFinite(state.cursorY) ? state.cursorY : null,
    keys: Array.isArray(state.keys) ? state.keys.filter(Number.isFinite) : [],
  };
}

/** `--cursor 320,240` -> `{ cursorX: 320, cursorY: 240 }`. */
export function parseCursor(value) {
  const parts = String(value).split(",");
  if (parts.length !== 2) throw new Error(`--cursor wants "x,y", got: ${value}`);
  const cursorX = Number(parts[0]);
  const cursorY = Number(parts[1]);
  if (!Number.isFinite(cursorX) || !Number.isFinite(cursorY)) {
    throw new Error(`--cursor wants two numbers, got: ${value}`);
  }
  return { cursorX, cursorY };
}

/** `--keys 9,32` -> `[9, 32]`. Key codes are whatever the example reads. */
export function parseKeys(value) {
  return String(value)
    .split(",")
    .map((part) => part.trim())
    .filter((part) => part.length > 0)
    .map((part) => {
      const code = Number(part);
      if (!Number.isInteger(code)) throw new Error(`--keys wants integers, got: ${part}`);
      return code;
    });
}

export function renderFrameUsage() {
  return [
    "Usage: node scripts/render-frame.mjs <example> [options]",
    "",
    "Renders one frame of an example with no browser, no GPU and no Playwright:",
    "the engine's headless path drives update/draw through the CPU rasterizer.",
    "",
    "Options:",
    "  --frames <n>        Update ticks before the captured draw (default 1)",
    "  --width <px>        Override the example's viewport width",
    "  --height <px>       Override the example's viewport height",
    "  --cursor <x,y>      Synthesized cursor position, for hover states",
    "  --keys <a,b>        Key codes held during every tick, for focus states",
    "  --state <name>      Label used in the artifact filenames (default: default)",
    "  --out-dir <dir>     Where to write (default: output/frames/<example>)",
    "  --no-build          Use the existing _build output instead of rebuilding",
    "  --json              Print the result as JSON",
    "  -h, --help          Show this help",
  ].join("\n");
}

export function parseRenderFrameArgs(argv) {
  const options = {
    example: null,
    state: DEFAULT_STATE,
    frames: 1,
    width: null,
    height: null,
    cursorX: null,
    cursorY: null,
    keys: [],
    outDir: null,
    build: true,
    json: false,
    help: false,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = () => {
      const value = argv[++i];
      if (value === undefined) throw new Error(`${arg} needs a value`);
      return value;
    };
    switch (arg) {
      case "-h":
      case "--help":
        options.help = true;
        break;
      case "--frames": {
        const value = Number(next());
        if (!Number.isInteger(value) || value < 0) {
          throw new Error("--frames wants a non-negative integer");
        }
        options.frames = value;
        break;
      }
      case "--width":
        options.width = requirePositiveInt("--width", next());
        break;
      case "--height":
        options.height = requirePositiveInt("--height", next());
        break;
      case "--cursor": {
        const { cursorX, cursorY } = parseCursor(next());
        options.cursorX = cursorX;
        options.cursorY = cursorY;
        break;
      }
      case "--keys":
        options.keys = parseKeys(next());
        break;
      case "--state":
        options.state = next();
        break;
      case "--out-dir":
        options.outDir = next();
        break;
      case "--no-build":
        options.build = false;
        break;
      case "--json":
        options.json = true;
        break;
      default:
        if (arg.startsWith("-")) throw new Error(`unknown option: ${arg}`);
        if (options.example !== null) throw new Error(`unexpected extra argument: ${arg}`);
        options.example = arg;
    }
  }
  if (!options.help && options.example === null) {
    throw new Error(`missing <example>\n\n${renderFrameUsage()}`);
  }
  return options;
}

function requirePositiveInt(flag, raw) {
  const value = Number(raw);
  if (!Number.isInteger(value) || value <= 0) {
    throw new Error(`${flag} wants a positive integer`);
  }
  return value;
}

/**
 * The module name a MoonBit example declares. This is the identity that
 * decides the build output path -- the directory name is just where the module
 * happens to live, and the two do differ in this repo.
 */
export function parseModuleName(moonModText) {
  const match = /^\s*name\s*=\s*"([^"]+)"/m.exec(moonModText);
  if (match == null) {
    const jsonMatch = /"name"\s*:\s*"([^"]+)"/.exec(moonModText);
    if (jsonMatch != null) return jsonMatch[1];
    throw new Error("could not read `name` from the example's moon.mod");
  }
  return match[1];
}

/**
 * `mizchi/ui_demo` under `examples/demos-2d/ui_demo` builds to
 * `_build/js/debug/build/mizchi/ui_demo/ui_demo.js`.
 */
export function bundlePathFor(exampleDir, moduleName) {
  const basename = moduleName.split("/").pop();
  return join(exampleDir, "_build", "js", "debug", "build", ...moduleName.split("/"), `${basename}.js`);
}

/** Artifact paths for one rendered state, all sharing a stem. */
export function artifactPaths(outDir, exampleName, stateName) {
  const stem = stateName === DEFAULT_STATE ? exampleName : `${exampleName}.${stateName}`;
  return {
    stem,
    png: join(outDir, `${stem}.png`),
    snapshot: join(outDir, `${stem}.snapshot.json`),
    elements: join(outDir, `${stem}.elements.json`),
    meta: join(outDir, `${stem}.frame.json`),
  };
}
