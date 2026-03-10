import test from "node:test";
import assert from "node:assert/strict";

import {
  buildStampReviewMarkdown,
  buildStampSyncScaffold,
} from "./model-authoring-vlm-local-feedback-utils.mjs";

test("buildStampReviewMarkdown summarizes manual sculpt stamp issues", () => {
  const markdown = buildStampReviewMarkdown({
    targetFile: "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt",
    patchPayload: {
      manual_issue_details: [
        {
          source_id: "frog_body",
          issue_kind: "review_stamp_count",
          current_stamp_count: 8,
          imported_stamp_count: 9,
          review_hint: "Do not invent sculpt stamps",
          suggested_moonbit:
            "// stamp_count mismatch for frog_body\n// current: 8, imported: 9",
        },
      ],
    },
    review: {
      target_file: "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt",
      manual_followups: [
        {
          source_id: "frog_body",
          issue_kind: "review_stamp_count",
          next_step: "Inspect Blender sculpt history.",
        },
      ],
      visual_findings: [
        {
          source_id: "frog_body",
          observation: "Stamp count increased by one.",
        },
      ],
      source_task_queue: [
        {
          source_id: "frog_body",
          summary_line:
            "[medium] frog_body manual_review: manual review_stamp_count,manual_sculpt_review; visual sculpt_stamp_count",
        },
      ],
    },
  });

  assert.match(markdown, /^# Kagura Sculpt Stamp Review/m);
  assert.match(markdown, /Target file: `tools\/modeling3d\/examples\/frog_authoring\/src\/model_doc\.mbt`/);
  assert.match(markdown, /## frog_body/);
  assert.match(markdown, /Current stamps: `8`/);
  assert.match(markdown, /Imported stamps: `9`/);
  assert.match(markdown, /Hint: Do not invent sculpt stamps/);
  assert.match(markdown, /Next step: Inspect Blender sculpt history\./);
  assert.match(markdown, /Visual finding: Stamp count increased by one\./);
  assert.match(markdown, /Task queue: \[medium\] frog_body manual_review/);
  assert.match(markdown, /```moonbit/);
});

test("buildStampReviewMarkdown reports when there are no sculpt stamp issues", () => {
  const markdown = buildStampReviewMarkdown({
    targetFile: "tools/modeling3d/examples/chair_authoring/src/model_doc.mbt",
    patchPayload: {
      manual_issue_details: [],
    },
    review: {
      target_file: "tools/modeling3d/examples/chair_authoring/src/model_doc.mbt",
    },
  });

  assert.match(markdown, /No sculpt stamp review issues\./);
});

test("buildStampSyncScaffold prints current stamps and TODO placeholders", () => {
  const scaffold = buildStampSyncScaffold({
    targetFile: "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt",
    bundle: {
      target_file: "tools/modeling3d/examples/frog_authoring/src/model_doc.mbt",
      current_document: {
        sculpt_layers: [
          {
            id: "frog_body",
            stamps: [
              {
                id: "body",
                mode: "add",
                center: [0, 0.04, 0.02],
                radius: 0.58,
              },
            ],
          },
        ],
      },
      patch_payload: {
        manual_issue_details: [
          {
            source_id: "frog_body",
            issue_kind: "review_stamp_count",
            current_stamp_count: 1,
            imported_stamp_count: 2,
            review_hint: "Do not invent sculpt stamps",
          },
        ],
      },
    },
  });

  assert.match(scaffold, /^fn apply_imported_stamp_sync/);
  assert.match(scaffold, /frog_body: current 1, imported 2/);
  assert.match(scaffold, /TODO append 1 stamp\(s\)/);
  assert.match(scaffold, /body: Add center=@math3d\.Vec3::new\(0, 0.04, 0.02\) radius=0.58/);
  assert.match(scaffold, /id: "frog_body_todo_1"/);
  assert.match(scaffold, /mode: Add/);
});
