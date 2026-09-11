import assert from "node:assert/strict";
import { test } from "node:test";

import {
  UI_REVIEW_AREAS,
  buildReviewHeaders,
  buildReviewPrompt,
  buildReviewRequest,
  deterministicVerdict,
  extractStructuredReview,
  formatDiffLines,
  formatReviewReport,
  normalizeProvider,
  parseVlmUiReviewArgs,
  parseVlmkitDiff,
  resolveReviewApiConfig,
  summarizeSnapshotForPrompt,
} from "./vlm-ui-review-utils.mjs";

const META = {
  example: "ui_demo",
  state: "default",
  width: 640,
  height: 480,
  frames: 3,
  drawn_triangles: 980,
  skipped_commands: 0,
};

const SNAPSHOT = {
  screen: { width: 640, height: 480, dpr: 1 },
  state: "demo",
  nodes: [
    {
      id: "button_1",
      role: "button",
      left: 16,
      top: 56,
      width: 184,
      height: 36,
      text: "BTN 1",
      focusable: true,
      focus_index: 0,
      focused: false,
    },
    { id: "panel_7", role: "panel", left: 8, top: 48, width: 200, height: 384 },
  ],
  focus_order: ["button_1"],
};

test("a clean frame with a clean snapshot passes the deterministic gate", () => {
  const verdict = deterministicVerdict({ meta: META, gate: { findings: [] } });
  assert.equal(verdict.ok, true);
  assert.deepEqual(verdict.blockers, []);
  assert.deepEqual(verdict.warnings, []);
});

test("a frame with no geometry is a blocker, not something to ask a model about", () => {
  const verdict = deterministicVerdict({ meta: { ...META, drawn_triangles: 0 } });
  assert.equal(verdict.ok, false);
  assert.equal(verdict.blockers[0].kind, "empty-frame");
});

test("skipped 3D commands warn without blocking -- the frame is real but partial", () => {
  const verdict = deterministicVerdict({ meta: { ...META, skipped_commands: 4 } });
  assert.equal(verdict.ok, true);
  assert.equal(verdict.warnings.length, 1);
  assert.match(verdict.warnings[0].detail, /4 draw command/);
});

test("every gate finding becomes a blocker, carrying the gate's own message", () => {
  const verdict = deterministicVerdict({
    meta: META,
    gate: {
      findings: [
        { kind: "text-overflow", message: "hp_label: measured text 57x15 exceeds rect 40x36" },
      ],
    },
  });
  assert.equal(verdict.ok, false);
  assert.deepEqual(verdict.blockers, [
    { kind: "text-overflow", detail: "hp_label: measured text 57x15 exceeds rect 40x36" },
  ]);
});

test("the snapshot summary gives the model the node ids a finding must name", () => {
  const summary = summarizeSnapshotForPrompt(SNAPSHOT);
  assert.match(summary, /button_1/);
  assert.match(summary, /16,56,184,36/);
  assert.match(summary, /BTN 1/);
  assert.match(summary, /focus order: button_1/);
});

test("the summary says so plainly when an example publishes no snapshot", () => {
  assert.match(summarizeSnapshotForPrompt(null), /no UI snapshot/);
});

test("the summary truncates rather than pasting an unbounded node list", () => {
  const nodes = Array.from({ length: 80 }, (_, i) => ({ id: `n${i}`, left: 0, top: 0, width: 1, height: 1 }));
  const summary = summarizeSnapshotForPrompt({ screen: { width: 1, height: 1 }, nodes }, { maxNodes: 10 });
  assert.match(summary, /70 more nodes omitted/);
});

test("the prompt tells the model which defects are already settled", () => {
  const prompt = buildReviewPrompt({
    example: "ui_demo",
    state: "default",
    meta: META,
    snapshot: SNAPSHOT,
    verdict: { ok: true, blockers: [], warnings: [] },
  });
  assert.match(prompt, /already been checked mechanically/);
  assert.match(prompt, /Do not report them/);
  assert.match(prompt, /WCAG AA contrast/);
  assert.match(prompt, /button_1/);
});

