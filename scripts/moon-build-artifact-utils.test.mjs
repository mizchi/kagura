import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";

import {
  findNestedBuildArtifact,
  resolveBuildArtifact,
  resolveBuildArtifactFallback,
} from "./moon-build-artifact-utils.mjs";

const makeExample = () => {
  const root = mkdtempSync(join(tmpdir(), "kagura-build-"));
  const buildDir = join(root, "_build", "js", "debug", "build");
  mkdirSync(buildDir, { recursive: true });
  return { root, buildDir };
};

test("resolves the flat path when moon emits one", () => {
  const { buildDir } = makeExample();
  const flat = join(buildDir, "flappy_bird.js");
  writeFileSync(flat, "// flat");
  assert.equal(resolveBuildArtifact(flat), flat);
});

test("falls back to the workspace-mode nested path", () => {
  const { buildDir } = makeExample();
  const nestedDir = join(buildDir, "mizchi", "flappy_bird");
  mkdirSync(nestedDir, { recursive: true });
  const nested = join(nestedDir, "flappy_bird.js");
  writeFileSync(nested, "// nested");

  assert.equal(resolveBuildArtifact(join(buildDir, "flappy_bird.js")), nested);
  // Sourcemaps and wasm artifacts travel the same path.
  writeFileSync(join(nestedDir, "flappy_bird.js.map"), "{}");
  assert.equal(
    resolveBuildArtifact(join(buildDir, "flappy_bird.js.map")),
    join(nestedDir, "flappy_bird.js.map"),
  );
});

test("returns null when nothing under build/ matches", () => {
  const { buildDir } = makeExample();
  assert.equal(resolveBuildArtifact(join(buildDir, "missing.js")), null);
});

test("returns null for paths that are not under a moon build dir", () => {
  assert.equal(resolveBuildArtifactFallback("/tmp/somewhere/else/app.js"), null);
});

test("does not re-search a path that is already nested", () => {
  const { buildDir } = makeExample();
  const nestedDir = join(buildDir, "mizchi", "flappy_bird");
  mkdirSync(nestedDir, { recursive: true });
  // An already-nested request that does not exist must 404 rather than
  // silently resolving to some other file with the same basename.
  assert.equal(
    resolveBuildArtifactFallback(join(buildDir, "mizchi", "flappy_bird", "gone.js")),
    null,
  );
});

test("finds an artifact at any depth", () => {
  const { buildDir } = makeExample();
  const deep = join(buildDir, "a", "b", "c");
  mkdirSync(deep, { recursive: true });
  writeFileSync(join(deep, "guest.wasm"), "\0asm");
  assert.equal(findNestedBuildArtifact(buildDir, "guest.wasm"), join(deep, "guest.wasm"));
  assert.equal(findNestedBuildArtifact(buildDir, "nope.wasm"), null);
});
