import { basename, extname, join, resolve } from "node:path";

import { resolveVlmReviewApiConfig } from "./model-authoring-vlm-review-utils.mjs";

const EXAMPLE_REVIEW_CONFIGS = {
  model_authoring: {
    targetFile: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
    profileId: "generic_model",
    constraints: [
      "Keep the primary silhouette readable from angled, front, side, and top views.",
      "Treat helper or debug primitives as non-final unless the imported diff marks them as intentional.",
    ],
  },
  chair_authoring: {
    targetFile: "tools/modeling3d/examples/chair_authoring/src/model_doc.mbt",
    profileId: "hard_surface_prop",
    constraints: [
      "A chair should read as a stable seat, backrest, and support structure.",
      "Legs, braces, and seat planes should stay aligned rather than drifting into floating helper geometry.",
    ],
  },
  shelf_authoring: {
    targetFile: "tools/modeling3d/examples/shelf_authoring/src/model_doc.mbt",
    profileId: "hard_surface_prop",
    constraints: [
      "A shelf should read as stacked horizontal boards supported by vertical uprights.",
      "Shelf levels, uprights, and storage props should stay aligned instead of collapsing into floating helper geometry.",
    ],
  },
  frog_authoring: {
    targetFile: "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt",
    profileId: "organic_character",
    constraints: [
      "Aim for a squat frog silhouette instead of a generic blob.",
      "Eyes should remain a deliberate paired feature.",
      "Haunches, forelimbs, and the mouth landmark should remain readable.",
    ],
  },
  dragon_authoring: {
    targetFile: "tools/modeling3d/examples/dragon_authoring/src/model_doc.mbt",
    profileId: "organic_character",
    constraints: [
      "Aim for a readable dragon silhouette with a clear head, neck, torso, and tail instead of a generic blob.",
      "Wings should read as deliberate side volumes rather than detached helper lumps.",
      "Horns, jawline, and glowing eyes should remain readable from angled and front views.",
    ],
  },
};

const HANDOFF_VIEW_ORIENTATIONS = {
  angled: { dx: 0, dy: 0 },
  front: { dx: 90, dy: 0 },
  side: { dx: -220, dy: 0 },
  top: { dx: 90, dy: -160 },
};

export function sanitizeArtifactStem(input) {
  const stem = basename(input, extname(input))
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return stem.length > 0 ? stem : "artifact";
}

export function resolveDownloadTargetPath({
  outDir,
  explicitPath,
  suggestedFilename,
}) {
  if (explicitPath != null) {
    return explicitPath;
  }
  return join(outDir, suggestedFilename);
}

export function resolveHandoffViewOrientation(label) {
  return HANDOFF_VIEW_ORIENTATIONS[label] ?? HANDOFF_VIEW_ORIENTATIONS.angled;
}

export function computeRelativeViewDrag(current, label) {
  const next = resolveHandoffViewOrientation(label);
  return {
    next,
    drag: {
      dx: next.dx - current.dx,
      dy: next.dy - current.dy,
    },
  };
}

export function decodeBrowserBinaryAsset(asset) {
  return Buffer.from(String(asset?.bytesBase64 ?? ""), "base64");
}

export function resolveExampleReviewConfig(example = "model_authoring") {
  return EXAMPLE_REVIEW_CONFIGS[example] ?? EXAMPLE_REVIEW_CONFIGS.model_authoring;
}

function parseContextJson(contextJson) {
  if (typeof contextJson !== "string" || contextJson.length === 0) {
    return null;
  }
  try {
    return JSON.parse(contextJson);
  } catch {
    return null;
  }
}

export function buildLiveReviewBundle({
  example = "model_authoring",
  contextJson = "",
  summary = "",
}) {
  const reviewConfig = resolveExampleReviewConfig(example);
  return JSON.stringify({
    review_mode: "current_state",
    target_file: reviewConfig.targetFile,
    review_profile: reviewConfig.profileId,
    review_constraints: reviewConfig.constraints,
    workbench_summary: summary,
    current_document: parseContextJson(contextJson),
    patch_payload: {
      auto_actions: [],
      manual_actions: [],
      opt_in_append_source_ids: [],
      opt_in_remove_source_ids: [],
      manual_issue_details: [],
    },
  });
}

export function buildLiveReviewPrompt({
  example = "model_authoring",
  contextJson = "",
  summary = "",
}) {
  const reviewConfig = resolveExampleReviewConfig(example);
  const parsedContext = parseContextJson(contextJson);
  const prettyContext =
    parsedContext == null
      ? "{}"
      : JSON.stringify(parsedContext, null, 2);
  const lines = [
    "# Kagura current-state review prompt",
    "",
    `Target file: \`${reviewConfig.targetFile}\``,
    "",
    "Review the current workbench state and propose the smallest code-first improvement that keeps Kagura ids stable.",
    "",
    "Rules:",
    "- This is not a round-trip diff. Judge the current model directly from the multi-view screenshots and current document JSON.",
    "- Prefer `edit_model_doc` for concrete source changes and `manual_sculpt_review` when the next step needs visual sculpt judgment.",
    "- Keep existing `id` values stable.",
    "- Do not invent sculpt stamps unless the next step explicitly asks for a new sculpt edit.",
    "- Treat helper or debug primitives as non-final unless they are clearly intentional.",
    "",
    `Review profile: \`${reviewConfig.profileId}\``,
  ];
  if (reviewConfig.constraints.length > 0) {
    lines.push("Review constraints:");
    for (const constraint of reviewConfig.constraints) {
      lines.push(`- ${constraint}`);
    }
    lines.push("");
  }
  lines.push(
    "## Workbench summary",
    "",
    "```text",
    summary,
    "```",
    "",
    "## Current document JSON",
    "",
    "```json",
    prettyContext,
    "```",
  );
  return lines.join("\n");
}

