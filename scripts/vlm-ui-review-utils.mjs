/**
 * Pure helpers for the game-UI VLM review loop.
 *
 * Design rule, inherited from vlmkit and from the 3D authoring loop already in
 * this repo: **the deterministic gates run first, and the VLM only ever judges
 * what is left.** Asking a model to find text overflow or a hit-box mismatch
 * that `scripts/ui-integrity-gate.mjs` can prove is how a review loop becomes
 * unreliable. The model's job here is the part no gate can compute -- whether
 * the frame reads well.
 */

/** What a UI finding can be about. The pixel/geometry defects are the gate's. */
export const UI_REVIEW_AREAS = [
  "hud_readability",
  "layout_balance",
  "text_legibility",
  "contrast",
  "visual_hierarchy",
  "safe_area",
  "state_consistency",
  "iconography",
  "theme_coherence",
];

export const UI_REVIEW_PRIORITIES = ["high", "medium", "low"];

export const UI_REVIEW_CONFIDENCE = ["low", "medium", "high"];

export const UI_REVIEW_SEVERITIES = ["blocking", "major", "minor"];

export const UI_REVIEW_RESPONSE_SCHEMA = {
  type: "object",
  additionalProperties: false,
  required: [
    "target",
    "overall_summary",
    "confidence",
    "visual_findings",
    "recommended_actions",
    "manual_followups",
  ],
  properties: {
    target: { type: "string" },
    overall_summary: { type: "string" },
    confidence: { type: "string", enum: UI_REVIEW_CONFIDENCE },
    visual_findings: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["node_id", "area", "severity", "observation", "impact"],
        properties: {
          node_id: { type: "string" },
          area: { type: "string", enum: UI_REVIEW_AREAS },
          severity: { type: "string", enum: UI_REVIEW_SEVERITIES },
          observation: { type: "string" },
          impact: { type: "string" },
        },
      },
    },
    recommended_actions: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["priority", "node_id", "action", "rationale", "suggested_change"],
        properties: {
          priority: { type: "string", enum: UI_REVIEW_PRIORITIES },
          node_id: { type: "string" },
          action: { type: "string" },
          rationale: { type: "string" },
          suggested_change: { type: "string" },
        },
      },
    },
    manual_followups: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["node_id", "issue_kind", "next_step", "rationale"],
        properties: {
          node_id: { type: "string" },
          issue_kind: { type: "string" },
          next_step: { type: "string" },
          rationale: { type: "string" },
        },
      },
    },
  },
};

const OPENROUTER_DEFAULT_MODEL = "anthropic/claude-sonnet-4.5";

export function normalizeProvider(provider = "openrouter") {
  const value = String(provider).toLowerCase();
  if (value !== "openrouter" && value !== "openai") {
    throw new Error(`unknown provider: ${provider} (expected openrouter or openai)`);
  }
  return value;
}

/**
 * Same env vars and endpoints the 3D authoring loop already uses, so a repo
 * that can run `just vlm-live-review` can run this with no new setup.
 */
export function resolveReviewApiConfig({
  provider = "openrouter",
  model = null,
  apiUrl = null,
  apiKeyEnv = null,
} = {}) {
  const normalized = normalizeProvider(provider);
  if (normalized === "openrouter") {
    return {
      provider: normalized,
      model: model ?? OPENROUTER_DEFAULT_MODEL,
      apiUrl: apiUrl ?? "https://openrouter.ai/api/v1/chat/completions",
      apiKeyEnv: apiKeyEnv ?? "OPENROUTER_API_KEY",
    };
  }
  return {
    provider: normalized,
    model: model ?? "gpt-5",
    apiUrl: apiUrl ?? "https://api.openai.com/v1/chat/completions",
    apiKeyEnv: apiKeyEnv ?? "OPENAI_API_KEY",
  };
}

