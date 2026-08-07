///|
priv struct ExportBufferSlice {
  offset : Int
  length : Int
}

///|
priv struct ExportMeshPayload {
  position_view : ExportBufferSlice
  normal_view : ExportBufferSlice
  uv_view : ExportBufferSlice
  index_view : ExportBufferSlice
  vertex_count : Int
  index_count : Int
  position_min : @math3d.Vec3
  position_max : @math3d.Vec3
}

///|
pub(all) struct ExportSceneNode {
  name : String
  mesh : @mesh3d.Mesh3D
  translation : @math3d.Vec3
  scale : @math3d.Vec3
  color : @math3d.Vec4
  source_id : String
  node_kind : String
  primitive_kind : String?
  stamp_count : Int?
}

///|
pub fn document_export_filename(doc : ModelDocument) -> String {
  let buf = StringBuilder::new()
  for ch in doc.name {
    if ch.is_ascii_alphabetic() || ch.is_ascii_digit() || ch == '_' || ch == '-' {
      buf.write_char(ch)
    } else if ch == ' ' {
      buf.write_char('-')
    } else {
      buf.write_char('_')
    }
  }
  let base = buf.to_string()
  if base.is_empty() {
    "model.glb"
  } else {
    base + ".glb"
  }
}

///|
pub fn export_scene_nodes(doc : ModelDocument) -> Array[ExportSceneNode] {
  let nodes : Array[ExportSceneNode] = []
  for primitive in doc.primitives {
    let mesh = primitive_mesh(primitive.kind)
    if mesh.triangle_count() <= 0 {
      continue
    }
    nodes.push({
      name: primitive.id,
      mesh,
      translation: primitive.position,
      scale: primitive.scale,
      color: hex_to_vec4(primitive.color_hex),
      source_id: primitive.id,
      node_kind: "primitive",
      primitive_kind: Some(primitive_kind_name(primitive.kind)),
      stamp_count: None,
    })
  }
  for layer in doc.sculpt_layers {
    let mesh = sculpt_layer_baked_mesh(layer)
    if mesh.triangle_count() <= 0 {
      continue
    }
    nodes.push({
      name: layer.id,
      mesh,
      translation: @math3d.Vec3::zero(),
      scale: @math3d.Vec3::one(),
      color: hex_to_vec4(layer.color_hex),
      source_id: layer.id,
      node_kind: "sculpt_layer",
      primitive_kind: None,
      stamp_count: Some(layer.stamps.length()),
    })
  }
  nodes
}

///|
fn push_u32_le(arr : Array[Byte], value : Int) -> Unit {
  arr.push((value & 0xFF).to_byte())
  arr.push(((value >> 8) & 0xFF).to_byte())
  arr.push(((value >> 16) & 0xFF).to_byte())
  arr.push(((value >> 24) & 0xFF).to_byte())
}

///|
fn f32_to_bytes(v : Double) -> Array[Byte] {
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
  [
    (bits & 0xFF).to_byte(),
    ((bits >> 8) & 0xFF).to_byte(),
    ((bits >> 16) & 0xFF).to_byte(),
    ((bits >> 24) & 0xFF).to_byte(),
  ]
}

///|
fn pad_bytes_to_alignment(
  bytes : Array[Byte],
  alignment : Int,
  fill : Byte,
) -> Unit {
  while bytes.length() % alignment != 0 {
    bytes.push(fill)
  }
}

///|
fn append_slice_bytes(
  bin : Array[Byte],
  values : Array[Byte],
  alignment : Int,
) -> ExportBufferSlice {
  pad_bytes_to_alignment(bin, alignment, b'\x00')
  let offset = bin.length()
  for value in values {
    bin.push(value)
  }
  { offset, length: values.length() }
}

