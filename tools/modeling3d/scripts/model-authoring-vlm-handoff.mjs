#!/usr/bin/env node

import { mkdirSync, writeFileSync, existsSync, readFileSync } from "node:fs";
import { basename, dirname, resolve } from "node:path";
import { spawn, spawnSync } from "node:child_process";
import { createServer } from "node:net";
import { createInterface } from "node:readline/promises";
import { stdin, stderr } from "node:process";

import {
  buildLiveReviewBundle,
  buildLiveReviewPrompt,
  buildModelAuthoringVlmHandoffPlan,
  computeRelativeViewDrag,
  decodeBrowserBinaryAsset,
  resolveDownloadTargetPath,
} from "./model-authoring-vlm-handoff-utils.mjs";
import {
  buildNativeCaptureConfig,
  resolveNativeCaptureStagePath,
  resolveNativeExampleDir,
} from "./model-authoring-native-capture-utils.mjs";
import {
  buildVlmReviewRequest,
  buildVlmReviewHeaders,
  extractStructuredReview,
} from "./model-authoring-vlm-review-utils.mjs";
import {
  buildDaemonCyclePlan,
  parseVlmDaemonCommand,
} from "./model-authoring-vlm-daemon-utils.mjs";

const MODULE_READY_AT_MS = Date.now();

function usage() {
  console.error(
    [
      "Usage: node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs \\",
      "  (--live-review | --import-glb <edited.glb> | --edit-profile <profile>) \\",
      "  [--example model_authoring|chair_authoring|shelf_authoring|frog_authoring] \\",
      "  [--serve] [--port 8113] [--url http://127.0.0.1:8113/] \\",
      "  [--out-dir output/playwright/<example>-handoff] \\",
      "  [--screenshot-out capture.png] [--bundle-out review_bundle.json] \\",
      "  [--prompt-out review_prompt.md] [--request-out request.json] \\",
      "  [--response-out response.json] [--parsed-out parsed.json] \\",
      "  [--provider openai|openrouter] [--preset free|preview|fast|balanced|quality] [--model gpt-5] [--renderer web|native] [--execute] [--headed] [--interactive] [--cycles 1] [--binarize-review] [--timeout-ms 30000]",
      "  [--daemon] [--daemon-host 127.0.0.1] [--daemon-port 9123]",
    ].join("\n"),
  );
}

function parseArgs(argv) {
  const options = {};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "--import-glb":
        options.importGlb = argv[i + 1];
        i += 1;
        break;
      case "--edit-profile":
        options.editProfile = argv[i + 1];
        i += 1;
        break;
      case "--example":
        options.example = argv[i + 1];
        i += 1;
        break;
      case "--live-review":
        options.liveReview = true;
        break;
      case "--serve":
        options.serve = true;
        break;
      case "--port":
        options.port = Number(argv[i + 1]);
        i += 1;
        break;
      case "--url":
        options.url = argv[i + 1];
        i += 1;
        break;
      case "--out-dir":
        options.outDir = argv[i + 1];
        i += 1;
        break;
      case "--screenshot-out":
        options.screenshotOut = argv[i + 1];
        i += 1;
        break;
      case "--bundle-out":
        options.bundleOut = argv[i + 1];
        i += 1;
        break;
      case "--prompt-out":
        options.promptOut = argv[i + 1];
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
      case "--provider":
        options.provider = argv[i + 1];
        i += 1;
        break;
      case "--renderer":
        options.renderer = argv[i + 1];
        i += 1;
        break;
      case "--preset":
        options.preset = argv[i + 1];
        i += 1;
        break;
      case "--model":
        options.model = argv[i + 1];
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
      case "--headed":
        options.headed = true;
        break;
      case "--interactive":
        options.interactive = true;
        break;
      case "--daemon":
        options.daemon = true;
        break;
      case "--daemon-host":
        options.daemonHost = argv[i + 1];
        i += 1;
        break;
      case "--daemon-port":
        options.daemonPort = Number(argv[i + 1]);
        i += 1;
        break;
      case "--cycles":
        options.cycles = Number(argv[i + 1]);
        i += 1;
        break;
      case "--binarize-review":
        options.reviewBinarize = true;
        break;
      case "--timeout-ms":
        options.timeoutMs = Number(argv[i + 1]);
        i += 1;
        break;
      default:
        throw new Error(`unknown argument: ${arg}`);
    }
  }
  return options;
}

async function waitForHttp(url, timeoutMs) {
  const deadline = Date.now() + timeoutMs;
  let lastError = null;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(url, { method: "GET" });
      if (response.ok) {
        return;
      }
      lastError = new Error(`HTTP ${response.status}`);
    } catch (error) {
      lastError = error;
    }
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 250));
  }
  throw new Error(`timed out waiting for ${url}: ${String(lastError?.message ?? lastError)}`);
}

function ensureParentDir(path) {
  mkdirSync(dirname(path), { recursive: true });
}

function runNodeScript(scriptPath, args) {
  const result = spawnSync(process.execPath, [resolve(process.cwd(), scriptPath), ...args], {
    encoding: "utf8",
  });
  if (result.status !== 0) {
    throw new Error(result.stderr || result.stdout || `${scriptPath} failed`);
  }
  return result.stdout;
}

