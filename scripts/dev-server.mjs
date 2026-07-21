import { createServer } from "vite";
import { resolve, join } from "node:path";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { moonbit } from "vite-plugin-moonbit";
import {
  detectFontEntries,
  renderDemoHtml,
  renderLoaderModule,
  resolveDemoPage,
} from "./web-demo-pages.mjs";

const ROOT = resolve(import.meta.dirname, "..");
const EXAMPLE_ROOTS = [
  resolve(ROOT, "tools", "effect-studio", "examples"),
  resolve(ROOT, "tools", "modeling3d", "examples"),
  resolve(ROOT, "examples"),
];
const name = process.argv[2];
if (!name) {
  console.error("Usage: node scripts/dev-server.mjs <example_name>");
  process.exit(1);
}

function isExampleDir(dir) {
  return existsSync(join(dir, "moon.mod.json")) || existsSync(join(dir, "moon.mod"));
}

function findExampleDir(name) {
  for (const root of EXAMPLE_ROOTS) {
    if (!existsSync(root)) continue;
    const direct = resolve(root, name);
    if (isExampleDir(direct)) return direct;
    for (const sub of readdirSync(root)) {
      const nested = resolve(root, sub, name);
      if (isExampleDir(nested)) return nested;
    }
  }
  return null;
}

function listAvailableExamples() {
  const available = new Set();
  for (const root of EXAMPLE_ROOTS) {
    if (!existsSync(root)) continue;
    for (const d of readdirSync(root)) {
      const dir = resolve(root, d);
      if (isExampleDir(dir)) {
        available.add(d);
        continue;
      }
      if (!existsSync(dir)) continue;
      for (const sub of readdirSync(dir)) {
        if (isExampleDir(resolve(dir, sub))) available.add(sub);
      }
    }
  }
  return [...available].sort();
}

const exampleDir = findExampleDir(name);
if (exampleDir == null) {
  console.error(`Error: example ${name} not found`);
  console.error("Available:");
  for (const d of listAvailableExamples()) console.error(`  ${d}`);
  process.exit(1);
}

const demo = resolveDemoPage(name);
const inlineLoader = renderLoaderModule({
  fontEntries: detectFontEntries(exampleDir),
  scriptPath: `./_build/js/debug/build/${name}.js`,
  libPrefix: "./lib/web",
});
const scriptTag = `<script type="module">\n${inlineLoader.replaceAll("</script>", "<\\/script>")}</script>`;
const indexHtml = renderDemoHtml({
  demo,
  homeHref: "https://github.com/mizchi/kagura",
  homeLabel: "Repository",
  scriptTag,
});

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
const localUrl = server.resolvedUrls?.local?.[0] ?? `http://127.0.0.1:${PORT}/`;
console.log(`\n  Serving ${name} at ${localUrl}`);
console.log(`  .mbt changes will trigger auto-rebuild + full-reload\n`);
server.printUrls();
