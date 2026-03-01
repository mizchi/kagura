///|
fn f32_to_bytes(v : Double) -> Array[Byte] {
  // Convert Double to IEEE 754 float32 LE bytes
  if v == 0.0 {
    return [b'\x00', b'\x00', b'\x00', b'\x00']
  }
  let mut val = v
  let mut sign_bit = 0
  if val < 0.0 {
    sign_bit = 1
    val = -val
  }
  let mut exp = 127
  if val >= 2.0 {
    while val >= 2.0 {
      val = val / 2.0
      exp = exp + 1
    }
  } else if val < 1.0 {
    while val < 1.0 && exp > 0 {
      val = val * 2.0
      exp = exp - 1
    }
  }
  let mantissa = ((val - 1.0) * 8388608.0 + 0.5).to_int()
  let bits = (sign_bit << 31) | (exp << 23) | (mantissa & 0x7FFFFF)
  let b0 : Byte = (bits & 0xFF).to_byte()
  let b1 : Byte = ((bits >> 8) & 0xFF).to_byte()
  let b2 : Byte = ((bits >> 16) & 0xFF).to_byte()
  let b3 : Byte = ((bits >> 24) & 0xFF).to_byte()
  [b0, b1, b2, b3]
}

///|
fn u16_to_bytes(v : Int) -> Array[Byte] {
  [(v & 0xFF).to_byte(), ((v >> 8) & 0xFF).to_byte()]
}

///|
fn make_triangle_buffer(has_normals : Bool) -> Bytes {
  let bytes : Array[Byte] = []
  // 3 positions: (0,0,0), (1,0,0), (0,1,0)
  for b in f32_to_bytes(0.0) {
    bytes.push(b)
  }
  for b in f32_to_bytes(0.0) {
    bytes.push(b)
  }
  for b in f32_to_bytes(0.0) {
    bytes.push(b)
  }
  for b in f32_to_bytes(1.0) {
    bytes.push(b)
  }
  for b in f32_to_bytes(0.0) {
    bytes.push(b)
  }
  for b in f32_to_bytes(0.0) {
    bytes.push(b)
  }
  for b in f32_to_bytes(0.0) {
    bytes.push(b)
  }
  for b in f32_to_bytes(1.0) {
    bytes.push(b)
  }
  for b in f32_to_bytes(0.0) {
    bytes.push(b)
  }
  if has_normals {
    // 3 normals: all (0,0,1)
    for _i in 0..<3 {
      for b in f32_to_bytes(0.0) {
        bytes.push(b)
      }
      for b in f32_to_bytes(0.0) {
        bytes.push(b)
      }
      for b in f32_to_bytes(1.0) {
        bytes.push(b)
      }
    }
  }
  // 3 indices: 0, 1, 2 as Uint16 LE
  for b in u16_to_bytes(0) {
    bytes.push(b)
  }
  for b in u16_to_bytes(1) {
    bytes.push(b)
  }
  for b in u16_to_bytes(2) {
    bytes.push(b)
  }
  Bytes::from_array(bytes[:])
}

///|
fn make_triangle_gltf(
  has_normals : Bool,
  material_color : @math3d.Vec4?,
) -> (String, Array[Bytes]) {
  let buf = make_triangle_buffer(has_normals)
  let idx_offset = if has_normals { 72 } else { 36 }
  let mut json = "{"
  json = json + "\"asset\":{\"version\":\"2.0\"},"
  json = json + "\"accessors\":["
  json = json +
    "{\"bufferView\":0,\"componentType\":5126,\"count\":3,\"type\":\"VEC3\"}"
  if has_normals {
    json = json +
      ",{\"bufferView\":1,\"componentType\":5126,\"count\":3,\"type\":\"VEC3\"}"
  }
  let idx_acc_bv = if has_normals { 2 } else { 1 }
  json = json +
    ",{\"bufferView\":" +
    idx_acc_bv.to_string() +
    ",\"componentType\":5123,\"count\":3,\"type\":\"SCALAR\"}"
  json = json + "],"
  json = json + "\"bufferViews\":["
  json = json + "{\"buffer\":0,\"byteOffset\":0,\"byteLength\":36}"
  if has_normals {
    json = json + ",{\"buffer\":0,\"byteOffset\":36,\"byteLength\":36}"
  }
  json = json +
    ",{\"buffer\":0,\"byteOffset\":" +
    idx_offset.to_string() +
    ",\"byteLength\":6}"
  json = json + "],"
  let idx_acc = if has_normals { 2 } else { 1 }
  let mut attrs = "\"POSITION\":0"
  if has_normals {
    attrs = attrs + ",\"NORMAL\":1"
  }
  let mat_str = match material_color {
    Some(_) => ",\"material\":0"
    None => ""
  }
  json = json +
    "\"meshes\":[{\"name\":\"tri\",\"primitives\":[{\"attributes\":{"
  json = json +
    attrs +
    "},\"indices\":" +
    idx_acc.to_string() +
    mat_str +
    "}]}],"
  match material_color {
    Some(c) => {
      json = json +
        "\"materials\":[{\"name\":\"mat0\",\"pbrMetallicRoughness\":{\"baseColorFactor\":["
      json = json +
        c.x.to_string() +
        "," +
        c.y.to_string() +
        "," +
        c.z.to_string() +
        "," +
        c.w.to_string() +
        "]}}],"
    }
    None => ()
  }
  json = json +
    "\"nodes\":[{\"mesh\":0}],\"scenes\":[{\"nodes\":[0]}],\"scene\":0,"
  json = json +
    "\"buffers\":[{\"byteLength\":" +
    buf.length().to_string() +
    "}]"
  json = json + "}"
  (json, [buf])
}