export function buildReviewHeaders({ apiKey, provider = "openrouter" }) {
  const headers = {
    Authorization: `Bearer ${apiKey}`,
    "Content-Type": "application/json",
  };
  if (normalizeProvider(provider) === "openrouter") {
    headers["HTTP-Referer"] = "https://github.com/mizchi/kagura";
    headers["X-Title"] = "kagura-ui-review";
  }
  return headers;
}

/**
 * Compact the UI snapshot into something a model can actually read.
 *
 * The whole snapshot is long and mostly redundant with the image; what the
 * model cannot get from the image is the *names*. Findings have to be
 * attributable to a node id or they are not actionable, so the table exists to
 * make the ids available alongside the geometry that anchors them.
 */
export function summarizeSnapshotForPrompt(snapshot, { maxNodes = 60 } = {}) {
  if (snapshot == null || !Array.isArray(snapshot.nodes)) {
    return "(this example publishes no UI snapshot -- findings cannot be tied to node ids)";
  }
  const lines = [
    `screen ${snapshot.screen?.width}x${snapshot.screen?.height} dpr=${snapshot.screen?.dpr ?? 1}` +
      (snapshot.state ? ` state=${snapshot.state}` : ""),
    "",
    "| node_id | role | rect (x,y,w,h) | text | focus |",
    "|---|---|---|---|---|",
  ];
  const nodes = snapshot.nodes.slice(0, maxNodes);
  for (const node of nodes) {
    const rect = `${round(node.left)},${round(node.top)},${round(node.width)},${round(node.height)}`;
    const text = node.text == null || node.text === "" ? "-" : truncate(node.text, 40);
    const focus = node.focused ? "focused" : node.focusable ? `#${node.focus_index ?? "?"}` : "-";
    lines.push(`| ${node.id ?? node.path ?? "?"} | ${node.role ?? "-"} | ${rect} | ${text} | ${focus} |`);
  }
  if (snapshot.nodes.length > nodes.length) {
    lines.push(`| ... | ${snapshot.nodes.length - nodes.length} more nodes omitted | | | |`);
  }
  if (Array.isArray(snapshot.focus_order) && snapshot.focus_order.length > 0) {
    lines.push("", `focus order: ${snapshot.focus_order.join(" -> ")}`);
  }
  return lines.join("\n");
}

function round(value) {
  return Number.isFinite(value) ? Math.round(value) : "?";
}

function truncate(text, limit) {
  const flat = String(text).replace(/\s+/g, " ").trim();
  return flat.length <= limit ? flat : `${flat.slice(0, limit - 1)}…`;
}

/**
 * Fold the machine-checkable signals into one verdict. `blocking` means the
 * frame is not worth a subjective review yet: a gate found a real defect, or
 * the capture itself is not trustworthy.
 */
export function deterministicVerdict({ meta, gate = null }) {
  const blockers = [];
  const warnings = [];
  if (meta.drawn_triangles === 0) {
    blockers.push({
      kind: "empty-frame",
      detail: "the draw produced no geometry -- the frame is the clear color and nothing else",
    });
  }
  if (meta.skipped_commands > 0) {
    warnings.push({
      kind: "incomplete-frame",
      detail:
        `${meta.skipped_commands} draw command(s) were skipped: the CPU rasterizer ` +
        "draws 2D geometry only, so any 3D content is missing from this frame",
    });
  }
  if (gate != null) {
    // `message` already carries the node label, in the same shape vlmkit's fix
    // lists use, so it is passed through verbatim rather than re-decorated.
    for (const finding of gate.findings ?? []) {
      blockers.push({ kind: finding.kind, detail: finding.message ?? "" });
    }
  }
  return {
    ok: blockers.length === 0,
    blockers,
    warnings,
  };
}

