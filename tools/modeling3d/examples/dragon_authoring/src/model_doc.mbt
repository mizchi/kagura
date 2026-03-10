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
    name: "vlm_dragon_study",
    notes: "Stylized dragon maquette built from a voxel sculpt body plus glowing eye landmarks. Useful for testing organic blockout, readable wings, and tail silhouette review in the VLM loop.",
    primitives: [
      {
        id: "stone_plinth",
        kind: Plane,
        position: @math3d.Vec3::new(0.0, -0.88, 0.0),
        scale: @math3d.Vec3::new(4.6, 1.0, 4.6),
        color_hex: 0x241A19,
      },
      {
        id: "left_eye_glow",
        kind: Sphere,
        position: @math3d.Vec3::new(-0.18, 0.46, 0.66),
        scale: @math3d.Vec3::new(0.07, 0.07, 0.07),
        color_hex: 0xF5CE43,
      },
      {
        id: "right_eye_glow",
        kind: Sphere,
        position: @math3d.Vec3::new(0.18, 0.46, 0.66),
        scale: @math3d.Vec3::new(0.07, 0.07, 0.07),
        color_hex: 0xF5CE43,
      },
    ],
    sculpt_layers: [
      {
        id: "dragon_body",
        voxel_size: 0.12,
        half_extent: 7,
        color_hex: 0x7A4D33,
        muted_stamp_ids: [],
        stamps: [
          {
            id: "torso",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.0, -0.04),
            radius: 0.48,
          },
          {
            id: "chest",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.16, 0.14),
            radius: 0.28,
          },
          {
            id: "shoulder_saddle",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.22, 0.02),
            radius: 0.22,
          },
          {
            id: "neck_base",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.3, 0.26),
            radius: 0.18,
          },
          {
            id: "neck_head",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.42, 0.46),
            radius: 0.16,
          },
          {
            id: "head",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.5, 0.62),
            radius: 0.22,
          },
          {
            id: "snout",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.4, 0.84),
            radius: 0.12,
          },
          {
            id: "lower_jaw",
            mode: Add,
            center: @math3d.Vec3::new(0.0, 0.28, 0.7),
            radius: 0.1,
          },
          {
            id: "left_horn",
            mode: Add,
            center: @math3d.Vec3::new(-0.12, 0.66, 0.52),
            radius: 0.08,
          },
          {
            id: "right_horn",
            mode: Add,
            center: @math3d.Vec3::new(0.12, 0.66, 0.52),
            radius: 0.08,
          },
          {
            id: "left_wing_root",
            mode: Add,
            center: @math3d.Vec3::new(-0.24, 0.28, -0.02),
            radius: 0.16,
          },
          {
            id: "right_wing_root",
            mode: Add,
            center: @math3d.Vec3::new(0.24, 0.28, -0.02),
            radius: 0.16,
          },
          {
            id: "left_wing_mid",
            mode: Add,
            center: @math3d.Vec3::new(-0.46, 0.42, -0.04),
            radius: 0.18,
          },
          {
            id: "right_wing_mid",
            mode: Add,
            center: @math3d.Vec3::new(0.46, 0.42, -0.04),
            radius: 0.18,
          },
          {
            id: "left_wing_tip",
            mode: Add,
            center: @math3d.Vec3::new(-0.72, 0.54, -0.12),
            radius: 0.12,
          },
          {
            id: "right_wing_tip",
            mode: Add,
            center: @math3d.Vec3::new(0.72, 0.54, -0.12),
            radius: 0.12,
          },
          {
            id: "left_foreleg",
            mode: Add,
            center: @math3d.Vec3::new(-0.22, -0.16, 0.16),
            radius: 0.16,
          },
          {
            id: "right_foreleg",
            mode: Add,
            center: @math3d.Vec3::new(0.22, -0.16, 0.16),
            radius: 0.16,
          },
          {
            id: "left_haunch",
            mode: Add,
            center: @math3d.Vec3::new(-0.28, -0.14, -0.24),
            radius: 0.22,
          },
          {
            id: "right_haunch",
            mode: Add,
            center: @math3d.Vec3::new(0.28, -0.14, -0.24),
            radius: 0.22,
          },
          {
            id: "tail_base",
            mode: Add,
            center: @math3d.Vec3::new(-0.02, 0.02, -0.42),
            radius: 0.18,
          },
          {
            id: "tail_mid_left",
            mode: Add,
            center: @math3d.Vec3::new(-0.12, 0.12, -0.68),
            radius: 0.14,
          },
          {
            id: "tail_mid_right",
            mode: Add,
            center: @math3d.Vec3::new(0.04, 0.24, -0.94),
            radius: 0.1,
          },
          {
            id: "tail_tip",
            mode: Add,
            center: @math3d.Vec3::new(0.12, 0.38, -1.18),
            radius: 0.07,
          },
          {
            id: "jaw_cut",
            mode: Subtract,
            center: @math3d.Vec3::new(0.0, 0.3, 0.78),
            radius: 0.1,
          },
          {
            id: "neck_cut",
            mode: Subtract,
            center: @math3d.Vec3::new(0.0, 0.22, 0.34),
            radius: 0.12,
          },
          {
            id: "belly_cut",
            mode: Subtract,
            center: @math3d.Vec3::new(0.0, -0.26, 0.04),
            radius: 0.26,
          },
        ],
      },
    ],
  })
}

///|
fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {
  doc
}
