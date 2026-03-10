#!/usr/bin/env node

import { basename, dirname, extname, join, resolve } from "node:path";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";

import {
  buildStampReviewMarkdown,
  buildStampSyncScaffold,
} from "./model-authoring-vlm-local-feedback-utils.mjs";
import { buildOptInMoonBitPatch } from "./model-authoring-vlm-opt-in-patch-utils.mjs";
import { buildReviewDrivenMoonBitPatch } from "./model-authoring-vlm-review-patch-utils.mjs";
import { enrichStructuredReview } from "./model-authoring-vlm-review-utils.mjs";

function usage() {
  console.error(
    [
      "Usage: node tools/modeling3d/scripts/model-authoring-vlm-local-feedback.mjs \\",
      "  --bundle <vlm_bundle.json> \\",
      "  --parsed <parsed_review.json> \\",
      "  [--out-dir output/playwright/model-authoring-local-feedback]",
    ].join("\n"),
  );
}

function parseArgs(argv) {
  const options = {
    outDir: null,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "--bundle":
        options.bundle = argv[i + 1];
        i += 1;
        break;
      case "--parsed":
        options.parsed = argv[i + 1];
        i += 1;
        break;
      case "--out-dir":
        options.outDir = argv[i + 1];
        i += 1;
        break;
      default:
        throw new Error(`unknown argument: ${arg}`);
    }
  }
  if (!options.bundle || !options.parsed) {
    throw new Error("--bundle and --parsed are required");
  }
  return options;
}

function resolveRequiredFile(pathArg, label) {
  const path = resolve(process.cwd(), pathArg);
  if (!existsSync(path)) {
    throw new Error(`${label} not found: ${path}`);
  }
  return path;
}

function ensureDir(path) {
  mkdirSync(path, { recursive: true });
}

function artifactStem(bundlePath) {
  const name = basename(bundlePath, extname(bundlePath));
  return name.replace(/[^a-zA-Z0-9_-]+/g, "-");
}

function writeJson(path, value) {
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`);
}

try {
  const options = parseArgs(process.argv.slice(2));
  const bundlePath = resolveRequiredFile(options.bundle, "Bundle");
  const parsedPath = resolveRequiredFile(options.parsed, "Parsed review");
  const bundle = JSON.parse(readFileSync(bundlePath, "utf8"));
  const review = enrichStructuredReview(JSON.parse(readFileSync(parsedPath, "utf8")));
  const stem = artifactStem(bundlePath);
  const outDir = resolve(
    process.cwd(),
    options.outDir ?? join(dirname(parsedPath), `${stem}-local-feedback`),
  );
  ensureDir(outDir);

  const reviewPath = join(outDir, `${stem}-local-review.md`);
  const taskQueuePath = join(outDir, `${stem}-task-queue.json`);
  const manualIssuesPath = join(outDir, `${stem}-manual-issues.json`);
  const stampReviewPath = join(outDir, `${stem}-stamp-review.md`);
  const stampScaffoldPath = join(outDir, `${stem}-stamp-sync.mbt`);
  const reviewPatchFilename = `${stem}-review-fixes.mbt`;
  const reviewPatchPath = join(outDir, reviewPatchFilename);
  const patchFilename =
    bundle.patch_payload?.snippet_filename ?? `${stem}-roundtrip-patch.mbt`;
  const patchPath = join(outDir, patchFilename);
  const optInPatchFilename = patchFilename.replace(/\.mbt$/, "-opt-in.mbt");
  const optInPatchPath = join(outDir, optInPatchFilename);
  const patchText =
    bundle.patch_payload?.moonbit_patch ??
    "// No MoonBit patch snippet was present in the bundle.";
  const optInPatchText = buildOptInMoonBitPatch(bundle);
  const reviewPatchText = buildReviewDrivenMoonBitPatch(bundle, review);
  const manualIssues = bundle.patch_payload?.manual_issue_details ?? [];

  writeFileSync(reviewPath, `${review.pr_comment_markdown}\n`);
  writeJson(taskQueuePath, review.source_task_queue);
  writeJson(manualIssuesPath, manualIssues);
  writeFileSync(
    stampReviewPath,
    buildStampReviewMarkdown({
      targetFile: bundle.target_file ?? review.target_file,
      patchPayload: bundle.patch_payload,
      review,
    }),
  );
  writeFileSync(
    stampScaffoldPath,
    buildStampSyncScaffold({
      targetFile: bundle.target_file ?? review.target_file,
      bundle,
    }),
  );
  writeFileSync(patchPath, `${patchText}\n`);
  writeFileSync(optInPatchPath, optInPatchText);
  writeFileSync(reviewPatchPath, reviewPatchText);

  console.log(
    JSON.stringify(
      {
        target_file: bundle.target_file ?? review.target_file,
        out_dir: outDir,
        review_path: reviewPath,
        task_queue_path: taskQueuePath,
        manual_issues_path: manualIssuesPath,
        stamp_review_path: stampReviewPath,
        stamp_scaffold_path: stampScaffoldPath,
        patch_filename: patchFilename,
        patch_path: patchPath,
        review_patch_filename: reviewPatchFilename,
        review_patch_path: reviewPatchPath,
        opt_in_patch_filename: optInPatchFilename,
        opt_in_patch_path: optInPatchPath,
        source_task_report: review.source_task_report,
      },
      null,
      2,
    ),
  );
} catch (error) {
  usage();
  console.error(String(error.message ?? error));
  process.exit(1);
}
