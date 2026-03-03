///| Helper: push a u32 LE value into a byte array
fn push_u32_le(arr : Array[Byte], value : Int) -> Unit {
  arr.push((value & 0xFF).to_byte())
  arr.push(((value >> 8) & 0xFF).to_byte())
  arr.push(((value >> 16) & 0xFF).to_byte())
  arr.push(((value >> 24) & 0xFF).to_byte())
}

///| Helper: build a minimal .glb from JSON string and optional binary buffer
fn build_glb(json_str : String, bin : Bytes?) -> Bytes {
  let json_bytes : Array[Byte] = []
  for c in json_str {
    json_bytes.push(c.to_int().to_byte())
  }
  // Pad JSON to 4-byte alignment with spaces (0x20)
  while json_bytes.length() % 4 != 0 {
    json_bytes.push(b'\x20')
  }
  let json_len = json_bytes.length()
  // Calculate BIN chunk padded size
  let bin_padded_len = match bin {
    Some(b) =>
      if b.length() % 4 != 0 {
        b.length() + (4 - b.length() % 4)
      } else {
        b.length()
      }
    None => 0
  }
  let bin_chunk_size = match bin {
    Some(_) => 8 + bin_padded_len
    None => 0
  }
  let total = 12 + 8 + json_len + bin_chunk_size
  let result : Array[Byte] = []
  // Header
  push_u32_le(result, 0x46546C67) // magic "glTF"
  push_u32_le(result, 2) // version
  push_u32_le(result, total) // total length
  // JSON chunk header
  push_u32_le(result, json_len) // chunk length
  push_u32_le(result, 0x4E4F534A) // chunk type JSON
  // JSON chunk data
  for b in json_bytes {
    result.push(b)
  }
  // BIN chunk
  match bin {
    Some(b) => {
      push_u32_le(result, bin_padded_len) // chunk length (padded)
      push_u32_le(result, 0x004E4942) // chunk type BIN
      for i in 0..<b.length() {
        result.push(b[i])
      }
      // Pad BIN to 4-byte alignment with zeros
      for _ in 0..<(bin_padded_len - b.length()) {
        result.push(b'\x00')
      }
    }
    None => ()
  }
  Bytes::from_array(result[:])
}

///|
test "parse_glb round-trip with triangle" {
  let (json, buffers) = make_triangle_gltf(false, None)
  let glb = build_glb(json, Some(buffers[0]))
  let (parsed_json, parsed_buffers) = parse_glb(glb)
  let mesh = mesh_from_gltf(parsed_json, parsed_buffers)
  assert_eq(mesh.vertex_count(), 3)
  assert_eq(mesh.triangle_count(), 1)
}

///|
test "parse_glb round-trip with normals" {
  let (json, buffers) = make_triangle_gltf(true, None)
  let glb = build_glb(json, Some(buffers[0]))
  let (parsed_json, parsed_buffers) = parse_glb(glb)
  let mesh = mesh_from_gltf(parsed_json, parsed_buffers)
  assert_eq(mesh.vertex_count(), 3)
  let vd = mesh.vertex_data
  for i in 0..<3 {
    let nz = vd[i * 8 + 5]
    assert_true((nz - 1.0).abs() < 1.0e-5)
  }
}

///|
test "parse_glb with material" {
  let color = @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0)
  let (json, buffers) = make_triangle_gltf(false, Some(color))
  let glb = build_glb(json, Some(buffers[0]))
  let (parsed_json, parsed_buffers) = parse_glb(glb)
  let graph = scene_graph_from_gltf(parsed_json, parsed_buffers)
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
test "parse_glb rejects invalid magic" {
  let data = Bytes::make(12, b'\x00')
  let result = try {
    parse_glb(data)
  } catch {
    e => Err(e)
  } else {
    v => Ok(v)
  }
  assert_true(result is Err(_))
}

///|
test "parse_glb rejects too-short data" {
  let data = Bytes::make(4, b'\x00')
  let result = try {
    parse_glb(data)
  } catch {
    e => Err(e)
  } else {
    v => Ok(v)
  }
  assert_true(result is Err(_))
}

///|
test "parse_glb no BIN chunk" {
  let json = "{\"asset\":{\"version\":\"2.0\"}}"
  let glb = build_glb(json, None)
  let (parsed_json, parsed_buffers) = parse_glb(glb)
  assert_eq(parsed_buffers.length(), 0)
  let mesh = mesh_from_gltf(parsed_json, parsed_buffers)
  assert_eq(mesh.vertex_count(), 0)
}
