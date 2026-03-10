#!/usr/bin/env node

import { randomUUID } from "node:crypto";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

import {
  buildVlmReviewRequest,
  buildVlmReviewHeaders,
  extractStructuredReview,
  resolveVlmReviewApiConfig,
} from "./model-authoring-vlm-review-utils.mjs";

function usage() {
  console.error(
    [
      "Usage: node tools/modeling3d/scripts/model-authoring-vlm-review.mjs \\",
      "  --screenshot <image.png> \\",
      "  --bundle <vlm_bundle.json> \\",
      "  --prompt <vlm_review.md> \\",
      "  [--provider openai|openrouter] [--preset free|preview|fast|balanced|quality] [--model gpt-5] [--request-out request.json] \\",
      "  [--response-out response.json] [--parsed-out review.json] [--execute]",
    ].join("\n"),
  );
}

function parseArgs(argv) {
  const options = {
    provider: "openai",
    preset: null,
    model: null,
    execute: false,
    requestOut: null,
    responseOut: null,
    parsedOut: null,
    apiUrl: null,
    apiKeyEnv: null,
    screenshots: [],
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "--provider":
        options.provider = argv[i + 1];
        i += 1;
        break;
      case "--screenshot":
        options.screenshots.push(argv[i + 1]);
        i += 1;
        break;
      case "--preset":
        options.preset = argv[i + 1];
        i += 1;
        break;
      case "--bundle":
        options.bundle = argv[i + 1];
        i += 1;
        break;
      case "--prompt":
        options.prompt = argv[i + 1];
        i += 1;
        break;
      case "--model":
        options.model = argv[i + 1];
        i += 1;
        break;
      case "--request-out":
        options.requestOut = argv[i + 1];
        i += 1;
        break;
      case "--response-out":
        options.responseOut = argv[i + 1];
        i += 1;
        break;
      case "--parsed-out":
        options.parsedOut = argv[i + 1];
        i += 1;
        break;
      case "--api-url":
        options.apiUrl = argv[i + 1];
        i += 1;
        break;
      case "--api-key-env":
        options.apiKeyEnv = argv[i + 1];
        i += 1;
        break;
      case "--execute":
        options.execute = true;
        break;
      default:
        throw new Error(`unknown argument: ${arg}`);
    }
  }

  if (options.screenshots.length === 0 || !options.bundle || !options.prompt) {
    throw new Error("screenshot, bundle, and prompt are required");
  }

  return options;
}

function readRequiredFile(pathArg, label) {
  const path = resolve(process.cwd(), pathArg);
  if (!existsSync(path)) {
    throw new Error(`${label} not found: ${path}`);
  }
  return path;
}

function writeJsonIfRequested(pathArg, value) {
  if (pathArg == null) {
    return;
  }
  writeFileSync(resolve(process.cwd(), pathArg), `${JSON.stringify(value, null, 2)}\n`);
}

const args = process.argv.slice(2);
let options;
try {
  options = parseArgs(args);
} catch (error) {
  usage();
  console.error(String(error.message ?? error));
  process.exit(1);
}

const screenshotPaths = options.screenshots.map((pathArg) =>
  readRequiredFile(pathArg, "Screenshot"));
const bundlePath = readRequiredFile(options.bundle, "Bundle JSON");
const promptPath = readRequiredFile(options.prompt, "Review prompt");
const apiConfig = resolveVlmReviewApiConfig({
  provider: options.provider,
  preset: options.preset,
  model: options.model,
  apiUrl: options.apiUrl,
  apiKeyEnv: options.apiKeyEnv,
});

const requestBody = buildVlmReviewRequest({
  provider: apiConfig.provider,
  model: apiConfig.model,
  screenshots: screenshotPaths.map((path, index) => ({
    label: index === 0 ? "angled" : `view_${index + 1}`,
    path,
    bytes: readFileSync(path),
  })),
  bundle: {
    path: bundlePath,
    text: readFileSync(bundlePath, "utf8"),
  },
  prompt: {
    path: promptPath,
    text: readFileSync(promptPath, "utf8"),
  },
});

