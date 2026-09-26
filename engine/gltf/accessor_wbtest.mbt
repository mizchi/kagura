///|
fn push_i16_le(bytes : Array[Byte], v : Int) -> Unit {
  bytes.push((v & 0xFF).to_byte())
  bytes.push(((v >> 8) & 0xFF).to_byte())
}

///|
/// One triangle in the layout gltfpack writes with KHR_mesh_quantization:
/// POSITION as non-normalized SHORT padded to 8 bytes, NORMAL as normalized
/// BYTE padded to 4 bytes, TEXCOORD_0 as normalized UNSIGNED_SHORT, and
/// UNSIGNED_BYTE indices.
fn make_quantized_triangle_gltf() -> (String, Array[Bytes]) {
  let bytes : Array[Byte] = []
  for p in [[0, 0, 0], [100, 0, 0], [0, -200, 0]] {
    for c in p {
      push_i16_le(bytes, c)
    }
    push_i16_le(bytes, 0)
  }
  // 24..36: normals. -128 must clamp to -1.0; 127 is exactly 1.0.
  for n in [[0, 0, 127], [0, 0, -128], [127, 0, 0]] {
    for c in n {
      bytes.push((c & 0xFF).to_byte())
    }
    bytes.push(b'\x00')
  }
  // 36..48: texcoords.
  for t in [[0, 0], [65535, 0], [0, 32768]] {
    for c in t {
      push_i16_le(bytes, c)
    }
  }
  // 48..51: indices.
  for i in [0, 1, 2] {
    bytes.push(i.to_byte())
  }
  let json =
    #|{"asset":{"version":"2.0"},"extensionsUsed":["KHR_mesh_quantization"],
    #|"accessors":[
    #|{"bufferView":0,"componentType":5122,"count":3,"type":"VEC3"},
    #|{"bufferView":1,"componentType":5120,"normalized":true,"count":3,"type":"VEC3"},
    #|{"bufferView":2,"componentType":5123,"normalized":true,"count":3,"type":"VEC2"},
    #|{"bufferView":3,"componentType":5121,"count":3,"type":"SCALAR"}],
    #|"bufferViews":[
    #|{"buffer":0,"byteOffset":0,"byteLength":24,"byteStride":8},
    #|{"buffer":0,"byteOffset":24,"byteLength":12,"byteStride":4},
    #|{"buffer":0,"byteOffset":36,"byteLength":12},
    #|{"buffer":0,"byteOffset":48,"byteLength":3}],
    #|"meshes":[{"primitives":[{"attributes":{"POSITION":0,"NORMAL":1,"TEXCOORD_0":2},"indices":3}]}],
    #|"nodes":[{"mesh":0}],"scenes":[{"nodes":[0]}],"scene":0}
  (json, [Bytes::from_array(bytes)])
}

///|
test "mesh_from_gltf reads quantized integer attributes" {
  let (json, buffers) = make_quantized_triangle_gltf()
  let mesh = mesh_from_gltf(json, buffers)
  assert_eq(mesh.vertex_count(), 3)
  assert_eq(mesh.triangle_count(), 1)
  let vd = mesh.vertex_data
  let s = @mesh3d.vertex3d_stride
  // Non-normalized integers are used as-is.
  assert_eq(vd[s], 100.0)
  assert_eq(vd[2 * s + 1], -200.0)
  // Normalized BYTE: 127 -> 1.0, -128 -> clamped to -1.0.
  assert_eq(vd[5], 1.0)
  assert_eq(vd[s + 5], -1.0)
  assert_eq(vd[2 * s + 3], 1.0)
  // Normalized UNSIGNED_SHORT.
  assert_eq(vd[s + 6], 1.0)
  assert_true((vd[2 * s + 7] - 32768.0 / 65535.0).abs() < 1.0e-12)
}

