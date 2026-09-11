// ============================================================
// Model document types
// ============================================================
//
// The document schema every authoring example shares. Each example supplies
// only its own data (default_model_document) and review profile; the schema,
// the editing/rendering/export code and the round-trip loop live here so a
// change lands once instead of five times.

///|
pub(all) enum PrimitiveKind {
  Cube
  Sphere
  Plane
}

///|
pub(all) enum SculptMode {
  Add
  Subtract
}

///|
pub(all) struct PrimitiveNode {
  id : String
  kind : PrimitiveKind
  position : @math3d.Vec3
  scale : @math3d.Vec3
  color_hex : Int
}

///|
pub(all) struct SculptStamp {
  id : String
  mode : SculptMode
  center : @math3d.Vec3
  radius : Double
}

///|
pub(all) struct SculptLayer {
  id : String
  voxel_size : Double
  half_extent : Int
  color_hex : Int
  muted_stamp_ids : Array[String]
  stamps : Array[SculptStamp]
}

///|
pub(all) struct ModelDocument {
  name : String
  notes : String
  primitives : Array[PrimitiveNode]
  sculpt_layers : Array[SculptLayer]
}

///|
pub(all) struct DocumentStats {
  primitive_count : Int
  sculpt_layer_count : Int
  occupied_voxel_count : Int
  render_object_count : Int
  baked_vertex_count : Int
  baked_triangle_count : Int
}
