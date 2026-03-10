#!/usr/bin/env node

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { spawnSync } from "node:child_process";

import {
  buildRendererParityArtifacts,
  summarizeRendererParity,
} from "./model-authoring-renderer-parity-utils.mjs";

function usage() {
  console.error(
    [
      "Usage: node tools/modeling3d/scripts/model-authoring-renderer-parity.mjs \\",
      "  [--example model_authoring|chair_authoring|shelf_authoring|frog_authoring] \\",
      "  [--provider openrouter|openai] [--port 8210] [--out-dir output/playwright/<example>-renderer-parity] \\",
      "  [--silhouette-threshold 0.2] [--visual-threshold 20]",
    ].join("\n"),
  );
}

function parseArgs(argv) {
  const options = {
    example: "frog_authoring",
    provider: "openrouter",
    port: 8210,
    outDir: null,
    silhouetteThreshold: 0.2,
    visualThreshold: 20,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "--example":
        options.example = argv[i + 1];
        i += 1;
        break;
      case "--provider":
        options.provider = argv[i + 1];
        i += 1;
        break;
      case "--port":
        options.port = Number(argv[i + 1]);
        i += 1;
        break;
      case "--out-dir":
        options.outDir = argv[i + 1];
        i += 1;
        break;
      case "--silhouette-threshold":
        options.silhouetteThreshold = Number(argv[i + 1]);
        i += 1;
        break;
      case "--visual-threshold":
        options.visualThreshold = Number(argv[i + 1]);
        i += 1;
        break;
      default:
        throw new Error(`unknown argument: ${arg}`);
    }
  }
  return options;
}

function runNodeScript(scriptPath, args, cwd) {
  const result = spawnSync(process.execPath, [resolve(cwd, scriptPath), ...args], {
    cwd,
    encoding: "utf8",
  });
  if (result.status !== 0) {
    throw new Error(result.stderr || result.stdout || `${scriptPath} failed`);
  }
  return JSON.parse(result.stdout);
}

function compareScreenshotsWithPillow({
  webPath,
  nativePath,
  rebinarizeThreshold = null,
}) {
  const python = `
import json
import sys
from PIL import Image

web = Image.open(sys.argv[1]).convert("RGBA")
native = Image.open(sys.argv[2]).convert("RGBA")

def rebinarize(image, threshold):
    data = []
    for r, g, b, a in image.getdata():
        lum = 0.299 * r + 0.587 * g + 0.114 * b
        v = 255 if lum >= threshold else 0
        data.append((v, v, v, 255))
    image.putdata(data)
    return image

threshold_arg = sys.argv[3]
if threshold_arg != "none":
    web = rebinarize(web, int(threshold_arg))
    native = rebinarize(native, int(threshold_arg))
native = native.resize(web.size, Image.Resampling.NEAREST)
web_pixels = web.load()
native_pixels = native.load()
total = web.size[0] * web.size[1]
different = 0
sum_abs_rgb = 0
for y in range(web.size[1]):
    for x in range(web.size[0]):
        wr, wg, wb, wa = web_pixels[x, y]
        nr, ng, nb, na = native_pixels[x, y]
        sum_abs_rgb += abs(wr - nr) + abs(wg - ng) + abs(wb - nb)
        if (wr, wg, wb, wa) != (nr, ng, nb, na):
            different += 1
print(json.dumps({
    "web_size": [web.size[0], web.size[1]],
    "native_size": [native.size[0], native.size[1]],
    "different_pixels": different,
    "total_pixels": total,
    "diff_ratio": different / total,
    "mean_abs_rgb_diff": sum_abs_rgb / (total * 3),
}))
`;
  const result = spawnSync(
    "python3",
    ["-c", python, webPath, nativePath, rebinarizeThreshold == null ? "none" : String(rebinarizeThreshold)],
    { encoding: "utf8" },
  );
  if (result.status !== 0) {
    throw new Error(result.stderr || result.stdout || "python screenshot diff failed");
  }
  return JSON.parse(result.stdout);
}

function main() {
  let options;
  try {
    options = parseArgs(process.argv.slice(2));
  } catch (error) {
    console.error(String(error.message ?? error));
    usage();
    process.exit(1);
  }

  const cwd = process.cwd();
  const artifacts = buildRendererParityArtifacts({
    cwd,
    outDir: options.outDir,
    example: options.example,
  });
  mkdirSync(artifacts.rootDir, { recursive: true });

  const commonArgs = [
    "--example",
    options.example,
    "--live-review",
    "--provider",
    options.provider,
  ];

  const webPlainResult = runNodeScript(
    "tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs",
    [
      ...commonArgs,
      "--serve",
      "--port",
      String(options.port),
      "--out-dir",
      artifacts.webDir,
    ],
    cwd,
  );
  const nativePlainResult = runNodeScript(
    "tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs",
    [
      ...commonArgs,
      "--renderer",
      "native",
      "--out-dir",
      artifacts.nativeDir,
    ],
    cwd,
  );
  const webBinarizedResult = runNodeScript(
    "tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs",
    [
      ...commonArgs,
      "--serve",
      "--port",
      String(options.port + 1),
      "--out-dir",
      artifacts.webBinarizedDir,
      "--binarize-review",
    ],
    cwd,
  );
  const nativeBinarizedResult = runNodeScript(
    "tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs",
    [
      ...commonArgs,
      "--renderer",
      "native",
      "--out-dir",
      artifacts.nativeBinarizedDir,
      "--binarize-review",
    ],
    cwd,
  );

  const webBundle = JSON.parse(readFileSync(webPlainResult.bundle, "utf8"));
  const nativeBundle = JSON.parse(readFileSync(nativePlainResult.bundle, "utf8"));
  const silhouetteDiff = compareScreenshotsWithPillow({
    webPath: webBinarizedResult.screenshot,
    nativePath: nativeBinarizedResult.screenshot,
    rebinarizeThreshold: 120,
  });
  const visualDiff = compareScreenshotsWithPillow({
    webPath: webPlainResult.screenshot,
    nativePath: nativePlainResult.screenshot,
  });

  const sameCurrentDocument =
    JSON.stringify(webBundle.current_document) ===
    JSON.stringify(nativeBundle.current_document);
  const sameSummary =
    String(webBundle.workbench_summary ?? "") ===
    String(nativeBundle.workbench_summary ?? "");
  const summary = summarizeRendererParity({
    sameCurrentDocument,
    sameSummary,
    silhouetteDiffRatio: silhouetteDiff.diff_ratio,
    silhouetteDiffThreshold: options.silhouetteThreshold,
    visualMeanAbsRgbDiff: visualDiff.mean_abs_rgb_diff,
    visualMeanAbsRgbThreshold: options.visualThreshold,
  });

  const report = {
    ok: summary.ok,
    silhouette_ok: summary.silhouetteOk,
    visual_ok: summary.visualOk,
    example: options.example,
    provider: options.provider,
    silhouette_threshold: options.silhouetteThreshold,
    visual_threshold: options.visualThreshold,
    web: webPlainResult,
    native: nativePlainResult,
    web_binarized: webBinarizedResult,
    native_binarized: nativeBinarizedResult,
    same_current_document: sameCurrentDocument,
    same_summary: sameSummary,
    silhouette_diff: silhouetteDiff,
    visual_diff: visualDiff,
    issues: summary.issues,
    visual_issues: summary.visualIssues,
  };
  writeFileSync(artifacts.reportPath, JSON.stringify(report, null, 2));
  console.log(JSON.stringify(report, null, 2));
  if (!summary.ok) {
    process.exit(1);
  }
}

main();
