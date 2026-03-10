import test from "node:test";
import assert from "node:assert/strict";

import {
  VLM_REVIEW_RESPONSE_SCHEMA,
  buildVlmReviewInstructions,
  buildVlmReviewRequest,
  buildVlmReviewHeaders,
  createDataUrl,
  detectMimeType,
  enrichStructuredReview,
  extractStructuredReview,
  resolveOpenRouterVisionPreset,
  resolveVlmReviewApiConfig,
} from "./model-authoring-vlm-review-utils.mjs";

test("detectMimeType maps common screenshot and text assets", () => {
  assert.equal(detectMimeType("capture.png"), "image/png");
  assert.equal(detectMimeType("capture.jpeg"), "image/jpeg");
  assert.equal(detectMimeType("bundle.json"), "application/json");
  assert.equal(detectMimeType("review.md"), "text/markdown");
  assert.equal(detectMimeType("unknown.bin"), "application/octet-stream");
});

test("createDataUrl base64 encodes binary payloads", () => {
  const dataUrl = createDataUrl("text/plain", Buffer.from("hello", "utf8"));
  assert.equal(dataUrl, "data:text/plain;base64,aGVsbG8=");
});

test("buildVlmReviewRequest attaches screenshot, bundle, and prompt as multimodal inputs", () => {
  const screenshotBytes = Buffer.from([0x89, 0x50, 0x4e, 0x47]);
  const bundleText =
    '{"target_file":"tools/modeling3d/examples/model_authoring/src/model_doc.mbt","patch_payload":{"manual_issue_details":[]}}';
  const promptText = "# Kagura review prompt\nReview the imported GLB diff.";

  const payload = buildVlmReviewRequest({
    model: "gpt-5",
    screenshot: {
      path: "output/playwright/model-authoring.png",
      bytes: screenshotBytes,
    },
    bundle: {
      path: "output/playwright/vlm_bundle.json",
      text: bundleText,
    },
    prompt: {
      path: "output/playwright/vlm_review.md",
      text: promptText,
    },
  });

  assert.equal(payload.model, "gpt-5");
  assert.equal(payload.store, false);
  assert.equal(payload.input.length, 1);
  assert.equal(payload.input[0].role, "user");
  assert.equal(payload.text.format.type, "json_schema");
  assert.equal(payload.text.format.strict, true);
  assert.equal(payload.text.format.name, "kagura_vlm_review");
  assert.deepEqual(payload.text.format.schema, VLM_REVIEW_RESPONSE_SCHEMA);

  const content = payload.input[0].content;
  assert.equal(content[0].type, "input_text");
  assert.match(content[0].text, /attached screenshot/i);
  assert.match(content[0].text, /bundle json/i);
  assert.match(content[0].text, /markdown review prompt/i);
  assert.deepEqual(
    content.slice(1).map((item) => item.type),
    ["input_image", "input_file", "input_file"],
  );
  assert.equal(content[1].image_url, createDataUrl("image/png", screenshotBytes));
  assert.equal(content[2].filename, "vlm_bundle.json");
  assert.match(content[2].file_data, /^data:application\/json;base64,/);
  assert.equal(content[3].filename, "vlm_review.md");
  assert.match(content[3].file_data, /^data:text\/markdown;base64,/);
});

test("buildVlmReviewRequest accepts multi-view screenshots", () => {
  const screenshotBytes = Buffer.from([0x89, 0x50, 0x4e, 0x47]);
  const bundleText =
    JSON.stringify({
      target_file: "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt",
      review_profile: "organic_character",
      review_constraints: [
        "Aim for a squat frog silhouette instead of a generic blob.",
        "Eyes should remain a deliberate paired feature.",
      ],
      patch_payload: { manual_issue_details: [] },
    });
  const promptText = "# Kagura review prompt\nReview the imported GLB diff.";

  const payload = buildVlmReviewRequest({
    model: "gpt-5",
    screenshots: [
      {
        label: "angled",
        path: "output/playwright/frog-angled.png",
        bytes: screenshotBytes,
      },
      {
        label: "front",
        path: "output/playwright/frog-front.png",
        bytes: screenshotBytes,
      },
      {
        label: "side",
        path: "output/playwright/frog-side.png",
        bytes: screenshotBytes,
      },
      {
        label: "top",
        path: "output/playwright/frog-top.png",
        bytes: screenshotBytes,
      },
    ],
    bundle: {
      path: "output/playwright/vlm_bundle.json",
      text: bundleText,
    },
    prompt: {
      path: "output/playwright/vlm_review.md",
      text: promptText,
    },
  });

  const content = payload.input[0].content;
  assert.equal(content[0].type, "input_text");
  assert.match(content[0].text, /fixed multi-view renders/i);
  assert.match(content[0].text, /organic character rubric:/i);
  assert.match(content[0].text, /custom review constraints:/i);
  assert.match(content[0].text, /squat frog silhouette/i);
  assert.deepEqual(
    content.slice(1).map((item) => item.type),
    ["input_image", "input_image", "input_image", "input_image", "input_file", "input_file"],
  );
});