export function buildReviewPrompt({ example, state, meta, snapshot, verdict, notes = [] }) {
  const sections = [
    `# Game UI review: ${example} [${state}]`,
    "",
    "You are reviewing one rendered frame of a game UI drawn on a canvas. There is no DOM;",
    "the attached table is the only source of node names, so every finding must name a",
    "`node_id` from it (use `-` only when a finding genuinely applies to the whole frame).",
    "",
    "## What has already been checked mechanically",
    "",
    "These are settled. Do not report them, and do not re-derive them from the image:",
    "",
    "- text measured against its rect (overflow, clipping)",
    "- nodes off screen, protruding, or violating the declared safe area",
    "- zero-size and collapsed containers",
    "- text nodes colliding within the same z band",
    "- hit rectangles disagreeing with drawn rectangles",
    "- children escaping their parent unclipped",
    "",
    "## What to review",
    "",
    "Only what a measurement cannot settle: whether the frame reads well. Legibility at",
    "this resolution, contrast, visual hierarchy, whether the layout is balanced, whether",
    "the state shown is coherent. Report nothing you are not seeing in the image.",
    "",
    `## Frame: ${meta.width}x${meta.height}, captured after ${meta.frames} update tick(s)`,
    "",
    summarizeSnapshotForPrompt(snapshot),
  ];
  if (verdict?.warnings?.length) {
    sections.push(
      "",
      "## Caveats about this capture",
      "",
      ...verdict.warnings.map((w) => `- ${w.detail}`),
    );
  }
  if (notes.length > 0) {
    sections.push("", "## Reviewer notes", "", ...notes.map((note) => `- ${note}`));
  }
  return sections.join("\n");
}

export function buildReviewRequest({ config, prompt, imageDataUrl }) {
  return {
    model: config.model,
    messages: [
      {
        role: "system",
        content:
          "You review game UI frames. Be specific and conservative: every finding names a " +
          "node_id and describes something visible in the image. Prefer no findings over " +
          "speculative ones.",
      },
      {
        role: "user",
        content: [
          { type: "text", text: prompt },
          { type: "image_url", image_url: { url: imageDataUrl } },
        ],
      },
    ],
    response_format: {
      type: "json_schema",
      json_schema: {
        name: "kagura_ui_review",
        strict: true,
        schema: UI_REVIEW_RESPONSE_SCHEMA,
      },
    },
  };
}

/** Pull the structured review out of a chat-completions response. */
export function extractStructuredReview(responseJson) {
  const content = responseJson?.choices?.[0]?.message?.content;
  if (typeof content !== "string" || content.trim() === "") {
    throw new Error("the model returned no content");
  }
  let parsed;
  try {
    parsed = JSON.parse(content);
  } catch {
    // Some models wrap JSON in a fenced block even under a schema.
    const fenced = /```(?:json)?\s*([\s\S]*?)```/.exec(content);
    if (fenced == null) throw new Error("the model's content was not JSON");
    parsed = JSON.parse(fenced[1]);
  }
  return normalizeReview(parsed);
}

export function normalizeReview(review) {
  return {
    target: String(review.target ?? ""),
    overall_summary: String(review.overall_summary ?? ""),
    confidence: UI_REVIEW_CONFIDENCE.includes(review.confidence) ? review.confidence : "low",
    visual_findings: Array.isArray(review.visual_findings) ? review.visual_findings : [],
    recommended_actions: Array.isArray(review.recommended_actions) ? review.recommended_actions : [],
    manual_followups: Array.isArray(review.manual_followups) ? review.manual_followups : [],
  };
}

/**
 * The report an agent (or a person) acts on. Deterministic findings come
 * first because they are proven; the VLM's come second and are labelled as
 * judgement.
 */
