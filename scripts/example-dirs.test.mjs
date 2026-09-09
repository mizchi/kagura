import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, test } from "node:test";

import {
  EXAMPLE_ROOT,
  findExampleCategory,
  findExampleDir,
  isExampleDir,
  listExampleNames,
} from "./example-dirs.mjs";

const roots = [];

function makeRoot(layout) {
  const root = mkdtempSync(join(tmpdir(), "kagura-example-dirs-"));
  roots.push(root);
  for (const [path, manifest] of Object.entries(layout)) {
    const dir = join(root, path);
    mkdirSync(dir, { recursive: true });
    if (manifest) writeFileSync(join(dir, manifest), "name = \"example\"\n");
  }
  return root;
}

after(() => {
  for (const root of roots) rmSync(root, { recursive: true, force: true });
});

test("a directory counts as an example when it carries either manifest name", () => {
  const root = makeRoot({
    text_manifest: "moon.mod",
    json_manifest: "moon.mod.json",
    no_manifest: null,
  });
  assert.equal(isExampleDir(join(root, "text_manifest")), true);
  assert.equal(isExampleDir(join(root, "json_manifest")), true);
  assert.equal(isExampleDir(join(root, "no_manifest")), false);
});

test("findExampleDir looks one level down, into the category directories", () => {
  const root = makeRoot({ "games/flappy_bird": "moon.mod" });
  assert.equal(findExampleDir("flappy_bird", [root]), join(root, "games", "flappy_bird"));
});

test("findExampleDir also finds an example sitting directly in a root", () => {
  const root = makeRoot({ effect_studio: "moon.mod" });
  assert.equal(findExampleDir("effect_studio", [root]), join(root, "effect_studio"));
});

test("findExampleDir returns null for a name no root holds", () => {
  const root = makeRoot({ "games/flappy_bird": "moon.mod" });
  assert.equal(findExampleDir("nope", [root]), null);
});

test("roots are searched in the order given", () => {
  const first = makeRoot({ "demos-2d/ui_demo": "moon.mod" });
  const second = makeRoot({ "games/ui_demo": "moon.mod" });
  assert.equal(findExampleDir("ui_demo", [first, second]), join(first, "demos-2d", "ui_demo"));
  assert.equal(findExampleDir("ui_demo", [second, first]), join(second, "games", "ui_demo"));
});

test("a missing root is skipped rather than throwing", () => {
  const root = makeRoot({ "games/flappy_bird": "moon.mod" });
  assert.equal(
    findExampleDir("flappy_bird", [join(root, "does-not-exist"), root]),
    join(root, "games", "flappy_bird"),
  );
});

test("findExampleCategory returns the category directory", () => {
  const root = makeRoot({ "demos-3d/particle_demo": "moon.mod" });
  assert.equal(findExampleCategory("particle_demo", [root]), "demos-3d");
});

test("findExampleCategory returns null for an example with no category level", () => {
  const root = makeRoot({ effect_studio: "moon.mod" });
  assert.equal(findExampleCategory("effect_studio", [root]), null);
});

test("findExampleCategory returns null for an unknown name", () => {
  const root = makeRoot({ "games/flappy_bird": "moon.mod" });
  assert.equal(findExampleCategory("nope", [root]), null);
});

test("listExampleNames collects both shapes, sorted and deduplicated", () => {
  const first = makeRoot({
    "games/flappy_bird": "moon.mod",
    "demos-2d/ui_demo": "moon.mod.json",
    "demos-2d/not_an_example": null,
  });
  const second = makeRoot({ effect_studio: "moon.mod", "games/flappy_bird": "moon.mod" });
  assert.deepEqual(listExampleNames([first, second]), [
    "effect_studio",
    "flappy_bird",
    "ui_demo",
  ]);
});

test("the declared roots match the repository layout", () => {
  assert.equal(findExampleCategory("flappy_bird", [EXAMPLE_ROOT.examples]), "games");
  assert.equal(findExampleCategory("particle_demo", [EXAMPLE_ROOT.examples]), "demos-3d");
  assert.equal(findExampleCategory("effect_studio", [EXAMPLE_ROOT.effectStudio]), null);
});