///|
fn mesh_position_bounds(mesh : @mesh3d.Mesh3D) -> (@math3d.Vec3, @math3d.Vec3) {
  let data = mesh.vertex_data
  let mut min = @math3d.Vec3::new(data[0], data[1], data[2])
  let mut max = min
  let vertex_count = mesh.vertex_count()
  for i in 1..<vertex_count {
    let base = i * 8
    let px = data[base]
    let py = data[base + 1]
    let pz = data[base + 2]
    min = @math3d.Vec3::new(
      if px < min.x {
        px
      } else {
        min.x
      },
      if py < min.y {
        py
      } else {
        min.y
      },
      if pz < min.z {
        pz
      } else {
        min.z
      },
    )
    max = @math3d.Vec3::new(
      if px > max.x {
        px
      } else {
        max.x
      },
      if py > max.y {
        py
      } else {
        max.y
      },
      if pz > max.z {
        pz
      } else {
        max.z
      },
    )
  }
  (min, max)
}

///|
fn pack_mesh_payload(
  mesh : @mesh3d.Mesh3D,
  bin : Array[Byte],
) -> ExportMeshPayload {
  let positions : Array[Byte] = []
  let normals : Array[Byte] = []
  let uvs : Array[Byte] = []
  let indices : Array[Byte] = []
  let vertex_count = mesh.vertex_count()
  for i in 0..<vertex_count {
    let base = i * 8
    for
      value in [
        mesh.vertex_data[base],
        mesh.vertex_data[base + 1],
        mesh.vertex_data[base + 2],
      ] {
      for byte in f32_to_bytes(value) {
        positions.push(byte)
      }
    }
    for
      value in [
        mesh.vertex_data[base + 3],
        mesh.vertex_data[base + 4],
        mesh.vertex_data[base + 5],
      ] {
      for byte in f32_to_bytes(value) {
        normals.push(byte)
      }
    }
    for value in [mesh.vertex_data[base + 6], mesh.vertex_data[base + 7]] {
      for byte in f32_to_bytes(value) {
        uvs.push(byte)
      }
    }
  }
  for index in mesh.indices {
    push_u32_le(indices, index)
  }
  let (position_min, position_max) = mesh_position_bounds(mesh)
  {
    position_view: append_slice_bytes(bin, positions, 4),
    normal_view: append_slice_bytes(bin, normals, 4),
    uv_view: append_slice_bytes(bin, uvs, 4),
    index_view: append_slice_bytes(bin, indices, 4),
    vertex_count,
    index_count: mesh.indices.length(),
    position_min,
    position_max,
  }
}

///|
fn append_vec3_json(buf : StringBuilder, value : @math3d.Vec3) -> Unit {
  buf.write_string("[")
  buf.write_string(value.x.to_string())
  buf.write_string(",")
  buf.write_string(value.y.to_string())
  buf.write_string(",")
  buf.write_string(value.z.to_string())
  buf.write_string("]")
}

///|
fn append_vec4_json(buf : StringBuilder, value : @math3d.Vec4) -> Unit {
  buf.write_string("[")
  buf.write_string(value.x.to_string())
  buf.write_string(",")
  buf.write_string(value.y.to_string())
  buf.write_string(",")
  buf.write_string(value.z.to_string())
  buf.write_string(",")
  buf.write_string(value.w.to_string())
  buf.write_string("]")
}

///|
fn append_buffer_view_json(
  buf : StringBuilder,
  slice : ExportBufferSlice,
  target : Int,
) -> Unit {
  buf.write_string("{\"buffer\":0,\"byteOffset\":")
  buf.write_string(slice.offset.to_string())
  buf.write_string(",\"byteLength\":")
  buf.write_string(slice.length.to_string())
  buf.write_string(",\"target\":")
  buf.write_string(target.to_string())
  buf.write_string("}")
}

///|
fn append_document_extras_json(
  buf : StringBuilder,
  doc_name : String,
  node_count : Int,
) -> Unit {
  buf.write_string("\"extras\":{\"kagura_document_name\":\"")
  buf.write_string(json_escape(doc_name))
  buf.write_string("\",\"kagura_export_node_count\":")
  buf.write_string(node_count.to_string())
  buf.write_string("},")
}

