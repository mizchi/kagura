import { spawnSync } from "node:child_process";
import { createServer } from "node:http";
import { existsSync, readFileSync, statSync } from "node:fs";
import { extname, join, normalize } from "node:path";
import process from "node:process";

import { resolveBuildArtifact } from "./moon-build-artifact-utils.mjs";
import { EXAMPLE_ROOT, findExampleDir } from "./example-dirs.mjs";

const ROOT = process.cwd();
const HOST = "127.0.0.1";
const PORT = Number.parseInt(process.env.PORT ?? "4173", 10);
// The modeling3d authoring examples are deliberately not served here.
const EXAMPLE_ROOTS = [EXAMPLE_ROOT.examples, EXAMPLE_ROOT.effectStudio];

const CONTENT_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".map": "application/json; charset=utf-8",
  ".wasm": "application/wasm",
  ".css": "text/css; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
  ".glb": "model/gltf-binary",
  ".obj": "text/plain; charset=utf-8",
};

const resolveExampleDir = (name) => findExampleDir(name, EXAMPLE_ROOTS);

const buildRuntimeSmoke = (target) => {
  const dir = resolveExampleDir("runtime_smoke");
  if (dir == null) {
    console.error("[e2e] runtime_smoke example not found");
    process.exit(1);
  }
  const result = spawnSync(
    "moon",
    ["build", "src", "--target", target],
    { cwd: dir, stdio: "inherit" },
  );
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
};

buildRuntimeSmoke("wasm");
buildRuntimeSmoke("wasm-gc");

const examplePublicPath = (name) => {
  const dir = resolveExampleDir(name);
  if (dir == null) {
    return null;
  }
  return `/${dir.slice(ROOT.length + 1).replaceAll("\\", "/")}`;
};

const buildJsExample = (name) => {
  const dir = resolveExampleDir(name);
  if (dir == null) {
    console.log(`[e2e] skipping ${name} (not found)`);
    return;
  }
  // Ensure dependencies are resolved (CI may not have run moon update in example dirs)
  spawnSync("moon", ["update"], { cwd: dir, stdio: "inherit" });
  const result = spawnSync("moon", ["build", "src", "--target", "js"], {
    cwd: dir,
    stdio: "inherit",
  });
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
};
const VRT_EXAMPLES = [
  "scene_demo", "flappy_bird", "survivor", "ui_demo", "action_rpg",
  "fps_demo", "arena3d", "collision3d_demo", "physics2d_demo",
  "physics3d_demo", "postfx_demo", "shadow3d_demo", "skeletal_anim",
  "ragdoll_demo", "obj_viewer", "gltf_viewer", "fetch_image",
  "hacknslash_3d", "effect_studio", "draw2d_ui_demo",
];

for (const name of VRT_EXAMPLES) {
  buildJsExample(name);
}

const resolvePath = (pathname) => {
  const normalized = normalize(pathname).replace(/^(\.\.[/\\])+/, "");
  const withoutLeadingSlash = normalized.startsWith("/")
    ? normalized.slice(1)
    : normalized;
  const filePath = join(ROOT, withoutLeadingSlash);
  if (!filePath.startsWith(ROOT)) {
    return null;
  }
  return filePath;
};

// SharedArrayBuffer needs cross-origin isolation. Scoped to the offscreen
// worker probe so the VRT and smoke pages keep serving exactly as before.
const isolationHeaders = (pathname) =>
  pathname.startsWith("/e2e/fixtures/offscreen-worker")
    ? {
        "cross-origin-opener-policy": "same-origin",
        "cross-origin-embedder-policy": "require-corp",
      }
    : {};

const serveFile = (res, filePath, extraHeaders = {}) => {
  const resolvedPath = resolveBuildArtifact(filePath) ?? filePath;
  if (!existsSync(resolvedPath)) {
    res.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
    res.end("not found");
    return;
  }
  const stat = statSync(resolvedPath);
  if (!stat.isFile()) {
    res.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
    res.end("not found");
    return;
  }
  const contentType = CONTENT_TYPES[extname(resolvedPath)] ?? "application/octet-stream";
  const body = readFileSync(resolvedPath);
  res.writeHead(200, {
    "content-type": contentType,
    "cache-control": "no-store",
    ...extraHeaders,
  });
  res.end(body);
};

