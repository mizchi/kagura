import test from "node:test";
import assert from "node:assert/strict";

import { buildOptInMoonBitPatch } from "./model-authoring-vlm-opt-in-patch-utils.mjs";

test("buildOptInMoonBitPatch merges auto patch with opt-in remove and append", () => {
  const patch = buildOptInMoonBitPatch({
    current_document: {
      primitives: [
        { id: "pedestal" },
        { id: "guide_orb" },
      ],
      sculpt_layers: [
        { id: "clay_head" },
      ],
    },
    patch_payload: {
      auto_actions: [
        {
          source_id: "pedestal",
          target_kind: "primitive",
          action_kind: "set_position",
          target_position: [0.2, 0.0, 0.0],
        },
        {
          source_id: "pedestal",
          target_kind: "primitive",
          action_kind: "set_color",
          target_color_hex: "#E39C54",
        },
      ],
      opt_in_remove_source_ids: ["guide_orb"],
      opt_in_append_source_ids: ["blender_helper"],
      manual_issue_details: [
        {
          source_id: "guide_orb",
          action_kind: "review_missing",
          target_kind: "primitive",
          suggested_moonbit: "// ignore(primitives.remove(1))",
        },
        {
          source_id: "clay_head",
          action_kind: "review_stamp_count",
          target_kind: "sculpt_layer",
          suggested_moonbit:
            "// stamp_count mismatch for clay_head\n// current: 6, imported: 7",
        },
        {
          source_id: "blender_helper",
          action_kind: "review_extra",
          target_kind: "primitive",
          imported_primitive_kind: "cube",
          imported_position: [1.2, 0, 0],
          imported_scale: [0.2, 0.2, 0.2],
          imported_color_hex: "0xAAAAAA",
          suggested_moonbit:
            "// primitives.push({ id: \"blender_helper\" })",
        },
      ],
    },
  });

  assert.match(patch, /let primitives = doc\.primitives\.copy\(\)/);
  assert.match(patch, /primitives\[0\] = \{/);
  assert.match(patch, /position: @math3d\.Vec3::new\(0.2, 0, 0\),/);
  assert.match(patch, /color_hex: 0xE39C54,/);
  assert.match(patch, /ignore\(primitives\.remove\(1\)\)/);
  assert.match(patch, /id: "blender_helper"/);
  assert.match(patch, /color_hex: 0xAAAAAA,/);
  assert.match(patch, /\/\/ stamp_count mismatch for clay_head/);
  assert.doesNotMatch(patch, /\/\/ primitives\.push\(\{ id: "blender_helper"/);
  assert.doesNotMatch(patch, /\/\/ ignore\(primitives\.remove\(1\)\)/);
});
