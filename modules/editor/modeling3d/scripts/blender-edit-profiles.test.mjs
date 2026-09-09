import test from "node:test";
import assert from "node:assert/strict";

import { buildBlenderEditRecipe } from "./blender-edit-profiles.mjs";

function expectedFor(nodes) {
  return {
    documentName: "test",
    nodes,
  };
}

test("buildBlenderEditRecipe keeps model_authoring roundtrip targets stable", () => {
  const recipe = buildBlenderEditRecipe(
    expectedFor([
      { source_id: "ground", node_kind: "primitive", primitive_kind: "plane" },
      { source_id: "pedestal", node_kind: "primitive", primitive_kind: "cube" },
      { source_id: "guide_orb", node_kind: "primitive", primitive_kind: "sphere" },
      { source_id: "clay_head", node_kind: "sculpt_layer" },
    ]),
    "roundtrip_diff_bundle",
  );

  assert.equal(recipe.normalizedProfile, "roundtrip_diff_bundle");
  assert.deepEqual(
    recipe.operations.map((operation) => operation.type),
    ["move_recolor", "delete", "increment_stamp_count", "duplicate_helper"],
  );
  assert.equal(recipe.operations[0].source_id, "pedestal");
  assert.equal(recipe.operations[1].source_id, "guide_orb");
  assert.equal(recipe.operations[2].source_id, "clay_head");
  assert.equal(recipe.operations[3].new_source_id, "blender_helper");
});

test("buildBlenderEditRecipe resolves chair_authoring targets", () => {
  const recipe = buildBlenderEditRecipe(
    expectedFor([
      { source_id: "ground", node_kind: "primitive", primitive_kind: "plane" },
      { source_id: "seat_board", node_kind: "primitive", primitive_kind: "cube" },
      { source_id: "right_side_brace", node_kind: "primitive", primitive_kind: "cube" },
      { source_id: "seat_cushion", node_kind: "sculpt_layer" },
    ]),
    "chair_roundtrip_diff_bundle",
  );

  assert.equal(recipe.normalizedProfile, "roundtrip_diff_bundle");
  assert.equal(recipe.operations[0].source_id, "seat_board");
  assert.equal(recipe.operations[1].source_id, "right_side_brace");
  assert.equal(recipe.operations[2].source_id, "seat_cushion");
  assert.equal(recipe.operations[3].new_source_id, "chair_helper");
});

test("buildBlenderEditRecipe resolves shelf_authoring targets", () => {
  const recipe = buildBlenderEditRecipe(
    expectedFor([
      { source_id: "ground", node_kind: "primitive", primitive_kind: "plane" },
      { source_id: "middle_shelf", node_kind: "primitive", primitive_kind: "cube" },
      { source_id: "rear_brace", node_kind: "primitive", primitive_kind: "cube" },
      { source_id: "crate_left", node_kind: "primitive", primitive_kind: "cube" },
    ]),
    "shelf_roundtrip_diff_bundle",
  );

  assert.equal(recipe.normalizedProfile, "roundtrip_diff_bundle");
  assert.equal(recipe.operations[0].source_id, "middle_shelf");
  assert.equal(recipe.operations[1].source_id, "rear_brace");
  assert.equal(recipe.operations[2].new_source_id, "shelf_helper");
  assert.deepEqual(
    recipe.operations.map((operation) => operation.type),
    ["move_recolor", "delete", "duplicate_helper"],
  );
});

test("buildBlenderEditRecipe resolves frog_authoring targets and kind mismatch aliases", () => {
  const bundle = buildBlenderEditRecipe(
    expectedFor([
      { source_id: "lily_pad", node_kind: "primitive", primitive_kind: "plane" },
      { source_id: "left_eye_white", node_kind: "primitive", primitive_kind: "sphere" },
      { source_id: "right_pupil", node_kind: "primitive", primitive_kind: "sphere" },
      { source_id: "frog_body", node_kind: "sculpt_layer" },
    ]),
    "frog_roundtrip_diff_bundle",
  );
  const mismatch = buildBlenderEditRecipe(
    expectedFor([
      { source_id: "lily_pad", node_kind: "primitive", primitive_kind: "plane" },
      { source_id: "left_eye_white", node_kind: "primitive", primitive_kind: "sphere" },
      { source_id: "right_pupil", node_kind: "primitive", primitive_kind: "sphere" },
      { source_id: "frog_body", node_kind: "sculpt_layer" },
    ]),
    "frog_kind_mismatch",
  );

  assert.equal(bundle.operations[0].source_id, "left_eye_white");
  assert.equal(bundle.operations[1].source_id, "right_pupil");
  assert.equal(bundle.operations[2].source_id, "frog_body");
  assert.equal(bundle.operations[3].new_source_id, "frog_helper");
  assert.equal(mismatch.normalizedProfile, "primary_kind_mismatch");
  assert.deepEqual(mismatch.operations, [
    {
      type: "set_primitive_kind",
      source_id: "left_eye_white",
      primitive_kind: "cube",
    },
  ]);
});

test("buildBlenderEditRecipe falls back to generic targets when no example preset matches", () => {
  const recipe = buildBlenderEditRecipe(
    expectedFor([
      { source_id: "floor", node_kind: "primitive", primitive_kind: "plane" },
      { source_id: "body", node_kind: "primitive", primitive_kind: "cube" },
      { source_id: "arm", node_kind: "primitive", primitive_kind: "cube" },
      { source_id: "goo", node_kind: "sculpt_layer" },
    ]),
    "roundtrip_diff_bundle",
  );

  assert.equal(recipe.operations[0].source_id, "body");
  assert.equal(recipe.operations[1].source_id, "floor");
  assert.equal(recipe.operations[2].source_id, "goo");
  assert.equal(recipe.operations[3].new_source_id, "body_helper");
});