const ASSET_EXAMPLES = {
  action_rpg: [["assets/Tiny5-Regular.ttf", "/examples/games/action_rpg/assets/Tiny5-Regular.ttf"]],
  hacknslash_3d: [["assets/Tiny5-Regular.ttf", "/examples/games/hacknslash_3d/assets/Tiny5-Regular.ttf"]],
  fetch_image: [["assets/sample.png", "/examples/demos-2d/fetch_image/assets/sample.png"]],
  gltf_viewer: [["assets/test_scene.glb", "/examples/demos-3d/gltf_viewer/assets/test_scene.glb"]],
  obj_viewer: [["assets/bunny.obj", "/examples/demos-3d/obj_viewer/assets/bunny.obj"]],
  draw2d_ui_demo: [["assets/Tiny5-Regular.ttf", "/examples/demos-2d/draw2d_ui_demo/assets/Tiny5-Regular.ttf"]],
};

const generateVrtHtml = (name) => {
  const publicPath = examplePublicPath(name);
  if (publicPath == null) {
    throw new Error(`unknown example: ${name}`);
  }
  const scriptPath = `${publicPath}/_build/js/debug/build/${name}.js`;
  const assetEntries = ASSET_EXAMPLES[name] ?? [];
  const fontEntries = assetEntries.filter(([key]) => /\.(ttf|otf)$/i.test(key));
  const fontPreloads = assetEntries
    .filter(([key]) => /\.(ttf|otf)$/i.test(key))
    .map(([, url]) => `<link rel="preload" href="${url}" as="font" crossorigin>`)
    .join("\n    ");
  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>VRT: ${name}</title>
    ${fontPreloads}
    <base href="${publicPath}/" />
    <style>
      body { margin: 0; background: #000; display: flex; justify-content: center; align-items: center; height: 100vh; }
      #app { border: none; }
    </style>
  </head>
  <body>
    <canvas id="app" width="320" height="240"
      style="width: 320px; height: 240px; image-rendering: pixelated"></canvas>
    <script type="module">
      import { initWebGPU, setupGlobalState, loadFonts, loadGameScript, showStartupError } from "/lib/web/kagura-init.js";
      import { installAudioHelpers } from "/lib/web/kagura-audio.js";
      import { installGfxHelpers } from "/lib/web/kagura-gfx.js";

      async function init() {
        const result = await initWebGPU("#app");
        if (!result) {
          showStartupError(
            "#app",
            "WebGPU only demo",
            "Kagura browser demos currently require WebGPU.",
          );
          return;
        }
        setupGlobalState(result.canvas, result.device, result.format, result.context);
        installAudioHelpers();
        installGfxHelpers();
        globalThis.__kaguraGfx.configureVrtReadback(true);
        await loadFonts(${JSON.stringify(fontEntries)});
        try {
          await loadGameScript(${JSON.stringify(scriptPath)});
        } catch (e) {
          showStartupError(
            "#app",
            "Failed to load game script",
            e && e.message ? e.message : String(e),
          );
        }
      }

      init().catch((e) => {
        showStartupError(
          "#app",
          "Failed to initialize Kagura runtime",
          e && e.message ? e.message : String(e),
        );
      });
    </script>
  </body>
</html>`;
};

const vrtNameSet = new Set(VRT_EXAMPLES);

const server = createServer((req, res) => {
  const url = new URL(req.url ?? "/", `http://${HOST}:${PORT}`);
  if (url.pathname === "/healthz") {
    res.writeHead(200, { "content-type": "text/plain; charset=utf-8" });
    res.end("ok");
    return;
  }
  // Dynamic VRT route: /vrt/{name}
  const vrtMatch = url.pathname.match(/^\/vrt\/([a-z0-9_]+)$/);
  if (vrtMatch != null) {
    const name = vrtMatch[1];
    if (!vrtNameSet.has(name)) {
      res.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
      res.end(`unknown VRT example: ${name}`);
      return;
    }
    const html = generateVrtHtml(name);
    res.writeHead(200, { "content-type": "text/html; charset=utf-8", "cache-control": "no-store" });
    res.end(html);
    return;
  }
  const pathname =
    url.pathname === "/" ? "/e2e/fixtures/runtime_smoke_wasm.html" : url.pathname;
  const filePath = resolvePath(pathname);
  if (filePath == null) {
    res.writeHead(403, { "content-type": "text/plain; charset=utf-8" });
    res.end("forbidden");
    return;
  }
  serveFile(res, filePath, isolationHeaders(pathname));
});

server.listen(PORT, HOST, () => {
  console.log(`[e2e] wasm smoke server ready: http://${HOST}:${PORT}`);
});

const shutdown = () => {
  server.close(() => {
    process.exit(0);
  });
};

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