test("buildVlmReviewRequest supports OpenRouter chat completions with inline bundle and prompt text", () => {
  const screenshotBytes = Buffer.from([0x89, 0x50, 0x4e, 0x47]);
  const bundleText =
    '{"target_file":"tools/modeling3d/examples/model_authoring/src/model_doc.mbt","patch_payload":{"manual_issue_details":[]}}';
  const promptText = "# Kagura review prompt\nReview the imported GLB diff.";

  const payload = buildVlmReviewRequest({
    provider: "openrouter",
    model: "google/gemini-2.5-flash",
    screenshot: {
      path: "output/playwright/model-authoring.png",
      bytes: screenshotBytes,
    },
    bundle: {
      path: "output/playwright/vlm_bundle.json",
      text: bundleText,
    },
    prompt: {
      path: "output/playwright/vlm_review.md",
      text: promptText,
    },
  });

  assert.equal(payload.model, "google/gemini-2.5-flash");
  assert.equal(payload.messages.length, 1);
  assert.equal(payload.messages[0].role, "user");
  assert.equal(payload.response_format.type, "json_schema");
  assert.equal(payload.response_format.json_schema.name, "kagura_vlm_review");
  assert.deepEqual(
    payload.messages[0].content.map((item) => item.type),
    ["text", "image_url", "text", "text"],
  );
  assert.match(payload.messages[0].content[0].text, /inline bundle json/i);
  assert.match(payload.messages[0].content[0].text, /do not echo current_document/i);
  assert.match(payload.messages[0].content[0].text, /overall_summary/i);
  assert.match(payload.messages[0].content[0].text, /review_missing/i);
  assert.match(payload.messages[0].content[0].text, /visual findings must include source_id/i);
  assert.deepEqual(payload.messages[0].content[1].image_url, {
    url: createDataUrl("image/png", screenshotBytes),
  });
  assert.match(payload.messages[0].content[2].text, /```json/);
  assert.match(payload.messages[0].content[2].text, /manual_issue_details/);
  assert.match(payload.messages[0].content[3].text, /```markdown/);
  assert.match(payload.messages[0].content[3].text, /Review the imported GLB diff/);
});

test("buildVlmReviewInstructions uses bundle review profile and constraints", () => {
  const instructions = buildVlmReviewInstructions({
    provider: "openrouter",
    screenshotPaths: [
      { label: "angled", path: "frog-angled.png" },
      { label: "front", path: "frog-front.png" },
      { label: "side", path: "frog-side.png" },
      { label: "top", path: "frog-top.png" },
    ],
    bundlePath: "vlm_frog_study_vlm_bundle.json",
    promptPath: "vlm_frog_study_vlm_review.md",
    bundleText: JSON.stringify({
      target_file: "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt",
      review_profile: "organic_character",
      review_constraints: [
        "Aim for a squat frog silhouette instead of a generic blob.",
        "Eyes should remain a deliberate paired feature.",
      ],
      patch_payload: { manual_issue_details: [] },
    }),
  });

  assert.match(instructions, /organic character rubric:/i);
  assert.match(instructions, /paired landmarks should read as a deliberate set/i);
  assert.match(instructions, /helper or debug primitives/i);
  assert.match(instructions, /source_id `scene` and area `scene_overview`/i);
  assert.match(instructions, /custom review constraints:/i);
  assert.match(instructions, /squat frog silhouette/i);
  assert.match(instructions, /angled:frog-angled\.png/i);
});

test("buildVlmReviewInstructions falls back to legacy target_file inference", () => {
  const instructions = buildVlmReviewInstructions({
    provider: "openrouter",
    screenshotPaths: [{ label: "angled", path: "chair-angled.png" }],
    bundlePath: "vlm_chair_study_vlm_bundle.json",
    promptPath: "vlm_chair_study_vlm_review.md",
    bundleText:
      '{"target_file":"tools/modeling3d/examples/chair_authoring/src/model_doc.mbt","patch_payload":{"manual_issue_details":[]}}',
  });

  assert.match(instructions, /hard-surface prop rubric:/i);
  assert.match(instructions, /major planes and support elements should remain readable/i);
});

test("buildVlmReviewInstructions infers hard-surface rubric for shelf target files", () => {
  const instructions = buildVlmReviewInstructions({
    provider: "openrouter",
    screenshotPaths: [{ label: "angled", path: "shelf-angled.png" }],
    bundlePath: "vlm_shelf_study_vlm_bundle.json",
    promptPath: "vlm_shelf_study_vlm_review.md",
    bundleText:
      '{"target_file":"tools/modeling3d/examples/shelf_authoring/src/model_doc.mbt","patch_payload":{"manual_issue_details":[]}}',
  });

  assert.match(instructions, /hard-surface prop rubric:/i);
  assert.match(instructions, /major planes and support elements should remain readable/i);
  assert.match(instructions, /review_alignment/i);
  assert.match(instructions, /review_overlap/i);
  assert.match(instructions, /exactly one source_id per item/i);
});

