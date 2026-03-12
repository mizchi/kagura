import { basename, extname, resolve, relative } from "node:path";

export const FAL_TRELLIS_MODEL_ID = "fal-ai/trellis-2";
export const EXAMPLE_ROOT = "examples/fal_trellis_demo";
export const EXAMPLE_GENERATED_DIR = `${EXAMPLE_ROOT}/assets/generated`;

const DEFAULT_PREPROCESS_PADDING = 0.14;
const DEFAULT_PREPROCESS_SIZE = 1024;

function defaultGeneratedStem(name) {
  const stem = basename(name, extname(name))
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return stem || "generated";
}

export function mimeTypeFromImagePath(imagePath) {
  const ext = extname(imagePath).toLowerCase();
  switch (ext) {
    case ".png":
      return "image/png";
    case ".jpg":
    case ".jpeg":
      return "image/jpeg";
    case ".webp":
      return "image/webp";
    default:
      throw new Error(`unsupported image extension: ${ext || "<none>"}`);
  }
}

export function bytesToDataUri(bytes, mimeType) {
  return `data:${mimeType};base64,${Buffer.from(bytes).toString("base64")}`;
}

export function buildFalTrellisInput({
  imageUrl,
  seed,
  resolution,
  meshSimplify,
  textureSize,
  ssGuidanceStrength,
  shapeSlatGuidanceStrength,
  shapeSlatSamplingSteps,
  remesh,
}) {
  const input = { image_url: imageUrl };
  if (seed != null) input.seed = seed;
  if (resolution != null) input.resolution = resolution;
  if (meshSimplify != null) input.mesh_simplify = meshSimplify;
  if (textureSize != null) input.texture_size = textureSize;
  if (ssGuidanceStrength != null) input.ss_guidance_strength = ssGuidanceStrength;
  if (shapeSlatGuidanceStrength != null) {
    input.shape_slat_guidance_strength = shapeSlatGuidanceStrength;
  }
  if (shapeSlatSamplingSteps != null) {
    input.shape_slat_sampling_steps = shapeSlatSamplingSteps;
  }
  if (remesh != null) input.remesh = remesh;
  return input;
}

export function extractFalModelGlbUrl(payload) {
  return (
    payload?.model_glb?.url ??
    payload?.output?.model_glb?.url ??
    payload?.outputs?.model_glb?.url ??
    payload?.data?.model_glb?.url ??
    ""
  );
}

export function defaultOutputPathForImage(imagePath) {
  const safeStem = defaultGeneratedStem(imagePath);
  return resolve(EXAMPLE_GENERATED_DIR, `${safeStem}-trellis.glb`);
}

export function defaultPreprocessedPathForImage(imagePath) {
  const safeStem = defaultGeneratedStem(imagePath);
  return resolve(EXAMPLE_GENERATED_DIR, `${safeStem}-prepped.png`);
}

export function toDemoQueryAssetPath(outputPath, cwd = process.cwd()) {
  const rel = relative(resolve(cwd, EXAMPLE_ROOT), resolve(outputPath));
  const normalized = rel.split("\\").join("/");
  if (normalized.startsWith("assets/")) {
    return `./${normalized}`;
  }
  return normalized;
}

export function applyFalTrellisPreset(options) {
  const next = { ...options };
  switch (options.preset) {
    case "":
    case null:
    case undefined:
      return next;
    case "hard-surface":
      if (next.resolution == null) next.resolution = 1024;
      if (next.textureSize == null) next.textureSize = 2048;
      if (next.ssGuidanceStrength == null) next.ssGuidanceStrength = 10;
      if (next.shapeSlatGuidanceStrength == null) next.shapeSlatGuidanceStrength = 10;
      if (next.shapeSlatSamplingSteps == null) next.shapeSlatSamplingSteps = 24;
      if (next.remesh == null) next.remesh = true;
      return next;
    default:
      throw new Error(`unknown trellis preset: ${options.preset}`);
  }
}

function maybeReadValue(argv, index) {
  const next = argv[index + 1];
  if (next == null || next.startsWith("--")) return [null, index];
  return [next, index + 1];
}

function parseOptionalBoolean(value) {
  if (value == null) return true;
  switch (value) {
    case "1":
    case "true":
    case "yes":
    case "on":
      return true;
    case "0":
    case "false":
    case "no":
    case "off":
      return false;
    default:
      throw new Error(`invalid boolean value: ${value}`);
  }
}

export function parseFalTrellisAssetArgs(argv) {
  const out = {
    image: "",
    imageUrl: "",
    output: "",
    seed: null,
    preset: "",
    preprocess: "",
    meshSimplify: null,
    resolution: null,
    textureSize: null,
    preprocessPadding: DEFAULT_PREPROCESS_PADDING,
    preprocessSize: DEFAULT_PREPROCESS_SIZE,
    ssGuidanceStrength: null,
    shapeSlatGuidanceStrength: null,
    shapeSlatSamplingSteps: null,
    remesh: null,
    pollIntervalMs: 1500,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = argv[i + 1];
    switch (arg) {
      case "--image":
        out.image = next ?? "";
        i += 1;
        break;
      case "--image-url":
        out.imageUrl = next ?? "";
        i += 1;
        break;
      case "--output":
        out.output = next ?? "";
        i += 1;
        break;
      case "--seed":
        out.seed = next == null ? null : Number.parseInt(next, 10);
        i += 1;
        break;
      case "--preset":
        out.preset = next ?? "";
        i += 1;
        break;
      case "--preprocess":
        out.preprocess = next ?? "";
        i += 1;
        break;
      case "--mesh-simplify":
        out.meshSimplify = next == null ? null : Number.parseFloat(next);
        i += 1;
        break;
      case "--resolution":
        out.resolution = next == null ? null : Number.parseInt(next, 10);
        i += 1;
        break;
      case "--texture-size":
        out.textureSize = next == null ? null : Number.parseInt(next, 10);
        i += 1;
        break;
      case "--preprocess-padding":
        out.preprocessPadding =
          next == null ? out.preprocessPadding : Number.parseFloat(next);
        i += 1;
        break;
      case "--preprocess-size":
        out.preprocessSize = next == null ? out.preprocessSize : Number.parseInt(next, 10);
        i += 1;
        break;
      case "--ss-guidance-strength":
        out.ssGuidanceStrength = next == null ? null : Number.parseFloat(next);
        i += 1;
        break;
      case "--shape-slat-guidance-strength":
        out.shapeSlatGuidanceStrength = next == null ? null : Number.parseFloat(next);
        i += 1;
        break;
      case "--shape-slat-sampling-steps":
        out.shapeSlatSamplingSteps = next == null ? null : Number.parseInt(next, 10);
        i += 1;
        break;
      case "--remesh": {
        const [value, newIndex] = maybeReadValue(argv, i);
        out.remesh = parseOptionalBoolean(value);
        i = newIndex;
        break;
      }
      case "--poll-interval-ms":
        out.pollIntervalMs = next == null ? out.pollIntervalMs : Number.parseInt(next, 10);
        i += 1;
        break;
      default:
        throw new Error(`unknown arg: ${arg}`);
    }
  }
  if (!out.image && !out.imageUrl) {
    throw new Error("either --image or --image-url is required");
  }
  return out;
}
