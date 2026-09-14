///|
test "loft produces outward faces and consistent rigid skinning" {
  let g = @procedural3d.RigidGeometry::new()
  g.loft(0.0, 0.0, [], 6, 0)
  assert_eq(g.build_mesh().indices.length(), 0)
  g.loft(0.0, 0.0, [(0.0, 1.0, 1.0), (2.0, 0.5, 0.5)], 6, 3)
  let mesh = g.build_mesh()
  let skin = g.build_skin()
  assert_eq(mesh.indices.length(), 72)
  assert_eq(skin.vertex_count, 72)
  assert_eq(skin.joint_indices.length(), skin.vertex_count * 4)
  for i in 0..<skin.vertex_count {
    assert_eq(skin.joint_indices[i * 4], 3)
    assert_eq(skin.weights[i * 4], 1.0)
    let v = i * 8
    let nx = mesh.vertex_data[v + 3]
    let ny = mesh.vertex_data[v + 4]
    let nz = mesh.vertex_data[v + 5]
    assert_true((nx * nx + ny * ny + nz * nz - 1.0).abs() < 0.00001)
    let radial = mesh.vertex_data[v] * nx + mesh.vertex_data[v + 2] * nz
    assert_true(radial >= -0.00001)
  }
  // Completed meshes are snapshots: later edits cannot alter a submitted asset.
  g.box(3.0, 0.0, 0.0, 1.0, 1.0, 1.0, 5)
  assert_eq(mesh.indices.length(), 72)
  assert_eq(g.build_mesh().indices.length(), 108)
}

///|
test "box faces have outward winding and top bottom joint assignments" {
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  let joints : Array[Int] = []
  let weights : Array[Double] = []
  let count = Ref(0)
  @procedural3d.append_box_segment(
    vertices, indices, joints, weights, count, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 2,
    4,
  )
  assert_eq(count.val, 24)
  for i in 0..<24 {
    assert_eq(joints[i * 4], if vertices[i * 8 + 1] < 0.0 { 2 } else { 4 })
    let dot = vertices[i * 8] * vertices[i * 8 + 3] +
      vertices[i * 8 + 1] * vertices[i * 8 + 4] +
      vertices[i * 8 + 2] * vertices[i * 8 + 5]
    assert_true(dot > 0.0)
  }
}
