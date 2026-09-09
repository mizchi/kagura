import { basename, extname } from "node:path";

const REVIEW_PRIORITY_VALUES = ["high", "medium", "low"];
const REVIEW_ACTION_VALUES = [
  "apply_auto_patch",
  "apply_opt_in_sync",
  "edit_model_doc",
  "manual_sculpt_review",
  "ignore",
];
const PATCH_CANDIDATE_ACTION_VALUES = [
  "apply_auto_patch",
  "apply_opt_in_sync",
  "edit_model_doc",
];
const REVIEW_PRIORITY_RANK = {
  high: 0,
  medium: 1,
  low: 2,
};
const REVIEW_MANUAL_ISSUE_KIND_VALUES = [
  "review_missing",
  "review_extra",
  "review_stamp_count",
  "review_node_kind",
  "review_alignment",
  "review_overlap",
];
const REVIEW_VISUAL_AREA_VALUES = [
  "primitive_transform",
  "primitive_color",
  "sculpt_stamp_count",
  "node_inventory",
  "scene_overview",
];
const SOURCE_ID_SPLIT_PATTERN = /\s*(?:,|\/|\||\+|&|\band\b)\s*/i;
const REVIEW_PROFILE_RUBRICS = {
  generic_model: [
    "Generic model rubric:",
    "- The silhouette should remain readable from angled, front, side, and top views.",
    "- Major forms should stay intentional and distinguishable instead of collapsing into an undifferentiated blob.",
    "- Helper or debug primitives should not be treated as part of the finished asset unless the bundle marks them as intentional.",
    "- Always include at least one visual_findings item with source_id `scene` and area `scene_overview` that judges whole-model readability across the multi-view screenshots.",
  ],
  hard_surface_prop: [
    "Hard-surface prop rubric:",
    "- Major planes and support elements should remain readable from front and side views.",
    "- Repeated or mirrored structural parts should stay aligned and proportionally consistent.",
    "- Seat, shelf, frame, or panel surfaces should look deliberate rather than warped organic masses.",
    "- Helper or debug primitives should not be treated as part of the finished asset unless the bundle marks them as intentional.",
    "- Always include at least one visual_findings item with source_id `scene` and area `scene_overview` that judges overall prop readability across the multi-view screenshots.",
  ],
  organic_character: [
    "Organic character rubric:",
    "- The silhouette should read as a deliberate creature or character, not a generic round blob.",
    "- Paired landmarks should read as a deliberate set from angled and front views.",
    "- Limb or appendage masses should remain visible as distinct volumes from side and angled views.",
    "- Mouth or facial landmark should remain legible from the front view.",
    "- Helper or debug primitives should not be treated as part of the finished asset unless the bundle marks them as intentional.",
    "- Always include at least one visual_findings item with source_id `scene` and area `scene_overview` that judges character readability across the multi-view screenshots.",
  ],
};

export const VLM_REVIEW_RESPONSE_SCHEMA = {
  type: "object",
  additionalProperties: false,
  required: [
    "target_file",
    "overall_summary",
    "confidence",
    "recommended_actions",
    "manual_followups",
    "visual_findings",
  ],
  properties: {
    target_file: { type: "string" },
    overall_summary: { type: "string" },
    confidence: {
      type: "string",
      enum: ["low", "medium", "high"],
    },
    recommended_actions: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: [
          "priority",
          "action",
          "source_id",
          "rationale",
          "suggested_moonbit",
        ],
        properties: {
          priority: {
            type: "string",
            enum: REVIEW_PRIORITY_VALUES,
          },
          action: {
            type: "string",
            enum: REVIEW_ACTION_VALUES,
          },
          source_id: { type: "string" },
          rationale: { type: "string" },
          suggested_moonbit: { type: "string" },
        },
      },
    },
    manual_followups: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["source_id", "issue_kind", "next_step", "rationale"],
        properties: {
          source_id: { type: "string" },
          issue_kind: {
            type: "string",
            enum: REVIEW_MANUAL_ISSUE_KIND_VALUES,
          },
          next_step: { type: "string" },
          rationale: { type: "string" },
        },
      },
    },
    visual_findings: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["source_id", "area", "observation", "impact"],
        properties: {
          source_id: { type: "string" },
          area: {
            type: "string",
            enum: REVIEW_VISUAL_AREA_VALUES,
          },
          observation: { type: "string" },
          impact: { type: "string" },
        },
      },
    },
  },
};

export function detectMimeType(path) {
  switch (extname(path).toLowerCase()) {
    case ".png":
      return "image/png";
    case ".jpg":
    case ".jpeg":
      return "image/jpeg";
    case ".webp":
      return "image/webp";
    case ".json":
      return "application/json";
    case ".md":
    case ".markdown":
      return "text/markdown";
    case ".txt":
      return "text/plain";
    default:
      return "application/octet-stream";
  }
}