test("buildVlmReviewInstructions adapts to current-state review bundles", () => {
  const instructions = buildVlmReviewInstructions({
    provider: "openrouter",
    screenshotPaths: [
      { label: "angled", path: "frog-angled.png" },
      { label: "front", path: "frog-front.png" },
      { label: "side", path: "frog-side.png" },
      { label: "top", path: "frog-top.png" },
    ],
    bundlePath: "current-state-vlm-bundle.json",
    promptPath: "current-state-vlm-review.md",
    bundleText: JSON.stringify({
      review_mode: "current_state",
      target_file: "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt",
      review_profile: "organic_character",
      review_constraints: [
        "Aim for a squat frog silhouette instead of a generic blob.",
      ],
      current_document: {
        stats: { primitive_count: 3 },
      },
      patch_payload: {
        auto_actions: [],
        manual_actions: [],
        manual_issue_details: [],
      },
    }),
  });

  assert.match(instructions, /current workbench state/i);
  assert.match(instructions, /Do not assume a round-trip diff is attached/i);
  assert.match(instructions, /Prefer `edit_model_doc` or `manual_sculpt_review`/i);
  assert.match(instructions, /organic character rubric:/i);
  assert.match(instructions, /squat frog silhouette/i);
});

test("buildVlmReviewInstructions describes single-image atlas captures", () => {
  const instructions = buildVlmReviewInstructions({
    provider: "openrouter",
    screenshotPaths: [
      {
        label: "atlas:angled,front,side,top",
        path: "frog-atlas.png",
      },
    ],
    bundlePath: "current-state-vlm-bundle.json",
    promptPath: "current-state-vlm-review.md",
    bundleText: JSON.stringify({
      review_mode: "current_state",
      target_file: "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt",
      review_profile: "organic_character",
      review_constraints: [],
      current_document: {},
      patch_payload: {
        auto_actions: [],
        manual_actions: [],
        manual_issue_details: [],
      },
    }),
  });

  assert.match(instructions, /single image atlas/i);
  assert.match(instructions, /angled, front, side, top/i);
});

test("manual_followups issue_kind schema is fixed to roundtrip review enums", () => {
  assert.deepEqual(
    VLM_REVIEW_RESPONSE_SCHEMA.properties.manual_followups.items.properties.issue_kind.enum,
    [
      "review_missing",
      "review_extra",
      "review_stamp_count",
      "review_node_kind",
      "review_alignment",
      "review_overlap",
    ],
  );
});

test("visual_findings area schema is fixed to canonical review enums", () => {
  assert.deepEqual(
    VLM_REVIEW_RESPONSE_SCHEMA.properties.visual_findings.items.properties.area.enum,
    [
      "primitive_transform",
      "primitive_color",
      "sculpt_stamp_count",
      "node_inventory",
      "scene_overview",
    ],
  );
  assert.deepEqual(
    VLM_REVIEW_RESPONSE_SCHEMA.properties.visual_findings.items.required,
    ["source_id", "area", "observation", "impact"],
  );
});

test("resolveVlmReviewApiConfig returns provider-specific defaults", () => {
  assert.deepEqual(resolveVlmReviewApiConfig({}), {
    provider: "openai",
    preset: null,
    model: "gpt-5",
    modelCandidates: ["gpt-5"],
    apiUrl: "https://api.openai.com/v1/responses",
    apiKeyEnv: "OPENAI_API_KEY",
  });
  assert.deepEqual(resolveVlmReviewApiConfig({ provider: "openrouter" }), {
    provider: "openrouter",
    preset: "preview",
    model: "google/gemini-3.1-flash-lite-preview",
    modelCandidates: [
      "google/gemini-3.1-flash-lite-preview",
      "mistralai/mistral-small-3.1-24b-instruct:free",
      "google/gemma-3-27b-it:free",
      "google/gemma-3-4b-it:free",
    ],
    apiUrl: "https://openrouter.ai/api/v1/chat/completions",
    apiKeyEnv: "OPENROUTER_API_KEY",
  });
});

test("resolveOpenRouterVisionPreset maps free, preview, fast, balanced, and quality tiers", () => {
  assert.equal(
    resolveOpenRouterVisionPreset("free"),
    "mistralai/mistral-small-3.1-24b-instruct:free",
  );
  assert.equal(
    resolveOpenRouterVisionPreset("preview"),
    "google/gemini-3.1-flash-lite-preview",
  );
  assert.equal(resolveOpenRouterVisionPreset("fast"), "google/gemini-2.5-flash-lite");
  assert.equal(resolveOpenRouterVisionPreset("balanced"), "google/gemini-2.5-flash");
  assert.equal(resolveOpenRouterVisionPreset("quality"), "anthropic/claude-sonnet-4.5");
  assert.throws(() => resolveOpenRouterVisionPreset("unknown"), /unsupported OpenRouter preset/);
});

