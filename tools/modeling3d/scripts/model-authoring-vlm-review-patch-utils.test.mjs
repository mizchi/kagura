import test from "node:test";
import assert from "node:assert/strict";

import { buildReviewDrivenMoonBitPatch } from "./model-authoring-vlm-review-patch-utils.mjs";

function shelfBundle() {
  return {
    current_document: {
      primitives: [
        {
          id: "middle_shelf",
          kind: "cube",
          position: [0, 0.08, 0],
          scale: [1.48, 0.12, 0.48],
        },
        {
          id: "crate_left",
          kind: "cube",
          position: [-0.2, 0.25, 0.02],
          scale: [0.24, 0.24, 0.22],
        },
        {
          id: "crate_right",
          kind: "cube",
          position: [0.2, 0.23, -0.02],
          scale: [0.22, 0.2, 0.2],
        },
        {
          id: "book_stack",
          kind: "cube",
          position: [0.02, 0.38, 0],
          scale: [0.18, 0.12, 0.16],
        },
      ],
      sculpt_layers: [],
    },
  };
}

test("buildReviewDrivenMoonBitPatch emits snap-to-plane and spacing fixes for alignment reviews", () => {
  const patch = buildReviewDrivenMoonBitPatch(shelfBundle(), {
    manual_followups: [
      {
        source_id: "crate_right",
        issue_kind: "review_alignment",
        next_step: "Adjust Z-axis offset and Y position to maintain consistent spacing with crate_left.",
        rationale: "The crate_right is slightly floating relative to the middle shelf compared to crate_left.",
      },
    ],
    visual_findings: [
      {
        source_id: "crate_right",
        area: "primitive_transform",
        observation: "Slight misalignment in height and depth compared to the adjacent crate_left.",
        impact: "Inconsistent visual baseline for storage items.",
      },
    ],
  });

  assert.match(patch, /snap_to_plane:middle_shelf/);
  assert.match(patch, /equalize_spacing:crate_left/);
  assert.match(patch, /primitives\[2\]/);
  assert.match(patch, /position: @math3d\.Vec3::new\(0\.2, 0\.24(?:000000000000002)?, -0\.02\)/);
});

test("buildReviewDrivenMoonBitPatch emits overlap separation fixes", () => {
  const patch = buildReviewDrivenMoonBitPatch(shelfBundle(), {
    manual_followups: [
      {
        source_id: "crate_left",
        issue_kind: "review_overlap",
        next_step: "Adjust crate_left and crate_right positions to avoid intersecting.",
        rationale: "The middle shelf props are clipping together.",
      },
    ],
    visual_findings: [],
  });

  assert.match(patch, /separate_overlap:crate_right/);
  assert.match(patch, /primitives\[1\]/);
});

test("buildReviewDrivenMoonBitPatch returns a no-op when nothing deterministic applies", () => {
  const patch = buildReviewDrivenMoonBitPatch(shelfBundle(), {
    manual_followups: [],
    visual_findings: [],
  });

  assert.match(patch, /fn apply_vlm_review_patch/);
  assert.match(patch, /doc/);
  assert.match(patch, /No deterministic review-driven fixes/);
});
