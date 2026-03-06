import { createServer } from "vite";
import { resolve, join } from "node:path";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { moonbit } from "vite-plugin-moonbit";

const ROOT = resolve(import.meta.dirname, "..");
const name = process.argv[2];
if (!name) {
  console.error("Usage: node scripts/dev-server.mjs <example_name>");
  process.exit(1);
}

const exampleDir = resolve(ROOT, "examples", name);
if (!existsSync(exampleDir)) {
  console.error(`Error: examples/${name} not found`);
  console.error("Available:");
  for (const d of readdirSync(resolve(ROOT, "examples"))) console.error(`  ${d}`);
  process.exit(1);
}

// Detect TTF fonts
function detectFonts() {
  const assetsDir = join(exampleDir, "assets");
  if (!existsSync(assetsDir)) return "";
  const ttfs = readdirSync(assetsDir).filter((f) => f.endsWith(".ttf"));
  if (ttfs.length === 0) return "";
  const entries = ttfs.map((f) => `["assets/${f}", "./assets/${f}"]`).join(", ");
  return `  await loadFonts([${entries}]);`;
}

const fontSnippet = detectFonts();
const title = name.replace(/_/g, " ");

// Generate index.html content
const indexHtml = `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>${title} - Kagura Dev</title>
    <style>
      body {
        margin: 0;
        background: #000;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
      }
      #app { border: 1px solid #444; }
    </style>
  </head>
  <body>
    <canvas id="app" width="320" height="240"
      style="width: 640px; height: 480px; image-rendering: pixelated"></canvas>
    <script type="module">
      import { initWebGPU, setupGlobalState, loadFonts, loadGameScript, showStartupError } from "./lib/web/kagura-init.js";
      import { installAudioHelpers } from "./lib/web/kagura-audio.js";
      import { installGfxHelpers } from "./lib/web/kagura-gfx.js";
      async function init() {
        const result = await initWebGPU("#app");
        if (!result) {
          showStartupError("#app", "WebGPU initialization failed", "Use a WebGPU-capable browser.");
          return;
        }
        setupGlobalState(result.canvas, result.device, result.format, result.context);
        installAudioHelpers();
        installGfxHelpers();
      ${fontSnippet}
        try {
          await loadGameScript("./_build/js/debug/build/${name}.js");
        } catch (e) {
          showStartupError("#app", "Failed to load game script", e && e.message ? e.message : String(e));
        }
      }
      init().catch((e) => {
        showStartupError("#app", "Unexpected runtime error", e && e.message ? e.message : String(e));
      });
    </script>
  </body>
</html>`;

const PORT = parseInt(process.env.PORT ?? "8080", 10);

const server = await createServer({
  root: ROOT,
  plugins: [
    moonbit({ root: exampleDir, target: "js", mode: "debug" }),
    {
      name: "kagura-dev-index",
      configureServer(server) {
        server.middlewares.use((req, res, next) => {
          const url = req.url?.split("?")[0];
          if (url === "/" || url === "/index.html") {
            res.setHeader("Content-Type", "text/html");
            res.end(indexHtml);
            return;
          }
          // Rewrite /assets/* to example assets
          if (url?.startsWith("/assets/")) {
            const assetPath = join(exampleDir, url);
            if (existsSync(assetPath)) {
              const ext = assetPath.split(".").pop();
              const types = { ttf: "font/ttf", otf: "font/otf", png: "image/png", jpg: "image/jpeg", glb: "model/gltf-binary", obj: "text/plain" };
              res.setHeader("Content-Type", types[ext] || "application/octet-stream");
              res.setHeader("Cache-Control", "no-store");
              res.end(readFileSync(assetPath));
              return;
            }
          }
          // Rewrite _build to example _build
          if (url?.startsWith("/_build/")) {
            const buildPath = join(exampleDir, url);
            if (existsSync(buildPath)) {
              res.setHeader("Content-Type", "text/javascript");
              res.setHeader("Cache-Control", "no-store");
              res.end(readFileSync(buildPath));
              return;
            }
          }
          next();
        });
      },
    },
  ],
  server: {
    port: PORT,
    host: "127.0.0.1",
  },
  appType: "custom",
});

await server.listen();
console.log(`\n  Serving ${name} at http://localhost:${PORT}`);
console.log(`  .mbt changes will trigger auto-rebuild + full-reload\n`);
server.printUrls();
