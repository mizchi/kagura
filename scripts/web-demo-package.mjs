import { cpSync, existsSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { resolveBuildArtifact } from "./moon-build-artifact-utils.mjs";
import { detectFontEntries, renderDemoHtml, renderLoaderModule } from "./web-demo-pages.mjs";
import {resolveProjectArtifact} from './web-project.mjs';

/** Package a release build with URLs relative to its public demo directory. */
export function emitExamplePage({ demo, exampleDir, site, cacheBust,
  demoDir = join(site, demo.name), artifactName = demo.name, packageName,
  entry = '.', libPrefix = "../lib", homeHref, homeLabel,
}) {
  const artifactPath = join(exampleDir, "_build", "js", "release", "build", packageName ?? '', `${artifactName}.js`);
  const builtScript = packageName
    ? resolveProjectArtifact({directory: exampleDir, packageName, artifactName, entry}, 'release')
    : resolveBuildArtifact(artifactPath);
  if (!builtScript) throw new Error(`Missing release build for ${demo.name}: ${artifactPath}`);

  mkdirSync(demoDir, { recursive: true });
  cpSync(builtScript, join(demoDir, `${artifactName}.js`));

  const assetsDir = join(exampleDir, "assets");
  if (existsSync(assetsDir)) {
    cpSync(assetsDir, join(demoDir, "assets"), { recursive: true });
  }
  writeFileSync(join(demoDir, "loader.js"), renderLoaderModule({
    fontEntries: detectFontEntries(exampleDir),
    scriptPath: `./${artifactName}.js?v=${cacheBust}`,
    libPrefix,
  }));
  writeFileSync(join(demoDir, "index.html"), renderDemoHtml({
    demo,
    libPrefix, homeHref, homeLabel,
    scriptTag: `<script type="module" src="./loader.js?v=${cacheBust}"></script>`,
  }));
}
