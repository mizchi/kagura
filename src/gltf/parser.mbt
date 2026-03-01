///|
fn parse_accessor(obj : Json) -> GltfAccessor {
  {
    buffer_view: json_get_int(obj, "bufferView", 0),
    byte_offset: json_get_int(obj, "byteOffset", 0),
    component_type: json_get_int(obj, "componentType", 5126),
    count: json_get_int(obj, "count", 0),
    type_: json_get_string(obj, "type", "SCALAR"),
  }
}

///|
fn parse_buffer_view(obj : Json) -> GltfBufferView {
  {
    buffer: json_get_int(obj, "buffer", 0),
    byte_offset: json_get_int(obj, "byteOffset", 0),
    byte_stride: json_get_int(obj, "byteStride", 0),
  }
}

///|
fn parse_primitive(obj : Json) -> GltfPrimitive {
  let attributes : Map[String, Int] = {}
  match json_get(obj, "attributes") {
    Some(Object(map)) => map.each(fn(k, v) { attributes[k] = json_int(v) })
    _ => ()
  }
  let indices = match json_get(obj, "indices") {
    Some(v) => json_int_opt(v)
    None => None
  }
  let material = match json_get(obj, "material") {
    Some(v) => json_int_opt(v)
    None => None
  }
  { attributes, indices, material, mode: json_get_int(obj, "mode", 4) }
}

///|
fn parse_mesh(obj : Json) -> GltfMesh {
  let primitives : Array[GltfPrimitive] = []
  for p in json_get_array(obj, "primitives") {
    primitives.push(parse_primitive(p))
  }
  { primitives, }
}

///|
fn parse_node(obj : Json) -> GltfNode {
  let children : Array[Int] = []
  for c in json_get_array(obj, "children") {
    children.push(json_int(c))
  }
  let t = json_get_array(obj, "translation")
  let translation = if t.length() >= 3 {
    @math3d.Vec3::new(json_double(t[0]), json_double(t[1]), json_double(t[2]))
  } else {
    @math3d.Vec3::zero()
  }
  let r = json_get_array(obj, "rotation")
  let rotation = if r.length() >= 4 {
    @math3d.Quaternion::new(
      json_double(r[0]),
      json_double(r[1]),
      json_double(r[2]),
      json_double(r[3]),
    )
  } else {
    @math3d.Quaternion::identity()
  }
  let s = json_get_array(obj, "scale")
  let scale = if s.length() >= 3 {
    @math3d.Vec3::new(json_double(s[0]), json_double(s[1]), json_double(s[2]))
  } else {
    @math3d.Vec3::one()
  }
  let mesh = match json_get(obj, "mesh") {
    Some(v) => json_int_opt(v)
    None => None
  }
  { mesh, children, translation, rotation, scale }
}

///|
fn parse_scene(obj : Json) -> GltfScene {
  let nodes : Array[Int] = []
  for n in json_get_array(obj, "nodes") {
    nodes.push(json_int(n))
  }
  { nodes, }
}

///|
fn parse_material(obj : Json) -> GltfMaterial {
  let mut color = @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
  match json_get(obj, "pbrMetallicRoughness") {
    Some(pbr) => {
      let f = json_get_array(pbr, "baseColorFactor")
      if f.length() >= 4 {
        color = @math3d.Vec4::new(
          json_double(f[0]),
          json_double(f[1]),
          json_double(f[2]),
          json_double(f[3]),
        )
      }
    }
    None => ()
  }
  { base_color_factor: color }
}

///|
fn parse_document(root : Json) -> GltfDocument {
  let accessors : Array[GltfAccessor] = []
  for a in json_get_array(root, "accessors") {
    accessors.push(parse_accessor(a))
  }
  let buffer_views : Array[GltfBufferView] = []
  for bv in json_get_array(root, "bufferViews") {
    buffer_views.push(parse_buffer_view(bv))
  }
  let meshes : Array[GltfMesh] = []
  for m in json_get_array(root, "meshes") {
    meshes.push(parse_mesh(m))
  }
  let nodes : Array[GltfNode] = []
  for n in json_get_array(root, "nodes") {
    nodes.push(parse_node(n))
  }
  let scenes : Array[GltfScene] = []
  for s in json_get_array(root, "scenes") {
    scenes.push(parse_scene(s))
  }
  let materials : Array[GltfMaterial] = []
  for m in json_get_array(root, "materials") {
    materials.push(parse_material(m))
  }
  let default_scene = json_get_int(root, "scene", 0)
  { accessors, buffer_views, meshes, nodes, scenes, materials, default_scene }
}
