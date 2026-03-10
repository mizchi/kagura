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
    name: "vlm_shelf_study",
    notes: "Primitive-first shelf study with simple storage props. Useful for testing stacked hard-surface alignment in the VLM loop without relying on blob-like voxel clutter.",
    primitives: [
      {
        id: "ground",
        kind: Plane,
        position: @math3d.Vec3::new(0.0, -0.92, 0.0),
        scale: @math3d.Vec3::new(5.2, 1.0, 5.2),
        color_hex: 0x1A2232,
      },
      {
        id: "left_upright",
        kind: Cube,
        position: @math3d.Vec3::new(-0.66, -0.06, 0.0),
        scale: @math3d.Vec3::new(0.12, 1.72, 0.48),
        color_hex: 0x6A4D33,
      },
      {
        id: "right_upright",
        kind: Cube,
        position: @math3d.Vec3::new(0.66, -0.06, 0.0),
        scale: @math3d.Vec3::new(0.12, 1.72, 0.48),
        color_hex: 0x6A4D33,
      },
      {
        id: "top_shelf",
        kind: Cube,
        position: @math3d.Vec3::new(0.0, 0.72, 0.0),
        scale: @math3d.Vec3::new(1.48, 0.12, 0.48),
        color_hex: 0x7F5F3F,
      },
      {
        id: "middle_shelf",
        kind: Cube,
        position: @math3d.Vec3::new(0.0, 0.08, 0.0),
        scale: @math3d.Vec3::new(1.48, 0.12, 0.48),
        color_hex: 0x7B5A3C,
      },
      {
        id: "bottom_shelf",
        kind: Cube,
        position: @math3d.Vec3::new(0.0, -0.56, 0.0),
        scale: @math3d.Vec3::new(1.48, 0.12, 0.48),
        color_hex: 0x7F5F3F,
      },
      {
        id: "rear_brace",
        kind: Cube,
        position: @math3d.Vec3::new(0.0, 0.08, -0.22),
        scale: @math3d.Vec3::new(1.36, 1.4, 0.08),
        color_hex: 0x5B412C,
      },
      {
        id: "crate_left",
        kind: Cube,
        position: @math3d.Vec3::new(-0.2, 0.25, 0.02),
        scale: @math3d.Vec3::new(0.24, 0.24, 0.22),
        color_hex: 0x8C6A48,
      },
      {
        id: "crate_right",
        kind: Cube,
        position: @math3d.Vec3::new(0.2, 0.23, -0.02),
        scale: @math3d.Vec3::new(0.22, 0.2, 0.2),
        color_hex: 0x835F3F,
      },
      {
        id: "book_stack",
        kind: Cube,
        position: @math3d.Vec3::new(0.02, 0.38, 0.0),
        scale: @math3d.Vec3::new(0.18, 0.12, 0.16),
        color_hex: 0xAD8A61,
      },
      {
        id: "storage_box",
        kind: Cube,
        position: @math3d.Vec3::new(0.0, -0.27, 0.02),
        scale: @math3d.Vec3::new(0.44, 0.18, 0.24),
        color_hex: 0x7A593B,
      },
    ],
    sculpt_layers: [],
  })
}

///|
// VLM_ROUNDTRIP_PATCH_START
fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {
  doc
}
// VLM_ROUNDTRIP_PATCH_END
