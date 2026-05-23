import test from "node:test";
import assert from "node:assert/strict";

import {
  EXAMPLE_GENERATED_DIR,
  FAL_TRELLIS_MODEL_ID,
  applyFalTrellisPreset,
  buildFalTrellisInput,
  defaultOutputPathForImage,
  parseFalTrellisAssetArgs,
  toDemoQueryAssetPath,
} from "./fal_trellis_asset_utils.mjs";

test("exports the expected model id", () => {
  assert.equal(FAL_TRELLIS_MODEL_ID, "fal-ai/trellis-2");
});

test("parseFalTrellisAssetArgs requires either image or image-url", () => {
  assert.throws(() => parseFalTrellisAssetArgs([]), /either --image or --image-url is required/);
});

test("parseFalTrellisAssetArgs parses image, preset, preprocess and remesh", () => {
  const args = parseFalTrellisAssetArgs([
    "--image",
    "assets/input.png",
    "--preset",
    "hard-surface",
    "--preprocess",
    "isolate",
    "--remesh",
    "false",
  ]);
  assert.equal(args.image, "assets/input.png");
  assert.equal(args.preset, "hard-surface");
  assert.equal(args.preprocess, "isolate");
  assert.equal(args.remesh, false);
});

test("applyFalTrellisPreset fills hard-surface defaults", () => {
  const args = applyFalTrellisPreset({
    image: "assets/input.png",
    imageUrl: "",
    output: "",
    seed: null,
    preset: "hard-surface",
    preprocess: "",
    meshSimplify: null,
    resolution: null,
    textureSize: null,
    preprocessPadding: 0.14,
    preprocessSize: 1024,
    ssGuidanceStrength: null,
    shapeSlatGuidanceStrength: null,
    shapeSlatSamplingSteps: null,
    remesh: null,
    pollIntervalMs: 1500,
  });
  assert.equal(args.resolution, 1024);
  assert.equal(args.textureSize, 2048);
  assert.equal(args.remesh, true);
});

test("buildFalTrellisInput only keeps provided fields", () => {
  const input = buildFalTrellisInput({
    imageUrl: "data:image/png;base64,AAA=",
    seed: 42,
    resolution: 1024,
    meshSimplify: null,
    textureSize: 2048,
    ssGuidanceStrength: null,
    shapeSlatGuidanceStrength: 10,
    shapeSlatSamplingSteps: null,
    remesh: true,
  });
  assert.deepEqual(input, {
    image_url: "data:image/png;base64,AAA=",
    seed: 42,
    resolution: 1024,
    texture_size: 2048,
    shape_slat_guidance_strength: 10,
    remesh: true,
  });
});

test("defaultOutputPathForImage resolves into the demo generated dir", () => {
  const output = defaultOutputPathForImage("examples/fal_trellis_demo/assets/fal_samples/chest-open.png");
  assert.match(output, new RegExp(`${EXAMPLE_GENERATED_DIR.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}.+chest-open-trellis\\.glb$`));
});

test("toDemoQueryAssetPath rewrites generated paths into local demo asset paths", () => {
  const queryPath = toDemoQueryAssetPath(
    "/tmp/repo/examples/fal_trellis_demo/assets/generated/chest-open-trellis.glb",
    "/tmp/repo",
  );
  assert.equal(queryPath, "./assets/generated/chest-open-trellis.glb");
});
