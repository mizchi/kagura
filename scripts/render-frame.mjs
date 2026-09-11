#!/usr/bin/env node

/**
 * Render one frame of a kagura example directly, with no browser, no GPU and no
 * Playwright.
 *
 *   node scripts/render-frame.mjs ui_demo --frames 3
 *
 * The engine's headless path (`engine/kagura_engine/headless_js.mbt`) runs the
 * example's own `update` / `draw` and rasterizes the resulting command stream on
 * the CPU (`engine/kagura_engine/raster`). What comes out is a PNG plus, for
 * examples that publish one, the UI snapshot that describes what is in it.
 *
 * This is the input side of the visual review loop: `scripts/vlm-ui-review.mjs`
 * takes these artifacts, runs the deterministic gates over them, and only then
 * asks a VLM about what is left.
 */

import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";

import { EXAMPLE_ROOT, findExampleDir } from "./example-dirs.mjs";
import {
  artifactPaths,
  bundlePathFor,
  parseModuleName,
  parseRenderFrameArgs,
  renderFrameUsage,
} from "./render-frame-utils.mjs";
import { toVlmkitElements } from "./ui-snapshot-utils.mjs";

const REPO_ROOT = dirname(import.meta.dirname);

// Order matters: the plain examples first, then the editor tools' own, so a
// name that exists in both resolves to the example a reviewer means.
const EXAMPLE_ROOTS = [
  EXAMPLE_ROOT.examples,
  EXAMPLE_ROOT.effectStudio,
  EXAMPLE_ROOT.modeling3d,
];

/** Locate an example, build it for js, and return where its bundle landed. */
export function prepareBundle(exampleName, { build = true } = {}) {
  const exampleDir = findExampleDir(exampleName, EXAMPLE_ROOTS);
  if (exampleDir == null) {
    throw new Error(`example not found: ${exampleName}`);
  }
  const moonModPath = existsSync(join(exampleDir, "moon.mod"))
    ? join(exampleDir, "moon.mod")
    : join(exampleDir, "moon.mod.json");
  const moduleName = parseModuleName(readFileSync(moonModPath, "utf8"));
  if (build) {
    execFileSync("moon", ["build", "--target", "js"], {
      cwd: exampleDir,
      stdio: "inherit",
    });
  }
  const bundlePath = bundlePathFor(exampleDir, moduleName);
  if (!existsSync(bundlePath)) {
    throw new Error(
      `no js bundle at ${relative(REPO_ROOT, bundlePath)}` +
        (build ? "" : " -- drop --no-build to build it first"),
    );
  }
  return { exampleDir, moduleName, bundlePath };
}

/**
 * Render a state and write its artifacts. Returns the paths written plus the
 * rasterizer's own report on the frame.
 */
export async function renderExampleState({
  exampleName,
  bundlePath,
  outDir,
  state,
  renderHeadlessFrame,
}) {
  const frame = await renderHeadlessFrame(bundlePath, {
    frames: state.frames,
    width: state.width ?? undefined,
    height: state.height ?? undefined,
    cursorX: state.cursorX ?? undefined,
    cursorY: state.cursorY ?? undefined,
    keys: state.keys,
  });
  mkdirSync(outDir, { recursive: true });
  const paths = artifactPaths(outDir, exampleName, state.name);
  writeFileSync(paths.png, frame.png);

  const written = { png: paths.png };
  if (frame.uiSnapshotJson != null) {
    writeFileSync(paths.snapshot, `${frame.uiSnapshotJson.trimEnd()}\n`);
    written.snapshot = paths.snapshot;
    // The elements payload is what lets `vlmkit diff png` name the UI node
    // behind a changed region instead of reporting a bare rectangle.
    const elements = toVlmkitElements(frame.uiSnapshotJson, { scale: "dpr" });
    writeFileSync(paths.elements, `${JSON.stringify(elements, null, 2)}\n`);
    written.elements = paths.elements;
  }
  const meta = {
    example: exampleName,
    state: state.name,
    width: frame.width,
    height: frame.height,
    frames: frame.frames,
    drawn_triangles: frame.drawnTriangles,
    // Commands the draw callback emitted. Moves independently of the triangle
    // count -- batching a text run divides this by ten and leaves the triangles
    // alone -- so a renderer regressing to one command per quad shows up here.
    draw_commands: frame.drawCommands ?? 0,
    skipped_commands: frame.skippedCommands,
    // How many source images the runtime hooks handed the rasterizer. Zero on
    // an example that draws only untextured geometry; zero on one that does
    // use an atlas means its art is missing from this frame.
    textures: frame.textureCount ?? 0,
    cursor: state.cursorX == null ? null : { x: state.cursorX, y: state.cursorY },
    keys: state.keys,
    artifacts: Object.fromEntries(
      Object.entries(written).map(([key, value]) => [key, relative(REPO_ROOT, value)]),
    ),
  };
  writeFileSync(paths.meta, `${JSON.stringify(meta, null, 2)}\n`);
  written.meta = paths.meta;
  return { frame, meta, written };
}

async function main(argv) {
  const options = parseRenderFrameArgs(argv);
  if (options.help) {
    process.stdout.write(`${renderFrameUsage()}\n`);
    return 0;
  }
  const { bundlePath } = prepareBundle(options.example, { build: options.build });
  const { renderHeadlessFrame } = await import("../assets/web/kagura-headless-frame.js");
  const outDir = options.outDir ?? join(REPO_ROOT, "output", "frames", options.example);
  const { meta } = await renderExampleState({
    exampleName: options.example,
    bundlePath,
    outDir,
    state: {
      name: options.state,
      frames: options.frames,
      width: options.width,
      height: options.height,
      cursorX: options.cursorX,
      cursorY: options.cursorY,
      keys: options.keys,
    },
    renderHeadlessFrame,
  });

  if (options.json) {
    process.stdout.write(`${JSON.stringify(meta, null, 2)}\n`);
    return 0;
  }
  process.stdout.write(
    `${meta.example} [${meta.state}]: ${meta.width}x${meta.height} ` +
      `after ${meta.frames} tick(s), ${meta.drawn_triangles} triangles ` +
      `in ${meta.draw_commands} command(s), ${meta.textures} texture(s)\n`,
  );
  for (const [kind, path] of Object.entries(meta.artifacts)) {
    process.stdout.write(`  ${kind}: ${path}\n`);
  }
  if (meta.skipped_commands > 0) {
    // Not a failure, but the PNG is then an incomplete picture of the scene and
    // a reviewer must not read it as the whole frame.
    process.stderr.write(
      `warning: ${meta.skipped_commands} draw command(s) were skipped -- ` +
        "the CPU rasterizer only draws 2D geometry, so any 3D content is missing " +
        "from this frame\n",
    );
  }
  return 0;
}

if (process.argv[1] === new URL(import.meta.url).pathname) {
  main(process.argv.slice(2)).then(
    (code) => {
      process.exitCode = code;
    },
    (error) => {
      process.stderr.write(`${error.message}\n`);
      process.exitCode = 1;
    },
  );
}