function resolveNativeMoonEnv() {
  const nextEnv = { ...process.env };
  const brewPrefixResult = spawnSync("brew", ["--prefix"], {
    encoding: "utf8",
  });
  const brewPrefix =
    brewPrefixResult.status === 0 ? brewPrefixResult.stdout.trim() : "";
  const glfwPrefixResult = spawnSync("brew", ["--prefix", "glfw"], {
    encoding: "utf8",
  });
  const glfwPrefix =
    glfwPrefixResult.status === 0 ? glfwPrefixResult.stdout.trim() : "";
  if (glfwPrefix.length > 0) {
    const includeDir = `${glfwPrefix}/include`;
    nextEnv.CPATH = nextEnv.CPATH ? `${includeDir}:${nextEnv.CPATH}` : includeDir;
  }
  if (brewPrefix.length > 0) {
    const libDir = `${brewPrefix}/lib`;
    nextEnv.LIBRARY_PATH = nextEnv.LIBRARY_PATH
      ? `${libDir}:${nextEnv.LIBRARY_PATH}`
      : libDir;
  }
  return nextEnv;
}

function logStep(message) {
  console.error(`[handoff] ${message}`);
}

function nowMs() {
  return Date.now();
}

async function loadChromium() {
  const playwright = await import("@playwright/test");
  return playwright.chromium;
}

async function readReviewAssets(page, timeoutMs) {
  await page.waitForFunction(
    () => {
      const assets = globalThis.__kaguraModelingReviewAssets;
      return Boolean(
        assets?.bundle?.filename &&
          assets?.bundle?.text &&
          assets?.prompt?.filename &&
          assets?.prompt?.text,
      );
    },
    { timeout: timeoutMs },
  );
  return page.evaluate(() => globalThis.__kaguraModelingReviewAssets);
}

async function readModelingContext(page, timeoutMs) {
  await page.waitForFunction(
    () => Boolean(globalThis.__kaguraModelingContext?.json),
    { timeout: timeoutMs },
  );
  return page.evaluate(() => globalThis.__kaguraModelingContext);
}

function writeReviewAssetFile(targetPath, text) {
  ensureParentDir(targetPath);
  writeFileSync(targetPath, text);
}

async function exportSourceGlb(page, targetPath) {
  await focusCanvas(page);
  await page.evaluate(() => {
    globalThis.__kaguraModelingExport = null;
    globalThis.__kaguraAutomation = {
      ...(globalThis.__kaguraAutomation ?? {}),
      disableDownloads: true,
    };
  });
  await dispatchSyntheticKey(page, "g");
  await page.waitForFunction(
    () =>
      Boolean(
        globalThis.__kaguraModelingExport?.filename &&
          globalThis.__kaguraModelingExport?.bytesBase64,
      ),
    { timeout: 30_000 },
  );
  const exported = await page.evaluate(() => globalThis.__kaguraModelingExport);
  ensureParentDir(targetPath);
  writeFileSync(targetPath, decodeBrowserBinaryAsset(exported));
  await page.evaluate(() => {
    if (globalThis.__kaguraAutomation != null) {
      globalThis.__kaguraAutomation.disableDownloads = false;
    }
  });
  return targetPath;
}

async function focusCanvas(page) {
  const canvas = await page.waitForSelector("canvas");
  const box = await canvas.boundingBox();
  if (box == null) {
    throw new Error("canvas bounding box is not available");
  }
  await page.mouse.click(
    box.x + box.width / 2,
    box.y + box.height / 2,
  );
}

async function dispatchSyntheticKey(page, keyName) {
  const upper = keyName.toUpperCase();
  const keyCode = upper.charCodeAt(0);
  const code = `Key${upper}`;
  const dispatch = async (type) => {
    await page.evaluate(
      ({ eventType, key, code: keyboardCode, keyCode: currentKeyCode }) => {
        const event = new KeyboardEvent(eventType, {
          key,
          code: keyboardCode,
          bubbles: true,
        });
        Object.defineProperty(event, "keyCode", {
          get: () => currentKeyCode,
        });
        Object.defineProperty(event, "which", {
          get: () => currentKeyCode,
        });
        window.dispatchEvent(event);
        document.dispatchEvent(event);
      },
      { eventType: type, key: upper, code, keyCode },
    );
  };
  await dispatch("keydown");
  await page.waitForTimeout(80);
  await dispatch("keyup");
  await page.waitForTimeout(80);
}

async function importGlb(page, glbPath, timeoutMs) {
  await focusCanvas(page);
  const filename = basename(glbPath);
  const bytesBase64 = readFileSync(glbPath).toString("base64");
  await page.waitForFunction(
    () => typeof globalThis.__kaguraModelingImport?.load === "function",
    { timeout: timeoutMs },
  );
  await page.evaluate(
    ({ currentFilename, currentBytesBase64 }) => {
      globalThis.__kaguraModelingImport.load(
        currentFilename,
        currentBytesBase64,
      );
    },
    {
      currentFilename: filename,
      currentBytesBase64: bytesBase64,
    },
  );
  await page.waitForFunction(
    () => {
      const patch = globalThis.__kaguraModelingPatch?.parsed;
      return Boolean(patch?.review_filename);
    },
    { timeout: timeoutMs },
  );
}

