///|
fn component_count(type_ : String) -> Int {
  match type_ {
    "SCALAR" => 1
    "VEC2" => 2
    "VEC3" => 3
    "VEC4" => 4
    _ => 1
  }
}

///|
fn read_accessor_floats(
  doc : GltfDocument,
  accessor_index : Int,
  buffers : Array[Bytes],
) -> Array[Double] raise GltfError {
  if accessor_index < 0 || accessor_index >= doc.accessors.length() {
    raise GltfError::InvalidAccessor(
      "index out of range: " + accessor_index.to_string(),
    )
  }
  let acc = doc.accessors[accessor_index]
  if acc.buffer_view < 0 || acc.buffer_view >= doc.buffer_views.length() {
    raise GltfError::InvalidBufferView(
      "index out of range: " + acc.buffer_view.to_string(),
    )
  }
  let bv = doc.buffer_views[acc.buffer_view]
  if bv.buffer < 0 || bv.buffer >= buffers.length() {
    raise GltfError::BufferOutOfRange(bv.buffer)
  }
  let buf = buffers[bv.buffer]
  let comp_count = component_count(acc.type_)
  let total = acc.count * comp_count
  let result : Array[Double] = Array::make(total, 0.0)
  let base_offset = bv.byte_offset + acc.byte_offset
  let default_stride = comp_count * 4
  let stride = if bv.byte_stride > 0 { bv.byte_stride } else { default_stride }
  match acc.component_type {
    5126 =>
      // FLOAT
      for i in 0..<acc.count {
        let elem_offset = base_offset + i * stride
        for j in 0..<comp_count {
          result[i * comp_count + j] = read_f32_le(buf, elem_offset + j * 4)
        }
      }
    _ => raise GltfError::UnsupportedComponentType(acc.component_type)
  }
  result
}

///|
fn read_accessor_indices(
  doc : GltfDocument,
  accessor_index : Int,
  buffers : Array[Bytes],
) -> Array[Int] raise GltfError {
  if accessor_index < 0 || accessor_index >= doc.accessors.length() {
    raise GltfError::InvalidAccessor(
      "index out of range: " + accessor_index.to_string(),
    )
  }
  let acc = doc.accessors[accessor_index]
  if acc.buffer_view < 0 || acc.buffer_view >= doc.buffer_views.length() {
    raise GltfError::InvalidBufferView(
      "index out of range: " + acc.buffer_view.to_string(),
    )
  }
  let bv = doc.buffer_views[acc.buffer_view]
  if bv.buffer < 0 || bv.buffer >= buffers.length() {
    raise GltfError::BufferOutOfRange(bv.buffer)
  }
  let buf = buffers[bv.buffer]
  let result : Array[Int] = Array::make(acc.count, 0)
  let base_offset = bv.byte_offset + acc.byte_offset
  match acc.component_type {
    5123 => {
      // UNSIGNED_SHORT
      let stride = if bv.byte_stride > 0 { bv.byte_stride } else { 2 }
      for i in 0..<acc.count {
        result[i] = read_u16_le(buf, base_offset + i * stride)
      }
    }
    5125 => {
      // UNSIGNED_INT
      let stride = if bv.byte_stride > 0 { bv.byte_stride } else { 4 }
      for i in 0..<acc.count {
        result[i] = read_u32_le(buf, base_offset + i * stride)
      }
    }
    5121 => {
      // UNSIGNED_BYTE
      let stride = if bv.byte_stride > 0 { bv.byte_stride } else { 1 }
      for i in 0..<acc.count {
        result[i] = buf[base_offset + i * stride].to_int()
      }
    }
    _ => raise GltfError::UnsupportedComponentType(acc.component_type)
  }
  result
}

