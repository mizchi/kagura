///|
fn approx_mesh(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-6
}

///|
test "make_wall_mesh assigns uv corners on front and top faces" {
  let mesh = make_wall_mesh(1.0, 0.4, 1.0)
  assert_eq(mesh.vertex_count(), 20)
  // Front face
  assert_true(approx_mesh(mesh.vertex_data[6], 0.0))
  assert_true(approx_mesh(mesh.vertex_data[7], 1.0))
  assert_true(approx_mesh(mesh.vertex_data[14], 1.0))
  assert_true(approx_mesh(mesh.vertex_data[15], 1.0))
  assert_true(approx_mesh(mesh.vertex_data[22], 1.0))
  assert_true(approx_mesh(mesh.vertex_data[23], 0.0))
  assert_true(approx_mesh(mesh.vertex_data[30], 0.0))
  assert_true(approx_mesh(mesh.vertex_data[31], 0.0))
  // Top face
  let top_base = 16 * 8
  assert_true(approx_mesh(mesh.vertex_data[top_base + 6], 0.0))
  assert_true(approx_mesh(mesh.vertex_data[top_base + 7], 1.0))
  assert_true(approx_mesh(mesh.vertex_data[top_base + 14], 1.0))
  assert_true(approx_mesh(mesh.vertex_data[top_base + 15], 1.0))
  assert_true(approx_mesh(mesh.vertex_data[top_base + 22], 1.0))
  assert_true(approx_mesh(mesh.vertex_data[top_base + 23], 0.0))
  assert_true(approx_mesh(mesh.vertex_data[top_base + 30], 0.0))
  assert_true(approx_mesh(mesh.vertex_data[top_base + 31], 0.0))
}

///|
test "make_pillar_mesh assigns varying uv coordinates" {
  let mesh = make_pillar_mesh(0.12, 0.8)
  let mut has_nonzero_uv = false
  for i in 0..<mesh.vertex_count() {
    let base = i * 8
    if mesh.vertex_data[base + 6] != 0.0 || mesh.vertex_data[base + 7] != 0.0 {
      has_nonzero_uv = true
      break
    }
  }
  assert_true(has_nonzero_uv)
}
