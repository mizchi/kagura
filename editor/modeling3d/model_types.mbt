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
  color_hex : Int32
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
  half_extent : Int32
  color_hex : Int32
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
  primitive_count : Int32
  sculpt_layer_count : Int32
  occupied_voxel_count : Int32
  render_object_count : Int32
  baked_vertex_count : Int32
  baked_triangle_count : Int32
}