async function openModelingPage(browser, url, timeoutMs) {
  const page = await browser.newPage();
  await resetModelingPage(page, url, timeoutMs);
  return page;
}

async function resetModelingPage(page, url, timeoutMs) {
  await page.goto(url, { waitUntil: "load" });
  await page.waitForSelector("canvas", { timeout: timeoutMs });
  await page.waitForFunction(
    () => Boolean(globalThis.__kaguraModelingContext?.parsed),
    { timeout: timeoutMs },
  );
  await focusCanvas(page);
  return page;
}

async function orbitCameraByDrag(page, dx, dy) {
  await focusCanvas(page);
  const canvas = await page.waitForSelector("canvas");
  const box = await canvas.boundingBox();
  if (box == null) {
    throw new Error("canvas bounding box is not available");
  }
  const startX = box.x + box.width * 0.5;
  const startY = box.y + box.height * 0.5;
  await page.mouse.move(startX, startY);
  await page.mouse.down();
  await page.mouse.move(startX + dx, startY + dy, { steps: 24 });
  await page.waitForTimeout(120);
  await page.mouse.up();
  await page.waitForTimeout(180);
}

async function applyViewOrientation(page, currentOrientation, label) {
  const transition = computeRelativeViewDrag(currentOrientation, label);
  if (transition.drag.dx !== 0 || transition.drag.dy !== 0) {
    await orbitCameraByDrag(page, transition.drag.dx, transition.drag.dy);
  }
  return transition.next;
}

async function captureCanvasScreenshot(page, targetPath) {
  ensureParentDir(targetPath);
  const canvas = await page.waitForSelector("canvas");
  await canvas.screenshot({ path: targetPath });
}

async function captureScreenshotViews({
  captureSession,
  screenshotViews,
  reviewBinarize,
}) {
  const { page } = captureSession;
  const labels = screenshotViews.map((view) => view.label);
  const targetPath = screenshotViews[0].path;
  logStep(
    `capturing ${reviewBinarize ? "binarized " : ""}atlas view to ${targetPath}`,
  );
  await page.waitForFunction(
    () =>
      typeof globalThis.__kaguraModelingCamera?.beginCapture === "function" &&
      typeof globalThis.__kaguraModelingCamera?.setPreset === "function" &&
      typeof globalThis.__kaguraModelingCamera?.endCapture === "function",
    { timeout: 30_000 },
  );
  const captureResult = await page.evaluate(
    async ({ currentLabels, binarize }) => {
      const now = () => performance.now();
      const controller = globalThis.__kaguraModelingCamera;
      const sourceCanvas = document.querySelector("canvas");
      if (controller == null || sourceCanvas == null) {
        throw new Error("camera controller or source canvas is not ready");
      }
      const totalStartedAt = now();
      const waitFrames = (count = 2) =>
        new Promise((resolve) => {
          const step = (remaining) => {
            requestAnimationFrame(() => {
              if (remaining <= 1) {
                resolve();
              } else {
                step(remaining - 1);
              }
            });
          };
          step(count);
        });
      const metrics = {
        wait_for_frames_ms: 0,
        preset_capture_ms: 0,
        atlas_draw_ms: 0,
        binarize_ms: 0,
        encode_ms: 0,
        total_ms: 0,
      };
      const tileWidth = Math.max(1, Math.floor(sourceCanvas.width * 0.5));
      const tileHeight = Math.max(1, Math.floor(sourceCanvas.height * 0.5));
      const atlasCanvas = document.createElement("canvas");
      atlasCanvas.width = tileWidth * 2;
      atlasCanvas.height = tileHeight * 2;
      const atlasCtx = atlasCanvas.getContext("2d");
      atlasCtx.fillStyle = binarize ? "#ffffff" : "#000000";
      atlasCtx.fillRect(0, 0, atlasCanvas.width, atlasCanvas.height);
      const binarizeCanvas = (canvas) => {
        const ctx = canvas.getContext("2d");
        const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
        const data = imageData.data;
        for (let i = 0; i < data.length; i += 4) {
          const luminance =
            data[i] * 0.299 +
            data[i + 1] * 0.587 +
            data[i + 2] * 0.114;
          const value = luminance >= 120 ? 255 : 0;
          data[i] = value;
          data[i + 1] = value;
          data[i + 2] = value;
          data[i + 3] = 255;
        }
        ctx.putImageData(imageData, 0, 0);
      };
      controller.beginCapture();
      try {
        for (let index = 0; index < currentLabels.length; index += 1) {
          const label = currentLabels[index];
          const presetStartedAt = now();
          controller.setPreset(label);
          const waitStartedAt = now();
          await waitFrames(3);
          metrics.wait_for_frames_ms += now() - waitStartedAt;
          const drawStartedAt = now();
          const x = (index % 2) * tileWidth;
          const y = Math.floor(index / 2) * tileHeight;
          atlasCtx.drawImage(sourceCanvas, x, y, tileWidth, tileHeight);
          metrics.atlas_draw_ms += now() - drawStartedAt;
          metrics.preset_capture_ms += now() - presetStartedAt;
        }
      } finally {
        controller.endCapture();
      }
      if (binarize) {
        const binarizeStartedAt = now();
        binarizeCanvas(atlasCanvas);
        metrics.binarize_ms = now() - binarizeStartedAt;
      }
      const encodeStartedAt = now();
      const pngBase64 = atlasCanvas.toDataURL("image/png").split(",")[1];
      metrics.encode_ms = now() - encodeStartedAt;
      metrics.tile_width = tileWidth;
      metrics.tile_height = tileHeight;
      metrics.atlas_width = atlasCanvas.width;
      metrics.atlas_height = atlasCanvas.height;
      metrics.tile_count = currentLabels.length;
      metrics.total_ms = now() - totalStartedAt;
      return {
        pngBase64,
        metrics,
      };
    },
    {
      currentLabels: labels,
      binarize: reviewBinarize,
    },
  );
  ensureParentDir(targetPath);
  writeFileSync(targetPath, Buffer.from(captureResult.pngBase64, "base64"));
  return {
    screenshots: [
      {
        label: `atlas:${labels.join(",")}`,
        path: targetPath,
        bytes: readFileSync(targetPath),
      },
    ],
    metrics: captureResult.metrics,
  };
}