export function createDataUrl(mimeType, bytes) {
  return `data:${mimeType};base64,${Buffer.from(bytes).toString("base64")}`;
}

export function normalizeVlmProvider(provider = "openai") {
  switch (String(provider).toLowerCase()) {
    case "openai":
      return "openai";
    case "openrouter":
      return "openrouter";
    default:
      throw new Error(`unsupported VLM provider: ${provider}`);
  }
}

export function resolveOpenRouterVisionPreset(preset = "balanced") {
  switch (String(preset).toLowerCase()) {
    case "free":
      return "mistralai/mistral-small-3.1-24b-instruct:free";
    case "preview":
      return "google/gemini-3.1-flash-lite-preview";
    case "fast":
      return "google/gemini-2.5-flash-lite";
    case "balanced":
      return "google/gemini-2.5-flash";
    case "quality":
      return "anthropic/claude-sonnet-4.5";
    default:
      throw new Error(`unsupported OpenRouter preset: ${preset}`);
  }
}

export function resolveOpenRouterVisionPresetModels(preset = "balanced") {
  const freeCandidates = [
    "mistralai/mistral-small-3.1-24b-instruct:free",
    "google/gemma-3-27b-it:free",
    "google/gemma-3-4b-it:free",
  ];
  switch (String(preset).toLowerCase()) {
    case "free":
      return freeCandidates;
    case "preview":
      return [
        "google/gemini-3.1-flash-lite-preview",
        ...freeCandidates,
      ];
    default:
      return [resolveOpenRouterVisionPreset(preset)];
  }
}

export function resolveVlmReviewApiConfig({
  provider = "openai",
  preset = null,
  model = null,
  apiUrl = null,
  apiKeyEnv = null,
} = {}) {
  const normalizedProvider = normalizeVlmProvider(provider);
  if (normalizedProvider === "openrouter") {
    const resolvedPreset = preset ?? "preview";
    const modelCandidates =
      model == null
        ? resolveOpenRouterVisionPresetModels(resolvedPreset)
        : [model];
    return {
      provider: normalizedProvider,
      preset: resolvedPreset,
      model: modelCandidates[0],
      modelCandidates,
      apiUrl: apiUrl ?? "https://openrouter.ai/api/v1/chat/completions",
      apiKeyEnv: apiKeyEnv ?? "OPENROUTER_API_KEY",
    };
  }
  return {
    provider: normalizedProvider,
    preset: null,
    model: model ?? "gpt-5",
    modelCandidates: [model ?? "gpt-5"],
    apiUrl: apiUrl ?? "https://api.openai.com/v1/responses",
    apiKeyEnv: apiKeyEnv ?? "OPENAI_API_KEY",
  };
}