export function buildModelAuthoringVlmHandoffPlan({
  cwd = process.cwd(),
  url = null,
  port = 8113,
  serve = false,
  example = "model_authoring",
  renderer = "web",
  outDir = null,
  importGlb = null,
  editProfile = null,
  liveReview = false,
  screenshotOut = null,
  bundleOut = null,
  promptOut = null,
  requestOut = null,
  responseOut = null,
  parsedOut = null,
  provider = "openai",
  preset = null,
  model = null,
  apiUrl = null,
  apiKeyEnv = null,
  execute = false,
  headed = false,
  interactive = false,
  daemon = false,
  daemonHost = "127.0.0.1",
  daemonPort = null,
  cycles = 1,
  reviewBinarize = false,
  timeoutMs = 30_000,
}) {
  if (!liveReview && importGlb == null && editProfile == null) {
    throw new Error("either importGlb or editProfile is required");
  }
  if (liveReview && editProfile != null) {
    throw new Error("liveReview does not support editProfile");
  }
  if (renderer === "native" && !liveReview) {
    throw new Error("native renderer currently supports --live-review only");
  }
  if (renderer === "native" && interactive) {
    throw new Error("native renderer does not support --interactive");
  }
  if (daemon && !liveReview) {
    throw new Error("daemon mode currently supports --live-review only");
  }
  if (daemon && renderer === "native") {
    throw new Error("daemon mode currently supports web renderer only");
  }
  if (daemon && interactive) {
    throw new Error("daemon mode does not support --interactive");
  }
  if (daemonPort != null && (!Number.isFinite(daemonPort) || daemonPort <= 0)) {
    throw new Error("daemonPort must be > 0");
  }
  if (!Number.isFinite(cycles) || cycles <= 0) {
    throw new Error("cycles must be > 0");
  }

  const rootDir = resolve(cwd);
  const exampleStem = example.replace(/_/g, "-");
  const resolvedOutDir = resolve(
    rootDir,
    outDir ?? `output/playwright/${exampleStem}-handoff`,
  );
  const stem = sanitizeArtifactStem(importGlb ?? editProfile ?? "current_state_review");
  const resolvedImportGlbPath =
    importGlb == null ? null : resolve(rootDir, importGlb);
  const generatedSourceGlbPath =
    editProfile == null || liveReview
      ? null
      : join(resolvedOutDir, `${stem}-source.glb`);
  const generatedImportGlbPath =
    editProfile == null || liveReview
      ? null
      : join(resolvedOutDir, `${stem}-edited.glb`);
  const resolvedScreenshotPath =
    screenshotOut == null
      ? join(resolvedOutDir, `${stem}-screenshot.png`)
      : resolve(rootDir, screenshotOut);
  const nativeConfigPath = join(resolvedOutDir, `${stem}-native-config.txt`);
  const nativeContextPath = join(resolvedOutDir, `${stem}-native-context.json`);
  const nativeSummaryPath = join(resolvedOutDir, `${stem}-native-summary.txt`);
  const screenshotBase = resolvedScreenshotPath.slice(
    0,
    resolvedScreenshotPath.length - extname(resolvedScreenshotPath).length,
  );
  const apiConfig = resolveVlmReviewApiConfig({
    provider,
    preset,
    model,
    apiUrl,
    apiKeyEnv,
  });

  return {
    example,
    renderer,
    browserRequired: renderer !== "native",
    devTarget: example,
    serve: renderer === "native" ? false : serve,
    artifactStem: stem,
    liveReview,
    reviewMode: liveReview ? "current_state" : "roundtrip_diff",
    capturePageMode: liveReview ? "shared" : interactive ? "persistent" : "shared",
    preserveWorkbenchPage: interactive && !liveReview,
    exportTransport: "browser_state",
    importTransport: "browser_state",
    port,
    url: url ?? `http://127.0.0.1:${port}/`,
    outDir: resolvedOutDir,
    importGlbPath: resolvedImportGlbPath,
    editProfile,
    generatedSourceGlbPath,
    generatedImportGlbPath,
    nativeConfigPath,
    nativeContextPath,
    nativeSummaryPath,
    screenshotPath: resolvedScreenshotPath,
    screenshotViews: [
      { label: "angled", path: resolvedScreenshotPath },
      { label: "front", path: `${screenshotBase}-front.png` },
      { label: "side", path: `${screenshotBase}-side.png` },
      { label: "top", path: `${screenshotBase}-top.png` },
    ],
    bundlePath: bundleOut == null ? null : resolve(rootDir, bundleOut),
    promptPath: promptOut == null ? null : resolve(rootDir, promptOut),
    requestPath:
      requestOut == null
        ? join(resolvedOutDir, `${stem}-request.json`)
        : resolve(rootDir, requestOut),
    responsePath:
      responseOut == null
        ? join(resolvedOutDir, `${stem}-response.json`)
        : resolve(rootDir, responseOut),
    parsedPath:
      parsedOut == null
        ? join(resolvedOutDir, `${stem}-parsed.json`)
        : resolve(rootDir, parsedOut),
    provider: apiConfig.provider,
    preset: apiConfig.preset,
    model: apiConfig.model,
    modelCandidates: apiConfig.modelCandidates,
    apiUrl: apiConfig.apiUrl,
    apiKeyEnv: apiConfig.apiKeyEnv,
    execute,
    headed: headed || interactive,
    interactive,
    daemon,
    daemonHost,
    daemonPort,
    cycles,
    reviewBinarize,
    timeoutMs,
  };
}
