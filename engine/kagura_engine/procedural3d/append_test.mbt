///|
test "composed geometry offsets indices and preserves skin ownership" {
  let target = @procedural3d.RigidGeometry::new()
  target.box(0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 2)
  let source = @procedural3d.RigidGeometry::new()
  source.box(2.0, 0.0, 0.0, 1.0, 1.0, 1.0, 7)
  let offset = target.vertices.length() / 8
  let old_indices = target.indices.length()
  target.append(source)
  assert_eq(target.indices[old_indices], source.indices[0] + offset)
  assert_eq(target.joints[offset * 4], 7)
  assert_eq(target.weights[offset * 4], 1.0)
  source.vertices[0] = 99.0
  assert_true(target.vertices[offset * 8] != 99.0)
  let count = target.vertices.length()
  target.append(target)
  assert_eq(target.vertices.length(), count * 2)
  assert_eq(
    target.build_skin().vertex_count,
    target.build_mesh().vertex_count(),
  )
}
