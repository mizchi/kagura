///|
/// Apply CPU skinning to a bind-pose mesh using skin data and skinning matrices.
/// Returns a new mesh with transformed positions and normals.
pub fn apply_skin(
  bind_mesh : @mesh3d.Mesh3D,
  skin : SkinData,
  skinning_matrices : Array[@math3d.Mat4],
) -> @mesh3d.Mesh3D {
  let stride = @mesh3d.vertex3d_stride
  let vc = skin.vertex_count
  let new_data : Array[Double] = Array::make(bind_mesh.vertex_data.length(), 0.0)
  for v in 0..<vc {
    let base = v * stride
    let bx = bind_mesh.vertex_data[base]
    let by = bind_mesh.vertex_data[base + 1]
    let bz = bind_mesh.vertex_data[base + 2]
    let bnx = bind_mesh.vertex_data[base + 3]
    let bny = bind_mesh.vertex_data[base + 4]
    let bnz = bind_mesh.vertex_data[base + 5]
    let u = bind_mesh.vertex_data[base + 6]
    let bv = bind_mesh.vertex_data[base + 7]
    let ji_base = v * 4
    let mut px = 0.0
    let mut py = 0.0
    let mut pz = 0.0
    let mut nx = 0.0
    let mut ny = 0.0
    let mut nz = 0.0
    for j in 0..<4 {
      let w = skin.weights[ji_base + j]
      if w > 0.0 {
        let joint = skin.joint_indices[ji_base + j]
        let m = skinning_matrices[joint]
        // Transform position: m * vec4(pos, 1.0)
        px += w * (m.elements[0] * bx + m.elements[4] * by + m.elements[8] * bz + m.elements[12])
        py += w * (m.elements[1] * bx + m.elements[5] * by + m.elements[9] * bz + m.elements[13])
        pz += w * (m.elements[2] * bx + m.elements[6] * by + m.elements[10] * bz + m.elements[14])
        // Transform normal: upper 3x3 of m * normal (w=0)
        nx += w * (m.elements[0] * bnx + m.elements[4] * bny + m.elements[8] * bnz)
        ny += w * (m.elements[1] * bnx + m.elements[5] * bny + m.elements[9] * bnz)
        nz += w * (m.elements[2] * bnx + m.elements[6] * bny + m.elements[10] * bnz)
      }
    }
    // Normalize the normal
    let len = (nx * nx + ny * ny + nz * nz).sqrt()
    if len > 1.0e-10 {
      nx = nx / len
      ny = ny / len
      nz = nz / len
    }
    new_data[base] = px
    new_data[base + 1] = py
    new_data[base + 2] = pz
    new_data[base + 3] = nx
    new_data[base + 4] = ny
    new_data[base + 5] = nz
    new_data[base + 6] = u
    new_data[base + 7] = bv
  }
  // Copy indices
  let new_indices : Array[Int] = Array::make(bind_mesh.indices.length(), 0)
  for i in 0..<bind_mesh.indices.length() {
    new_indices[i] = bind_mesh.indices[i]
  }
  @mesh3d.Mesh3D::new(new_data, new_indices)
}