test("capture caveats reach the prompt, so a partial frame is not read as whole", () => {
  const prompt = buildReviewPrompt({
    example: "ui_demo",
    state: "default",
    meta: META,
    snapshot: SNAPSHOT,
    verdict: { ok: true, blockers: [], warnings: [{ kind: "incomplete-frame", detail: "3D content missing" }] },
  });
  assert.match(prompt, /Caveats about this capture/);
  assert.match(prompt, /3D content missing/);
});

test("reviewer notes are passed through", () => {
  const prompt = buildReviewPrompt({
    example: "ui_demo",
    state: "default",
    meta: META,
    snapshot: SNAPSHOT,
    verdict: { ok: true, blockers: [], warnings: [] },
    notes: ["the header font is intentionally 1px"],
  });
  assert.match(prompt, /intentionally 1px/);
});

test("provider resolution keeps the env vars the 3D loop already uses", () => {
  const openrouter = resolveReviewApiConfig({});
  assert.equal(openrouter.provider, "openrouter");
  assert.equal(openrouter.apiKeyEnv, "OPENROUTER_API_KEY");
  assert.match(openrouter.apiUrl, /openrouter\.ai/);
  const openai = resolveReviewApiConfig({ provider: "openai" });
  assert.equal(openai.apiKeyEnv, "OPENAI_API_KEY");
  assert.equal(resolveReviewApiConfig({ model: "x/y" }).model, "x/y");
});

test("an unknown provider is rejected", () => {
  assert.throws(() => normalizeProvider("anthropic"), /unknown provider/);
});

test("openrouter gets its attribution headers, openai does not", () => {
  const headers = buildReviewHeaders({ apiKey: "k", provider: "openrouter" });
  assert.equal(headers.Authorization, "Bearer k");
  assert.equal(headers["X-Title"], "kagura-ui-review");
  assert.equal(buildReviewHeaders({ apiKey: "k", provider: "openai" })["X-Title"], undefined);
});

test("the request pins the structured schema and carries the frame", () => {
  const request = buildReviewRequest({
    config: resolveReviewApiConfig({}),
    prompt: "prompt",
    imageDataUrl: "data:image/png;base64,AAAA",
  });
  assert.equal(request.response_format.json_schema.strict, true);
  assert.deepEqual(
    request.response_format.json_schema.schema.properties.visual_findings.items.properties.area.enum,
    UI_REVIEW_AREAS,
  );
  const content = request.messages.at(-1).content;
  assert.equal(content[1].image_url.url, "data:image/png;base64,AAAA");
});

test("a structured review is read back from a chat completion", () => {
  const review = extractStructuredReview({
    choices: [
      {
        message: {
          content: JSON.stringify({
            target: "ui_demo",
            overall_summary: "reads well",
            confidence: "medium",
            visual_findings: [],
            recommended_actions: [],
            manual_followups: [],
          }),
        },
      },
    ],
  });
  assert.equal(review.confidence, "medium");
  assert.deepEqual(review.visual_findings, []);
});

test("a fenced JSON body is still read", () => {
  const review = extractStructuredReview({
    choices: [{ message: { content: '```json\n{"target":"x","confidence":"high"}\n```' } }],
  });
  assert.equal(review.target, "x");
  assert.equal(review.confidence, "high");
});

test("an unusable confidence falls back to low rather than being echoed", () => {
  const review = extractStructuredReview({
    choices: [{ message: { content: '{"confidence":"very sure"}' } }],
  });
  assert.equal(review.confidence, "low");
});

test("an empty response is an error, not an empty review", () => {
  assert.throws(() => extractStructuredReview({ choices: [] }), /no content/);
});