export function buildVlmReviewInstructions({
  provider = "openai",
  screenshotPaths,
  bundlePath,
  promptPath,
  bundleText = "",
}) {
  const normalizedProvider = normalizeVlmProvider(provider);
  const reviewConfig = resolveBundleReviewConfig(bundleText);
  const screenshotNames = screenshotPaths.map(({ path, label }) =>
    `${label}:${basename(path)}`);
  const atlasLabel =
    screenshotPaths.length === 1 &&
      typeof screenshotPaths[0]?.label === "string" &&
      screenshotPaths[0].label.startsWith("atlas:")
      ? screenshotPaths[0].label.slice("atlas:".length)
      : null;
  const openingLine =
    reviewConfig.reviewMode === "current_state"
      ? "You are reviewing the current workbench state of a Kagura model_authoring session."
      : "You are reviewing a Kagura model_authoring round-trip diff.";
  const patchPolicyLine =
    reviewConfig.reviewMode === "current_state"
      ? "Do not assume a round-trip diff is attached. Prefer `edit_model_doc` or `manual_sculpt_review` unless the bundle already includes an explicitly safe patch payload."
      : "Recommend auto patch or opt-in sync only when the attached bundle already marks them as safe.";
  const echoLine =
    reviewConfig.reviewMode === "current_state"
      ? "Do not echo current_document or patch_payload verbatim."
      : "Do not echo current_document, roundtrip_report, or patch_payload verbatim.";
  return [
    openingLine,
    normalizedProvider === "openrouter"
      ? "Use the screenshot, the inline bundle JSON, and the inline Markdown review prompt together."
      : "Use the attached screenshot, the attached bundle JSON, and the attached Markdown review prompt together.",
    atlasLabel != null
      ? `Treat the single image atlas as a fixed 2x2 view sheet ordered as ${atlasLabel.split(",").join(", ")}.`
      : screenshotPaths.length > 1
      ? `Treat the images as fixed multi-view renders of the same model in this order: ${screenshotNames.join(", ")}.`
      : "Treat the image as a single reference render of the model.",
    "Prefer the smallest code-first update that keeps Kagura source ids stable.",
    "Do not invent sculpt stamps or topology edits that are not present in the attachments.",
    patchPolicyLine,
    echoLine,
    `Review profile: ${reviewConfig.profileId}`,
    ...reviewRubricLines(reviewConfig.profileId),
    ...(reviewConfig.constraints.length > 0
      ? [
          "Custom review constraints:",
          ...reviewConfig.constraints.map((line) => `- ${line}`),
        ]
      : []),
    "Required top-level keys: target_file, overall_summary, confidence, recommended_actions, manual_followups, visual_findings.",
    `Use only these recommended_actions.action values: ${REVIEW_ACTION_VALUES.join(", ")}.`,
    `Use only these manual_followups.issue_kind values: ${REVIEW_MANUAL_ISSUE_KIND_VALUES.join(", ")}.`,
    "For hard-surface placement problems, use `review_alignment` for misalignment, floating, or off-plane placement, and `review_overlap` for clipping or intersecting props.",
    `Use only these visual_findings.area values: ${REVIEW_VISUAL_AREA_VALUES.join(", ")}.`,
    "Use exactly one source_id per item. If the same issue applies to multiple sources, emit one item per source_id instead of joining ids with commas or `and`.",
    "Visual findings must include source_id. Use a Kagura source_id such as pedestal, clay_head, guide_orb, blender_helper, or scene.",
    `Screenshot files: ${screenshotNames.join(", ")}`,
    `Bundle JSON file: ${basename(bundlePath)}`,
    `Markdown review prompt file: ${basename(promptPath)}`,
    "Return JSON that matches the schema exactly.",
  ].join("\n");
}

function reviewRubricLines(profileId) {
  return REVIEW_PROFILE_RUBRICS[profileId] ?? REVIEW_PROFILE_RUBRICS.generic_model;
}

function normalizeReviewConstraints(value) {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .filter((item) => typeof item === "string")
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
}

function defaultReviewProfileForTargetFile(targetFile) {
  if (
    targetFile.includes("/frog_authoring/") ||
    targetFile.includes("/dragon_authoring/")
  ) {
    return "organic_character";
  }
  if (
    targetFile.includes("/chair_authoring/") ||
    targetFile.includes("/shelf_authoring/")
  ) {
    return "hard_surface_prop";
  }
  return "generic_model";
}

function resolveBundleReviewConfig(bundleText) {
  if (typeof bundleText !== "string" || bundleText.length === 0) {
    return {
      reviewMode: "roundtrip_diff",
      profileId: "generic_model",
      constraints: [],
    };
  }
  try {
    const parsed = JSON.parse(bundleText);
    const targetFile = String(parsed?.target_file ?? "");
    const reviewMode =
      String(parsed?.review_mode ?? "").trim() === "current_state"
        ? "current_state"
        : "roundtrip_diff";
    const explicitProfile = String(parsed?.review_profile ?? "").trim();
    const profileId =
      explicitProfile.length > 0 &&
        Object.hasOwn(REVIEW_PROFILE_RUBRICS, explicitProfile)
        ? explicitProfile
        : defaultReviewProfileForTargetFile(targetFile);
    return {
      reviewMode,
      profileId,
      constraints: normalizeReviewConstraints(parsed?.review_constraints),
    };
  } catch {
    return {
      reviewMode: "roundtrip_diff",
      profileId: "generic_model",
      constraints: [],
    };
  }
}

function createInputFilePart(path, bytes) {
  return {
    type: "input_file",
    filename: basename(path),
    file_data: createDataUrl(detectMimeType(path), bytes),
  };
}

function createInputImagePart(path, bytes) {
  return {
    type: "input_image",
    image_url: createDataUrl(detectMimeType(path), bytes),
  };
}

function createChatImagePart(path, bytes) {
  return {
    type: "image_url",
    image_url: {
      url: createDataUrl(detectMimeType(path), bytes),
    },
  };
}

function createInlineTextPart(label, filename, language, text) {
  return {
    type: "text",
    text: `${label}: ${basename(filename)}\n\`\`\`${language}\n${text}\n\`\`\``,
  };
}