test("resolveVlmReviewApiConfig resolves OpenRouter presets before model overrides", () => {
  assert.deepEqual(
    resolveVlmReviewApiConfig({ provider: "openrouter", preset: "preview" }),
    {
      provider: "openrouter",
      preset: "preview",
      model: "google/gemini-3.1-flash-lite-preview",
      modelCandidates: [
        "google/gemini-3.1-flash-lite-preview",
        "mistralai/mistral-small-3.1-24b-instruct:free",
        "google/gemma-3-27b-it:free",
        "google/gemma-3-4b-it:free",
      ],
      apiUrl: "https://openrouter.ai/api/v1/chat/completions",
      apiKeyEnv: "OPENROUTER_API_KEY",
    },
  );
  assert.deepEqual(
    resolveVlmReviewApiConfig({ provider: "openrouter", preset: "fast" }),
    {
      provider: "openrouter",
      preset: "fast",
      model: "google/gemini-2.5-flash-lite",
      modelCandidates: ["google/gemini-2.5-flash-lite"],
      apiUrl: "https://openrouter.ai/api/v1/chat/completions",
      apiKeyEnv: "OPENROUTER_API_KEY",
    },
  );
  assert.deepEqual(
    resolveVlmReviewApiConfig({
      provider: "openrouter",
      preset: "quality",
      model: "google/gemini-2.5-flash",
    }),
    {
      provider: "openrouter",
      preset: "quality",
      model: "google/gemini-2.5-flash",
      modelCandidates: ["google/gemini-2.5-flash"],
      apiUrl: "https://openrouter.ai/api/v1/chat/completions",
      apiKeyEnv: "OPENROUTER_API_KEY",
    },
  );
});

test("resolveVlmReviewApiConfig expands free preset into fallback candidates", () => {
  assert.deepEqual(
    resolveVlmReviewApiConfig({ provider: "openrouter", preset: "free" }),
    {
      provider: "openrouter",
      preset: "free",
      model: "mistralai/mistral-small-3.1-24b-instruct:free",
      modelCandidates: [
        "mistralai/mistral-small-3.1-24b-instruct:free",
        "google/gemma-3-27b-it:free",
        "google/gemma-3-4b-it:free",
      ],
      apiUrl: "https://openrouter.ai/api/v1/chat/completions",
      apiKeyEnv: "OPENROUTER_API_KEY",
    },
  );
});

test("buildVlmReviewHeaders adds OpenRouter ranking headers", () => {
  const headers = buildVlmReviewHeaders({
    provider: "openrouter",
    apiKey: "test-key",
    requestId: "req-123",
  });

  assert.equal(headers.Authorization, "Bearer test-key");
  assert.equal(headers["Content-Type"], "application/json");
  assert.equal(headers["X-Client-Request-Id"], "req-123");
  assert.equal(headers["HTTP-Referer"], "https://github.com/mizchi/kagura");
  assert.equal(headers["X-Title"], "kagura-model-authoring");
});

test("extractStructuredReview parses top-level output_text JSON", () => {
  const expected = {
    target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
    overall_summary: "Apply the pedestal transform patch and review sculpt drift manually.",
    confidence: "high",
    recommended_actions: [],
    manual_followups: [],
    visual_findings: [],
    source_summaries: [],
    source_digests: [],
    source_report_lines: [],
    source_report: "",
    source_task_queue: [],
    source_task_report_lines: [],
    source_task_report: "",
    pr_comment_lines: [
      "## Kagura VLM Review",
      "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
      "- Confidence: `high`",
      "- Summary: Apply the pedestal transform patch and review sculpt drift manually.",
    ],
    pr_comment_markdown: [
      "## Kagura VLM Review",
      "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
      "- Confidence: `high`",
      "- Summary: Apply the pedestal transform patch and review sculpt drift manually.",
    ].join("\n"),
  };

  assert.deepEqual(
    extractStructuredReview({ output_text: JSON.stringify(expected) }),
    expected,
  );
});

test("extractStructuredReview falls back to message content text", () => {
  const expected = {
    target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
    overall_summary: "Review the helper primitive before appending it.",
    confidence: "medium",
    recommended_actions: [],
    manual_followups: [],
    visual_findings: [],
    source_summaries: [],
    source_digests: [],
    source_report_lines: [],
    source_report: "",
    source_task_queue: [],
    source_task_report_lines: [],
    source_task_report: "",
    pr_comment_lines: [
      "## Kagura VLM Review",
      "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
      "- Confidence: `medium`",
      "- Summary: Review the helper primitive before appending it.",
    ],
    pr_comment_markdown: [
      "## Kagura VLM Review",
      "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
      "- Confidence: `medium`",
      "- Summary: Review the helper primitive before appending it.",
    ].join("\n"),
  };

  assert.deepEqual(
    extractStructuredReview({
      output: [
        {
          type: "message",
          content: [
            {
              type: "output_text",
              text: JSON.stringify(expected),
            },
          ],
        },
      ],
    }),
    expected,
  );
});

test("extractStructuredReview parses OpenRouter chat completions output", () => {
  const expected = {
    target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
    overall_summary: "Use the safe auto patch and review the sculpt layer manually.",
    confidence: "medium",
    recommended_actions: [],
    manual_followups: [],
    visual_findings: [],
    source_summaries: [],
    source_digests: [],
    source_report_lines: [],
    source_report: "",
    source_task_queue: [],
    source_task_report_lines: [],
    source_task_report: "",
    pr_comment_lines: [
      "## Kagura VLM Review",
      "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
      "- Confidence: `medium`",
      "- Summary: Use the safe auto patch and review the sculpt layer manually.",
    ],
    pr_comment_markdown: [
      "## Kagura VLM Review",
      "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
      "- Confidence: `medium`",
      "- Summary: Use the safe auto patch and review the sculpt layer manually.",
    ].join("\n"),
  };

  assert.deepEqual(
    extractStructuredReview({
      choices: [
        {
          message: {
            content: JSON.stringify(expected),
          },
        },
      ],
    }),
    expected,
  );
});

