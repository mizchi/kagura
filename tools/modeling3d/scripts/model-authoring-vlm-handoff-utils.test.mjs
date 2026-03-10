import test from "node:test";
import assert from "node:assert/strict";

import {
  buildLiveReviewBundle,
  buildLiveReviewPrompt,
  buildModelAuthoringVlmHandoffPlan,
  computeRelativeViewDrag,
  decodeBrowserBinaryAsset,
  resolveExampleReviewConfig,
  resolveHandoffViewOrientation,
  resolveDownloadTargetPath,
  sanitizeArtifactStem,
} from "./model-authoring-vlm-handoff-utils.mjs";

test("sanitizeArtifactStem normalizes filenames for artifact prefixes", () => {
  assert.equal(sanitizeArtifactStem("roundtrip_diff_bundle.glb"), "roundtrip-diff-bundle");
  assert.equal(sanitizeArtifactStem("vlm clay totem"), "vlm-clay-totem");
  assert.equal(sanitizeArtifactStem("___"), "artifact");
});

test("buildModelAuthoringVlmHandoffPlan derives default paths for imported GLB mode", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    importGlb: "tmp/roundtrip_diff_bundle.glb",
    port: 8123,
  });

  assert.equal(plan.url, "http://127.0.0.1:8123/");
  assert.equal(plan.importGlbPath, "/repo/tmp/roundtrip_diff_bundle.glb");
  assert.equal(plan.generatedImportGlbPath, null);
  assert.equal(plan.outDir, "/repo/output/playwright/model-authoring-handoff");
  assert.equal(
    plan.screenshotPath,
    "/repo/output/playwright/model-authoring-handoff/roundtrip-diff-bundle-screenshot.png",
  );
  assert.deepEqual(plan.screenshotViews, [
    {
      label: "angled",
      path: "/repo/output/playwright/model-authoring-handoff/roundtrip-diff-bundle-screenshot.png",
    },
    {
      label: "front",
      path: "/repo/output/playwright/model-authoring-handoff/roundtrip-diff-bundle-screenshot-front.png",
    },
    {
      label: "side",
      path: "/repo/output/playwright/model-authoring-handoff/roundtrip-diff-bundle-screenshot-side.png",
    },
    {
      label: "top",
      path: "/repo/output/playwright/model-authoring-handoff/roundtrip-diff-bundle-screenshot-top.png",
    },
  ]);
  assert.equal(
    plan.requestPath,
    "/repo/output/playwright/model-authoring-handoff/roundtrip-diff-bundle-request.json",
  );
  assert.equal(plan.provider, "openai");
  assert.equal(plan.preset, null);
  assert.equal(plan.model, "gpt-5");
  assert.equal(plan.cycles, 1);
  assert.equal(plan.capturePageMode, "shared");
  assert.equal(plan.preserveWorkbenchPage, false);
  assert.equal(plan.exportTransport, "browser_state");
  assert.equal(plan.importTransport, "browser_state");
  assert.deepEqual(plan.modelCandidates, ["gpt-5"]);
  assert.equal(plan.apiUrl, "https://api.openai.com/v1/responses");
  assert.equal(plan.apiKeyEnv, "OPENAI_API_KEY");
});

test("buildModelAuthoringVlmHandoffPlan prepares edit-profile export/import paths", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    editProfile: "roundtrip_diff_bundle",
    outDir: "tmp/handoff",
    serve: true,
  });

  assert.equal(plan.serve, true);
  assert.equal(plan.importGlbPath, null);
  assert.equal(plan.generatedSourceGlbPath, "/repo/tmp/handoff/roundtrip-diff-bundle-source.glb");
  assert.equal(plan.generatedImportGlbPath, "/repo/tmp/handoff/roundtrip-diff-bundle-edited.glb");
  assert.equal(plan.importTransport, "browser_state");
  assert.equal(plan.url, "http://127.0.0.1:8113/");
});

test("buildModelAuthoringVlmHandoffPlan supports alternate authoring examples", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    example: "chair_authoring",
    editProfile: "roundtrip_diff_bundle",
  });

  assert.equal(plan.example, "chair_authoring");
  assert.equal(plan.devTarget, "chair_authoring");
  assert.equal(plan.outDir, "/repo/output/playwright/chair-authoring-handoff");
  assert.equal(plan.generatedSourceGlbPath, "/repo/output/playwright/chair-authoring-handoff/roundtrip-diff-bundle-source.glb");
  assert.equal(plan.generatedImportGlbPath, "/repo/output/playwright/chair-authoring-handoff/roundtrip-diff-bundle-edited.glb");
});