function normalizeScreenshots({ screenshot, screenshots }) {
  if (Array.isArray(screenshots) && screenshots.length > 0) {
    return screenshots.map((entry, index) => ({
      label: entry?.label ?? `view_${index + 1}`,
      path: entry.path,
      bytes: entry.bytes,
    }));
  }
  if (screenshot != null) {
    return [
      {
        label: screenshot.label ?? "angled",
        path: screenshot.path,
        bytes: screenshot.bytes,
      },
    ];
  }
  throw new Error("at least one screenshot is required");
}

export function buildVlmReviewRequest({
  provider = "openai",
  model,
  screenshot,
  screenshots = null,
  bundle,
  prompt,
  store = false,
}) {
  const normalizedProvider = normalizeVlmProvider(provider);
  const normalizedScreenshots = normalizeScreenshots({ screenshot, screenshots });
  const instructions = buildVlmReviewInstructions({
    provider: normalizedProvider,
    screenshotPaths: normalizedScreenshots,
    bundlePath: bundle.path,
    promptPath: prompt.path,
    bundleText: bundle.text,
  });

  if (normalizedProvider === "openrouter") {
    return {
      model,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: instructions,
            },
            ...normalizedScreenshots.map((item) =>
              createChatImagePart(item.path, item.bytes)),
            createInlineTextPart(
              "Bundle JSON",
              bundle.path,
              "json",
              bundle.text,
            ),
            createInlineTextPart(
              "Markdown review prompt",
              prompt.path,
              "markdown",
              prompt.text,
            ),
          ],
        },
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "kagura_vlm_review",
          strict: true,
          schema: VLM_REVIEW_RESPONSE_SCHEMA,
        },
      },
    };
  }
  return {
    model,
    store,
    input: [
      {
        role: "user",
        content: [
          {
            type: "input_text",
            text: instructions,
          },
          ...normalizedScreenshots.map((item) =>
            createInputImagePart(item.path, item.bytes)),
          createInputFilePart(bundle.path, Buffer.from(bundle.text, "utf8")),
          createInputFilePart(prompt.path, Buffer.from(prompt.text, "utf8")),
        ],
      },
    ],
    text: {
      format: {
        type: "json_schema",
        name: "kagura_vlm_review",
        strict: true,
        schema: VLM_REVIEW_RESPONSE_SCHEMA,
      },
    },
  };
}

export function buildVlmReviewHeaders({
  provider = "openai",
  apiKey,
  requestId = null,
  referer = "https://github.com/mizchi/kagura",
  title = "kagura-model-authoring",
}) {
  const normalizedProvider = normalizeVlmProvider(provider);
  const headers = {
    Authorization: `Bearer ${apiKey}`,
    "Content-Type": "application/json",
  };
  if (requestId != null) {
    headers["X-Client-Request-Id"] = requestId;
  }
  if (normalizedProvider === "openrouter") {
    headers["HTTP-Referer"] = referer;
    headers["X-Title"] = title;
  }
  return headers;
}

function extractOutputTextFromContent(responseJson) {
  if (!Array.isArray(responseJson?.output)) {
    return null;
  }
  const textParts = [];
  for (const item of responseJson.output) {
    if (!Array.isArray(item?.content)) {
      continue;
    }
    for (const content of item.content) {
      if (
        (content?.type === "output_text" || content?.type === "text") &&
        typeof content.text === "string"
      ) {
        textParts.push(content.text);
      }
    }
  }
  if (textParts.length === 0) {
    return null;
  }
  return textParts.join("\n");
}

function extractOutputTextFromChoices(responseJson) {
  if (!Array.isArray(responseJson?.choices) || responseJson.choices.length === 0) {
    return null;
  }
  const content = responseJson.choices[0]?.message?.content;
  if (typeof content === "string" && content.length > 0) {
    return content;
  }
  if (!Array.isArray(content)) {
    return null;
  }
  const textParts = [];
  for (const item of content) {
    if (typeof item === "string") {
      textParts.push(item);
      continue;
    }
    if (typeof item?.text === "string" && item.text.length > 0) {
      textParts.push(item.text);
    }
  }
  if (textParts.length === 0) {
    return null;
  }
  return textParts.join("\n");
}

function normalizeJsonText(text) {
  const trimmed = text.trim();
  const fencedMatch = trimmed.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
  if (fencedMatch != null) {
    return fencedMatch[1].trim();
  }
  return trimmed;
}