export function formatReviewReport({
  example,
  state,
  meta,
  verdict,
  review = null,
  skipReason = null,
  diff = null,
  artifacts = {},
}) {
  const lines = [
    `# UI review: ${example} [${state}]`,
    "",
    `frame: ${meta.width}x${meta.height}, ${meta.frames} tick(s), ` +
      `${meta.drawn_triangles} triangles, ${meta.skipped_commands} skipped command(s)`,
    "",
    "## Deterministic gate",
    "",
  ];
  if (verdict.ok && verdict.warnings.length === 0) {
    lines.push("CLEAN -- no measurable defect in the frame or the UI snapshot.");
  } else {
    for (const blocker of verdict.blockers) lines.push(`- [${blocker.kind}] ${blocker.detail}`);
    for (const warning of verdict.warnings) lines.push(`- (warning) [${warning.kind}] ${warning.detail}`);
  }
  if (diff != null) {
    lines.push("", "## Change since the baseline frame", "", ...formatDiffLines(diff));
  }
  lines.push("", "## VLM review", "");
  if (review == null) {
    lines.push(skipReason == null ? "not run" : `not run -- ${skipReason}`);
  } else {
    lines.push(`confidence: ${review.confidence}`, "", review.overall_summary, "");
    if (review.visual_findings.length === 0) {
      lines.push("No visual findings.");
    } else {
      lines.push("### Findings", "");
      for (const finding of review.visual_findings) {
        lines.push(
          `- **${finding.node_id}** [${finding.area}/${finding.severity}] ${finding.observation}`,
          `  - impact: ${finding.impact}`,
        );
      }
    }
    if (review.recommended_actions.length > 0) {
      lines.push("", "### Recommended changes", "");
      for (const action of review.recommended_actions) {
        lines.push(
          `- (${action.priority}) **${action.node_id}**: ${action.action}`,
          `  - why: ${action.rationale}`,
          `  - change: ${action.suggested_change}`,
        );
      }
    }
    if (review.manual_followups.length > 0) {
      lines.push("", "### Needs a human", "");
      for (const followup of review.manual_followups) {
        lines.push(`- **${followup.node_id}** (${followup.issue_kind}): ${followup.next_step}`);
      }
    }
  }
  const artifactEntries = Object.entries(artifacts);
  if (artifactEntries.length > 0) {
    lines.push("", "## Artifacts", "");
    for (const [kind, path] of artifactEntries) lines.push(`- ${kind}: ${path}`);
  }
  return `${lines.join("\n")}\n`;
}

/**
 * `vlmkit diff png --elements-json` output, trimmed to the lines that say what
 * changed and which UI node owns it. The raw output is a full markdown report;
 * what a fix loop needs from it is the attribution.
 */
export function formatDiffLines(diff) {
  if (diff.changedRatio === 0) {
    return ["No pixel changed -- the edit did not reach this frame."];
  }
  const lines = [`${(diff.changedRatio * 100).toFixed(2)}% of pixels changed.`];
  if (diff.selectors.length > 0) {
    lines.push("", "Attributed to:");
    for (const selector of diff.selectors) lines.push(`- ${selector}`);
  }
  if (diff.regions.length > 0) {
    lines.push("", "Regions:");
    for (const region of diff.regions) lines.push(`- ${region}`);
  }
  return lines;
}

/**
 * Parse the `diff png` report. vlmkit prints a human report rather than JSON,
 * so this reads the three lines a fix loop acts on and leaves the rest alone;
 * an unparseable report degrades to "changed, attribution unknown" instead of
 * failing the run.
 */
