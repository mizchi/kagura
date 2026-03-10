///|
enum PrimitiveKind {
  Cube
  Sphere
  Plane
}

///|
enum SculptMode {
  Add
  Subtract
}

///|
struct PrimitiveNode {
  id : String
  kind : PrimitiveKind
  position : @math3d.Vec3
  scale : @math3d.Vec3
  color_hex : Int
}

///|
struct SculptStamp {
  id : String
  mode : SculptMode
  center : @math3d.Vec3
  radius : Double
}

///|
struct SculptLayer {
  id : String
  voxel_size : Double
  half_extent : Int
  color_hex : Int
  muted_stamp_ids : Array[String]
  stamps : Array[SculptStamp]
}

///|
struct ModelDocument {
  name : String
  notes : String
  primitives : Array[PrimitiveNode]
  sculpt_layers : Array[SculptLayer]
}

///|
struct DocumentStats {
  primitive_count : Int
  sculpt_layer_count : Int
  occupied_voxel_count : Int
  render_object_count : Int
  baked_vertex_count : Int
  baked_triangle_count : Int
}

///|
fn default_model_document() -> ModelDocument {
  apply_imported_patch({
    name: "vlm_frog_study",
    notes: "Stylized frog maquette built from a voxel sculpt body plus eye primitives. Includes creature scaffolding for head, eye ridges, forelimbs, haunches, and a mouth landmark so the VLM loop does not drift back into a generic blob.",
    primitives: [
      {
        id: "lily_pad",
        kind: Plane,
        position: @math3d.Vec3::new(0.0, -0.72, 0.0),
        scale: @math3d.Vec3::new(4.2, 1.0, 4.2),
        color_hex: 0x274A2E,
      },
      {
        id: "left_eye_white",
        kind: Sphere,
        position: @math3d.Vec3::new(-0.2, 0.57, 0.36),
        scale: @math3d.Vec3::new(0.18, 0.18, 0.18),
        color_hex: 0xF4F2E8,
      },
      {
        id: "right_eye_white",
        kind: Sphere,
        position: @math3d.Vec3::new(0.2, 0.57, 0.36),
        scale: @math3d.Vec3::new(0.18, 0.18, 0.18),
        color_hex: 0xF4F2E8,
      },
      {
        id: "left_pupil",
        kind: Sphere,
        position: @math3d.Vec3::new(-0.2, 0.59, 0.48),
        scale: @math3d.Vec3::new(0.06, 0.06, 0.06),
        color_hex: 0x101418,
      },
      {
        id: "right_pupil",
        kind: Sphere,
        position: @math3d.Vec3::new(0.2, 0.59, 0.48),
        scale: @math3d.Vec3::new(0.06, 0.06, 0.06),
        color_hex: 0x101418,
      },
    ],
    sculpt_layers: [
      {
        id: "frog_body",
        voxel_size: 0.12,
        half_extent: 6,
        color_hex: 0x5DA35C,
        muted_stamp_ids: [],
        stamps: [
          {
            id: "body",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.04, 0.02),
            radius: 0.58,
          },
          {
            id: "head",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.28, 0.26),
            radius: 0.38,
          },
          {
            id: "left_eye_ridge",
            mode: Add,
            center: @math3d.Vec3::new(-0.18, 0.38, 0.24),
            radius: 0.14,
          },
          {
            id: "right_eye_ridge",
            mode: Add,
            center: @math3d.Vec3::new(0.18, 0.38, 0.24),
            radius: 0.14,
          },
          {
            id: "left_haunch",
            mode: Add,
            center: @math3d.Vec3::new(-0.36, -0.08, -0.24),
            radius: 0.28,
          },
          {
            id: "right_haunch",
            mode: Add,
            center: @math3d.Vec3::new(0.36, -0.08, -0.24),
            radius: 0.28,
          },
          {
            id: "left_forearm",
            mode: Add,
            center: @math3d.Vec3::new(-0.34, -0.06, 0.34),
            radius: 0.18,
          },
          {
            id: "right_forearm",
            mode: Add,
            center: @math3d.Vec3::new(0.34, -0.06, 0.34),
            radius: 0.18,
          },
          {
            id: "mouth_cut",
            mode: Subtract,
            center: @math3d.Vec3::new(0.0, 0.18, 0.54),
            radius: 0.12,
          },
          {
            id: "belly_flatten",
            mode: Subtract,
            center: @math3d.Vec3::new(0.0, -0.2, 0.16),
            radius: 0.24,
          },
        ],
      },
    ],
  })
}

