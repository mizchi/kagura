///|
priv struct GltfAccessor {
  buffer_view : Int32
  byte_offset : Int32
  component_type : Int32
  count : Int32
  type_ : String
  normalized : Bool
}

///|
/// The EXT_meshopt_compression / KHR_meshopt_compression part of a
/// bufferView: where the compressed bytes are and how to decode them.
priv struct GltfCompressedView {
  buffer : Int32
  byte_offset : Int32
  byte_length : Int32
  byte_stride : Int32
  count : Int32
  mode : String
  filter : String
}

///|
priv struct GltfBufferView {
  buffer : Int32
  byte_offset : Int32
  byte_stride : Int32
  compressed : GltfCompressedView?
}

///|
priv struct GltfPrimitive {
  attributes : Map[String, Int32]
  indices : Int32?
  material : Int32?
  mode : Int32
}

///|
priv struct GltfMesh {
  primitives : Array[GltfPrimitive]
}

///|
priv struct GltfNode {
  mesh : Int32?
  skin : Int32?
  children : Array[Int32]
  translation : @math3d.Vec3
  rotation : @math3d.Quaternion
  scale : @math3d.Vec3
}

///|
priv struct GltfScene {
  nodes : Array[Int32]
}

///|
priv struct GltfMaterial {
  base_color_factor : @math3d.Vec4
}

///|
priv struct GltfSkin {
  joints : Array[Int32]
  inverse_bind_matrices : Int32? // accessor index
}

///|
priv struct GltfAnimSampler {
  input : Int32 // accessor index (keyframe times)
  output : Int32 // accessor index (keyframe values)
  interpolation : String // "LINEAR", "STEP", "CUBICSPLINE"
}

///|
priv struct GltfAnimChannel {
  sampler : Int32
  target_node : Int32
  target_path : String // "translation", "rotation", "scale"
}

///|
priv struct GltfAnimation {
  name : String
  channels : Array[GltfAnimChannel]
  samplers : Array[GltfAnimSampler]
}

///|
priv struct GltfDocument {
  accessors : Array[GltfAccessor]
  buffer_views : Array[GltfBufferView]
  meshes : Array[GltfMesh]
  nodes : Array[GltfNode]
  scenes : Array[GltfScene]
  materials : Array[GltfMaterial]
  skins : Array[GltfSkin]
  animations : Array[GltfAnimation]
  default_scene : Int32
}