test("buildModelAuthoringVlmHandoffPlan supports shelf authoring examples", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    example: "shelf_authoring",
    editProfile: "roundtrip_diff_bundle",
  });

  assert.equal(plan.example, "shelf_authoring");
  assert.equal(plan.devTarget, "shelf_authoring");
  assert.equal(plan.outDir, "/repo/output/playwright/shelf-authoring-handoff");
  assert.equal(plan.generatedSourceGlbPath, "/repo/output/playwright/shelf-authoring-handoff/roundtrip-diff-bundle-source.glb");
  assert.equal(plan.generatedImportGlbPath, "/repo/output/playwright/shelf-authoring-handoff/roundtrip-diff-bundle-edited.glb");
});

test("buildModelAuthoringVlmHandoffPlan supports dragon authoring examples", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    example: "dragon_authoring",
    liveReview: true,
  });

  assert.equal(plan.example, "dragon_authoring");
  assert.equal(plan.devTarget, "dragon_authoring");
  assert.equal(plan.outDir, "/repo/output/playwright/dragon-authoring-handoff");
  assert.equal(
    plan.screenshotPath,
    "/repo/output/playwright/dragon-authoring-handoff/current-state-review-screenshot.png",
  );
});

test("buildModelAuthoringVlmHandoffPlan enables headed mode for interactive sessions", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    editProfile: "roundtrip_diff_bundle",
    interactive: true,
  });

  assert.equal(plan.interactive, true);
  assert.equal(plan.headed, true);
  assert.equal(plan.capturePageMode, "persistent");
  assert.equal(plan.preserveWorkbenchPage, true);
});

test("buildModelAuthoringVlmHandoffPlan accepts explicit cycle count", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    liveReview: true,
    cycles: 4,
  });

  assert.equal(plan.cycles, 4);
});

test("buildModelAuthoringVlmHandoffPlan enables daemon mode for web live review", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    liveReview: true,
    daemon: true,
    daemonPort: 9123,
  });

  assert.equal(plan.daemon, true);
  assert.equal(plan.liveReview, true);
  assert.equal(plan.renderer, "web");
  assert.equal(plan.daemonPort, 9123);
  assert.equal(plan.daemonHost, "127.0.0.1");
});

test("buildModelAuthoringVlmHandoffPlan supports live review without Blender roundtrip", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    example: "frog_authoring",
    liveReview: true,
    interactive: true,
  });

  assert.equal(plan.liveReview, true);
  assert.equal(plan.reviewMode, "current_state");
  assert.equal(plan.capturePageMode, "shared");
  assert.equal(plan.preserveWorkbenchPage, false);
  assert.equal(plan.importGlbPath, null);
  assert.equal(plan.generatedSourceGlbPath, null);
  assert.equal(plan.generatedImportGlbPath, null);
  assert.equal(
    plan.screenshotPath,
    "/repo/output/playwright/frog-authoring-handoff/current-state-review-screenshot.png",
  );
});

test("buildModelAuthoringVlmHandoffPlan supports native live review artifacts", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    example: "frog_authoring",
    liveReview: true,
    renderer: "native",
  });

  assert.equal(plan.renderer, "native");
  assert.equal(plan.browserRequired, false);
  assert.equal(plan.serve, false);
  assert.equal(
    plan.nativeConfigPath,
    "/repo/output/playwright/frog-authoring-handoff/current-state-review-native-config.txt",
  );
  assert.equal(
    plan.nativeContextPath,
    "/repo/output/playwright/frog-authoring-handoff/current-state-review-native-context.json",
  );
  assert.equal(
    plan.nativeSummaryPath,
    "/repo/output/playwright/frog-authoring-handoff/current-state-review-native-summary.txt",
  );
});

test("resolveExampleReviewConfig exposes dragon organic review metadata", () => {
  const config = resolveExampleReviewConfig("dragon_authoring");

  assert.equal(config.targetFile, "tools/modeling3d/examples/dragon_authoring/src/model_doc.mbt");
  assert.equal(config.profileId, "organic_character");
  assert.match(config.constraints.join("\n"), /dragon/i);
  assert.match(config.constraints.join("\n"), /tail/i);
});

test("buildModelAuthoringVlmHandoffPlan rejects native roundtrip mode", () => {
  assert.throws(
    () =>
      buildModelAuthoringVlmHandoffPlan({
        cwd: "/repo",
        importGlb: "tmp/roundtrip_diff_bundle.glb",
        renderer: "native",
      }),
    /native renderer currently supports --live-review only/,
  );
});

