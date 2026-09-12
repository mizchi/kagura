// Append a box to existing Mesh3D/SkinData buffers. vertex_count must match
// the current number of vertices. Lower and upper halves may use different joints.

///|
pub fn append_box_segment(
  verts : Array[Double],
  indices : Array[Int],
  joint_indices : Array[Int],
  weights : Array[Double],
  vertex_count : Ref[Int],
  x0 : Double,
  y0 : Double,
  z0 : Double,
  x1 : Double,
  y1 : Double,
  z1 : Double,
  bone_bottom : Int,
  bone_top : Int,
) -> Unit {
  // 8 corners of box
  let corners : Array[(Double, Double, Double)] = [
    (x0, y0, z1),
    (x1, y0, z1),
    (x1, y1, z1),
    (x0, y1, z1), // front
    (x0, y0, z0),
    (x1, y0, z0),
    (x1, y1, z0),
    (x0, y1, z0), // back
  ]
  // 6 faces: front, back, right, left, top, bottom
  let faces : Array[(Int, Int, Int, Int, Double, Double, Double)] = [
    (0, 1, 2, 3, 0.0, 0.0, 1.0), // front
    (5, 4, 7, 6, 0.0, 0.0, -1.0), // back
    (1, 5, 6, 2, 1.0, 0.0, 0.0), // right
    (4, 0, 3, 7, -1.0, 0.0, 0.0), // left
    (3, 2, 6, 7, 0.0, 1.0, 0.0), // top
    (4, 5, 1, 0, 0.0, -1.0, 0.0), // bottom
  ]
  let y_mid = (y0 + y1) / 2.0
  for face in faces {
    let (i0, i1, i2, i3, nx, ny, nz) = face
    let base = vertex_count.val
    let face_corners = [corners[i0], corners[i1], corners[i2], corners[i3]]
    for ci in 0..<4 {
      let (px, py, pz) = face_corners[ci]
      verts.push(px)
      verts.push(py)
      verts.push(pz)
      verts.push(nx)
      verts.push(ny)
      verts.push(nz)
      verts.push(if ci == 0 || ci == 3 { 0.0 } else { 1.0 })
      verts.push(if ci < 2 { 0.0 } else { 1.0 })
      // Skinning: assign based on y position
      let bone = if py < y_mid { bone_bottom } else { bone_top }
      joint_indices.push(bone)
      joint_indices.push(0)
      joint_indices.push(0)
      joint_indices.push(0)
      weights.push(1.0)
      weights.push(0.0)
      weights.push(0.0)
      weights.push(0.0)
      vertex_count.val = vertex_count.val + 1
    }
    indices.push(base)
    indices.push(base + 1)
    indices.push(base + 2)
    indices.push(base)
    indices.push(base + 2)
    indices.push(base + 3)
  }
}
