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
