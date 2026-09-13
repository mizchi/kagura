///|
test "extract rigid joint preserves geometry, offsets indices and remaps ownership" {
  let source = @procedural3d.RigidGeometry::new()
  source.box(0.0, 1.0, 0.0, 0.5, 0.5, 0.5, 2)
  source.box(0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 1)
  let mesh = source.build_mesh()
  let skin = source.build_skin()
  let selected = @procedural3d.RigidGeometry::new()
  selected.append_joint(mesh, skin, 2, 5)
  assert_eq(selected.indices.length() * 2, mesh.indices.length())
  assert_eq(selected.vertices[1], mesh.vertex_data[1])
  for i in 0..<selected.build_skin().vertex_count {
    assert_eq(selected.joints[i * 4], 5)
    assert_eq(selected.weights[i * 4], 1.0)
  }
  let offset = selected.vertices.length() / 8
  let count = selected.indices.length()
  selected.append_joint(mesh, skin, 1, 8)
  assert_eq(selected.indices[count], offset)
  selected.vertices[0] = 100.0
  assert_true(mesh.vertex_data[0] != 100.0)
  assert_eq(skin.joint_indices[0], 2)
}

///|
test "extract rigid joint skips mixed triangles and absent joints" {
  let source = @procedural3d.RigidGeometry::new()
  source.triangle(
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_x(),
    @math3d.Vec3::unit_y(),
    2,
  )
  let skin = source.build_skin()
  skin.weights[0] = 0.5
  skin.weights[1] = 0.5
  skin.joint_indices[1] = 1
  let selected = @procedural3d.RigidGeometry::new()
  selected.append_joint(source.build_mesh(), skin, 2, 5)
  selected.append_joint(source.build_mesh(), source.build_skin(), 8, 5)
  assert_eq(selected.indices.length(), 0)
  assert_eq(selected.vertices.length(), 0)
}
