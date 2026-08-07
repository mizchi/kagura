// ============================================================
// Chair study document
// ============================================================
//
// This example's model data. The document schema, the editor, the renderer and
// the round-trip review loop live in `mizchi/kagura_modeling3d`; only the data
// and the review profile are per-example.
//
// `tools/modeling3d/scripts/model-authoring-vlm-apply-patch.mjs` edits this file
// by locating the `default_model_document` and `apply_imported_patch` signatures
// verbatim, so the alias below is what keeps them spelled `ModelDocument`.

///|
using @modeling3d {type ModelDocument}

///|
fn default_model_document() -> ModelDocument {
  apply_imported_patch({
    name: "vlm_chair_study",
    notes: "Primitive-first dining chair study with a small voxel cushion layer. Useful for testing hard-surface transforms and small sculpt touch-ups in the VLM loop.",
    primitives: [
      {
        id: "ground",
        kind: Plane,
        position: @math3d.Vec3::new(0.0, -0.72, 0.0),
        scale: @math3d.Vec3::new(4.5, 1.0, 4.5),
        color_hex: 0x1A2232,
      },
      {
        id: "seat_board",
        kind: Cube,
        position: @math3d.Vec3::new(0.0, 0.02, 0.0),
        scale: @math3d.Vec3::new(1.18, 0.12, 1.18),
        color_hex: 0x7B5A3C,
      },
      {
        id: "backrest",
        kind: Cube,
        position: @math3d.Vec3::new(0.0, 0.84, -0.49),
        scale: @math3d.Vec3::new(1.18, 1.18, 0.12),
        color_hex: 0x7B5A3C,
      },
      {
        id: "front_left_leg",
        kind: Cube,
        position: @math3d.Vec3::new(-0.46, -0.48, 0.42),
        scale: @math3d.Vec3::new(0.14, 0.96, 0.14),
        color_hex: 0x6F5137,
      },
      {
        id: "front_right_leg",
        kind: Cube,
        position: @math3d.Vec3::new(0.46, -0.48, 0.42),
        scale: @math3d.Vec3::new(0.14, 0.96, 0.14),
        color_hex: 0x6F5137,
      },
      {
        id: "rear_left_leg",
        kind: Cube,
        position: @math3d.Vec3::new(-0.46, -0.48, -0.42),
        scale: @math3d.Vec3::new(0.14, 0.96, 0.14),
        color_hex: 0x6F5137,
      },
      {
        id: "rear_right_leg",
        kind: Cube,
        position: @math3d.Vec3::new(0.46, -0.48, -0.42),
        scale: @math3d.Vec3::new(0.14, 0.96, 0.14),
        color_hex: 0x6F5137,
      },
      {
        id: "left_side_brace",
        kind: Cube,
        position: @math3d.Vec3::new(-0.46, -0.16, 0.0),
        scale: @math3d.Vec3::new(0.1, 0.08, 0.9),
        color_hex: 0x57402D,
      },
      {
        id: "right_side_brace",
        kind: Cube,
        position: @math3d.Vec3::new(0.46, -0.16, 0.0),
        scale: @math3d.Vec3::new(0.1, 0.08, 0.9),
        color_hex: 0x57402D,
      },
    ],
    sculpt_layers: [
      {
        id: "seat_cushion",
        voxel_size: 0.11,
        half_extent: 5,
        color_hex: 0xC89E72,
        muted_stamp_ids: [],
        stamps: [
          {
            id: "cushion_base",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.17, 0.02),
            radius: 0.46,
          },
          {
            id: "back_support",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.2, -0.12),
            radius: 0.3,
          },
          {
            id: "front_round",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.14, 0.24),
            radius: 0.2,
          },
          {
            id: "seat_dip",
            mode: Subtract,
            center: @math3d.Vec3::new(0.0, 0.22, 0.06),
            radius: 0.16,
          },
        ],
      },
    ],
  })
}

///|
// VLM_ROUNDTRIP_PATCH_START
fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {
  let primitives = doc.primitives.copy()
  let sculpt_layers = doc.sculpt_layers.copy()
  primitives[1] = {
    ..primitives[1],
    position: @math3d.Vec3::new(0.20000000298023224, 0.019999999552965164, 0),
    scale: @math3d.Vec3::new(
      1.1799999475479126, 0.1379999965429306, 1.1799999475479126,
    ),
    color_hex: 0xC09C74,
  }
  ignore(primitives.remove(8))
  primitives.push({
    id: "chair_helper",
    kind: Cube,
    position: @math3d.Vec3::new(1.2000000476837158, 0, 0),
    scale: @math3d.Vec3::new(
      0.20000000298023224, 0.20000000298023224, 0.20000000298023224,
    ),
    color_hex: 0xC09C74,
  })
  let seat_stamps = sculpt_layers[0].stamps.copy()
  seat_stamps.push({
    id: "seat_right_bolster",
    mode: Add,
    center: @math3d.Vec3::new(0.22, 0.19, 0.02),
    radius: 0.13,
  })
  sculpt_layers[0] = {
    ..sculpt_layers[0],
    muted_stamp_ids: [],
    stamps: seat_stamps,
  }
  { ..doc, primitives, sculpt_layers }
}
// VLM_ROUNDTRIP_PATCH_END
