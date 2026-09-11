import assert from "node:assert/strict";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, test } from "node:test";

import {
  createHeadlessRequest,
  installHeadlessViewport,
  renderHeadlessFrame,
} from "./kagura-headless-frame.js";

const dirs = [];

after(() => {
  for (const dir of dirs) rmSync(dir, { recursive: true, force: true });
});

/**
 * A stand-in for a built example bundle. The engine contract is small enough to
 * restate: read `__kaguraHeadless`, publish a frame on `__kaguraHeadlessFrame`.
 * Testing against it keeps the host half honest without a MoonBit build.
 */
function writeFakeBundle(body) {
  const dir = mkdtempSync(join(tmpdir(), "kagura-headless-"));
  dirs.push(dir);
  // `.mjs`, not `.js`: a temp directory has no `package.json`, so Node would
  // resolve a bare `.js` as CommonJS and cache it by path -- the exact trap the
  // repeat-import check exists for. The real bundles are ES modules because the
  // repository's package.json says `"type": "module"`.
  const path = join(dir, "bundle.mjs");
  writeFileSync(path, body);
  return path;
}

const ENGINE_LIKE_BUNDLE = `
const request = globalThis.__kaguraHeadless;
const width = request.width ?? 320;
const height = request.height ?? 240;
globalThis.__kaguraHeadlessViewport = { width, height };
const rect = document.querySelector("canvas").getBoundingClientRect();
globalThis.__kaguraHeadlessFrame = {
  width,
  height,
  frames: request.frames,
  skipped_commands: 0,
  drawn_triangles: 12,
  draw_commands: 4,
  png: new Uint8Array([137, 80, 78, 71, rect.width & 0xff, rect.height & 0xff]),
};
globalThis.__kaguraUISnapshot = {
  json: JSON.stringify({ screen: { width, height }, nodes: [{ id: "root" }] }),
  parsed: { screen: { width, height }, nodes: [{ id: "root" }] },
};
`;

test("the request only carries the fields that were actually asked for", () => {
  assert.deepEqual(createHeadlessRequest({ frames: 3 }), { frames: 3 });
  assert.deepEqual(createHeadlessRequest({ frames: 1, width: 640, height: 480 }), {
    frames: 1,
    width: 640,
    height: 480,
  });
  assert.deepEqual(createHeadlessRequest({ frames: 1, cursorX: 10, cursorY: 20, keys: [9, 32] }), {
    frames: 1,
    cursor_x: 10,
    cursor_y: 20,
    keys: "9,32",
  });
});

test("a zero viewport is dropped rather than sent as an override", () => {
  assert.deepEqual(createHeadlessRequest({ frames: 1, width: 0, height: -5 }), { frames: 1 });
});

test("the viewport stub answers the DOM calls examples actually make", () => {
  const restore = installHeadlessViewport({ width: 640, height: 480 });
  try {
    const canvas = document.querySelector("canvas");
    assert.equal(canvas.getBoundingClientRect().width, 640);
    assert.equal(canvas.getBoundingClientRect().height, 480);
    assert.equal(document.getElementById("app").clientWidth, 640);
    assert.equal(canvas.getContext("2d"), null);
    assert.equal(globalThis.window, globalThis);
  } finally {
    restore();
  }
  assert.equal(typeof globalThis.document, "undefined");
});

test("the stub follows the viewport the engine resolved, not the one requested", () => {
  const restore = installHeadlessViewport({ width: 320, height: 240 });
  try {
    globalThis.__kaguraHeadlessViewport = { width: 640, height: 480 };
    // An example scaling the cursor by its CSS width has to see the size the
    // frame was really rendered at, or every pointer lands in the wrong place.
    assert.equal(document.querySelector("canvas").getBoundingClientRect().width, 640);
  } finally {
    restore();
  }
});

test("restoring puts back globals that were already there", () => {
  const before = { marker: true };
  globalThis.document = before;
  const restore = installHeadlessViewport({ width: 1, height: 1 });
  assert.notEqual(globalThis.document, before);
  restore();
  assert.equal(globalThis.document, before);
  delete globalThis.document;
});

test("rendering returns the frame and the snapshot the bundle published", async () => {
  const bundle = writeFakeBundle(ENGINE_LIKE_BUNDLE);
  const frame = await renderHeadlessFrame(bundle, { frames: 3, width: 640, height: 480 });
  assert.equal(frame.width, 640);
  assert.equal(frame.height, 480);
  assert.equal(frame.frames, 3);
  assert.equal(frame.drawnTriangles, 12);
  assert.equal(frame.drawCommands, 4);
  assert.ok(Buffer.isBuffer(frame.png));
  assert.deepEqual([...frame.png.subarray(0, 4)], [137, 80, 78, 71]);
  assert.equal(frame.uiSnapshot.nodes[0].id, "root");
  assert.equal(JSON.parse(frame.uiSnapshotJson).screen.width, 640);
});

