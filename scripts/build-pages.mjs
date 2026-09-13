import {copyWebRuntimeAssets} from './web-runtime-assets.mjs';
import { emitExamplePage } from './web-demo-package.mjs';
import { spawnSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  readdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { join, resolve } from "node:path";

import {
  DEMO_PAGES,
  renderLandingHtml,
} from "./web-demo-pages.mjs";

const ROOT = resolve(import.meta.dirname, "..");
const SITE = join(ROOT, "_site");
const CACHE_BUST = resolveCacheBust();
const EFFECT_STUDIO_EXAMPLES_ROOT = join(ROOT, "editor", "effect-studio", "examples");
const MODELING_EXAMPLES_ROOT = join(ROOT, "editor", "modeling3d", "examples");

buildPages();

function buildPages() {
  rmSync(SITE, { recursive: true, force: true });
  mkdirSync(join(SITE, "lib"), { recursive: true });

  copyWebRuntimeAssets(join(SITE, "lib"));

  for (const demo of DEMO_PAGES) {
    buildExample(demo.name);
    emitExamplePage({ demo, exampleDir: resolveExampleDir(demo.name), site: SITE, cacheBust: CACHE_BUST });
  }

  writeFileSync(join(SITE, "index.html"), renderLandingHtml({ demos: DEMO_PAGES }));
  console.log(`Done! Site built at ${SITE}`);
}

function buildExample(name) {
  console.log(`Building ${name} ...`);
  const result = spawnSync("moon", ["build", existsSync(join(resolveExampleDir(name), "moon.pkg")) ? "." : "src", "--target", "js", "--release"], {
    cwd: resolveExampleDir(name),
    stdio: "inherit",
  });
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
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
  // Examples live under examples/<category>/<name> after the reorg; fall back
  // to the legacy flat examples/<name> layout if a project sits there.
  const examplesRoot = join(ROOT, "examples");
  const flat = join(examplesRoot, name);
  if (existsSync(join(flat, "moon.mod.json")) || existsSync(join(flat, "moon.mod"))) {
    return flat;
  }
  for (const category of readdirSync(examplesRoot)) {
    const candidate = join(examplesRoot, category, name);
    if (statSync(candidate, { throwIfNoEntry: false })?.isDirectory()) {
      return candidate;
    }
  }
  return flat;
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