test("extractStructuredReview strips fenced JSON blocks from OpenRouter output", () => {
  const expected = {
    target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
    overall_summary: "Use the safe auto patch and review the sculpt layer manually.",
    confidence: "medium",
    recommended_actions: [],
    manual_followups: [],
    visual_findings: [],
    source_summaries: [],
    source_digests: [],
    source_report_lines: [],
    source_report: "",
    source_task_queue: [],
    source_task_report_lines: [],
    source_task_report: "",
    pr_comment_lines: [
      "## Kagura VLM Review",
      "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
      "- Confidence: `medium`",
      "- Summary: Use the safe auto patch and review the sculpt layer manually.",
    ],
    pr_comment_markdown: [
      "## Kagura VLM Review",
      "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
      "- Confidence: `medium`",
      "- Summary: Use the safe auto patch and review the sculpt layer manually.",
    ].join("\n"),
  };

  assert.deepEqual(
    extractStructuredReview({
      choices: [
        {
          message: {
            content: `\`\`\`json\n${JSON.stringify(expected, null, 2)}\n\`\`\``,
          },
        },
      ],
    }),
    expected,
  );
});

test("extractStructuredReview normalizes legacy manual issue kinds", () => {
  const review = extractStructuredReview({
    choices: [
      {
        message: {
          content: JSON.stringify({
            target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
            overall_summary: "summary",
            confidence: "high",
            recommended_actions: [],
            manual_followups: [
              {
                source_id: "guide_orb",
                issue_kind: "missing_node",
                next_step: "review",
                rationale: "missing",
              },
              {
                source_id: "blender_helper",
                issue_kind: "extra_primitive",
                next_step: "review",
                rationale: "extra",
              },
              {
                source_id: "clay_head",
                issue_kind: "stamp_count_mismatch",
                next_step: "review",
                rationale: "stamp",
              },
            ],
            visual_findings: [],
          }),
        },
      },
    ],
  });

  assert.deepEqual(
    review.manual_followups.map((item) => item.issue_kind),
    ["review_missing", "review_extra", "review_stamp_count"],
  );
});

test("extractStructuredReview reclassifies node-kind followups into alignment and overlap issues", () => {
  const review = extractStructuredReview({
    choices: [
      {
        message: {
          content: JSON.stringify({
            target_file: "tools/modeling3d/examples/shelf_authoring/src/model_doc.mbt",
            overall_summary: "summary",
            confidence: "high",
            recommended_actions: [],
            manual_followups: [
              {
                source_id: "crate_left",
                issue_kind: "review_node_kind",
                next_step: "realign the crate with the middle shelf plane",
                rationale: "the prop is misaligned and floating above the shelf",
              },
              {
                source_id: "crate_right",
                issue_kind: "review_node_kind",
                next_step: "separate the props to remove clipping",
                rationale: "the props overlap and intersect from the front view",
              },
              {
                source_id: "storage_box",
                issue_kind: "node_kind_mismatch",
                next_step: "verify the node kind metadata",
                rationale: "kind metadata disagrees with the current source model",
              },
            ],
            visual_findings: [],
          }),
        },
      },
    ],
  });

  assert.deepEqual(
    review.manual_followups.map((item) => item.issue_kind),
    ["review_alignment", "review_overlap", "review_node_kind"],
  );
});

test("extractStructuredReview splits composite source_id values into one item per source", () => {
  const review = extractStructuredReview({
    choices: [
      {
        message: {
          content: JSON.stringify({
            target_file: "tools/modeling3d/examples/shelf_authoring/src/model_doc.mbt",
            overall_summary: "summary",
            confidence: "high",
            recommended_actions: [
              {
                priority: "medium",
                action: "edit_model_doc",
                source_id: "crate_left, crate_right",
                rationale: "realign both crates",
                suggested_moonbit: "patch",
              },
            ],
            manual_followups: [
              {
                source_id: "crate_left and crate_right",
                issue_kind: "review_overlap",
                next_step: "separate the props",
                rationale: "the top shelf props are clipping together",
              },
            ],
            visual_findings: [
              {
                source_id: "crate_left / crate_right",
                area: "primitive_transform",
                observation: "both crates feel offset from the shelf edge",
                impact: "the shelf reads as cluttered",
              },
            ],
          }),
        },
      },
    ],
  });

  assert.deepEqual(
    review.recommended_actions.map((item) => item.source_id),
    ["crate_left", "crate_right"],
  );
  assert.deepEqual(
    review.manual_followups.map((item) => item.source_id),
    ["crate_left", "crate_right"],
  );
  assert.deepEqual(
    review.visual_findings.map((item) => item.source_id),
    ["crate_left", "crate_right"],
  );
});

