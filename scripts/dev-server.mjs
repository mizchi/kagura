import { createServer } from "vite";
import { resolve, join } from "node:path";
import { existsSync, readFileSync } from "node:fs";
import { moonbit } from "vite-plugin-moonbit";
import { moonbitWebRuntimePlugin } from "./build-web-runtime.mjs";
import { resolveBuildArtifact } from "./moon-build-artifact-utils.mjs";
import { pathToFileURL } from "node:url";
import { resolveWebProject, resolveProjectArtifact } from "./web-project.mjs";
import { closeOnSignal } from "./dev-lifecycle.mjs";
import {spawnSync} from 'node:child_process';
import {
  detectFontEntries,
  renderDemoHtml,
  renderLoaderModule,
  resolveDemoPage,
} from "./web-demo-pages.mjs";

const ROOT = resolve(import.meta.dirname, "..");
export async function startDevServer({project, port = 8080, host = "127.0.0.1"}) {
  const {directory: exampleDir, name, artifactName, packageName} = project;
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error("Invalid server port");
  // Publish a URL only once a runnable first build exists. The plugin then owns
  // incremental builds and reloads, including recovery from later source errors.
  const initial = spawnSync('moon', ['build', project.entry, '--target', 'js'], {cwd: exampleDir, stdio: 'inherit'});
  if (initial.error) throw initial.error;
  if (initial.status !== 0) throw Object.assign(new Error(`Initial MoonBit build failed (exit ${initial.status ?? 1})`), {exitCode: initial.status ?? 1});
  const demo = resolveDemoPage(name);
  const inlineLoader = renderLoaderModule({
    fontEntries: detectFontEntries(exampleDir),
    scriptPath: `./_build/js/debug/build/${packageName}/${artifactName}.js`,
    libPrefix: "./assets/web",
  });
  // This custom HTML bypasses transformIndexHtml, so install Vite's reload client
  // explicitly. Both MoonBit build watchers publish full-reload over this channel.
  const scriptTag = `<script type="module" src="/@vite/client"></script>\n<script type="module">\n${inlineLoader.replaceAll("</script>", "<\\/script>")}</script>`;
  const indexHtml = renderDemoHtml({
    demo,
    homeHref: "https://github.com/mizchi/kagura",
    homeLabel: "Repository",
    libPrefix: "./assets/web",
    scriptTag,
  });

  const server = await createServer({
    root: ROOT,
    plugins: [
      moonbitWebRuntimePlugin(),
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
                const types = { ttf: "font/ttf", otf: "font/otf", png: "image/png", jpg: "image/jpeg", glb: "model/gltf-binary", obj: "text/plain", mjs: "text/javascript", js: "text/javascript", css: "text/css", svg: "image/svg+xml" };
                res.setHeader("Content-Type", types[ext] || "application/octet-stream");
                res.setHeader("Cache-Control", "no-store");
                res.end(readFileSync(assetPath));
                return;
              }
            }
            // The game script can be a workspace or a standalone build.
            if (url?.startsWith("/_build/")) {
              const buildPath = url === `/_build/js/debug/build/${packageName}/${artifactName}.js`
                ? resolveProjectArtifact(project, 'debug')
                : resolveBuildArtifact(join(exampleDir, url));
              if (buildPath != null) {
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
      port, host, strictPort: true,
      fs: {allow: [ROOT, exampleDir]},
      watch: {
        // The vite root is the repo, and every example carries its own
        // multi-thousand-file _build/ and .mooncakes/. Watching them all blows
        // past the inotify limit on Linux and takes the server down with
        // ENOSPC. Nothing here needs them: the plugin watches the one build
        // directory it cares about with its own recursive fs.watch, and adds
        // the .mbt sources it tracks to this watcher by path.
        ignored: ["**/_build/**", "**/.mooncakes/**", "**/node_modules/**", "**/target/**"],
      },
    },
    appType: "custom",
  });

  try { await server.listen(); } catch (error) { await server.close(); throw error; }
  const localUrl = server.resolvedUrls?.local?.[0] ?? `http://127.0.0.1:${port}/`;
  console.log(`\n  Serving ${name} at ${localUrl}`);
  console.log(`  .mbt changes will trigger auto-rebuild + full-reload\n`);
  server.printUrls();
  return server;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const server = await startDevServer({project: resolveWebProject(process.argv[2]), port: Number(process.env.PORT ?? 8080), host: process.env.HOST ?? '127.0.0.1'});
    closeOnSignal(() => server.close());
  } catch (error) {
    console.error(error.message);
    process.exitCode = error.exitCode ?? 1;
  }
}
