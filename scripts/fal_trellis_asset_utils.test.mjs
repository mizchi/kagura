import test from "node:test";
import assert from "node:assert/strict";
import {
  applyFalTrellisPreset,
  buildFalTrellisInput,
  bytesToDataUri,
  defaultPreprocessedPathForImage,
  defaultOutputPathForImage,
  extractFalModelGlbUrl,
  mimeTypeFromImagePath,
  parseFalTrellisAssetArgs,
  toHacknslashQueryAssetPath,
} from "./fal_trellis_asset_utils.mjs";

test("mimeTypeFromImagePath infers supported formats", () => {
  assert.equal(mimeTypeFromImagePath("foo.png"), "image/png");
  assert.equal(mimeTypeFromImagePath("foo.JPG"), "image/jpeg");
  assert.equal(mimeTypeFromImagePath("foo.webp"), "image/webp");
});

test("bytesToDataUri encodes bytes as base64 data uri", () => {
  const uri = bytesToDataUri(Uint8Array.from([0x89, 0x50, 0x4e, 0x47]), "image/png");
  assert.match(uri, /^data:image\/png;base64,/);
  assert.ok(uri.endsWith("iVBORw=="));
});

test("buildFalTrellisInput keeps optional fields when provided", () => {
  assert.deepEqual(
    buildFalTrellisInput({
      imageUrl: "data:image/png;base64,AAA",
      seed: 7,
      resolution: 1024,
      meshSimplify: 0.8,
      textureSize: 1024,
      ssGuidanceStrength: 8.5,
      shapeSlatGuidanceStrength: 8.0,
      shapeSlatSamplingSteps: 16,
    }),
    {
      image_url: "data:image/png;base64,AAA",
      seed: 7,
      resolution: 1024,
      mesh_simplify: 0.8,
      texture_size: 1024,
      ss_guidance_strength: 8.5,
      shape_slat_guidance_strength: 8.0,
      shape_slat_sampling_steps: 16,
    },
  );
});

test("applyFalTrellisPreset fills hard-surface defaults", () => {
  assert.deepEqual(
    applyFalTrellisPreset({
      preset: "hard-surface",
      resolution: null,
      textureSize: null,
      ssGuidanceStrength: null,
      shapeSlatGuidanceStrength: null,
      shapeSlatSamplingSteps: null,
      remesh: null,
    }),
    {
      preset: "hard-surface",
      resolution: 1024,
      textureSize: 2048,
      ssGuidanceStrength: 10,
      shapeSlatGuidanceStrength: 10,
      shapeSlatSamplingSteps: 24,
      remesh: true,
    },
  );
});

test("extractFalModelGlbUrl accepts direct and wrapped payloads", () => {
  assert.equal(
    extractFalModelGlbUrl({ model_glb: { url: "https://example.com/a.glb" } }),
    "https://example.com/a.glb",
  );
  assert.equal(
    extractFalModelGlbUrl({ output: { model_glb: { url: "https://example.com/b.glb" } } }),
    "https://example.com/b.glb",
  );
});

test("defaultOutputPathForImage writes into hacknslash generated assets", () => {
  assert.match(
    defaultOutputPathForImage("/tmp/Frog Hero.png"),
    /examples\/hacknslash_3d\/assets\/generated\/frog-hero-trellis\.glb$/,
  );
});

test("defaultPreprocessedPathForImage writes png beside generated assets", () => {
  assert.match(
    defaultPreprocessedPathForImage("/tmp/Frog Hero.png"),
    /examples\/hacknslash_3d\/assets\/generated\/frog-hero-prepped\.png$/,
  );
});

test("toHacknslashQueryAssetPath converts example asset path to query path", () => {
  const out = toHacknslashQueryAssetPath(
    "/repo/examples/hacknslash_3d/assets/generated/frog.glb",
    "/repo",
  );
  assert.equal(out, "./assets/generated/frog.glb");
});

test("parseFalTrellisAssetArgs accepts image path and options", () => {
  assert.deepEqual(
    parseFalTrellisAssetArgs([
      "--image",
      "frog.png",
      "--output",
      "out.glb",
      "--seed",
      "9",
      "--preset",
      "hard-surface",
      "--preprocess",
      "isolate",
      "--mesh-simplify",
      "0.5",
      "--resolution",
      "1024",
      "--texture-size",
      "512",
    ]),
    {
      image: "frog.png",
      imageUrl: "",
      output: "out.glb",
      seed: 9,
      preset: "hard-surface",
      preprocess: "isolate",
      meshSimplify: 0.5,
      resolution: 1024,
      textureSize: 512,
      preprocessPadding: 0.14,
      preprocessSize: 1024,
      pollIntervalMs: 1500,
      ssGuidanceStrength: null,
      shapeSlatGuidanceStrength: null,
      shapeSlatSamplingSteps: null,
      remesh: null,
    },
  );
});
