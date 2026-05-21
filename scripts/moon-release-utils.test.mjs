import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  createPublishManifest,
  validateReleaseWorkspace,
  writePreparedManifests,
} from "./moon-release-utils.mjs";

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function makeModule(root, dir, manifest) {
  const moduleRoot = path.join(root, dir);
  fs.mkdirSync(path.join(moduleRoot, manifest.source), { recursive: true });
  fs.writeFileSync(
    path.join(moduleRoot, manifest.source, "lib.mbt"),
    `///|\npub fn module_name() -> String { "${manifest.name}" }\n`,
  );
  writeJson(path.join(moduleRoot, "moon.mod.json"), manifest);
}

function makeFixtureRepo() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "kagura-release-utils-"));
  fs.mkdirSync(path.join(root, "scripts"), { recursive: true });
  fs.writeFileSync(
    path.join(root, "scripts", "moon-prebuild-native-link-flags.cjs"),
    "#!/usr/bin/env node\nprocess.stdout.write('{\"vars\":{}}\\n');\n",
  );
  for (const fileName of [
    "moon-native-cc.sh",
    "moon-native-cc.cmd",
    "moon-native-cc-win.cjs",
    "setup-wgpu-native.sh",
    "setup-windows-native.sh",
  ]) {
    fs.writeFileSync(path.join(root, "scripts", fileName), "");
  }
  fs.writeFileSync(
    path.join(root, "moon.work"),
    [
      "members = [",
      '  ".",',
      '  "./modules/core",',
      '  "./modules/engine",',
      "]",
      "",
    ].join("\n"),
  );

  makeModule(root, ".", {
    name: "example/root",
    version: "1.0.0",
    description: "Root facade",
    repository: "https://example.test/root",
    license: "Apache-2.0",
    readme: "README.mbt.md",
    source: "src",
    deps: {
      "example/core": { path: "modules/core" },
      "example/engine": { path: "./modules/engine" },
    },
    "--moonbit-unstable-prebuild": "scripts/moon-prebuild-native-link-flags.cjs",
  });
  makeModule(root, "modules/core", {
    name: "example/core",
    version: "1.2.0",
    description: "Core contracts",
    repository: "https://example.test/root",
    license: "Apache-2.0",
    source: "src",
    deps: {},
  });
  makeModule(root, "modules/engine", {
    name: "example/engine",
    version: "1.3.0",
    description: "Engine implementation",
    repository: "https://example.test/root",
    license: "Apache-2.0",
    source: "src",
    deps: {
      "example/core": { path: "../core" },
    },
    "--moonbit-unstable-prebuild": "../../scripts/moon-prebuild-native-link-flags.cjs",
  });
  fs.writeFileSync(path.join(root, "README.mbt.md"), "# example/root\n");
  fs.writeFileSync(path.join(root, "modules", "engine", "README.md"), "# example/engine\n");

  return root;
}

const fixtureModuleDirs = [".", "modules/core", "modules/engine"];
const fixturePolicy = {
  "example/root": ["example/core", "example/engine"],
  "example/core": [],
  "example/engine": ["example/core"],
};

test("release validation accepts workspace path deps that publish as versions", () => {
  const root = makeFixtureRepo();
  const result = validateReleaseWorkspace({
    repoRoot: root,
    moduleDirs: fixtureModuleDirs,
    depPolicy: fixturePolicy,
  });

  assert.deepEqual(result.errors, []);
  const rootModule = result.modules.find((mod) => mod.name === "example/root");
  const prepared = createPublishManifest(rootModule, result.byDir);

  assert.equal(prepared.manifest.deps["example/core"], "1.2.0");
  assert.equal(prepared.manifest.deps["example/engine"], "1.3.0");
  assert.deepEqual(
    prepared.conversions.map((entry) => entry.name),
    ["example/core", "example/engine"],
  );
});

test("release validation rejects local path deps outside release modules", () => {
  const root = makeFixtureRepo();
  const rootManifestPath = path.join(root, "moon.mod.json");
  const rootManifest = JSON.parse(fs.readFileSync(rootManifestPath, "utf8"));
  rootManifest.deps["example/fixture"] = { path: "examples/fixture" };
  writeJson(rootManifestPath, rootManifest);
  fs.mkdirSync(path.join(root, "examples/fixture"), { recursive: true });

  const result = validateReleaseWorkspace({
    repoRoot: root,
    moduleDirs: fixtureModuleDirs,
    depPolicy: fixturePolicy,
  });

  assert.equal(result.errors.length, 1);
  assert.match(result.errors[0], /not a release module/);
});

test("writePreparedManifests writes converted publish manifests", () => {
  const root = makeFixtureRepo();
  const outDir = path.join(root, ".moon-release");

  const result = writePreparedManifests({
    repoRoot: root,
    outDir,
    moduleDirs: fixtureModuleDirs,
    depPolicy: fixturePolicy,
  });

  assert.deepEqual(result.validation.errors, []);
  const rootManifest = JSON.parse(
    fs.readFileSync(path.join(outDir, "example__root", "moon.mod.json"), "utf8"),
  );
  assert.equal(rootManifest.deps["example/core"], "1.2.0");
  assert.equal(rootManifest.deps["example/engine"], "1.3.0");
  assert.equal(
    fs.existsSync(path.join(outDir, "example__root", "src", "lib.mbt")),
    true,
  );
  assert.equal(
    fs.readFileSync(path.join(outDir, "example__root", "README.mbt.md"), "utf8"),
    "# example/root\n",
  );
  assert.equal(
    fs.existsSync(
      path.join(
        outDir,
        "example__root",
        "scripts",
        "moon-prebuild-native-link-flags.cjs",
      ),
    ),
    true,
  );

  const engineManifest = JSON.parse(
    fs.readFileSync(path.join(outDir, "example__engine", "moon.mod.json"), "utf8"),
  );
  assert.equal(
    engineManifest["--moonbit-unstable-prebuild"],
    "scripts/moon-prebuild-native-link-flags.cjs",
  );
  assert.equal(
    fs.existsSync(
      path.join(
        outDir,
        "example__engine",
        "scripts",
        "moon-prebuild-native-link-flags.cjs",
      ),
    ),
    true,
  );
  assert.equal(
    fs.existsSync(path.join(outDir, "example__engine", "src", "lib.mbt")),
    true,
  );
  assert.equal(
    fs.readFileSync(path.join(outDir, "example__engine", "README.md"), "utf8"),
    "# example/engine\n",
  );

  const summary = JSON.parse(
    fs.readFileSync(path.join(outDir, "release-manifests.json"), "utf8"),
  );
  assert.equal(summary.modules.length, 3);
  assert.equal(summary.modules[0].name, "example/root");
});