///|
fn build_mesh_from_primitive(
  doc : GltfDocument,
  prim : GltfPrimitive,
  buffers : Array[Bytes],
) -> @mesh3d.Mesh3D raise GltfError {
  if prim.mode != 4 {
    raise GltfError::UnsupportedMode(prim.mode)
  }
  let pos_idx = match prim.attributes.get("POSITION") {
    Some(i) => i
    None => raise GltfError::MissingAttribute("POSITION")
  }
  let positions = read_accessor_floats(doc, pos_idx, buffers)
  let has_normals = prim.attributes.contains("NORMAL")
  let normals = if has_normals {
    match prim.attributes.get("NORMAL") {
      Some(i) => read_accessor_floats(doc, i, buffers)
      None => []
    }
  } else {
    []
  }
  let has_texcoords = prim.attributes.contains("TEXCOORD_0")
  let texcoords = if has_texcoords {
    match prim.attributes.get("TEXCOORD_0") {
      Some(i) => read_accessor_floats(doc, i, buffers)
      None => []
    }
  } else {
    []
  }
  let vertex_count = positions.length() / 3
  let vertex_data : Array[Double] = []
  for i in 0..<vertex_count {
    let px = positions[i * 3]
    let py = positions[i * 3 + 1]
    let pz = positions[i * 3 + 2]
    let nx = if has_normals && i * 3 + 2 < normals.length() {
      normals[i * 3]
    } else {
      0.0
    }
    let ny = if has_normals && i * 3 + 2 < normals.length() {
      normals[i * 3 + 1]
    } else {
      0.0
    }
    let nz = if has_normals && i * 3 + 2 < normals.length() {
      normals[i * 3 + 2]
    } else {
      0.0
    }
    let u = if has_texcoords && i * 2 + 1 < texcoords.length() {
      texcoords[i * 2]
    } else {
      0.0
    }
    let v = if has_texcoords && i * 2 + 1 < texcoords.length() {
      texcoords[i * 2 + 1]
    } else {
      0.0
    }
    vertex_data.push(px)
    vertex_data.push(py)
    vertex_data.push(pz)
    vertex_data.push(nx)
    vertex_data.push(ny)
    vertex_data.push(nz)
    vertex_data.push(u)
    vertex_data.push(v)
  }
  let indices : Array[Int] = match prim.indices {
    Some(idx) => read_accessor_indices(doc, idx, buffers)
    None => {
      let arr : Array[Int] = []
      for i in 0..<vertex_count {
        arr.push(i)
      }
      arr
    }
  }
  if !has_normals {
    compute_flat_normals(vertex_data, indices)
  }
  @mesh3d.Mesh3D::new(vertex_data, indices)
}

///|
fn compute_flat_normals(
  vertex_data : Array[Double],
  indices : Array[Int],
) -> Unit {
  let tri_count = indices.length() / 3
  for t in 0..<tri_count {
    let i0 = indices[t * 3]
    let i1 = indices[t * 3 + 1]
    let i2 = indices[t * 3 + 2]
    let p0x = vertex_data[i0 * 8]
    let p0y = vertex_data[i0 * 8 + 1]
    let p0z = vertex_data[i0 * 8 + 2]
    let p1x = vertex_data[i1 * 8]
    let p1y = vertex_data[i1 * 8 + 1]
    let p1z = vertex_data[i1 * 8 + 2]
    let p2x = vertex_data[i2 * 8]
    let p2y = vertex_data[i2 * 8 + 1]
    let p2z = vertex_data[i2 * 8 + 2]
    let e1x = p1x - p0x
    let e1y = p1y - p0y
    let e1z = p1z - p0z
    let e2x = p2x - p0x
    let e2y = p2y - p0y
    let e2z = p2z - p0z
    let mut nx = e1y * e2z - e1z * e2y
    let mut ny = e1z * e2x - e1x * e2z
    let mut nz = e1x * e2y - e1y * e2x
    let mag = (nx * nx + ny * ny + nz * nz).sqrt()
    if mag > 1.0e-10 {
      nx = nx / mag
      ny = ny / mag
      nz = nz / mag
    }
    for vi in 0..<3 {
      let idx = indices[t * 3 + vi]
      vertex_data[idx * 8 + 3] = nx
      vertex_data[idx * 8 + 4] = ny
      vertex_data[idx * 8 + 5] = nz
    }
  }
}

///|
fn build_mesh(
  doc : GltfDocument,
  mesh_index : Int,
  buffers : Array[Bytes],
) -> @mesh3d.Mesh3D raise GltfError {
  let mesh = doc.meshes[mesh_index]
  if mesh.primitives.length() == 1 {
    return build_mesh_from_primitive(doc, mesh.primitives[0], buffers)
  }
  let all_vertex_data : Array[Double] = []
  let all_indices : Array[Int] = []
  for prim in mesh.primitives {
    let m = build_mesh_from_primitive(doc, prim, buffers)
    let base = all_vertex_data.length() / 8
    for v in m.vertex_data {
      all_vertex_data.push(v)
    }
    for idx in m.indices {
      all_indices.push(idx + base)
    }
  }
  @mesh3d.Mesh3D::new(all_vertex_data, all_indices)
}