test("buildModelAuthoringVlmHandoffPlan rejects native interactive mode", () => {
  assert.throws(
    () =>
      buildModelAuthoringVlmHandoffPlan({
        cwd: "/repo",
        liveReview: true,
        renderer: "native",
        interactive: true,
      }),
    /native renderer does not support --interactive/,
  );
});

test("buildModelAuthoringVlmHandoffPlan rejects daemon without live review", () => {
  assert.throws(
    () =>
      buildModelAuthoringVlmHandoffPlan({
        cwd: "/repo",
        importGlb: "tmp/roundtrip_diff_bundle.glb",
        daemon: true,
      }),
    /daemon mode currently supports --live-review only/,
  );
});

test("buildModelAuthoringVlmHandoffPlan resolves OpenRouter defaults", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    importGlb: "tmp/roundtrip_diff_bundle.glb",
    provider: "openrouter",
  });

  assert.equal(plan.provider, "openrouter");
  assert.equal(plan.preset, "preview");
  assert.equal(plan.model, "google/gemini-3.1-flash-lite-preview");
  assert.deepEqual(plan.modelCandidates, [
    "google/gemini-3.1-flash-lite-preview",
    "mistralai/mistral-small-3.1-24b-instruct:free",
    "google/gemma-3-27b-it:free",
    "google/gemma-3-4b-it:free",
  ]);
  assert.equal(plan.apiUrl, "https://openrouter.ai/api/v1/chat/completions");
  assert.equal(plan.apiKeyEnv, "OPENROUTER_API_KEY");
});

test("buildModelAuthoringVlmHandoffPlan resolves OpenRouter preset aliases", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    importGlb: "tmp/roundtrip_diff_bundle.glb",
    provider: "openrouter",
    preset: "quality",
  });

  assert.equal(plan.provider, "openrouter");
  assert.equal(plan.preset, "quality");
  assert.equal(plan.model, "anthropic/claude-sonnet-4.5");
  assert.deepEqual(plan.modelCandidates, ["anthropic/claude-sonnet-4.5"]);
});

test("buildModelAuthoringVlmHandoffPlan resolves OpenRouter preview preset", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    importGlb: "tmp/roundtrip_diff_bundle.glb",
    provider: "openrouter",
    preset: "preview",
  });

  assert.equal(plan.provider, "openrouter");
  assert.equal(plan.preset, "preview");
  assert.equal(plan.model, "google/gemini-3.1-flash-lite-preview");
  assert.deepEqual(plan.modelCandidates, [
    "google/gemini-3.1-flash-lite-preview",
    "mistralai/mistral-small-3.1-24b-instruct:free",
    "google/gemma-3-27b-it:free",
    "google/gemma-3-4b-it:free",
  ]);
});

test("buildModelAuthoringVlmHandoffPlan resolves OpenRouter free preset", () => {
  const plan = buildModelAuthoringVlmHandoffPlan({
    cwd: "/repo",
    importGlb: "tmp/roundtrip_diff_bundle.glb",
    provider: "openrouter",
    preset: "free",
  });

  assert.equal(plan.provider, "openrouter");
  assert.equal(plan.preset, "free");
  assert.equal(plan.model, "mistralai/mistral-small-3.1-24b-instruct:free");
  assert.deepEqual(plan.modelCandidates, [
    "mistralai/mistral-small-3.1-24b-instruct:free",
    "google/gemma-3-27b-it:free",
    "google/gemma-3-4b-it:free",
  ]);
});

test("buildModelAuthoringVlmHandoffPlan rejects missing import source", () => {
  assert.throws(
    () =>
      buildModelAuthoringVlmHandoffPlan({
        cwd: "/repo",
      }),
    /either importGlb or editProfile is required/,
  );
});

test("resolveDownloadTargetPath prefers explicit override and falls back to suggested names", () => {
  assert.equal(
    resolveDownloadTargetPath({
      outDir: "/repo/output",
      explicitPath: "/repo/custom/bundle.json",
      suggestedFilename: "vlm_bundle.json",
    }),
    "/repo/custom/bundle.json",
  );
  assert.equal(
    resolveDownloadTargetPath({
      outDir: "/repo/output",
      explicitPath: null,
      suggestedFilename: "vlm_bundle.json",
    }),
    "/repo/output/vlm_bundle.json",
  );
});