function classifyNodeKindFollowup(item) {
  const haystack = `${String(item?.next_step ?? "")} ${String(item?.rationale ?? "")}`.toLowerCase();
  if (
    haystack.includes("overlap") ||
    haystack.includes("intersect") ||
    haystack.includes("clip") ||
    haystack.includes("clipping") ||
    haystack.includes("collision") ||
    haystack.includes("z-fighting") ||
    haystack.includes("z fighting")
  ) {
    return "review_overlap";
  }
  if (
    haystack.includes("align") ||
    haystack.includes("aligned") ||
    haystack.includes("misaligned") ||
    haystack.includes("offset") ||
    haystack.includes("floating") ||
    haystack.includes("center") ||
    haystack.includes("centred") ||
    haystack.includes("plane")
  ) {
    return "review_alignment";
  }
  return "review_node_kind";
}

function normalizeManualIssueKind(issueKind, item = null) {
  switch (issueKind) {
    case "missing_node":
    case "missing_primitive":
      return "review_missing";
    case "extra_node":
    case "extra_primitive":
      return "review_extra";
    case "stamp_count_mismatch":
    case "sculpt_topology_change":
      return "review_stamp_count";
    case "node_kind_mismatch":
      return "review_node_kind";
    case "review_node_kind":
      return classifyNodeKindFollowup(item);
    default:
      return issueKind;
  }
}

function normalizeVisualFindingArea(area) {
  const normalized = String(area).toLowerCase();
  if (
    normalized.includes("sculpt") ||
    normalized.includes("clay_head") ||
    normalized.includes("clay head") ||
    normalized.includes("stamp")
  ) {
    return "sculpt_stamp_count";
  }
  if (
    normalized.includes("node") ||
    normalized.includes("guide_orb") ||
    normalized.includes("guide orb") ||
    normalized.includes("blender_helper") ||
    normalized.includes("blender helper")
  ) {
    return "node_inventory";
  }
  if (normalized.includes("color") || normalized.includes("material")) {
    return "primitive_color";
  }
  if (
    normalized.includes("pedestal") ||
    normalized.includes("primitive") ||
    normalized.includes("alignment") ||
    normalized.includes("transform")
  ) {
    return "primitive_transform";
  }
  if (normalized.includes("scene") || normalized.includes("overview")) {
    return "scene_overview";
  }
  return area;
}

function inferVisualFindingSourceId(sourceId, area, observation) {
  if (sourceId != null) {
    if (typeof sourceId === "string" && sourceId.trim().length > 0) {
      return sourceId.trim();
    }
    return sourceId;
  }
  const haystack = `${String(area ?? "")} ${String(observation ?? "")}`.toLowerCase();
  const matches = [];
  const candidates = [
    ["pedestal", ["pedestal"]],
    ["clay_head", ["clay_head", "clay head", "clay sculpt"]],
    ["guide_orb", ["guide_orb", "guide orb"]],
    ["blender_helper", ["blender_helper", "blender helper"]],
    ["ground", ["ground"]],
  ];
  for (const [canonicalId, needles] of candidates) {
    if (needles.some((needle) => haystack.includes(needle))) {
      matches.push(canonicalId);
    }
  }
  if (matches.length === 1) {
    return matches[0];
  }
  return "scene";
}

function normalizeSourceIdToken(value) {
  if (typeof value !== "string") {
    return value;
  }
  return value
    .trim()
    .replace(/^`+|`+$/g, "")
    .replace(/[.。]+$/g, "")
    .trim();
}

function splitSourceIds(sourceId) {
  const normalized = normalizeSourceIdToken(sourceId);
  if (typeof normalized !== "string") {
    return [normalized];
  }
  if (normalized.length === 0) {
    return [normalized];
  }
  const parts = normalized
    .split(SOURCE_ID_SPLIT_PATTERN)
    .map((item) => normalizeSourceIdToken(item))
    .filter((item) => typeof item === "string" && item.length > 0);
  if (parts.length === 0) {
    return [normalized];
  }
  return Array.from(new Set(parts));
}

function extractMentionedSourceIds(text) {
  if (typeof text !== "string" || text.trim().length === 0) {
    return [];
  }
  const matches = text
    .toLowerCase()
    .match(/\b[a-z][a-z0-9]*(?:_[a-z0-9]+)+\b/g);
  if (matches == null) {
    return [];
  }
  return Array.from(new Set(matches.map((item) => item.trim())));
}

function expandSourceScopedItems(
  items,
  mapSourceId,
  {
    relatedTextFields = [],
    shouldExpandRelated = () => true,
  } = {},
) {
  if (!Array.isArray(items)) {
    return items;
  }
  return items.flatMap((item) => {
    if (item == null || typeof item !== "object" || Array.isArray(item)) {
      return [item];
    }
    const sourceIds = new Set(splitSourceIds(mapSourceId(item)));
    if (shouldExpandRelated(item)) {
      const relatedText = relatedTextFields
        .map((key) => item[key])
        .filter((value) => typeof value === "string")
        .join(" ");
      for (const sourceId of extractMentionedSourceIds(relatedText)) {
        if (sourceId !== "scene") {
          sourceIds.add(sourceId);
        }
      }
    }
    if (sourceIds.size === 0) {
      return [item];
    }
    return Array.from(sourceIds).map((sourceId) => ({
      ...item,
      source_id: sourceId,
    }));
  });
}