async function finalizeReviewArtifacts({
  plan,
  cycle,
  importGlbPath,
  bundlePath,
  bundleText,
  promptPath,
  promptText,
  screenshots,
  timings,
  captureMetrics,
}) {
  logStep(`writing request JSON to ${plan.requestPath}`);
  const requestBody = buildVlmReviewRequest({
    provider: plan.provider,
    model: plan.model,
    screenshots,
    bundle: {
      path: bundlePath,
      text: bundleText,
    },
    prompt: {
      path: promptPath,
      text: promptText,
    },
  });
  writeFileSync(plan.requestPath, `${JSON.stringify(requestBody, null, 2)}\n`);

  let responseJson = null;
  let parsedReview = null;
  let selectedModel = plan.model;
  const attemptErrors = [];
  if (plan.execute) {
    logStep(`executing ${plan.provider} API request`);
    for (const candidateModel of plan.modelCandidates) {
      selectedModel = candidateModel;
      const candidateRequestBody = buildVlmReviewRequest({
        provider: plan.provider,
        model: candidateModel,
        screenshots,
        bundle: {
          path: bundlePath,
          text: bundleText,
        },
        prompt: {
          path: promptPath,
          text: promptText,
        },
      });
      writeFileSync(plan.requestPath, `${JSON.stringify(candidateRequestBody, null, 2)}\n`);
      const response = await fetch(plan.apiUrl, {
        method: "POST",
        headers: buildVlmReviewHeaders({
          provider: plan.provider,
          apiKey: process.env[plan.apiKeyEnv],
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
        writeFileSync(plan.responsePath, `${JSON.stringify(responseJson, null, 2)}\n`);
        break;
      } catch (error) {
        attemptErrors.push({
          model: candidateModel,
          status: response.status,
          error: { message: String(error.message ?? error) },
          response: responseJson,
        });
        responseJson = null;
        parsedReview = null;
      }
    }
    if (parsedReview == null || responseJson == null) {
      throw new Error(
        JSON.stringify(
          {
            message: "all model candidates failed",
            provider: plan.provider,
            preset: plan.preset,
            model_candidates: plan.modelCandidates,
            attempts: attemptErrors,
          },
          null,
          2,
        ),
      );
    }
    writeFileSync(plan.parsedPath, `${JSON.stringify(parsedReview, null, 2)}\n`);
  }

  return {
    mode: plan.execute ? "execute" : "dry-run",
    renderer: plan.renderer,
    provider: plan.provider,
    example: plan.example,
    cycle,
    interactive: plan.interactive,
    preset: plan.preset,
    api_url: plan.apiUrl,
    api_key_env: plan.apiKeyEnv,
    model: selectedModel,
    model_candidates: plan.modelCandidates,
    url: plan.url,
    import_glb: importGlbPath,
    edit_profile: plan.editProfile,
    review_mode: plan.reviewMode,
    screenshot: plan.screenshotPath,
    screenshots: screenshots.map((item) => ({
      label: item.label,
      path: item.path,
    })),
    bundle: bundlePath,
    prompt: promptPath,
    request: plan.requestPath,
    response: plan.execute ? plan.responsePath : null,
    parsed: plan.execute ? plan.parsedPath : null,
    attempts: attemptErrors,
    source_report: parsedReview?.source_report ?? null,
    source_task_report: parsedReview?.source_task_report ?? null,
    pr_comment: parsedReview?.pr_comment_markdown ?? null,
    parsed_review: parsedReview,
    capture_page_mode: plan.capturePageMode,
    timings: timings ?? {},
    capture_metrics: captureMetrics ?? null,
  };
}

async function runNativeLiveReview(plan) {
  const startedAt = nowMs();
  const configText = buildNativeCaptureConfig({
    screenshotPath: plan.screenshotPath,
    contextPath: plan.nativeContextPath,
    summaryPath: plan.nativeSummaryPath,
    binarize: plan.reviewBinarize,
  });
  writeFileSync(plan.nativeConfigPath, configText);
  const exampleDir = resolveNativeExampleDir({
    cwd: process.cwd(),
    example: plan.example,
  });
  const stageConfigPath = resolveNativeCaptureStagePath({
    cwd: process.cwd(),
    example: plan.example,
  });
  logStep(`staging native capture config at ${stageConfigPath}`);
  writeFileSync(stageConfigPath, configText);
  try {
    const nativeCaptureStartedAt = nowMs();
    logStep(`running native capture for ${plan.example}`);
    const result = spawnSync(
      "moon",
      ["-C", exampleDir, "run", "src/main_native.mbt", "--target", "native"],
      {
        cwd: process.cwd(),
        env: resolveNativeMoonEnv(),
        encoding: "utf8",
      },
    );
    if (result.status !== 0) {
      throw new Error(result.stderr || result.stdout || "native capture failed");
    }
    if (!existsSync(plan.screenshotPath)) {
      throw new Error(`native screenshot was not written: ${plan.screenshotPath}`);
    }
    if (!existsSync(plan.nativeContextPath)) {
      throw new Error(`native context was not written: ${plan.nativeContextPath}`);
    }
    if (!existsSync(plan.nativeSummaryPath)) {
      throw new Error(`native summary was not written: ${plan.nativeSummaryPath}`);
    }
    const contextJson = readFileSync(plan.nativeContextPath, "utf8");
    const summary = readFileSync(plan.nativeSummaryPath, "utf8");
    const bundleStartedAt = nowMs();
    const bundlePath = resolveDownloadTargetPath({
      outDir: plan.outDir,
      explicitPath: plan.bundlePath,
      suggestedFilename: `${plan.artifactStem}-vlm-bundle.json`,
    });
    const promptPath = resolveDownloadTargetPath({
      outDir: plan.outDir,
      explicitPath: plan.promptPath,
      suggestedFilename: `${plan.artifactStem}-vlm-review.md`,
    });
    const bundleText = buildLiveReviewBundle({
      example: plan.example,
      contextJson,
      summary,
    });
    const promptText = buildLiveReviewPrompt({
      example: plan.example,
      contextJson,
      summary,
    });
    writeReviewAssetFile(bundlePath, bundleText);
    writeReviewAssetFile(promptPath, promptText);
    const finalizeStartedAt = nowMs();
    return finalizeReviewArtifacts({
      plan,
      cycle: 1,
      importGlbPath: null,
      bundlePath,
      bundleText,
      promptPath,
      promptText,
      screenshots: [
        {
          label: "atlas:angled,front,side,top",
          path: plan.screenshotPath,
          bytes: readFileSync(plan.screenshotPath),
        },
      ],
      timings: {
        native_capture_ms: bundleStartedAt - nativeCaptureStartedAt,
        bundle_prompt_ms: finalizeStartedAt - bundleStartedAt,
        finalize_ms: nowMs() - finalizeStartedAt,
        total_cycle_ms: nowMs() - startedAt,
      },
      captureMetrics: null,
    });
  } finally {
    writeFileSync(stageConfigPath, "");
  }
}

async function openCaptureSession({
  browser,
  plan,
  sourcePage,
}) {
  if (plan.capturePageMode === "shared") {
    return {
      page: sourcePage,
      currentOrientation: { dx: 0, dy: 0 },
      persistent: false,
    };
  }
  logStep("opening persistent capture page");
  const page = await openModelingPage(browser, plan.url, plan.timeoutMs);
  return {
    page,
    currentOrientation: { dx: 0, dy: 0 },
    persistent: true,
  };
}

async function closeCaptureSession(captureSession) {
  if (captureSession?.persistent) {
    await captureSession.page.close();
  }
}

async function runHandoffCycle({
  plan,
  sourcePage,
  captureSession,
  cycle,
}) {
  const cycleStartedAt = nowMs();
  const timings = {};
  let importGlbPath = plan.importGlbPath;
  if (!plan.liveReview && plan.editProfile != null) {
    const sourceGlbPath = plan.generatedSourceGlbPath;
    const generatedImportGlbPath = plan.generatedImportGlbPath;
    ensureParentDir(sourceGlbPath);
    ensureParentDir(generatedImportGlbPath);
    logStep(`exporting source GLB to ${sourceGlbPath}`);
    await exportSourceGlb(sourcePage, sourceGlbPath);
    logStep(`running Blender edit profile ${plan.editProfile}`);
    runNodeScript("tools/modeling3d/scripts/blender-roundtrip-edit.mjs", [
      sourceGlbPath,
      generatedImportGlbPath,
      plan.editProfile,
    ]);
    importGlbPath = generatedImportGlbPath;
  }

  if (importGlbPath == null || !existsSync(importGlbPath)) {
    if (!plan.liveReview) {
      throw new Error(`import GLB not found: ${String(importGlbPath)}`);
    }
  }

  const capturePage = captureSession.page;
  try {
    await capturePage.bringToFront();
    let bundlePath;
    let promptPath;
    let bundleText;
    let promptText;
    if (plan.liveReview) {
      const contextStartedAt = nowMs();
      logStep("reading current workbench state from browser");
      const modelingContext = await readModelingContext(capturePage, plan.timeoutMs);
      timings.context_read_ms = nowMs() - contextStartedAt;
      const bundleStartedAt = nowMs();
      bundlePath = resolveDownloadTargetPath({
        outDir: plan.outDir,
        explicitPath: plan.bundlePath,
        suggestedFilename: `${plan.artifactStem}-vlm-bundle.json`,
      });
      promptPath = resolveDownloadTargetPath({
        outDir: plan.outDir,
        explicitPath: plan.promptPath,
        suggestedFilename: `${plan.artifactStem}-vlm-review.md`,
      });
      bundleText = buildLiveReviewBundle({
        example: plan.example,
        contextJson: modelingContext?.json ?? "",
        summary: modelingContext?.summary ?? "",
      });
      promptText = buildLiveReviewPrompt({
        example: plan.example,
        contextJson: modelingContext?.json ?? "",
        summary: modelingContext?.summary ?? "",
      });
      writeReviewAssetFile(bundlePath, bundleText);
      writeReviewAssetFile(promptPath, promptText);
      timings.bundle_prompt_ms = nowMs() - bundleStartedAt;
    } else {
      const importStartedAt = nowMs();
      logStep(`importing ${importGlbPath}`);
      await importGlb(capturePage, importGlbPath, plan.timeoutMs);
      timings.import_ms = nowMs() - importStartedAt;

      const reviewAssetsStartedAt = nowMs();
      logStep("reading bundle and prompt from browser state");
      const reviewAssets = await readReviewAssets(capturePage, plan.timeoutMs);
      bundlePath = resolveDownloadTargetPath({
        outDir: plan.outDir,
        explicitPath: plan.bundlePath,
        suggestedFilename: reviewAssets.bundle.filename,
      });
      promptPath = resolveDownloadTargetPath({
        outDir: plan.outDir,
        explicitPath: plan.promptPath,
        suggestedFilename: reviewAssets.prompt.filename,
      });
      writeReviewAssetFile(bundlePath, reviewAssets.bundle.text);
      writeReviewAssetFile(promptPath, reviewAssets.prompt.text);
      bundleText = reviewAssets.bundle.text;
      promptText = reviewAssets.prompt.text;
      timings.review_assets_ms = nowMs() - reviewAssetsStartedAt;
    }
    const captureStartedAt = nowMs();
    const captureResult = await captureScreenshotViews({
      captureSession,
      screenshotViews: plan.screenshotViews,
      reviewBinarize: plan.reviewBinarize,
    });
    timings.capture_ms = nowMs() - captureStartedAt;
    const finalizeStartedAt = nowMs();
    const result = await finalizeReviewArtifacts({
      plan,
      cycle,
      importGlbPath,
      bundlePath,
      bundleText,
      promptPath,
      promptText,
      screenshots: captureResult.screenshots,
      timings: {
        ...timings,
        finalize_ms: 0,
        total_cycle_ms: 0,
      },
      captureMetrics: captureResult.metrics,
    });
    result.timings.finalize_ms = nowMs() - finalizeStartedAt;
    result.timings.total_cycle_ms = nowMs() - cycleStartedAt;
    return result;
  } finally {
    if (plan.preserveWorkbenchPage) {
      await sourcePage.bringToFront();
    }
  }
}

async function runInteractiveLoop({ plan, sourcePage, captureSession }) {
  const prompt = createInterface({
    input: stdin,
    output: stderr,
  });
  let cycle = 1;
  try {
    logStep("interactive session keeps the workbench page open; artifacts are overwritten on each rerun");
    for (;;) {
      const result = await runHandoffCycle({
        plan,
        sourcePage,
        captureSession,
        cycle,
      });
      console.log(JSON.stringify(result, null, 2));
      let answer = "q";
      try {
        answer = await prompt.question(
          "[handoff] Press Enter to rerun from the current workbench state, or q to quit: ",
        );
      } catch (error) {
        if (error?.code !== "ERR_USE_AFTER_CLOSE") {
          throw error;
        }
      }
      if (answer.trim().toLowerCase() === "q") {
        break;
      }
      cycle += 1;
    }
  } finally {
    prompt.close();
  }
}

async function runFixedCycles({ plan, sourcePage, captureSession }) {
  const results = [];
  for (let cycle = 1; cycle <= plan.cycles; cycle += 1) {
    results.push(
      await runHandoffCycle({
        plan,
        sourcePage,
        captureSession,
        cycle,
      }),
    );
  }
  return results;
}

function writeDaemonEvent(event, payload = {}) {
  console.log(JSON.stringify({ event, ...payload }));
}

async function runDaemonLoop({ plan, sourcePage, captureSession }) {
  const prompt = createInterface({
    input: stdin,
    output: stderr,
    terminal: false,
  });
  let shutdownRequested = false;
  writeDaemonEvent("ready", {
    example: plan.example,
    provider: plan.provider,
    renderer: plan.renderer,
    url: plan.url,
    live_review: true,
  });
  try {
    for await (const line of prompt) {
      if (line.trim().length === 0) {
        continue;
      }
      let command;
      try {
        command = parseVlmDaemonCommand(line);
      } catch (error) {
        writeDaemonEvent("error", {
          message: String(error.message ?? error),
        });
        continue;
      }
      if (command.op === "shutdown") {
        shutdownRequested = true;
        break;
      }
      const cyclePlan = buildDaemonCyclePlan(plan, command);
      mkdirSync(cyclePlan.outDir, { recursive: true });
      ensureParentDir(cyclePlan.requestPath);
      if (cyclePlan.execute) {
        ensureParentDir(cyclePlan.responsePath);
        ensureParentDir(cyclePlan.parsedPath);
      }
      try {
        const result = await runHandoffCycle({
          plan: cyclePlan,
          sourcePage,
          captureSession,
          cycle: command.cycle ?? 1,
        });
        writeDaemonEvent("result", {
          result,
        });
      } catch (error) {
        writeDaemonEvent("error", {
          cycle: command.cycle ?? null,
          message: String(error.message ?? error),
        });
      }
    }
  } finally {
    prompt.close();
  }
  return {
    shutdownRequested,
  };
}

async function runTcpDaemonServer({ plan, sourcePage, captureSession }) {
  const host = plan.daemonHost;
  const port = plan.daemonPort;
  if (port == null) {
    throw new Error("runTcpDaemonServer requires daemonPort");
  }
  let commandQueue = Promise.resolve();
  let shutdownRequested = false;
  let serverClosed = false;
  let resolveDone;
  const done = new Promise((resolvePromise) => {
    resolveDone = resolvePromise;
  });
  const server = createServer((socket) => {
    let buffer = "";
    let handled = false;
    socket.setEncoding("utf8");
    socket.on("data", (chunk) => {
      buffer += chunk;
      const newlineIndex = buffer.indexOf("\n");
      if (newlineIndex < 0 || handled) {
        return;
      }
      handled = true;
      const line = buffer.slice(0, newlineIndex);
      commandQueue = commandQueue
        .then(async () => {
          const command = parseVlmDaemonCommand(line);
          if (command.op === "shutdown") {
            shutdownRequested = true;
            socket.write(`${JSON.stringify({ event: "shutdown", ok: true })}\n`);
            socket.end();
            if (!serverClosed) {
              serverClosed = true;
              server.close(() => {
                resolveDone();
              });
            }
            return;
          }
          const cyclePlan = buildDaemonCyclePlan(plan, command);
          mkdirSync(cyclePlan.outDir, { recursive: true });
          ensureParentDir(cyclePlan.requestPath);
          if (cyclePlan.execute) {
            ensureParentDir(cyclePlan.responsePath);
            ensureParentDir(cyclePlan.parsedPath);
          }
          const result = await runHandoffCycle({
            plan: cyclePlan,
            sourcePage,
            captureSession,
            cycle: command.cycle ?? 1,
          });
          socket.write(`${JSON.stringify({ event: "result", result })}\n`);
          socket.end();
        })
        .catch((error) => {
          socket.write(
            `${JSON.stringify({
              event: "error",
              message: String(error.message ?? error),
            })}\n`,
          );
          socket.end();
        });
    });
    socket.on("error", () => {
      socket.destroy();
    });
  });

  await new Promise((resolvePromise, rejectPromise) => {
    server.once("error", rejectPromise);
    server.listen(port, host, () => {
      server.off("error", rejectPromise);
      resolvePromise();
    });
  });
  logStep(`daemon listening on tcp://${host}:${port}`);
  await done;
  return {
    shutdownRequested,
    transport: "tcp",
  };
}

async function main() {
  let plan;
  try {
    plan = buildModelAuthoringVlmHandoffPlan({
      cwd: process.cwd(),
      ...parseArgs(process.argv.slice(2)),
    });
  } catch (error) {
    usage();
    console.error(String(error.message ?? error));
    process.exit(1);
  }

  mkdirSync(plan.outDir, { recursive: true });
  ensureParentDir(plan.requestPath);
  if (plan.execute) {
    if (!process.env[plan.apiKeyEnv]) {
      console.error(`${plan.apiKeyEnv} is required when --execute is set`);
      process.exit(1);
    }
    ensureParentDir(plan.responsePath);
    ensureParentDir(plan.parsedPath);
  }

  let devServer = null;
  let browser = null;
  let output = null;
  const startupTimings = {};
  const teardownTimings = {};
  const processStartedAt = Number(process.env.KAGURA_HANDOFF_PROCESS_STARTED_AT);
  if (Number.isFinite(processStartedAt) && processStartedAt > 0) {
    startupTimings.runner_bootstrap_ms = Math.max(
      0,
      MODULE_READY_AT_MS - processStartedAt,
    );
  }
  const startupStartedAt = nowMs();
  try {
    if (plan.renderer === "native") {
      output = await runNativeLiveReview(plan);
      startupTimings.startup_total_ms = nowMs() - startupStartedAt;
    } else {
      if (plan.serve) {
      const serverReadyStartedAt = nowMs();
      logStep(`starting dev server for ${plan.devTarget} at ${plan.url}`);
      devServer = spawn("just", ["dev", plan.devTarget], {
        cwd: process.cwd(),
        env: { ...process.env, PORT: String(plan.port) },
        stdio: "pipe",
      });
      await waitForHttp(plan.url, plan.timeoutMs);
      startupTimings.server_ready_ms = nowMs() - serverReadyStartedAt;
      } else {
      const serverReadyStartedAt = nowMs();
      logStep(`waiting for existing server at ${plan.url}`);
      await waitForHttp(plan.url, plan.timeoutMs);
      startupTimings.server_ready_ms = nowMs() - serverReadyStartedAt;
      }

      logStep("loading Playwright browser runtime");
      const playwrightImportStartedAt = nowMs();
      const chromium = await loadChromium();
      startupTimings.playwright_import_ms = nowMs() - playwrightImportStartedAt;
      logStep("launching browser");
      const browserLaunchStartedAt = nowMs();
      browser = await chromium.launch({
        channel: "chrome",
        headless: !plan.headed,
        args: ["--enable-unsafe-webgpu"],
      });
      startupTimings.browser_launch_ms = nowMs() - browserLaunchStartedAt;
      const sourcePageOpenStartedAt = nowMs();
      const sourcePage = await openModelingPage(browser, plan.url, plan.timeoutMs);
      startupTimings.source_page_open_ms = nowMs() - sourcePageOpenStartedAt;
      const captureSessionOpenStartedAt = nowMs();
      const captureSession = await openCaptureSession({
        browser,
        plan,
        sourcePage,
      });
      startupTimings.capture_session_open_ms =
        nowMs() - captureSessionOpenStartedAt;
      if (plan.importGlbPath != null && (plan.liveReview || (plan.interactive && plan.editProfile == null))) {
        logStep(`loading workbench model from ${plan.importGlbPath}`);
        const initialImportStartedAt = nowMs();
        await importGlb(sourcePage, plan.importGlbPath, plan.timeoutMs);
        startupTimings.initial_import_ms = nowMs() - initialImportStartedAt;
      }
      startupTimings.startup_total_ms = nowMs() - startupStartedAt;
      try {
        if (plan.daemon) {
          output =
            plan.daemonPort != null
              ? await runTcpDaemonServer({
                  plan,
                  sourcePage,
                  captureSession,
                })
              : await runDaemonLoop({
                  plan,
                  sourcePage,
                  captureSession,
                });
        } else if (plan.interactive) {
          await runInteractiveLoop({
            plan,
            sourcePage,
            captureSession,
          });
        } else if (plan.cycles > 1) {
          const results = await runFixedCycles({
            plan,
            sourcePage,
            captureSession,
          });
          output = {
            mode: "batch",
            renderer: plan.renderer,
            cycles: plan.cycles,
            results,
          };
        } else {
          output = await runHandoffCycle({
            plan,
            sourcePage,
            captureSession,
            cycle: 1,
          });
        }
      } finally {
        await closeCaptureSession(captureSession);
      }
    }
  } finally {
    const teardownStartedAt = nowMs();
    if (browser != null) {
      const browserCloseStartedAt = nowMs();
      await browser.close();
      teardownTimings.browser_close_ms = nowMs() - browserCloseStartedAt;
    }
    if (devServer != null) {
      const devServerStopStartedAt = nowMs();
      devServer.kill("SIGINT");
      await new Promise((resolvePromise) => {
        let settled = false;
        const finish = () => {
          if (settled) {
            return;
          }
          settled = true;
          devServer.stdout?.destroy();
          devServer.stderr?.destroy();
          resolvePromise();
        };
        devServer.once("exit", finish);
        setTimeout(() => {
          if (devServer.exitCode == null) {
            devServer.kill("SIGKILL");
          }
          finish();
        }, 2000);
      });
      teardownTimings.dev_server_stop_ms = nowMs() - devServerStopStartedAt;
    }
    teardownTimings.teardown_total_ms = nowMs() - teardownStartedAt;
  }
  if (plan.daemon && plan.daemonPort == null) {
    writeDaemonEvent("shutdown", {
      startup_timings: startupTimings,
      teardown_timings: teardownTimings,
      shutdown_requested: output?.shutdownRequested ?? false,
    });
  } else if (plan.daemon) {
    console.log(
      JSON.stringify({
        mode: "daemon-server",
        transport: output?.transport ?? "tcp",
        startup_timings: startupTimings,
        teardown_timings: teardownTimings,
        shutdown_requested: output?.shutdownRequested ?? false,
      }),
    );
  } else if (output != null) {
    output.startup_timings = startupTimings;
    output.teardown_timings = teardownTimings;
    console.log(JSON.stringify(output, null, 2));
  }
}

await main();
