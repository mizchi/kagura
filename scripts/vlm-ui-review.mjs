#!/usr/bin/env node

/**
 * Visual review loop for game UI: render a frame directly, gate it
 * deterministically, then ask a VLM only about what a gate cannot measure.
 *
 *   node scripts/vlm-ui-review.mjs ui_demo --frames 3 --dry-run
 *   OPENROUTER_API_KEY=... node scripts/vlm-ui-review.mjs ui_demo --frames 3
 *
 * No browser and no Playwright are involved: the frame comes from the engine's
 * headless path through the CPU rasterizer, which is also why this runs in CI
 * on Linux where the canvas capture and the Dawn readback both fail.
 *
 * The ordering is the point. `scripts/ui-integrity-gate.mjs` proves text
 * overflow, clipping, off-screen nodes, collisions and hit-box drift from the
 * UI snapshot; those are settled before a model sees anything, and by default a
 * defect there stops the run. What the model is asked is the residue --
 * legibility, contrast, hierarchy, balance -- which no measurement settles.
 */

import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";

import { prepareBundle, renderExampleState } from "./render-frame.mjs";
import { analyzeSnapshot } from "./ui-integrity-utils.mjs";
import {
  buildReviewHeaders,
  buildReviewPrompt,
  buildReviewRequest,
  deterministicVerdict,
  extractStructuredReview,
  formatReviewReport,
  parseVlmkitDiff,
  parseVlmUiReviewArgs,
  resolveReviewApiConfig,
  vlmUiReviewUsage,
} from "./vlm-ui-review-utils.mjs";

const REPO_ROOT = dirname(import.meta.dirname);

async function main(argv) {
  const options = parseVlmUiReviewArgs(argv);
  if (options.help) {
    process.stdout.write(`${vlmUiReviewUsage()}\n`);
    return 0;
  }

  const outDir = options.outDir ?? join(REPO_ROOT, "output", "ui-review", options.example);
  const { bundlePath } = prepareBundle(options.example, { build: options.build });
  const { renderHeadlessFrame } = await import("../lib/web/kagura-headless-frame.js");
  const { frame, meta, written } = await renderExampleState({
    exampleName: options.example,
    bundlePath,
    outDir,
    state: {
      name: options.state,
      frames: options.frames,
      width: options.width,
      height: options.height,
      cursorX: options.cursorX,
      cursorY: options.cursorY,
      keys: options.keys,
    },
    renderHeadlessFrame,
  });

  const snapshot = frame.uiSnapshot;
  const gate = snapshot == null ? null : analyzeSnapshot(snapshot);
  const verdict = deterministicVerdict({ meta, gate });

  const artifacts = Object.fromEntries(
    Object.entries(written).map(([kind, path]) => [kind, relative(REPO_ROOT, path)]),
  );

  const prompt = buildReviewPrompt({
    example: options.example,
    state: options.state,
    meta,
    snapshot,
    verdict,
    notes: options.notes,
  });
  const config = resolveReviewApiConfig({ provider: options.provider, model: options.model });
  const imageDataUrl = `data:image/png;base64,${frame.png.toString("base64")}`;
  const request = buildReviewRequest({ config, prompt, imageDataUrl });

  mkdirSync(outDir, { recursive: true });
  const promptPath = join(outDir, `${options.state}.prompt.md`);
  writeFileSync(promptPath, `${prompt}\n`);
  artifacts.prompt = relative(REPO_ROOT, promptPath);

  const diff = options.compare == null ? null : diffAgainstBaseline({
    baseline: options.compare,
    current: written.png,
    elements: written.elements ?? null,
  });

  let review = null;
  let skipReason = null;
  if (!verdict.ok && !options.forceVlm) {
    skipReason = "the deterministic gate found defects";
  } else if (options.dryRun) {
    skipReason = "--dry-run";
    // The image is megabytes of base64 and adds nothing to a readable bundle;
    // the PNG itself is already written next to it.
    const requestPath = join(outDir, `${options.state}.request.json`);
    writeFileSync(
      requestPath,
      `${JSON.stringify({ ...request, messages: redactImages(request.messages) }, null, 2)}\n`,
    );
    artifacts.request = relative(REPO_ROOT, requestPath);
  } else {
    review = await callReviewApi({ config, request });
    const reviewPath = join(outDir, `${options.state}.review.json`);
    writeFileSync(reviewPath, `${JSON.stringify(review, null, 2)}\n`);
    artifacts.review = relative(REPO_ROOT, reviewPath);
  }

  const report = formatReviewReport({
    example: options.example,
    state: options.state,
    meta,
    verdict,
    review,
    skipReason,
    diff,
    artifacts,
  });
  const reportPath = join(outDir, `${options.state}.report.md`);
  writeFileSync(reportPath, report);
  process.stdout.write(report);
  if (skipReason != null && skipReason !== "--dry-run") {
    process.stdout.write(`\nVLM review skipped: ${skipReason}. Re-run with --force-vlm to override.\n`);
  }
  process.stdout.write(`\nreport: ${relative(REPO_ROOT, reportPath)}\n`);

  // A deterministic defect fails the run; the VLM's judgement never does. A
  // subjective opinion must not be able to break a build.
  return verdict.ok ? 0 : 1;
}

/**
 * Ask vlmkit what changed between the baseline and this frame, and which UI
 * node owns the change. This is the half of the loop that closes a fix: it says
 * whether the edit moved the pixels it was supposed to move.
 */
function diffAgainstBaseline({ baseline, current, elements }) {
  if (!existsSync(baseline)) {
    throw new Error(`baseline frame not found: ${baseline}`);
  }
  const args = ["exec", "vlmkit", "diff", "png", baseline, current];
  if (elements != null) args.push("--elements-json", elements);
  try {
    const stdout = execFileSync("pnpm", args, { cwd: REPO_ROOT, encoding: "utf8" });
    return parseVlmkitDiff(stdout);
  } catch (error) {
    // vlmkit exits non-zero when a diff exceeds its own threshold, and the
    // report is still on stdout -- a difference is the expected outcome here.
    const stdout = error.stdout;
    if (typeof stdout === "string" && stdout.includes("diff:")) return parseVlmkitDiff(stdout);
    throw error;
  }
}

function redactImages(messages) {
  return messages.map((message) => {
    if (!Array.isArray(message.content)) return message;
    return {
      ...message,
      content: message.content.map((part) =>
        part.type === "image_url" ? { type: "image_url", image_url: { url: "<frame png omitted>" } } : part,
      ),
    };
  });
}

async function callReviewApi({ config, request }) {
  const apiKey = process.env[config.apiKeyEnv];
  if (!apiKey) {
    throw new Error(
      `${config.apiKeyEnv} is not set. Use --dry-run to build the request without calling the API.`,
    );
  }
  const response = await fetch(config.apiUrl, {
    method: "POST",
    headers: buildReviewHeaders({ apiKey, provider: config.provider }),
    body: JSON.stringify(request),
  });
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`${config.provider} returned ${response.status}: ${body.slice(0, 400)}`);
  }
  return extractStructuredReview(await response.json());
}

if (process.argv[1] === new URL(import.meta.url).pathname) {
  main(process.argv.slice(2)).then(
    (code) => {
      process.exitCode = code;
    },
    (error) => {
      process.stderr.write(`${error.message}\n`);
      process.exitCode = 1;
    },
  );
}

export { main };