test("extractStructuredReview expands manual and visual source ids from related source mentions", () => {
  const review = extractStructuredReview({
    choices: [
      {
        message: {
          content: JSON.stringify({
            target_file: "tools/modeling3d/examples/shelf_authoring/src/model_doc.mbt",
            overall_summary: "summary",
            confidence: "high",
            recommended_actions: [],
            manual_followups: [
              {
                source_id: "crate_left",
                issue_kind: "review_overlap",
                next_step: "Adjust crate_left and crate_right positions to avoid intersecting.",
                rationale: "The middle shelf props are clipping together.",
              },
            ],
            visual_findings: [
              {
                source_id: "crate_left",
                area: "primitive_transform",
                observation: "Crate_left and crate_right overlap significantly with the book_stack primitive.",
                impact: "Creates visual Z-fighting and non-physical object behavior.",
              },
            ],
          }),
        },
      },
    ],
  });

  assert.deepEqual(
    review.manual_followups.map((item) => item.source_id),
    ["crate_left", "crate_right"],
  );
  assert.deepEqual(
    review.visual_findings.map((item) => item.source_id),
    ["crate_left", "crate_right", "book_stack"],
  );
});

test("extractStructuredReview normalizes legacy visual finding areas", () => {
  const review = extractStructuredReview({
    choices: [
      {
        message: {
          content: JSON.stringify({
            target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
            overall_summary: "summary",
            confidence: "high",
            recommended_actions: [],
            manual_followups: [],
            visual_findings: [
              {
                area: "Pedestal Primitive",
                observation: "moved",
                impact: "shifted",
              },
              {
                area: "Clay Sculpt",
                observation: "stamp mismatch",
                impact: "topology drift",
              },
              {
                area: "Node Consistency",
                observation: "missing guide_orb and added blender_helper",
                impact: "inventory drift",
              },
            ],
          }),
        },
      },
    ],
  });

  assert.deepEqual(
    review.visual_findings.map((item) => ({
      source_id: item.source_id,
      area: item.area,
    })),
    [
      { source_id: "pedestal", area: "primitive_transform" },
      { source_id: "clay_head", area: "sculpt_stamp_count" },
      { source_id: "scene", area: "node_inventory" },
    ],
  );
});

test("extractStructuredReview keeps explicit visual finding source_id values", () => {
  const review = extractStructuredReview({
    choices: [
      {
        message: {
          content: JSON.stringify({
            target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
            overall_summary: "summary",
            confidence: "high",
            recommended_actions: [],
            manual_followups: [],
            visual_findings: [
              {
                source_id: "pedestal",
                area: "primitive_transform",
                observation: "moved",
                impact: "shifted",
              },
            ],
          }),
        },
      },
    ],
  });

  assert.equal(review.visual_findings[0].source_id, "pedestal");
});

test("extractStructuredReview rejects JSON that does not match the review schema", () => {
  assert.throws(
    () =>
      extractStructuredReview({
        choices: [
          {
            message: {
              content: JSON.stringify({
                target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
                patch_payload: {},
              }),
            },
          },
        ],
      }),
    /missing required review field: overall_summary/,
  );
});

test("extractStructuredReview rejects unknown manual issue kinds", () => {
  assert.throws(
    () =>
      extractStructuredReview({
        choices: [
          {
            message: {
              content: JSON.stringify({
                target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
                overall_summary: "summary",
                confidence: "high",
                recommended_actions: [],
                manual_followups: [
                  {
                    source_id: "guide_orb",
                    issue_kind: "unexpected_kind",
                    next_step: "review",
                    rationale: "unknown",
                  },
                ],
                visual_findings: [],
              }),
            },
          },
        ],
      }),
    /issue_kind must be one of/,
  );
});

test("extractStructuredReview rejects unknown visual finding areas", () => {
  assert.throws(
    () =>
      extractStructuredReview({
        choices: [
          {
            message: {
              content: JSON.stringify({
                target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
                overall_summary: "summary",
                confidence: "high",
                recommended_actions: [],
                manual_followups: [],
                visual_findings: [
                  {
                    area: "totally_unknown_area",
                    observation: "unknown",
                    impact: "unknown",
                  },
                ],
              }),
            },
          },
        ],
      }),
    /visual_findings.area must be one of/,
  );
});

test("extractStructuredReview rejects non-string visual finding source_id", () => {
  assert.throws(
    () =>
      extractStructuredReview({
        choices: [
          {
            message: {
              content: JSON.stringify({
                target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
                overall_summary: "summary",
                confidence: "high",
                recommended_actions: [],
                manual_followups: [],
                visual_findings: [
                  {
                    source_id: 1,
                    area: "primitive_transform",
                    observation: "unknown",
                    impact: "unknown",
                  },
                ],
              }),
            },
          },
        ],
      }),
    /visual_findings.source_id must be a non-empty string/,
  );
});

test("extractStructuredReview rejects wrong confidence and item shapes", () => {
  assert.throws(
    () =>
      extractStructuredReview({
        choices: [
          {
            message: {
              content: JSON.stringify({
                target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
                overall_summary: "summary",
                confidence: 0.9,
                recommended_actions: ["apply"],
                manual_followups: [],
                visual_findings: [],
              }),
            },
          },
        ],
      }),
    /confidence must be one of: low, medium, high/,
  );
});