///|
test "from_gltf minimal triangle" {
  let (json, buffers) = make_triangle_gltf(false, None)
  let mesh = mesh_from_gltf(json, buffers)
  assert_eq(mesh.vertex_count(), 3)
  assert_eq(mesh.triangle_count(), 1)
  let vd = mesh.vertex_data
  assert_true((vd[0] - 0.0).abs() < 1.0e-5)
  assert_true((vd[1] - 0.0).abs() < 1.0e-5)
  assert_true((vd[2] - 0.0).abs() < 1.0e-5)
  assert_true((vd[8] - 1.0).abs() < 1.0e-5)
  assert_true((vd[17] - 1.0).abs() < 1.0e-5)
}

///|
test "from_gltf flat normals auto-computed" {
  let (json, buffers) = make_triangle_gltf(false, None)
  let mesh = mesh_from_gltf(json, buffers)
  let vd = mesh.vertex_data
  for i in 0..<3 {
    let nx = vd[i * 8 + 3]
    let ny = vd[i * 8 + 4]
    let nz = vd[i * 8 + 5]
    assert_true((nx - 0.0).abs() < 1.0e-5)
    assert_true((ny - 0.0).abs() < 1.0e-5)
    assert_true((nz - 1.0).abs() < 1.0e-5)
  }
}

///|
test "from_gltf with normals" {
  let (json, buffers) = make_triangle_gltf(true, None)
  let mesh = mesh_from_gltf(json, buffers)
  assert_eq(mesh.vertex_count(), 3)
  let vd = mesh.vertex_data
  for i in 0..<3 {
    let nz = vd[i * 8 + 5]
    assert_true((nz - 1.0).abs() < 1.0e-5)
  }
}

///|
test "from_gltf material color" {
  let color = @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0)
  let (json, buffers) = make_triangle_gltf(false, Some(color))
  let graph = scene_graph_from_gltf(json, buffers)
  match graph.get_node(0) {
    Some(node) =>
      match node.material {
        Some(mat) => {
          assert_true((mat.color.x - 1.0).abs() < 1.0e-5)
          assert_true((mat.color.y - 0.0).abs() < 1.0e-5)
        }
        None => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "meshes_from_gltf returns array" {
  let (json, buffers) = make_triangle_gltf(false, None)
  let meshes = meshes_from_gltf(json, buffers)
  assert_eq(meshes.length(), 1)
  assert_eq(meshes[0].vertex_count(), 3)
}

///|
test "from_gltf empty" {
  let json = "{\"asset\":{\"version\":\"2.0\"}}"
  let mesh = mesh_from_gltf(json, [])
  assert_eq(mesh.vertex_count(), 0)
  assert_eq(mesh.triangle_count(), 0)
}

///|
test "scene_graph with parent-child nodes" {
  let buf = make_triangle_buffer(false)
  let mut json = "{"
  json = json + "\"asset\":{\"version\":\"2.0\"},"
  json = json +
    "\"accessors\":[{\"bufferView\":0,\"componentType\":5126,\"count\":3,\"type\":\"VEC3\"},{\"bufferView\":1,\"componentType\":5123,\"count\":3,\"type\":\"SCALAR\"}],"
  json = json +
    "\"bufferViews\":[{\"buffer\":0,\"byteOffset\":0,\"byteLength\":36},{\"buffer\":0,\"byteOffset\":36,\"byteLength\":6}],"
  json = json +
    "\"meshes\":[{\"name\":\"tri\",\"primitives\":[{\"attributes\":{\"POSITION\":0},\"indices\":1}]}],"
  json = json +
    "\"nodes\":[{\"name\":\"parent\",\"children\":[1],\"translation\":[1.0,2.0,3.0]},{\"name\":\"child\",\"mesh\":0}],"
  json = json + "\"scenes\":[{\"nodes\":[0]}],\"scene\":0,"
  json = json +
    "\"buffers\":[{\"byteLength\":" +
    buf.length().to_string() +
    "}]"
  json = json + "}"
  let graph = scene_graph_from_gltf(json, [buf])
  match graph.get_node(0) {
    Some(parent) => {
      assert_eq(parent.children.length(), 1)
      assert_true(parent.mesh is None)
      assert_true((parent.transform.position.x - 1.0).abs() < 1.0e-5)
      assert_true((parent.transform.position.y - 2.0).abs() < 1.0e-5)
    }
    None => assert_true(false)
  }
  match graph.get_node(1) {
    Some(child) =>
      match child.mesh {
        Some(m) => assert_eq(m.vertex_count(), 3)
        None => assert_true(false)
      }
    None => assert_true(false)
  }
}
