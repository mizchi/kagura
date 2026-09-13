import { cpSync, existsSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { resolveBuildArtifact } from "./moon-build-artifact-utils.mjs";
import { detectFontEntries, renderDemoHtml, renderLoaderModule } from "./web-demo-pages.mjs";

/** Package a release build with URLs relative to its public demo directory. */
export function emitExamplePage({ demo, exampleDir, site, cacheBust }) {
  const artifactPath = join(exampleDir, "_build", "js", "release", "build", `${demo.name}.js`);
  const builtScript = resolveBuildArtifact(artifactPath);
  if (!builtScript) throw new Error(`Missing release build for ${demo.name}: ${artifactPath}`);

  const demoDir = join(site, demo.name);
  mkdirSync(demoDir, { recursive: true });
  cpSync(builtScript, join(demoDir, `${demo.name}.js`));

  const assetsDir = join(exampleDir, "assets");
  if (existsSync(assetsDir)) {
    cpSync(assetsDir, join(demoDir, "assets"), { recursive: true });
  }
  writeFileSync(join(demoDir, "loader.js"), renderLoaderModule({
    fontEntries: detectFontEntries(exampleDir),
    scriptPath: `./${demo.name}.js?v=${cacheBust}`,
    libPrefix: "../lib",
  }));
  writeFileSync(join(demoDir, "index.html"), renderDemoHtml({
    demo,
    scriptTag: `<script type="module" src="./loader.js?v=${cacheBust}"></script>`,
  }));
}