test("extractStructuredReview rejects invalid recommended action enums", () => {
  assert.throws(
    () =>
      extractStructuredReview({
        choices: [
          {
            message: {
              content: JSON.stringify({
                target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
                overall_summary: "summary",
                confidence: "high",
                recommended_actions: [
                  {
                    priority: "urgent",
                    action: "apply_auto_patch",
                    source_id: "pedestal",
                    rationale: "reason",
                    suggested_moonbit: "patch",
                  },
                ],
                manual_followups: [],
                visual_findings: [],
              }),
            },
          },
        ],
      }),
    /priority must be one of/,
  );
});

test("extractStructuredReview rejects non-string recommended action source_id", () => {
  assert.throws(
    () =>
      extractStructuredReview({
        choices: [
          {
            message: {
              content: JSON.stringify({
                target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
                overall_summary: "summary",
                confidence: "high",
                recommended_actions: [
                  {
                    priority: "high",
                    action: "apply_auto_patch",
                    source_id: 1,
                    rationale: "reason",
                    suggested_moonbit: "patch",
                  },
                ],
                manual_followups: [],
                visual_findings: [],
              }),
            },
          },
        ],
      }),
    /recommended_actions.source_id must be a non-empty string/,
  );
});

test("extractStructuredReview rejects non-string manual followup source_id", () => {
  assert.throws(
    () =>
      extractStructuredReview({
        choices: [
          {
            message: {
              content: JSON.stringify({
                target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
                overall_summary: "summary",
                confidence: "high",
                recommended_actions: [],
                manual_followups: [
                  {
                    source_id: 1,
                    issue_kind: "review_missing",
                    next_step: "review",
                    rationale: "missing",
                  },
                ],
                visual_findings: [],
              }),
            },
          },
        ],
      }),
    /manual_followups.source_id must be a non-empty string/,
  );
});

