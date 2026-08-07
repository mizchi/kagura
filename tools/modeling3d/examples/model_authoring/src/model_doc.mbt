// ============================================================
// Generic model document
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
    name: "vlm_clay_totem",
    notes: "Code-first hard-surface parts plus an ordered voxel sculpt layer. Designed for screenshot + JSON context review.",
    primitives: [
      {
        id: "ground",
        kind: Plane,
        position: @math3d.Vec3::new(0.0, -0.72, 0.0),
        scale: @math3d.Vec3::new(4.5, 1.0, 4.5),
        color_hex: 0x1E2638,
      },
      {
        id: "pedestal",
        kind: Cube,
        position: @math3d.Vec3::new(0.0, -0.25, 0.0),
        scale: @math3d.Vec3::new(0.9, 0.35, 0.9),
        color_hex: 0x51617A,
      },
      {
        id: "guide_orb",
        kind: Sphere,
        position: @math3d.Vec3::new(0.55, 0.95, -0.55),
        scale: @math3d.Vec3::new(0.18, 0.18, 0.18),
        color_hex: 0x6FC7FF,
      },
    ],
    sculpt_layers: [
      {
        id: "clay_head",
        voxel_size: 0.14,
        half_extent: 5,
        color_hex: 0xD98F70,
        muted_stamp_ids: [],
        stamps: [
          {
            id: "skull",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.82, 0.0),
            radius: 0.55,
          },
          {
            id: "jaw",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.55, 0.08),
            radius: 0.34,
          },
          {
            id: "crown",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 1.12, -0.02),
            radius: 0.26,
          },
          {
            id: "left_eye_socket",
            mode: Subtract,
            center: @math3d.Vec3::new(-0.18, 0.86, 0.28),
            radius: 0.15,
          },
          {
            id: "right_eye_socket",
            mode: Subtract,
            center: @math3d.Vec3::new(0.18, 0.86, 0.28),
            radius: 0.15,
          },
          {
            id: "mouth_cut",
            mode: Subtract,
            center: @math3d.Vec3::new(0.0, 0.56, 0.36),
            radius: 0.18,
          },
        ],
      },
    ],
  })
}

// VLM_ROUNDTRIP_PATCH_START

///|
fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {
  let primitives = doc.primitives.copy()
  primitives[1] = {
    ..primitives[1],
    position: @math3d.Vec3::new(0.20000000298023224, -0.25, 0),
    scale: @math3d.Vec3::new(
      0.8999999761581421, 0.4025000035762787, 0.8999999761581421,
    ),
    color_hex: 0xE39C54,
  }
  { ..doc, primitives, }
}

// Manual review
// primitive missing in imported GLB
// ignore(primitives.remove(2))
// stamp_count mismatch for clay_head
// current: 6, imported: 7
// TODO: mirror Blender-side sculpt edits back into layer.stamps manually.
// extra primitive from imported GLB
// primitives.push({
//   id: "blender_helper",
//   kind: Cube,
//   position: @math3d.Vec3::new(1.2000000476837158, 0, 0),
//   scale: @math3d.Vec3::new(0.20000000298023224, 0.20000000298023224, 0.20000000298023224),
//   color_hex: 0xE39C54,
// })
// VLM_ROUNDTRIP_PATCH_END
