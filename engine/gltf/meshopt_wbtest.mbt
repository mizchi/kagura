///|
fn hex_to_bytes(s : String) -> Bytes {
  let chars = s.to_array()
  let digit = (c : Char) => {
    let v = c.to_int()
    if v >= 'a'.to_int() {
      v - 'a'.to_int() + 10
    } else {
      v - '0'.to_int()
    }
  }
  Bytes::makei(chars.length() / 2, i => {
    (digit(chars[2 * i]) * 16 + digit(chars[2 * i + 1])).to_byte()
  })
}

///|
/// One triangle written the way gltfpack -c writes meshes: every bufferView
/// points into an empty fallback buffer (index 1) and carries an
/// EXT_meshopt_compression range in the GLB's BIN chunk (index 0).
/// The streams were encoded by meshoptimizer 1.3: POSITION as SHORT (stride
/// 8), NORMAL as octahedral 8-bit (stride 4) and a TRIANGLES index stream.
fn make_meshopt_triangle(index_stream : String) -> (String, Array[Bytes]) {
  let position = "a1fbaa00c8c7000070000001000000000000000000000000000000000000000000000000"
  let normal = "a1af00fe9100fefd0000000000000000000000000000000000000000007f7f00"
  let bin = hex_to_bytes(position + normal + index_stream)
  let json =
    #|{"asset":{"version":"2.0"},
    #|"extensionsUsed":["KHR_mesh_quantization","EXT_meshopt_compression"],
    #|"extensionsRequired":["KHR_mesh_quantization","EXT_meshopt_compression"],
    #|"buffers":[{"byteLength":86},{"byteLength":42,"extensions":{"EXT_meshopt_compression":{"fallback":true}}}],
    #|"bufferViews":[
    #|{"buffer":1,"byteOffset":0,"byteLength":24,"byteStride":8,"extensions":{"EXT_meshopt_compression":{"buffer":0,"byteOffset":0,"byteLength":36,"byteStride":8,"count":3,"mode":"ATTRIBUTES"}}},
    #|{"buffer":1,"byteOffset":24,"byteLength":12,"byteStride":4,"extensions":{"EXT_meshopt_compression":{"buffer":0,"byteOffset":36,"byteLength":32,"byteStride":4,"count":3,"mode":"ATTRIBUTES","filter":"OCTAHEDRAL"}}},
    #|{"buffer":1,"byteOffset":36,"byteLength":6,"extensions":{"EXT_meshopt_compression":{"buffer":0,"byteOffset":68,"byteLength":18,"byteStride":2,"count":3,"mode":"TRIANGLES"}}}],
    #|"accessors":[
    #|{"bufferView":0,"componentType":5122,"count":3,"type":"VEC3"},
    #|{"bufferView":1,"componentType":5120,"normalized":true,"count":3,"type":"VEC3"},
    #|{"bufferView":2,"componentType":5123,"count":3,"type":"SCALAR"}],
    #|"meshes":[{"primitives":[{"attributes":{"POSITION":0,"NORMAL":1},"indices":2}]}],
    #|"nodes":[{"mesh":0}],"scenes":[{"nodes":[0]}],"scene":0}
  (json, [bin])
}

///|
test "mesh_from_gltf decodes EXT_meshopt_compression bufferViews" {
  let (json, buffers) = make_meshopt_triangle(
    "e1f0007687566778a9866589689801690000",
  )
  let mesh = mesh_from_gltf(json, buffers)
  assert_eq(mesh.vertex_count(), 3)
  assert_eq(mesh.indices, [0, 1, 2])
  let vd = mesh.vertex_data
  let s = @mesh3d.vertex3d_stride
  assert_eq([vd[0], vd[1], vd[2]], [0.0, 0.0, 0.0])
  assert_eq([vd[s], vd[s + 1], vd[s + 2]], [100.0, 0.0, 0.0])
  assert_eq([vd[2 * s], vd[2 * s + 1], vd[2 * s + 2]], [0.0, -200.0, 0.0])
  // Normals after the octahedral filter, as the C decoder produces them:
  // (0, 0, 127), (0, 0, -127), (76, 0, 102) as normalized BYTE.
  assert_eq([vd[3], vd[4], vd[5]], [0.0, 0.0, 1.0])
  assert_eq([vd[s + 3], vd[s + 4], vd[s + 5]], [0.0, 0.0, -1.0])
  assert_eq([vd[2 * s + 3], vd[2 * s + 4], vd[2 * s + 5]], [
    76.0 / 127.0,
    0.0,
    102.0 / 127.0,
  ])
  // The same file also loads as a scene graph.
  let graph = scene_graph_from_gltf(json, buffers)
  assert_eq(graph.roots.length(), 1)
}

///|
test "corrupted EXT_meshopt_compression data raises CompressionError" {
  // Index stream whose header claims codec version 2.
  let (json, buffers) = make_meshopt_triangle(
    "e2f0007687566778a9866589689801690000",
  )
  try mesh_from_gltf(json, buffers) catch {
    CompressionError(_) => ()
    _ => fail("unexpected error")
  } noraise {
    _ => fail("corrupted stream was accepted")
  }
}