test("enrichStructuredReview groups actions and findings by source_id", () => {
  const review = enrichStructuredReview({
    target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
    overall_summary: "summary",
    confidence: "high",
    recommended_actions: [
      {
        priority: "high",
        action: "apply_auto_patch",
        source_id: "pedestal",
        rationale: "reason",
        suggested_moonbit: "patch",
      },
    ],
    manual_followups: [
      {
        source_id: "guide_orb",
        issue_kind: "review_missing",
        next_step: "review",
        rationale: "missing",
      },
      {
        source_id: "clay_head",
        issue_kind: "review_stamp_count",
        next_step: "review",
        rationale: "stamp",
      },
    ],
    visual_findings: [
      {
        source_id: "pedestal",
        area: "primitive_transform",
        observation: "moved",
        impact: "shifted",
      },
      {
        source_id: "scene",
        area: "scene_overview",
        observation: "overall drift",
        impact: "needs review",
      },
    ],
  });

  assert.deepEqual(review.source_summaries, [
    {
      source_id: "pedestal",
      recommended_actions: [
        {
          priority: "high",
          action: "apply_auto_patch",
          source_id: "pedestal",
          rationale: "reason",
          suggested_moonbit: "patch",
        },
      ],
      manual_followups: [],
      visual_findings: [
        {
          source_id: "pedestal",
          area: "primitive_transform",
          observation: "moved",
          impact: "shifted",
        },
      ],
    },
    {
      source_id: "guide_orb",
      recommended_actions: [],
      manual_followups: [
        {
          source_id: "guide_orb",
          issue_kind: "review_missing",
          next_step: "review",
          rationale: "missing",
        },
      ],
      visual_findings: [],
    },
    {
      source_id: "clay_head",
      recommended_actions: [],
      manual_followups: [
        {
          source_id: "clay_head",
          issue_kind: "review_stamp_count",
          next_step: "review",
          rationale: "stamp",
        },
      ],
      visual_findings: [],
    },
    {
      source_id: "scene",
      recommended_actions: [],
      manual_followups: [],
      visual_findings: [
        {
          source_id: "scene",
          area: "scene_overview",
          observation: "overall drift",
          impact: "needs review",
        },
      ],
    },
  ]);
  assert.deepEqual(review.source_digests, [
    {
      source_id: "pedestal",
      patch_candidate: true,
      manual_review_required: false,
      recommended_action_types: ["apply_auto_patch"],
      manual_issue_kinds: [],
      visual_areas: ["primitive_transform"],
      summary_line: "pedestal: patch apply_auto_patch; visual primitive_transform",
    },
    {
      source_id: "guide_orb",
      patch_candidate: false,
      manual_review_required: true,
      recommended_action_types: [],
      manual_issue_kinds: ["review_missing"],
      visual_areas: [],
      summary_line: "guide_orb: manual review_missing",
    },
    {
      source_id: "clay_head",
      patch_candidate: false,
      manual_review_required: true,
      recommended_action_types: [],
      manual_issue_kinds: ["review_stamp_count"],
      visual_areas: [],
      summary_line: "clay_head: manual review_stamp_count",
    },
    {
      source_id: "scene",
      patch_candidate: false,
      manual_review_required: false,
      recommended_action_types: [],
      manual_issue_kinds: [],
      visual_areas: ["scene_overview"],
      summary_line: "scene: visual scene_overview",
    },
  ]);
  assert.deepEqual(review.source_report_lines, [
    "pedestal: patch apply_auto_patch; visual primitive_transform",
    "guide_orb: manual review_missing",
    "clay_head: manual review_stamp_count",
    "scene: visual scene_overview",
  ]);
  assert.equal(
    review.source_report,
    [
      "pedestal: patch apply_auto_patch; visual primitive_transform",
      "guide_orb: manual review_missing",
      "clay_head: manual review_stamp_count",
      "scene: visual scene_overview",
    ].join("\n"),
  );
  assert.deepEqual(review.source_task_queue, [
    {
      source_id: "pedestal",
      priority: "high",
      task_type: "apply_patch",
      blocking: false,
      recommended_action_types: ["apply_auto_patch"],
      manual_issue_kinds: [],
      visual_areas: ["primitive_transform"],
      summary_line:
        "[high] pedestal apply_patch: patch apply_auto_patch; visual primitive_transform",
    },
    {
      source_id: "guide_orb",
      priority: "high",
      task_type: "manual_review",
      blocking: true,
      recommended_action_types: [],
      manual_issue_kinds: ["review_missing"],
      visual_areas: [],
      summary_line: "[high] guide_orb manual_review: manual review_missing",
    },
    {
      source_id: "clay_head",
      priority: "medium",
      task_type: "manual_review",
      blocking: true,
      recommended_action_types: [],
      manual_issue_kinds: ["review_stamp_count"],
      visual_areas: [],
      summary_line: "[medium] clay_head manual_review: manual review_stamp_count",
    },
    {
      source_id: "scene",
      priority: "low",
      task_type: "visual_check",
      blocking: false,
      recommended_action_types: [],
      manual_issue_kinds: [],
      visual_areas: ["scene_overview"],
      summary_line: "[low] scene visual_check: visual scene_overview",
    },
  ]);
  assert.deepEqual(review.source_task_report_lines, [
    "[high] pedestal apply_patch: patch apply_auto_patch; visual primitive_transform",
    "[high] guide_orb manual_review: manual review_missing",
    "[medium] clay_head manual_review: manual review_stamp_count",
    "[low] scene visual_check: visual scene_overview",
  ]);
  assert.equal(
    review.source_task_report,
    [
      "[high] pedestal apply_patch: patch apply_auto_patch; visual primitive_transform",
      "[high] guide_orb manual_review: manual review_missing",
      "[medium] clay_head manual_review: manual review_stamp_count",
      "[low] scene visual_check: visual scene_overview",
    ].join("\n"),
  );
  assert.deepEqual(review.pr_comment_lines, [
    "## Kagura VLM Review",
    "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
    "- Confidence: `high`",
    "- Summary: summary",
    "",
    "### Source Task Queue",
    "- [high] pedestal apply_patch: patch apply_auto_patch; visual primitive_transform",
    "- [high] guide_orb manual_review: manual review_missing",
    "- [medium] clay_head manual_review: manual review_stamp_count",
    "- [low] scene visual_check: visual scene_overview",
    "",
    "### Manual Followups",
    "- `guide_orb` review_missing: review",
    "- `clay_head` review_stamp_count: review",
    "",
    "### Visual Findings",
    "- `pedestal` primitive_transform: moved",
    "- `scene` scene_overview: overall drift",
  ]);
  assert.equal(
    review.pr_comment_markdown,
    [
      "## Kagura VLM Review",
      "- Target: `tools/modeling3d/examples/model_authoring/src/model_doc.mbt`",
      "- Confidence: `high`",
      "- Summary: summary",
      "",
      "### Source Task Queue",
      "- [high] pedestal apply_patch: patch apply_auto_patch; visual primitive_transform",
      "- [high] guide_orb manual_review: manual review_missing",
      "- [medium] clay_head manual_review: manual review_stamp_count",
      "- [low] scene visual_check: visual scene_overview",
      "",
      "### Manual Followups",
      "- `guide_orb` review_missing: review",
      "- `clay_head` review_stamp_count: review",
      "",
      "### Visual Findings",
      "- `pedestal` primitive_transform: moved",
      "- `scene` scene_overview: overall drift",
    ].join("\n"),
  );
});

test("enrichStructuredReview prioritizes alignment and overlap issues separately", () => {
  const review = enrichStructuredReview({
    target_file: "tools/modeling3d/examples/shelf_authoring/src/model_doc.mbt",
    overall_summary: "summary",
    confidence: "high",
    recommended_actions: [],
    manual_followups: [
      {
        source_id: "crate_left",
        issue_kind: "review_alignment",
        next_step: "realign it",
        rationale: "misaligned",
      },
      {
        source_id: "crate_right",
        issue_kind: "review_overlap",
        next_step: "separate it",
        rationale: "overlapping",
      },
    ],
    visual_findings: [],
  });

  assert.deepEqual(review.source_task_queue, [
    {
      source_id: "crate_left",
      priority: "high",
      task_type: "manual_review",
      blocking: true,
      recommended_action_types: [],
      manual_issue_kinds: ["review_alignment"],
      visual_areas: [],
      summary_line: "[high] crate_left manual_review: manual review_alignment",
    },
    {
      source_id: "crate_right",
      priority: "medium",
      task_type: "manual_review",
      blocking: true,
      recommended_action_types: [],
      manual_issue_kinds: ["review_overlap"],
      visual_areas: [],
      summary_line: "[medium] crate_right manual_review: manual review_overlap",
    },
  ]);
});
