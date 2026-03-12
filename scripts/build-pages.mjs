import { spawnSync } from "node:child_process";
import {
  cpSync,
  existsSync,
  mkdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { join, resolve } from "node:path";

import {
  DEMO_PAGES,
  detectFontEntries,
  renderDemoHtml,
  renderLandingHtml,
  renderLoaderModule,
} from "./web-demo-pages.mjs";

const ROOT = resolve(import.meta.dirname, "..");
const SITE = join(ROOT, "_site");
const CACHE_BUST = resolveCacheBust();
const EFFECT_STUDIO_EXAMPLES_ROOT = join(ROOT, "tools", "effect-studio", "examples");
const MODELING_EXAMPLES_ROOT = join(ROOT, "tools", "modeling3d", "examples");

buildPages();

function buildPages() {
  rmSync(SITE, { recursive: true, force: true });
  mkdirSync(join(SITE, "lib"), { recursive: true });

  copySharedLib("kagura-init.js");
  copySharedLib("kagura-audio.js");
  copySharedLib("kagura-gfx.js");

  for (const demo of DEMO_PAGES) {
    buildExample(demo.name);
    emitExamplePage(demo);
  }

  writeFileSync(join(SITE, "index.html"), renderLandingHtml({ demos: DEMO_PAGES }));
  console.log(`Done! Site built at ${SITE}`);
}

function buildExample(name) {
  console.log(`Building ${name} ...`);
  const result = spawnSync("moon", ["build", "src", "--target", "js"], {
    cwd: resolveExampleDir(name),
    stdio: "inherit",
  });
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

function emitExamplePage(demo) {
  const exampleDir = resolveExampleDir(demo.name);
  const demoDir = join(SITE, demo.name);
  mkdirSync(demoDir, { recursive: true });

  const builtScript = join(
    exampleDir,
    "_build",
    "js",
    "debug",
    "build",
    `${demo.name}.js`,
  );
  cpSync(builtScript, join(demoDir, `${demo.name}.js`));

  const assetsDir = join(exampleDir, "assets");
  if (existsSync(assetsDir)) {
    cpSync(assetsDir, join(demoDir, "assets"), { recursive: true });
  }

  const fontEntries = detectFontEntries(exampleDir);
  writeFileSync(
    join(demoDir, "loader.js"),
    renderLoaderModule({
      fontEntries,
      scriptPath: `./${demo.name}.js?v=${CACHE_BUST}`,
      libPrefix: "../lib",
    }),
  );
  writeFileSync(
    join(demoDir, "index.html"),
    renderDemoHtml({
      demo,
      scriptTag: `<script type="module" src="./loader.js?v=${CACHE_BUST}"></script>`,
    }),
  );
}

function resolveExampleDir(name) {
  const effectStudioDir = join(EFFECT_STUDIO_EXAMPLES_ROOT, name);
  if (existsSync(effectStudioDir)) {
    return effectStudioDir;
  }
  const modelingDir = join(MODELING_EXAMPLES_ROOT, name);
  if (existsSync(modelingDir)) {
    return modelingDir;
  }
  return join(ROOT, "examples", name);
}

function copySharedLib(fileName) {
  cpSync(join(ROOT, "lib", "web", fileName), join(SITE, "lib", fileName));
}

function resolveCacheBust() {
  const result = spawnSync("git", ["-C", ROOT, "rev-parse", "--short", "HEAD"], {
    encoding: "utf8",
  });
  if (result.status === 0) {
    return result.stdout.trim();
  }
  return String(Date.now());
}