///|
fn append_export_node_extras_json(
  buf : StringBuilder,
  node : ExportSceneNode,
) -> Unit {
  buf.write_string("\"extras\":{\"kagura_source_id\":\"")
  buf.write_string(json_escape(node.source_id))
  buf.write_string("\",\"kagura_node_kind\":\"")
  buf.write_string(json_escape(node.node_kind))
  buf.write_string("\"")
  match node.primitive_kind {
    Some(kind) => {
      buf.write_string(",\"kagura_primitive_kind\":\"")
      buf.write_string(json_escape(kind))
      buf.write_string("\"")
    }
    None => ()
  }
  match node.stamp_count {
    Some(count) => {
      buf.write_string(",\"kagura_stamp_count\":")
      buf.write_string(count.to_string())
    }
    None => ()
  }
  buf.write_string(",\"kagura_color_hex\":\"")
  buf.write_string(
    hex6(
      ((node.color.x * 255.0).to_int() << 16) |
      ((node.color.y * 255.0).to_int() << 8) |
      (node.color.z * 255.0).to_int(),
    ),
  )
  buf.write_string("\"}")
}

///|
fn append_glb_json(
  buf : StringBuilder,
  doc : ModelDocument,
  nodes : Array[ExportSceneNode],
  payloads : Array[ExportMeshPayload],
  bin_len : Int,
) -> Unit {
  buf.write_string("{")
  buf.write_string(
    "\"asset\":{\"version\":\"2.0\",\"generator\":\"kagura-model-authoring\"},",
  )
  append_document_extras_json(buf, doc.name, nodes.length())
  buf.write_string("\"buffers\":[{\"byteLength\":")
  buf.write_string(bin_len.to_string())
  buf.write_string("}],")
  buf.write_string("\"bufferViews\":[")
  for i in 0..<payloads.length() {
    let payload = payloads[i]
    if i > 0 {
      buf.write_string(",")
    }
    append_buffer_view_json(buf, payload.position_view, 34962)
    buf.write_string(",")
    append_buffer_view_json(buf, payload.normal_view, 34962)
    buf.write_string(",")
    append_buffer_view_json(buf, payload.uv_view, 34962)
    buf.write_string(",")
    append_buffer_view_json(buf, payload.index_view, 34963)
  }
  buf.write_string("],")
  buf.write_string("\"accessors\":[")
  for i in 0..<payloads.length() {
    let payload = payloads[i]
    if i > 0 {
      buf.write_string(",")
    }
    let position_view_index = i * 4
    let normal_view_index = i * 4 + 1
    let uv_view_index = i * 4 + 2
    let index_view_index = i * 4 + 3
    buf.write_string("{\"bufferView\":")
    buf.write_string(position_view_index.to_string())
    buf.write_string(",\"componentType\":5126,\"count\":")
    buf.write_string(payload.vertex_count.to_string())
    buf.write_string(",\"type\":\"VEC3\",\"min\":")
    append_vec3_json(buf, payload.position_min)
    buf.write_string(",\"max\":")
    append_vec3_json(buf, payload.position_max)
    buf.write_string("},")
    buf.write_string("{\"bufferView\":")
    buf.write_string(normal_view_index.to_string())
    buf.write_string(",\"componentType\":5126,\"count\":")
    buf.write_string(payload.vertex_count.to_string())
    buf.write_string(",\"type\":\"VEC3\"},")
    buf.write_string("{\"bufferView\":")
    buf.write_string(uv_view_index.to_string())
    buf.write_string(",\"componentType\":5126,\"count\":")
    buf.write_string(payload.vertex_count.to_string())
    buf.write_string(",\"type\":\"VEC2\"},")
    buf.write_string("{\"bufferView\":")
    buf.write_string(index_view_index.to_string())
    buf.write_string(",\"componentType\":5125,\"count\":")
    buf.write_string(payload.index_count.to_string())
    buf.write_string(",\"type\":\"SCALAR\"}")
  }
  buf.write_string("],")
  buf.write_string("\"materials\":[")
  for i in 0..<nodes.length() {
    let node = nodes[i]
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string("{\"name\":\"")
    buf.write_string(json_escape(node.name + "_mat"))
    buf.write_string("\",\"pbrMetallicRoughness\":{\"baseColorFactor\":")
    append_vec4_json(buf, node.color)
    buf.write_string(
      ",\"metallicFactor\":0.0,\"roughnessFactor\":0.85},\"doubleSided\":true,",
    )
    append_export_node_extras_json(buf, node)
    buf.write_string("}")
  }
  buf.write_string("],")
  buf.write_string("\"meshes\":[")
  for i in 0..<nodes.length() {
    let node = nodes[i]
    if i > 0 {
      buf.write_string(",")
    }
    let position_accessor = i * 4
    let normal_accessor = i * 4 + 1
    let uv_accessor = i * 4 + 2
    let index_accessor = i * 4 + 3
    buf.write_string("{\"name\":\"")
    buf.write_string(json_escape(node.name))
    buf.write_string("\",\"primitives\":[{\"attributes\":{\"POSITION\":")
    buf.write_string(position_accessor.to_string())
    buf.write_string(",\"NORMAL\":")
    buf.write_string(normal_accessor.to_string())
    buf.write_string(",\"TEXCOORD_0\":")
    buf.write_string(uv_accessor.to_string())
    buf.write_string("},\"indices\":")
    buf.write_string(index_accessor.to_string())
    buf.write_string(",\"material\":")
    buf.write_string(i.to_string())
    buf.write_string(",\"mode\":4}],")
    append_export_node_extras_json(buf, node)
    buf.write_string("}")
  }
  buf.write_string("],")
  buf.write_string("\"nodes\":[")
  for i in 0..<nodes.length() {
    let node = nodes[i]
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string("{\"name\":\"")
    buf.write_string(json_escape(node.name))
    buf.write_string("\",\"mesh\":")
    buf.write_string(i.to_string())
    buf.write_string(",\"translation\":")
    append_vec3_json(buf, node.translation)
    buf.write_string(",\"scale\":")
    append_vec3_json(buf, node.scale)
    buf.write_string(",")
    append_export_node_extras_json(buf, node)
    buf.write_string("}")
  }
  buf.write_string("],")
  buf.write_string("\"scenes\":[{\"nodes\":[")
  for i in 0..<nodes.length() {
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string(i.to_string())
  }
  buf.write_string("]}],\"scene\":0}")
}

