///|
priv struct GltfAccessor {
  buffer_view : Int
  byte_offset : Int
  component_type : Int
  count : Int
  type_ : String
  normalized : Bool
}

///|
/// The EXT_meshopt_compression / KHR_meshopt_compression part of a
/// bufferView: where the compressed bytes are and how to decode them.
priv struct GltfCompressedView {
  buffer : Int
  byte_offset : Int
  byte_length : Int
  byte_stride : Int
  count : Int
  mode : String
  filter : String
}

///|
priv struct GltfBufferView {
  buffer : Int
  byte_offset : Int
  byte_stride : Int
  compressed : GltfCompressedView?
}

///|
priv struct GltfPrimitive {
  attributes : Map[String, Int]
  indices : Int?
  material : Int?
  mode : Int
}

///|
priv struct GltfMesh {
  primitives : Array[GltfPrimitive]
}

///|
priv struct GltfNode {
  mesh : Int?
  skin : Int?
  children : Array[Int]
  translation : @math3d.Vec3
  rotation : @math3d.Quaternion
  scale : @math3d.Vec3
}

///|
priv struct GltfScene {
  nodes : Array[Int]
}

///|
priv struct GltfMaterial {
  base_color_factor : @math3d.Vec4
}

///|
priv struct GltfSkin {
  joints : Array[Int]
  inverse_bind_matrices : Int? // accessor index
}

///|
priv struct GltfAnimSampler {
  input : Int // accessor index (keyframe times)
  output : Int // accessor index (keyframe values)
  interpolation : String // "LINEAR", "STEP", "CUBICSPLINE"
}

///|
priv struct GltfAnimChannel {
  sampler : Int
  target_node : Int
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
  default_scene : Int
}