writeJsonIfRequested(options.requestOut, requestBody);

if (!options.execute) {
  console.log(
    JSON.stringify(
      {
        mode: "dry-run",
        provider: apiConfig.provider,
        preset: apiConfig.preset,
        api_url: apiConfig.apiUrl,
        api_key_env: apiConfig.apiKeyEnv,
        model: apiConfig.model,
        model_candidates: apiConfig.modelCandidates,
        screenshots: screenshotPaths,
        request_out: options.requestOut,
        request: requestBody,
      },
      null,
      2,
    ),
  );
  process.exit(0);
}

const apiKey = process.env[apiConfig.apiKeyEnv];
if (!apiKey) {
  console.error(`${apiConfig.apiKeyEnv} is required when --execute is set`);
  process.exit(1);
}

let selectedModel = null;
let response = null;
let responseJson = null;
let parsedReview = null;
const attemptErrors = [];

for (const candidateModel of apiConfig.modelCandidates) {
  selectedModel = candidateModel;
  const candidateRequestBody = buildVlmReviewRequest({
    provider: apiConfig.provider,
    model: candidateModel,
    screenshots: screenshotPaths.map((path, index) => ({
      label: index === 0 ? "angled" : `view_${index + 1}`,
      path,
      bytes: readFileSync(path),
    })),
    bundle: {
      path: bundlePath,
      text: readFileSync(bundlePath, "utf8"),
    },
    prompt: {
      path: promptPath,
      text: readFileSync(promptPath, "utf8"),
    },
  });
  writeJsonIfRequested(options.requestOut, candidateRequestBody);
  response = await fetch(apiConfig.apiUrl, {
    method: "POST",
    headers: buildVlmReviewHeaders({
      provider: apiConfig.provider,
      apiKey,
      requestId: `kagura-vlm-review-${randomUUID()}`,
    }),
    body: JSON.stringify(candidateRequestBody),
  });
  const responseText = await response.text();
  try {
    responseJson = JSON.parse(responseText);
  } catch {
    responseJson = { error: { message: responseText } };
  }
  if (!response.ok) {
    attemptErrors.push({
      model: candidateModel,
      status: response.status,
      error: responseJson,
    });
    continue;
  }
  try {
    parsedReview = extractStructuredReview(responseJson);
    writeJsonIfRequested(options.responseOut, responseJson);
    break;
  } catch (error) {
    attemptErrors.push({
      model: candidateModel,
      status: response.status,
      error: {
        message: String(error.message ?? error),
      },
      response: responseJson,
    });
    responseJson = null;
    parsedReview = null;
  }
}

if (parsedReview == null || responseJson == null || response == null) {
  console.error(
    JSON.stringify(
      {
        message: "all model candidates failed",
        provider: apiConfig.provider,
        preset: apiConfig.preset,
        model_candidates: apiConfig.modelCandidates,
        attempts: attemptErrors,
      },
      null,
      2,
    ),
  );
  process.exit(1);
}

writeJsonIfRequested(options.parsedOut, parsedReview);

console.log(
  JSON.stringify(
    {
      mode: "execute",
      provider: apiConfig.provider,
      preset: apiConfig.preset,
      api_url: apiConfig.apiUrl,
      api_key_env: apiConfig.apiKeyEnv,
      model: selectedModel,
      model_candidates: apiConfig.modelCandidates,
      request_id: response.headers.get("x-request-id"),
      attempts: attemptErrors,
      source_report: parsedReview?.source_report ?? null,
      source_task_report: parsedReview?.source_task_report ?? null,
      pr_comment: parsedReview?.pr_comment_markdown ?? null,
      parsed_review: parsedReview,
    },
    null,
    2,
  ),
);