test("the vlmkit diff report is reduced to what a fix loop acts on", () => {
  const diff = parseVlmkitDiff(
    [
      "PNG Diff",
      "  baseline: a.png",
      "  diff:     2.07% (6362 / 307200 px)",
      "  regions:  1",
      "    (16,48) 192x48 [content] #4a4a6a -> #6a6a9a",
      "  selectors:",
      "    (16,48) 192x48 -> .button (medium, coverage 0.7188)",
      "  summary:  1 element-added",
    ].join("\n"),
  );
  assert.equal(Math.round(diff.changedRatio * 10000) / 10000, 0.0207);
  assert.deepEqual(diff.selectors, ["(16,48) 192x48 -> .button (medium, coverage 0.7188)"]);
  assert.deepEqual(diff.regions, ["(16,48) 192x48 [content] #4a4a6a -> #6a6a9a"]);
});

test("a report with no diff line yields no measurement, not a zero", () => {
  const diff = parseVlmkitDiff("PNG Diff\n  baseline: a.png\n");
  assert.equal(diff.changedRatio, null);
  assert.match(formatDiffLines(diff)[0], /comparison did not run/);
});

test("an unchanged diff is reported as the edit not reaching the frame", () => {
  const diff = parseVlmkitDiff("  diff:     0.00% (0 / 307200 px)\n  regions:  0\n");
  assert.equal(diff.changedRatio, 0);
  assert.deepEqual(formatDiffLines(diff), ["No pixel changed -- the edit did not reach this frame."]);
});

test("the report puts the proven findings before the model's judgement", () => {
  const report = formatReviewReport({
    example: "ui_demo",
    state: "default",
    meta: META,
    verdict: {
      ok: false,
      blockers: [{ kind: "text-overflow", detail: "hp_label: too wide" }],
      warnings: [],
    },
    skipReason: "the deterministic gate found defects",
  });
  assert.ok(report.indexOf("Deterministic gate") < report.indexOf("VLM review"));
  assert.match(report, /\[text-overflow\] hp_label: too wide/);
  assert.match(report, /not run -- the deterministic gate found defects/);
});

test("a review renders its findings, changes and follow-ups", () => {
  const report = formatReviewReport({
    example: "ui_demo",
    state: "default",
    meta: META,
    verdict: { ok: true, blockers: [], warnings: [] },
    review: {
      target: "ui_demo",
      overall_summary: "cramped footer",
      confidence: "high",
      visual_findings: [
        {
          node_id: "footer_11",
          area: "text_legibility",
          severity: "minor",
          observation: "the hint text is dim",
          impact: "hard to read on a small screen",
        },
      ],
      recommended_actions: [
        {
          priority: "medium",
          node_id: "footer_11",
          action: "raise the hint contrast",
          rationale: "it sits below 3:1",
          suggested_change: "use 0xd0d0e0 instead of 0x8c8c8c",
        },
      ],
      manual_followups: [
        { node_id: "-", issue_kind: "art", next_step: "ask the artist", rationale: "palette call" },
      ],
    },
    artifacts: { png: "output/frames/ui_demo/ui_demo.png" },
  });
  assert.match(report, /confidence: high/);
  assert.match(report, /\*\*footer_11\*\* \[text_legibility\/minor\]/);
  assert.match(report, /use 0xd0d0e0/);
  assert.match(report, /Needs a human/);
  assert.match(report, /output\/frames\/ui_demo\/ui_demo\.png/);
});

test("the review CLI accepts a comparison baseline and a forced review", () => {
  const options = parseVlmUiReviewArgs([
    "ui_demo",
    "--state",
    "hover",
    "--cursor",
    "100,74",
    "--compare",
    "base.png",
    "--force-vlm",
    "--dry-run",
  ]);
  assert.equal(options.state, "hover");
  assert.equal(options.cursorX, 100);
  assert.equal(options.compare, "base.png");
  assert.equal(options.forceVlm, true);
  assert.equal(options.dryRun, true);
});

test("the review CLI accepts --matrix to walk every declared state", () => {
  const options = parseVlmUiReviewArgs(["ui_demo", "--matrix", "--dry-run"]);
  assert.equal(options.matrix, true);
  assert.equal(options.dryRun, true);
});

test("the review CLI rejects an unknown flag and a missing example", () => {
  assert.throws(() => parseVlmUiReviewArgs(["ui_demo", "--nope"]), /unknown option/);
  assert.throws(() => parseVlmUiReviewArgs([]), /missing <example>/);
});