function normalizeStructuredReviewShape(parsed) {
  if (
    parsed == null ||
    typeof parsed !== "object" ||
    Array.isArray(parsed) ||
    !Array.isArray(parsed.manual_followups)
  ) {
    return parsed;
  }
  return {
    ...parsed,
    recommended_actions: expandSourceScopedItems(
      parsed.recommended_actions,
      (item) => item.source_id,
    ).map((item) =>
      item == null || typeof item !== "object" || Array.isArray(item)
        ? item
        : {
            ...item,
            source_id: normalizeSourceIdToken(item.source_id),
          },
    ),
    manual_followups: expandSourceScopedItems(
      parsed.manual_followups,
      (item) => item.source_id,
      {
        relatedTextFields: ["next_step", "rationale"],
      },
    ).map((item) =>
      item == null || typeof item !== "object" || Array.isArray(item)
        ? item
        : {
            ...item,
            source_id: normalizeSourceIdToken(item.source_id),
            issue_kind:
              typeof item.issue_kind === "string"
                ? normalizeManualIssueKind(item.issue_kind, item)
                : item.issue_kind,
          },
    ),
    visual_findings: Array.isArray(parsed.visual_findings)
      ? expandSourceScopedItems(
          parsed.visual_findings,
          (item) =>
            inferVisualFindingSourceId(
              item.source_id,
              item.area,
              item.observation,
            ),
          {
            relatedTextFields: ["observation", "impact"],
            shouldExpandRelated: (item) =>
              normalizeVisualFindingArea(item.area) !== "scene_overview" &&
              inferVisualFindingSourceId(
                item.source_id,
                item.area,
                item.observation,
              ) !== "scene",
          },
        ).map((item) =>
          item == null || typeof item !== "object" || Array.isArray(item)
            ? item
            : {
                ...item,
                source_id: normalizeSourceIdToken(item.source_id),
                area:
                  typeof item.area === "string"
                    ? normalizeVisualFindingArea(item.area)
                    : item.area,
              },
        )
      : parsed.visual_findings,
  };
}

function validateStructuredReviewShape(parsed) {
  if (parsed == null || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new Error("parsed review must be an object");
  }
  for (const key of VLM_REVIEW_RESPONSE_SCHEMA.required) {
    if (!(key in parsed)) {
      throw new Error(`missing required review field: ${key}`);
    }
  }
  if (!Array.isArray(parsed.recommended_actions)) {
    throw new Error("recommended_actions must be an array");
  }
  if (!Array.isArray(parsed.manual_followups)) {
    throw new Error("manual_followups must be an array");
  }
  if (!Array.isArray(parsed.visual_findings)) {
    throw new Error("visual_findings must be an array");
  }
  if (!["low", "medium", "high"].includes(parsed.confidence)) {
    throw new Error("confidence must be one of: low, medium, high");
  }
  for (const item of parsed.recommended_actions) {
    if (item == null || typeof item !== "object" || Array.isArray(item)) {
      throw new Error("recommended_actions items must be objects");
    }
    for (const key of ["priority", "action", "source_id", "rationale", "suggested_moonbit"]) {
      if (!(key in item)) {
        throw new Error(`recommended_actions items must include: ${key}`);
      }
    }
    if (!REVIEW_PRIORITY_VALUES.includes(item.priority)) {
      throw new Error(
        `priority must be one of: ${REVIEW_PRIORITY_VALUES.join(", ")}`,
      );
    }
    if (!REVIEW_ACTION_VALUES.includes(item.action)) {
      throw new Error(
        `action must be one of: ${REVIEW_ACTION_VALUES.join(", ")}`,
      );
    }
    if (typeof item.source_id !== "string" || item.source_id.trim().length === 0) {
      throw new Error("recommended_actions.source_id must be a non-empty string");
    }
  }
  for (const item of parsed.manual_followups) {
    if (item == null || typeof item !== "object" || Array.isArray(item)) {
      throw new Error("manual_followups items must be objects");
    }
    for (const key of ["source_id", "issue_kind", "next_step", "rationale"]) {
      if (!(key in item)) {
        throw new Error(`manual_followups items must include: ${key}`);
      }
    }
    if (!REVIEW_MANUAL_ISSUE_KIND_VALUES.includes(item.issue_kind)) {
      throw new Error(
        `issue_kind must be one of: ${REVIEW_MANUAL_ISSUE_KIND_VALUES.join(", ")}`,
      );
    }
    if (typeof item.source_id !== "string" || item.source_id.trim().length === 0) {
      throw new Error("manual_followups.source_id must be a non-empty string");
    }
  }
  for (const item of parsed.visual_findings) {
    if (item == null || typeof item !== "object" || Array.isArray(item)) {
      throw new Error("visual_findings items must be objects");
    }
    for (const key of ["source_id", "area", "observation", "impact"]) {
      if (!(key in item)) {
        throw new Error(`visual_findings items must include: ${key}`);
      }
    }
    if (typeof item.source_id !== "string" || item.source_id.trim().length === 0) {
      throw new Error("visual_findings.source_id must be a non-empty string");
    }
    if (!REVIEW_VISUAL_AREA_VALUES.includes(item.area)) {
      throw new Error(
        `visual_findings.area must be one of: ${REVIEW_VISUAL_AREA_VALUES.join(", ")}`,
      );
    }
  }
  return parsed;
}