export function parseVlmkitDiff(stdout) {
  const ratioMatch = /diff:\s+([0-9.]+)%/.exec(stdout);
  const changedRatio = ratioMatch == null ? 0 : Number(ratioMatch[1]) / 100;
  const selectors = [];
  const regions = [];
  let section = null;
  for (const rawLine of stdout.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (/^selectors:/.test(line)) {
      section = "selectors";
      continue;
    }
    if (/^regions:/.test(line)) {
      section = "regions";
      continue;
    }
    if (line === "" || /^[a-z]+:/.test(line)) {
      if (!/^\(/.test(line)) section = null;
      continue;
    }
    if (section === "selectors") selectors.push(line);
    else if (section === "regions") regions.push(line);
  }
  return { changedRatio, selectors, regions };
}

export function vlmUiReviewUsage() {
  return [
    "Usage: node scripts/vlm-ui-review.mjs <example> [options]",
    "",
    "Renders a frame directly (no browser, no Playwright), runs the deterministic",
    "gates over it, and only then asks a VLM about what a gate cannot measure.",
    "",
    "Options:",
    "  --frames <n>       Update ticks before the captured draw (default 1)",
    "  --width <px>       Override the example's viewport width",
    "  --height <px>      Override the example's viewport height",
    "  --cursor <x,y>     Synthesized cursor position, for hover states",
    "  --keys <a,b>       Key codes held during every tick, for focus states",
    "  --state <name>     Label used in the artifact filenames (default: default)",
    "  --out-dir <dir>    Where to write (default: output/ui-review/<example>)",
    "  --provider <p>     openrouter (default) or openai",
    "  --model <id>       Override the model id",
    "  --note <text>      Extra context for the reviewer (repeatable)",
    "  --compare <png>    Diff the frame against a baseline PNG and attribute the",
    "                     change to UI nodes (needs vlmkit)",
    "  --force-vlm        Review even when the deterministic gate found defects",
    "  --dry-run          Write the request bundle, call nothing",
    "  --no-build         Use the existing _build output",
    "  -h, --help         Show this help",
  ].join("\n");
}

export function parseVlmUiReviewArgs(argv) {
  const options = {
    example: null,
    state: "default",
    frames: 1,
    width: null,
    height: null,
    cursorX: null,
    cursorY: null,
    keys: [],
    outDir: null,
    provider: "openrouter",
    model: null,
    notes: [],
    compare: null,
    forceVlm: false,
    dryRun: false,
    build: true,
    help: false,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = () => {
      const value = argv[++i];
      if (value === undefined) throw new Error(`${arg} needs a value`);
      return value;
    };
    switch (arg) {
      case "-h":
      case "--help":
        options.help = true;
        break;
      case "--frames":
        options.frames = requireNonNegativeInt("--frames", next());
        break;
      case "--width":
        options.width = requirePositiveInt("--width", next());
        break;
      case "--height":
        options.height = requirePositiveInt("--height", next());
        break;
      case "--cursor": {
        const [x, y] = next().split(",").map(Number);
        if (!Number.isFinite(x) || !Number.isFinite(y)) {
          throw new Error('--cursor wants "x,y"');
        }
        options.cursorX = x;
        options.cursorY = y;
        break;
      }
      case "--keys":
        options.keys = next()
          .split(",")
          .map((part) => part.trim())
          .filter((part) => part !== "")
          .map((part) => requireNonNegativeInt("--keys", part));
        break;
      case "--state":
        options.state = next();
        break;
      case "--out-dir":
        options.outDir = next();
        break;
      case "--provider":
        options.provider = normalizeProvider(next());
        break;
      case "--model":
        options.model = next();
        break;
      case "--note":
        options.notes.push(next());
        break;
      case "--compare":
        options.compare = next();
        break;
      case "--force-vlm":
        options.forceVlm = true;
        break;
      case "--dry-run":
        options.dryRun = true;
        break;
      case "--no-build":
        options.build = false;
        break;
      default:
        if (arg.startsWith("-")) throw new Error(`unknown option: ${arg}`);
        if (options.example !== null) throw new Error(`unexpected extra argument: ${arg}`);
        options.example = arg;
    }
  }
  if (!options.help && options.example === null) {
    throw new Error(`missing <example>\n\n${vlmUiReviewUsage()}`);
  }
  return options;
}

function requirePositiveInt(flag, raw) {
  const value = Number(raw);
  if (!Number.isInteger(value) || value <= 0) throw new Error(`${flag} wants a positive integer`);
  return value;
}

function requireNonNegativeInt(flag, raw) {
  const value = Number(raw);
  if (!Number.isInteger(value) || value < 0) {
    throw new Error(`${flag} wants a non-negative integer`);
  }
  return value;
}
