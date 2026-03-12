import { execFile } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { promisify } from "node:util";
import {
  EXAMPLE_ROOT,
  FAL_TRELLIS_MODEL_ID,
  applyFalTrellisPreset,
  buildFalTrellisInput,
  bytesToDataUri,
  defaultOutputPathForImage,
  defaultPreprocessedPathForImage,
  extractFalModelGlbUrl,
  mimeTypeFromImagePath,
  parseFalTrellisAssetArgs,
  toDemoQueryAssetPath,
} from "./fal_trellis_asset_utils.mjs";

const FAL_QUEUE_BASE = "https://queue.fal.run";
const execFileAsync = promisify(execFile);

function falHeaders() {
  const key = process.env.FAL_KEY || process.env.FAL_API_KEY || process.env.FAL_AI;
  if (!key) {
    throw new Error("FAL_KEY or FAL_API_KEY or FAL_AI is required");
  }
  return {
    Authorization: `Key ${key}`,
    "Content-Type": "application/json",
  };
}

async function postJson(url, body) {
  const response = await fetch(url, {
    method: "POST",
    headers: falHeaders(),
    body: JSON.stringify(body),
  });
  if (!response.ok) {
    throw new Error(`fal submit failed: ${response.status} ${await response.text()}`);
  }
  return response.json();
}

async function getJson(url) {
  const response = await fetch(url, { headers: { Authorization: falHeaders().Authorization } });
  if (!response.ok) {
    throw new Error(`fal poll failed: ${response.status} ${await response.text()}`);
  }
  return response.json();
}

async function sleep(ms) {
  await new Promise((resolvePromise) => setTimeout(resolvePromise, ms));
}

async function getJsonWithRetry(url, maxAttempts = 4) {
  let lastError = null;
  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      return await getJson(url);
    } catch (error) {
      lastError = error;
      if (attempt >= maxAttempts) break;
      console.warn(`[fal] poll retry ${attempt}/${maxAttempts - 1}: ${String(error?.message || error)}`);
      await sleep(1000 * attempt);
    }
  }
  throw lastError;
}

async function resolveImageUrl({ image, imageUrl }) {
  if (imageUrl) return imageUrl;
  const bytes = await readFile(image);
  return bytesToDataUri(bytes, mimeTypeFromImagePath(image));
}

async function preprocessImageIfRequested(args) {
  if (!args.image || !args.preprocess || args.preprocess === "none") {
    return { imagePath: args.image, preprocessedPath: "", preprocessMode: "" };
  }
  const outputPath = defaultPreprocessedPathForImage(args.image);
  await mkdir(dirname(outputPath), { recursive: true });
  await execFileAsync("python3", [
    resolve(import.meta.dirname, "fal_trellis_preprocess.py"),
    "--image",
    args.image,
    "--output",
    outputPath,
    "--mode",
    args.preprocess,
    "--padding",
    String(args.preprocessPadding),
    "--size",
    String(args.preprocessSize),
  ]);
  return { imagePath: outputPath, preprocessedPath: outputPath, preprocessMode: args.preprocess };
}

async function pollFalCompletion(submitResult, pollIntervalMs) {
  const statusUrl =
    submitResult?.status_url ??
    `${FAL_QUEUE_BASE}/${FAL_TRELLIS_MODEL_ID}/requests/${submitResult.request_id}/status`;
  const responseUrl =
    submitResult?.response_url ??
    `${FAL_QUEUE_BASE}/${FAL_TRELLIS_MODEL_ID}/requests/${submitResult.request_id}`;
  let lastStatus = "";
  for (;;) {
    const status = await getJsonWithRetry(statusUrl);
    const state = status?.status ?? status?.state ?? "";
    if (state && state !== lastStatus) {
      console.log(`[fal] status=${state}`);
      lastStatus = state;
    }
    if (state === "COMPLETED") {
      return getJsonWithRetry(responseUrl);
    }
    if (state === "FAILED" || state === "ERROR" || state === "CANCELLED") {
      throw new Error(`fal job failed: ${JSON.stringify(status)}`);
    }
    await sleep(pollIntervalMs);
  }
}

async function downloadGlb(glbUrl, outputPath) {
  const response = await fetch(glbUrl);
  if (!response.ok) {
    throw new Error(`glb download failed: ${response.status} ${await response.text()}`);
  }
  const bytes = new Uint8Array(await response.arrayBuffer());
  await mkdir(dirname(outputPath), { recursive: true });
  await writeFile(outputPath, bytes);
}

async function main() {
  const args = applyFalTrellisPreset(parseFalTrellisAssetArgs(process.argv.slice(2)));
  const prepared = await preprocessImageIfRequested(args);
  const imageUrl = await resolveImageUrl({
    image: prepared.imagePath,
    imageUrl: args.imageUrl,
  });
  const outputPath = resolve(args.output || defaultOutputPathForImage(args.image || "generated.png"));
  const input = buildFalTrellisInput({
    imageUrl,
    seed: args.seed,
    resolution: args.resolution,
    meshSimplify: args.meshSimplify,
    textureSize: args.textureSize,
    ssGuidanceStrength: args.ssGuidanceStrength,
    shapeSlatGuidanceStrength: args.shapeSlatGuidanceStrength,
    shapeSlatSamplingSteps: args.shapeSlatSamplingSteps,
    remesh: args.remesh,
  });

  console.log(`[fal] submit model=${FAL_TRELLIS_MODEL_ID}`);
  const submitResult = await postJson(`${FAL_QUEUE_BASE}/${FAL_TRELLIS_MODEL_ID}`, input);
  const result = await pollFalCompletion(submitResult, args.pollIntervalMs);
  const glbUrl = extractFalModelGlbUrl(result);
  if (!glbUrl) {
    throw new Error(`fal result did not contain model_glb.url: ${JSON.stringify(result)}`);
  }
  await downloadGlb(glbUrl, outputPath);

  const queryAssetPath = toDemoQueryAssetPath(outputPath);
  const sidecarPath = `${outputPath}.json`;
  await writeFile(
    sidecarPath,
    JSON.stringify(
      {
        model: FAL_TRELLIS_MODEL_ID,
        exampleRoot: EXAMPLE_ROOT,
        outputPath,
        queryAssetPath,
        glbUrl,
        input: {
          image: args.image || "",
          preparedImage: prepared.preprocessedPath,
          imageUrl: args.imageUrl || "",
          seed: args.seed,
          preset: args.preset,
          preprocess: prepared.preprocessMode,
          preprocessPadding: args.preprocessPadding,
          preprocessSize: args.preprocessSize,
          meshSimplify: args.meshSimplify,
          resolution: args.resolution,
          textureSize: args.textureSize,
          ssGuidanceStrength: args.ssGuidanceStrength,
          shapeSlatGuidanceStrength: args.shapeSlatGuidanceStrength,
          shapeSlatSamplingSteps: args.shapeSlatSamplingSteps,
          remesh: args.remesh,
        },
      },
      null,
      2,
    ),
  );

  console.log(`[fal] saved ${outputPath}`);
  console.log(`[fal] query path ${queryAssetPath}`);
  console.log(`[fal] demo url http://127.0.0.1:8080/?asset=${encodeURIComponent(queryAssetPath)}`);
}

main().catch((error) => {
  console.error(String(error?.stack || error));
  process.exitCode = 1;
});
