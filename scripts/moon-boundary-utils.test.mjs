import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  parseMoonPkgImports,
  validateModuleImportBoundaries,
} from "./moon-boundary-utils.mjs";

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function writeModule(root, dir, manifest, moonPkg = "") {
  const moduleRoot = path.join(root, dir);
  fs.mkdirSync(path.join(moduleRoot, manifest.source), { recursive: true });
  writeJson(path.join(moduleRoot, "moon.mod.json"), manifest);
  fs.writeFileSync(path.join(moduleRoot, manifest.source, "moon.pkg"), moonPkg);
}

function makeFixtureRepo({ coreImport = "", gameImport = "" } = {}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "kagura-boundary-utils-"));
  fs.writeFileSync(
    path.join(root, "moon.work"),
    [
      "members = [",
      '  ".",',
      '  "./modules/core",',
      '  "./modules/engine",',
      '  "./modules/game",',
      '  "./modules/js_runtime",',
      "]",
      "",
    ].join("\n"),
  );
  writeModule(
    root,
    ".",
    {
      name: "example/root",
      version: "1.0.0",
      description: "Root facade",
      repository: "https://example.test/root",
      license: "Apache-2.0",
      source: "src",
    },
    'import {\n  "example/core" @core,\n  "example/engine" @engine,\n}\n',
  );
  writeModule(
    root,
    "modules/core",
    {
      name: "example/core",
      version: "1.0.0",
      description: "Core",
      repository: "https://example.test/root",
      license: "Apache-2.0",
      source: "src",
    },
    coreImport,
  );
  writeModule(
    root,
    "modules/engine",
    {
      name: "example/engine",
      version: "1.0.0",
      description: "Engine",
      repository: "https://example.test/root",
      license: "Apache-2.0",
      source: "src",
    },
    'import {\n  "example/core/math" @math,\n  "example/engine/gfx" @gfx,\n}\n',
  );
  writeModule(
    root,
    "modules/game",
    {
      name: "example/game",
      version: "1.0.0",
      description: "Game",
      repository: "https://example.test/root",
      license: "Apache-2.0",
      source: "src",
    },
    gameImport,
  );
  writeModule(
    root,
    "modules/js_runtime",
    {
      name: "example/js_runtime",
      version: "1.0.0",
      description: "JS runtime",
      repository: "https://example.test/root",
      license: "Apache-2.0",
      source: "src",
    },
    'import {\n  "mizchi/js/core" @core,\n}\n',
  );
  return root;
}

const fixtureModuleDirs = [
  ".",
  "modules/core",
  "modules/engine",
  "modules/game",
  "modules/js_runtime",
];
const fixturePolicy = {
  "example/root": ["example/core", "example/engine"],
  "example/core": [],
  "example/engine": ["example/core"],
  "example/game": ["example/core", "example/engine"],
  "example/js_runtime": [],
};

test("parseMoonPkgImports returns quoted package imports with line numbers", () => {
  assert.deepEqual(
    parseMoonPkgImports(
      'import {\n  "example/core" @core,\n  "example/engine/gfx" @gfx,\n}\n',
    ),
    [
      { path: "example/core", line: 2 },
      { path: "example/engine/gfx", line: 3 },
    ],
  );
  assert.deepEqual(
    parseMoonPkgImports(
      'supported_targets = "js"\nimport {\n  "example/core" @core,\n}\noptions(targets: { "file.mbt": [ "js" ] })\n',
    ),
    [{ path: "example/core", line: 3 }],
  );
});

test("module boundary lint accepts allowed release imports", () => {
  const result = validateModuleImportBoundaries({
    repoRoot: makeFixtureRepo({
      gameImport: 'import {\n  "example/core" @core,\n  "example/engine" @engine,\n}\n',
    }),
    moduleDirs: fixtureModuleDirs,
    policy: fixturePolicy,
  });

  assert.deepEqual(result.errors, []);
});

test("module boundary lint rejects imports against dependency direction", () => {
  const result = validateModuleImportBoundaries({
    repoRoot: makeFixtureRepo({
      coreImport: 'import {\n  "example/engine/gfx" @gfx,\n}\n',
      gameImport: 'import {\n  "example/root" @root,\n}\n',
    }),
    moduleDirs: fixtureModuleDirs,
    policy: fixturePolicy,
  });

  assert.equal(result.errors.length, 2);
  assert.match(result.errors[0], /example\/core/);
  assert.match(result.errors[0], /example\/engine/);
  assert.match(result.errors[1], /example\/game/);
  assert.match(result.errors[1], /example\/root/);
});
