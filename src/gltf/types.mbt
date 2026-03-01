///|
priv struct GltfAccessor {
  buffer_view : Int
  byte_offset : Int
  component_type : Int
  count : Int
  type_ : String
}

///|
priv struct GltfBufferView {
  buffer : Int
  byte_offset : Int
  byte_stride : Int
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
priv struct GltfDocument {
  accessors : Array[GltfAccessor]
  buffer_views : Array[GltfBufferView]
  meshes : Array[GltfMesh]
  nodes : Array[GltfNode]
  scenes : Array[GltfScene]
  materials : Array[GltfMaterial]
  default_scene : Int
}