function getSourceSummary(map, sourceId) {
  let summary = map.get(sourceId);
  if (summary == null) {
    summary = {
      source_id: sourceId,
      recommended_actions: [],
      manual_followups: [],
      visual_findings: [],
    };
    map.set(sourceId, summary);
  }
  return summary;
}

function uniqueValues(items, key) {
  return Array.from(
    new Set(
      items
        .map((item) => item[key])
        .filter((value) => typeof value === "string" && value.length > 0),
    ),
  );
}

function buildSourceDigest(summary) {
  const recommendedActionTypes = uniqueValues(summary.recommended_actions, "action");
  const manualIssueKinds = uniqueValues(summary.manual_followups, "issue_kind");
  const visualAreas = uniqueValues(summary.visual_findings, "area");
  const patchCandidate = recommendedActionTypes.some((action) =>
    PATCH_CANDIDATE_ACTION_VALUES.includes(action),
  );
  const manualReviewRequired =
    manualIssueKinds.length > 0 || recommendedActionTypes.includes("manual_sculpt_review");
  const parts = [];
  const patchActions = recommendedActionTypes.filter((action) =>
    PATCH_CANDIDATE_ACTION_VALUES.includes(action),
  );
  if (patchActions.length > 0) {
    parts.push(`patch ${patchActions.join(",")}`);
  }
  const manualItems = [
    ...manualIssueKinds,
    ...recommendedActionTypes.filter((action) => action === "manual_sculpt_review"),
  ];
  if (manualItems.length > 0) {
    parts.push(`manual ${manualItems.join(",")}`);
  }
  if (visualAreas.length > 0) {
    parts.push(`visual ${visualAreas.join(",")}`);
  }
  if (parts.length === 0 && recommendedActionTypes.includes("ignore")) {
    parts.push("ignore");
  }
  if (parts.length === 0) {
    parts.push("no_action");
  }
  return {
    source_id: summary.source_id,
    patch_candidate: patchCandidate,
    manual_review_required: manualReviewRequired,
    recommended_action_types: recommendedActionTypes,
    manual_issue_kinds: manualIssueKinds,
    visual_areas: visualAreas,
    summary_line: `${summary.source_id}: ${parts.join("; ")}`,
  };
}

function inferPriorityFromManualIssueKinds(manualIssueKinds) {
  if (
    manualIssueKinds.includes("review_missing") ||
    manualIssueKinds.includes("review_node_kind") ||
    manualIssueKinds.includes("review_alignment")
  ) {
    return "high";
  }
  if (
    manualIssueKinds.includes("review_extra") ||
    manualIssueKinds.includes("review_stamp_count") ||
    manualIssueKinds.includes("review_overlap")
  ) {
    return "medium";
  }
  return "low";
}

function inferSourceTaskPriority(summary, digest) {
  const actionPriorities = uniqueValues(summary.recommended_actions, "priority");
  if (actionPriorities.includes("high")) {
    return "high";
  }
  if (actionPriorities.includes("medium")) {
    return "medium";
  }
  if (actionPriorities.includes("low")) {
    return "low";
  }
  if (digest.manual_issue_kinds.length > 0) {
    return inferPriorityFromManualIssueKinds(digest.manual_issue_kinds);
  }
  if (digest.visual_areas.length > 0) {
    return "low";
  }
  return "low";
}

function inferSourceTaskType(digest) {
  if (digest.patch_candidate && digest.manual_review_required) {
    return "apply_patch_then_review";
  }
  if (digest.patch_candidate) {
    return "apply_patch";
  }
  if (digest.manual_review_required) {
    return "manual_review";
  }
  if (digest.visual_areas.length > 0) {
    return "visual_check";
  }
  return "ignore";
}