test("resolveHandoffViewOrientation returns absolute camera targets", () => {
  assert.deepEqual(resolveHandoffViewOrientation("angled"), { dx: 0, dy: 0 });
  assert.deepEqual(resolveHandoffViewOrientation("front"), { dx: 90, dy: 0 });
  assert.deepEqual(resolveHandoffViewOrientation("side"), { dx: -220, dy: 0 });
  assert.deepEqual(resolveHandoffViewOrientation("top"), { dx: 90, dy: -160 });
});

test("computeRelativeViewDrag converts absolute view presets into same-page deltas", () => {
  assert.deepEqual(
    computeRelativeViewDrag({ dx: 0, dy: 0 }, "front"),
    {
      next: { dx: 90, dy: 0 },
      drag: { dx: 90, dy: 0 },
    },
  );
  assert.deepEqual(
    computeRelativeViewDrag({ dx: 90, dy: 0 }, "side"),
    {
      next: { dx: -220, dy: 0 },
      drag: { dx: -310, dy: 0 },
    },
  );
  assert.deepEqual(
    computeRelativeViewDrag({ dx: -220, dy: 0 }, "top"),
    {
      next: { dx: 90, dy: -160 },
      drag: { dx: 310, dy: -160 },
    },
  );
});

test("decodeBrowserBinaryAsset decodes base64-encoded browser payloads", () => {
  const bytes = decodeBrowserBinaryAsset({
    filename: "scene.glb",
    bytesBase64: "AAEC",
  });

  assert.deepEqual([...bytes], [0, 1, 2]);
});

test("resolveExampleReviewConfig maps authoring examples to review profiles", () => {
  assert.deepEqual(resolveExampleReviewConfig("model_authoring"), {
    targetFile: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
    profileId: "generic_model",
    constraints: [
      "Keep the primary silhouette readable from angled, front, side, and top views.",
      "Treat helper or debug primitives as non-final unless the imported diff marks them as intentional.",
    ],
  });
  assert.deepEqual(resolveExampleReviewConfig("chair_authoring"), {
    targetFile: "tools/modeling3d/examples/chair_authoring/src/model_doc.mbt",
    profileId: "hard_surface_prop",
    constraints: [
      "A chair should read as a stable seat, backrest, and support structure.",
      "Legs, braces, and seat planes should stay aligned rather than drifting into floating helper geometry.",
    ],
  });
  assert.deepEqual(resolveExampleReviewConfig("shelf_authoring"), {
    targetFile: "tools/modeling3d/examples/shelf_authoring/src/model_doc.mbt",
    profileId: "hard_surface_prop",
    constraints: [
      "A shelf should read as stacked horizontal boards supported by vertical uprights.",
      "Shelf levels, uprights, and storage props should stay aligned instead of collapsing into floating helper geometry.",
    ],
  });
});

test("buildLiveReviewBundle emits current-state bundle JSON", () => {
  const bundleText = buildLiveReviewBundle({
    example: "frog_authoring",
    contextJson: "{\"stats\":{\"primitive_count\":2}}",
    summary: "FROG current state",
  });
  const parsed = JSON.parse(bundleText);

  assert.equal(parsed.review_mode, "current_state");
  assert.equal(parsed.target_file, "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt");
  assert.equal(parsed.review_profile, "organic_character");
  assert.deepEqual(parsed.review_constraints, [
    "Aim for a squat frog silhouette instead of a generic blob.",
    "Eyes should remain a deliberate paired feature.",
    "Haunches, forelimbs, and the mouth landmark should remain readable.",
  ]);
  assert.equal(parsed.workbench_summary, "FROG current state");
  assert.deepEqual(parsed.current_document, { stats: { primitive_count: 2 } });
  assert.deepEqual(parsed.patch_payload, {
    auto_actions: [],
    manual_actions: [],
    opt_in_append_source_ids: [],
    opt_in_remove_source_ids: [],
    manual_issue_details: [],
  });
});

test("buildLiveReviewPrompt describes current-state review loop", () => {
  const promptText = buildLiveReviewPrompt({
    example: "chair_authoring",
    contextJson: "{\"stats\":{\"primitive_count\":6}}",
    summary: "CHAIR current state",
  });

  assert.match(promptText, /current-state review prompt/i);
  assert.match(promptText, /Review the current workbench state/i);
  assert.match(promptText, /This is not a round-trip diff/i);
  assert.match(promptText, /examples\/chair_authoring\/src\/model_doc\.mbt/);
  assert.match(promptText, /CHAIR current state/);
  assert.match(promptText, /"primitive_count": 6/);
});
