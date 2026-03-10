import test from "node:test";
import assert from "node:assert/strict";

import {
  buildVlmCloseLoopPlan,
  extractJsonDocument,
  shouldApplyBundlePatch,
  summarizeBundlePatchPayload,
} from "./model-authoring-vlm-close-loop-utils.mjs";

test("extractJsonDocument parses pretty JSON after log lines", () => {
  const parsed = extractJsonDocument(
    [
      "[handoff] starting dev server",
      "{",
      '  "example": "chair_authoring",',
      '  "bundle": "/tmp/vlm_bundle.json"',
      "}",
    ].join("\n"),
  );

  assert.deepEqual(parsed, {
    example: "chair_authoring",
    bundle: "/tmp/vlm_bundle.json",
  });
});

test("summarizeBundlePatchPayload returns counts and issue ids", () => {
  const summary = summarizeBundlePatchPayload({
    patch_payload: {
      auto_actions: [{}, {}],
      manual_actions: [{}],
      opt_in_remove_source_ids: ["guide_orb"],
      opt_in_append_source_ids: ["blender_helper"],
      manual_issue_details: [
        {
          source_id: "clay_head",
          action_kind: "review_stamp_count",
        },
      ],
    },
  });

  assert.deepEqual(summary, {
    auto_actions: 2,
    manual_actions: 1,
    opt_in_remove_source_ids: ["guide_orb"],
    opt_in_append_source_ids: ["blender_helper"],
    issues: [
      {
        source_id: "clay_head",
        issue_kind: "review_stamp_count",
      },
    ],
  });
});

test("shouldApplyBundlePatch ignores manual-only and empty summaries", () => {
  assert.equal(
    shouldApplyBundlePatch({
      auto_actions: 0,
      manual_actions: 1,
      opt_in_remove_source_ids: [],
      opt_in_append_source_ids: [],
      issues: [{ source_id: "clay_head", issue_kind: "review_stamp_count" }],
    }),
    false,
  );
  assert.equal(
    shouldApplyBundlePatch({
      auto_actions: 0,
      manual_actions: 0,
      opt_in_remove_source_ids: [],
      opt_in_append_source_ids: [],
      issues: [],
    }),
    false,
  );
});

test("shouldApplyBundlePatch accepts auto and opt-in changes", () => {
  assert.equal(
    shouldApplyBundlePatch({
      auto_actions: 1,
      manual_actions: 0,
      opt_in_remove_source_ids: [],
      opt_in_append_source_ids: [],
      issues: [],
    }),
    true,
  );
  assert.equal(
    shouldApplyBundlePatch({
      auto_actions: 0,
      manual_actions: 0,
      opt_in_remove_source_ids: ["guide_orb"],
      opt_in_append_source_ids: [],
      issues: [],
    }),
    true,
  );
});

test("buildVlmCloseLoopPlan prepares initial and residual directories", () => {
  const plan = buildVlmCloseLoopPlan({
    cwd: "/repo",
    example: "frog_authoring",
    editProfile: "roundtrip_diff_bundle",
    port: 8200,
    write: true,
  });

  assert.equal(plan.example, "frog_authoring");
  assert.equal(plan.port, 8200);
  assert.equal(plan.residualPort, 8201);
  assert.equal(plan.write, true);
  assert.equal(plan.feedbackOutDir, "/repo/output/playwright/frog-authoring-close-loop/feedback");
  assert.equal(plan.residualOutDir, "/repo/output/playwright/frog-authoring-close-loop/residual");
  assert.deepEqual(plan.initialArgs, [
    "--example",
    "frog_authoring",
    "--edit-profile",
    "roundtrip_diff_bundle",
    "--provider",
    "openrouter",
    "--serve",
    "--port",
    "8200",
    "--out-dir",
    "/repo/output/playwright/frog-authoring-close-loop/initial",
    "--execute",
  ]);
});