function buildSourceTask(summary, digest, index) {
  const priority = inferSourceTaskPriority(summary, digest);
  const taskType = inferSourceTaskType(digest);
  const summaryLine = `[${priority}] ${summary.source_id} ${taskType}: ${digest.summary_line.split(": ").slice(1).join(": ")}`;
  return {
    source_id: summary.source_id,
    priority,
    task_type: taskType,
    blocking:
      taskType === "manual_review" || taskType === "apply_patch_then_review",
    recommended_action_types: digest.recommended_action_types,
    manual_issue_kinds: digest.manual_issue_kinds,
    visual_areas: digest.visual_areas,
    summary_line: summaryLine,
    _sort_index: index,
  };
}

function buildPrComment(review, sourceTaskQueue) {
  const lines = [
    "## Kagura VLM Review",
    `- Target: \`${review.target_file}\``,
    `- Confidence: \`${review.confidence}\``,
    `- Summary: ${review.overall_summary}`,
  ];
  if (sourceTaskQueue.length > 0) {
    lines.push("", "### Source Task Queue");
    for (const item of sourceTaskQueue) {
      lines.push(`- ${item.summary_line}`);
    }
  }
  if (review.manual_followups.length > 0) {
    lines.push("", "### Manual Followups");
    for (const item of review.manual_followups) {
      lines.push(`- \`${item.source_id}\` ${item.issue_kind}: ${item.next_step}`);
    }
  }
  if (review.visual_findings.length > 0) {
    lines.push("", "### Visual Findings");
    for (const item of review.visual_findings) {
      lines.push(`- \`${item.source_id}\` ${item.area}: ${item.observation}`);
    }
  }
  return {
    prCommentLines: lines,
    prCommentMarkdown: lines.join("\n"),
  };
}

export function enrichStructuredReview(review) {
  const normalizedReview = validateStructuredReviewShape(
    normalizeStructuredReviewShape(review),
  );
  const sourceSummaryMap = new Map();
  for (const item of normalizedReview.recommended_actions) {
    getSourceSummary(sourceSummaryMap, item.source_id).recommended_actions.push(item);
  }
  for (const item of normalizedReview.manual_followups) {
    getSourceSummary(sourceSummaryMap, item.source_id).manual_followups.push(item);
  }
  for (const item of normalizedReview.visual_findings) {
    getSourceSummary(sourceSummaryMap, item.source_id).visual_findings.push(item);
  }
  const sourceSummaries = Array.from(sourceSummaryMap.values());
  const sourceDigests = sourceSummaries.map((summary) => buildSourceDigest(summary));
  const sourceTaskQueue = sourceSummaries
    .map((summary, index) => buildSourceTask(summary, sourceDigests[index], index))
    .sort((left, right) => {
      const byPriority =
        REVIEW_PRIORITY_RANK[left.priority] - REVIEW_PRIORITY_RANK[right.priority];
      if (byPriority !== 0) {
        return byPriority;
      }
      return left._sort_index - right._sort_index;
    })
    .map(({ _sort_index, ...task }) => task);
  const { prCommentLines, prCommentMarkdown } = buildPrComment(
    normalizedReview,
    sourceTaskQueue,
  );
  return {
    ...normalizedReview,
    source_summaries: sourceSummaries,
    source_digests: sourceDigests,
    source_report_lines: sourceDigests.map((item) => item.summary_line),
    source_report: sourceDigests.map((item) => item.summary_line).join("\n"),
    source_task_queue: sourceTaskQueue,
    source_task_report_lines: sourceTaskQueue.map((item) => item.summary_line),
    source_task_report: sourceTaskQueue.map((item) => item.summary_line).join("\n"),
    pr_comment_lines: prCommentLines,
    pr_comment_markdown: prCommentMarkdown,
  };
}

export function extractStructuredReview(responseJson) {
  if (responseJson == null || typeof responseJson !== "object") {
    throw new Error("response JSON must be an object");
  }
  if (
    responseJson.output_parsed != null &&
    typeof responseJson.output_parsed === "object"
  ) {
    return enrichStructuredReview(responseJson.output_parsed);
  }
  const outputText =
    typeof responseJson.output_text === "string" && responseJson.output_text.length > 0
      ? responseJson.output_text
      : extractOutputTextFromContent(responseJson) ?? extractOutputTextFromChoices(responseJson);
  if (outputText == null) {
    throw new Error("response did not contain output_text");
  }
  return enrichStructuredReview(JSON.parse(normalizeJsonText(outputText)));
}