///|
fn build_glb(json_str : String, bin : Bytes?) -> Bytes {
  let json_bytes : Array[Byte] = []
  for c in json_str {
    json_bytes.push(c.to_int().to_byte())
  }
  pad_bytes_to_alignment(json_bytes, 4, b'\x20')
  let json_len = json_bytes.length()
  let bin_padded_len = match bin {
    Some(data) =>
      if data.length() % 4 == 0 {
        data.length()
      } else {
        data.length() + (4 - data.length() % 4)
      }
    None => 0
  }
  let bin_chunk_size = match bin {
    Some(_) => 8 + bin_padded_len
    None => 0
  }
  let total_len = 12 + 8 + json_len + bin_chunk_size
  let result : Array[Byte] = []
  push_u32_le(result, 0x46546C67)
  push_u32_le(result, 2)
  push_u32_le(result, total_len)
  push_u32_le(result, json_len)
  push_u32_le(result, 0x4E4F534A)
  for byte in json_bytes {
    result.push(byte)
  }
  match bin {
    Some(data) => {
      push_u32_le(result, bin_padded_len)
      push_u32_le(result, 0x004E4942)
      for i in 0..<data.length() {
        result.push(data[i])
      }
      for _ in 0..<(bin_padded_len - data.length()) {
        result.push(b'\x00')
      }
    }
    None => ()
  }
  Bytes::from_array(result[:])
}

///|
pub fn document_glb_bytes(doc : ModelDocument) -> Bytes {
  let nodes = export_scene_nodes(doc)
  let bin : Array[Byte] = []
  let payloads : Array[ExportMeshPayload] = []
  for node in nodes {
    payloads.push(pack_mesh_payload(node.mesh, bin))
  }
  let json_buf = StringBuilder::new()
  append_glb_json(json_buf, doc, nodes, payloads, bin.length())
  let bin_bytes = if bin.is_empty() {
    None
  } else {
    Some(Bytes::from_array(bin[:]))
  }
  build_glb(json_buf.to_string(), bin_bytes)
}