test("the bundle sees the viewport it was asked for, through the DOM stub", async () => {
  const bundle = writeFakeBundle(ENGINE_LIKE_BUNDLE);
  const frame = await renderHeadlessFrame(bundle, { frames: 1, width: 200, height: 100 });
  // The fake bundle stamps the rect it read into the last two bytes.
  assert.deepEqual([...frame.png.subarray(4)], [200, 100]);
});

test("two renders in one process do not share the bundle's module instance", async () => {
  const bundle = writeFakeBundle(`
    globalThis.__kaguraRenderCount = (globalThis.__kaguraRenderCount ?? 0) + 1;
    globalThis.__kaguraHeadlessFrame = {
      width: 4, height: 4, frames: globalThis.__kaguraHeadless.frames,
      skipped_commands: 0, drawn_triangles: globalThis.__kaguraRenderCount,
      png: new Uint8Array([1]),
    };
  `);
  const first = await renderHeadlessFrame(bundle, { frames: 1 });
  const second = await renderHeadlessFrame(bundle, { frames: 2 });
  assert.equal(first.drawnTriangles, 1);
  assert.equal(second.drawnTriangles, 2, "the module must re-execute, not be served from cache");
  assert.equal(second.frames, 2);
});

test("source images the hooks mirrored out are counted and handed back", async () => {
  const bundle = writeFakeBundle(`
    // What platform/web_runtime_hooks does while the game loads its atlas.
    globalThis.__kaguraSourceImages = [
      { image_id: 100, width: 1, height: 1, pixels: new Uint8Array([255, 0, 0, 255]) },
    ];
    globalThis.__kaguraHeadlessFrame = {
      width: 2, height: 2, frames: 1, skipped_commands: 0, drawn_triangles: 2,
      png: new Uint8Array([1]),
    };
  `);
  const frame = await renderHeadlessFrame(bundle, { frames: 1 });
  assert.equal(frame.textureCount, 1);
});

test("one example's atlas cannot leak into the next render", async () => {
  const withAtlas = writeFakeBundle(`
    globalThis.__kaguraSourceImages = [
      { image_id: 7, width: 1, height: 1, pixels: new Uint8Array([1, 2, 3, 4]) },
    ];
    globalThis.__kaguraHeadlessFrame = {
      width: 1, height: 1, frames: 1, skipped_commands: 0, drawn_triangles: 1,
      png: new Uint8Array([1]),
    };
  `);
  const withoutAtlas = writeFakeBundle(`
    globalThis.__kaguraHeadlessFrame = {
      width: 1, height: 1, frames: 1, skipped_commands: 0, drawn_triangles: 1,
      png: new Uint8Array([1]),
    };
  `);
  assert.equal((await renderHeadlessFrame(withAtlas, { frames: 1 })).textureCount, 1);
  assert.equal((await renderHeadlessFrame(withoutAtlas, { frames: 1 })).textureCount, 0);
});

test("a bundle that publishes nothing is reported, not returned as an empty frame", async () => {
  const bundle = writeFakeBundle("globalThis.__kaguraNoop = true;\n");
  await assert.rejects(renderHeadlessFrame(bundle, { frames: 1 }), /did not publish a frame/);
});

test("an engine-side failure surfaces as an error", async () => {
  const bundle = writeFakeBundle('globalThis.__kaguraHeadlessError = "PNG encoding failed";\n');
  await assert.rejects(renderHeadlessFrame(bundle, { frames: 1 }), /PNG encoding failed/);
});

test("a missing bundle names the path instead of failing inside import", async () => {
  await assert.rejects(renderHeadlessFrame("/nope/bundle.mjs", {}), /bundle not found/);
});

test("a bundle served from the module cache is named as such, not silently reused", async () => {
  const dir = mkdtempSync(join(tmpdir(), "kagura-headless-cjs-"));
  dirs.push(dir);
  // A bare `.js` in a directory with no package.json is CommonJS: Node caches
  // it by path and ignores the cache-busting query, so the second render gets
  // no fresh module instance.
  const path = join(dir, "bundle.js");
  writeFileSync(
    path,
    "globalThis.__kaguraHeadlessFrame = { width: 1, height: 1, frames: 1, " +
      "skipped_commands: 0, drawn_triangles: 1, png: new Uint8Array([1]) };\n",
  );
  await renderHeadlessFrame(path, { frames: 1 });
  await assert.rejects(renderHeadlessFrame(path, { frames: 1 }), /served from the module cache/);
});

test("the viewport stub is torn down even when the bundle throws", async () => {
  const bundle = writeFakeBundle('throw new Error("boom");\n');
  await assert.rejects(renderHeadlessFrame(bundle, { frames: 1 }), /boom/);
  assert.equal(typeof globalThis.document, "undefined");
});

test("a bundle that publishes no command count reports 0, not undefined", async () => {
  // Older bundles predate `draw_commands`. Callers print the field
  // unconditionally, so it has to read as a number.
  const bundle = writeFakeBundle(`
globalThis.__kaguraHeadlessFrame = {
  width: 1, height: 1, frames: 1, skipped_commands: 0, drawn_triangles: 1,
  png: new Uint8Array([1]),
};
`);
  const frame = await renderHeadlessFrame(bundle, { frames: 1 });
  assert.equal(frame.drawCommands, 0);
});