///|
// VLM_ROUNDTRIP_PATCH_START
fn apply_imported_patch_stage_0(doc : ModelDocument) -> ModelDocument {
  let primitives = doc.primitives.copy()
  let sculpt_layers = doc.sculpt_layers.copy()
  primitives[1] = {
    ..primitives[1],
    position: @math3d.Vec3::new(0, 0.5699999928474426, 0.36000001430511475),
    scale: @math3d.Vec3::new(
      0.18000000715255737, 0.2070000022649765, 0.18000000715255737,
    ),
    color_hex: 0xF0D060,
  }
  ignore(primitives.remove(4))
  primitives.push({
    id: "frog_helper",
    kind: Cube,
    position: @math3d.Vec3::new(1.2000000476837158, 0, 0),
    scale: @math3d.Vec3::new(
      0.20000000298023224, 0.20000000298023224, 0.20000000298023224,
    ),
    color_hex: 0xF0D060,
  })
  let frog_stamps = sculpt_layers[0].stamps.copy()
  frog_stamps.push({
    id: "left_brow_pad",
    mode: Add,
    center: @math3d.Vec3::new(-0.18, 0.37, 0.22),
    radius: 0.12,
  })
  sculpt_layers[0] = {
    ..sculpt_layers[0],
    muted_stamp_ids: [],
    stamps: frog_stamps,
  }
  { ..doc, primitives, sculpt_layers }
}

///|
fn apply_imported_patch_stage_1(doc : ModelDocument) -> ModelDocument {
  let primitives = doc.primitives.copy()
  primitives[1] = {
    ..primitives[1],
    position: @math3d.Vec3::new(
      0.20000000298023224, 0.5699999928474426, 0.36000001430511475,
    ),
    scale: @math3d.Vec3::new(
      0.18000000715255737, 0.23804999887943268, 0.18000000715255737,
    ),
    color_hex: 0xCCA673,
  }
  ignore(primitives.remove(2))
  primitives.push({
    id: "left_eye_white_helper",
    kind: Cube,
    position: @math3d.Vec3::new(1.2000000476837158, 0, 0),
    scale: @math3d.Vec3::new(
      0.20000000298023224, 0.20000000298023224, 0.20000000298023224,
    ),
    color_hex: 0xCCA673,
  })
  { ..doc, primitives, }
}

///|
fn apply_imported_patch_stage_2(doc : ModelDocument) -> ModelDocument {
  let sculpt_layers = doc.sculpt_layers.copy()
  let frog_stamps = sculpt_layers[0].stamps.copy()
  frog_stamps.push({
    id: "right_brow_pad",
    mode: Add,
    center: @math3d.Vec3::new(0.18, 0.37, 0.22),
    radius: 0.12,
  })
  sculpt_layers[0] = {
    ..sculpt_layers[0],
    muted_stamp_ids: [],
    stamps: frog_stamps,
  }
  { ..doc, sculpt_layers, }
}

///|
fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {
  let stage_0 = apply_imported_patch_stage_0(doc)
  let stage_1 = apply_imported_patch_stage_1(stage_0)
  let stage_2 = apply_imported_patch_stage_2(stage_1)
  stage_2
}
// VLM_ROUNDTRIP_PATCH_END