///|
test "read_accessor_floats rejects UNSIGNED_INT attributes" {
  let json =
    #|{"asset":{"version":"2.0"},
    #|"accessors":[{"bufferView":0,"componentType":5125,"count":1,"type":"VEC3"}],
    #|"bufferViews":[{"buffer":0,"byteOffset":0,"byteLength":12}],
    #|"meshes":[{"primitives":[{"attributes":{"POSITION":0}}]}]}
  let buffers = [Bytes::make(12, b'\x00')]
  try mesh_from_gltf(json, buffers) catch {
    UnsupportedComponentType(5125) => ()
    _ => fail("unexpected error")
  } noraise {
    _ => fail("UNSIGNED_INT attribute was accepted")
  }
}

///|
/// Two joints, a skinned triangle with normalized UNSIGNED_BYTE weights (as
/// gltfpack writes them even with -noq) and two MAT4 inverse bind matrices.
test "skinned_scene_from_gltf reads normalized weights and MAT4 matrices" {
  let bytes : Array[Byte] = []
  // 0..36: positions (float)
  for p in [[0.0, 0.0, 0.0], [1.0, 0.0, 0.0], [0.0, 1.0, 0.0]] {
    for c in p {
      for b in f32_to_bytes(c) {
        bytes.push(b)
      }
    }
  }
  // 36..48: joints (UNSIGNED_BYTE VEC4)
  for j in [[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 0, 0]] {
    for c in j {
      bytes.push(c.to_byte())
    }
  }
  // 48..60: weights (normalized UNSIGNED_BYTE VEC4). 128 + 127 = 255.
  for w in [[128, 127, 0, 0], [255, 0, 0, 0], [255, 0, 0, 0]] {
    for c in w {
      bytes.push(c.to_byte())
    }
  }
  // 60..188: inverse bind matrices, identity and translation(-2, 0, 0).
  for
    m in [
      [
        1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
        1.0,
      ],
      [
        1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -2.0, 0.0, 0.0,
        1.0,
      ],
    ] {
    for c in m {
      for b in f32_to_bytes(c) {
        bytes.push(b)
      }
    }
  }
  let json =
    #|{"asset":{"version":"2.0"},
    #|"accessors":[
    #|{"bufferView":0,"componentType":5126,"count":3,"type":"VEC3"},
    #|{"bufferView":1,"componentType":5121,"count":3,"type":"VEC4"},
    #|{"bufferView":2,"componentType":5121,"normalized":true,"count":3,"type":"VEC4"},
    #|{"bufferView":3,"componentType":5126,"count":2,"type":"MAT4"}],
    #|"bufferViews":[
    #|{"buffer":0,"byteOffset":0,"byteLength":36},
    #|{"buffer":0,"byteOffset":36,"byteLength":12},
    #|{"buffer":0,"byteOffset":48,"byteLength":12},
    #|{"buffer":0,"byteOffset":60,"byteLength":128}],
    #|"meshes":[{"primitives":[{"attributes":{"POSITION":0,"JOINTS_0":1,"WEIGHTS_0":2}}]}],
    #|"nodes":[{"children":[1]},{"translation":[2,0,0]},{"mesh":0,"skin":0}],
    #|"skins":[{"joints":[0,1],"inverseBindMatrices":3}],
    #|"scenes":[{"nodes":[0,2]}],"scene":0}
  let (_graph, skeleton, _clips, skin_data) = skinned_scene_from_gltf(json, [
    Bytes::from_array(bytes),
  ])
  guard skin_data is Some(skin) else { fail("expected skin data") }
  assert_eq(skin.vertex_count, 3)
  assert_eq(skin.joint_indices[0:4].to_array(), [0, 1, 0, 0])
  assert_true((skin.weights[0] - 128.0 / 255.0).abs() < 1.0e-12)
  assert_true((skin.weights[1] - 127.0 / 255.0).abs() < 1.0e-12)
  assert_true((skin.weights[0] + skin.weights[1] - 1.0).abs() < 1.0e-12)
  assert_eq(skin.weights[4], 1.0)
  guard skeleton is Some(skel) else { fail("expected skeleton") }
  assert_eq(skel.bone_count(), 2)
  assert_true(
    @math3d.Mat4::translation(-2.0, 0.0, 0.0).approx_eq(
      skel.inverse_bind_matrices[1],
      1.0e-6,
    ),
  )
}
