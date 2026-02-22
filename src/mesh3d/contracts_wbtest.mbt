///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-6
}

///|
test "Mesh3D cube vertex count" {
  let mesh = Mesh3D::cube(1.0)
  assert_eq(mesh.vertex_count(), 24) // 6 faces * 4 vertices
  assert_eq(mesh.triangle_count(), 12) // 6 faces * 2 triangles
}

///|
test "Mesh3D cube stride" {
  let mesh = Mesh3D::cube(2.0)
  assert_eq(mesh.vertex_data.length(), 24 * vertex3d_stride)
  assert_eq(mesh.indices.length(), 36) // 12 triangles * 3
}

///|
test "Mesh3D cube normals" {
  let mesh = Mesh3D::cube(1.0)
  // First face (+Z): normal should be (0, 0, 1)
  let nx = mesh.vertex_data[3]
  let ny = mesh.vertex_data[4]
  let nz = mesh.vertex_data[5]
  assert_true(approx(nx, 0.0))
  assert_true(approx(ny, 0.0))
  assert_true(approx(nz, 1.0))
}

///|
test "Mesh3D plane" {
  let mesh = Mesh3D::plane(10.0, 5.0)
  assert_eq(mesh.vertex_count(), 4)
  assert_eq(mesh.triangle_count(), 2)
  // Normal should be (0, 1, 0) for all vertices
  for i in 0..<4 {
    let base = i * vertex3d_stride
    assert_true(approx(mesh.vertex_data[base + 3], 0.0))
    assert_true(approx(mesh.vertex_data[base + 4], 1.0))
    assert_true(approx(mesh.vertex_data[base + 5], 0.0))
  }
}

///|
test "Mesh3D sphere vertex count" {
  let mesh = Mesh3D::sphere(1.0, 8, 4)
  let expected_verts = (4 + 1) * (8 + 1)
  assert_eq(mesh.vertex_count(), expected_verts)
  let expected_tris = 4 * 8 * 2
  assert_eq(mesh.triangle_count(), expected_tris)
}

///|
test "Mesh3D sphere normals are unit length" {
  let mesh = Mesh3D::sphere(1.0, 4, 4)
  for i in 0..<mesh.vertex_count() {
    let base = i * vertex3d_stride
    let nx = mesh.vertex_data[base + 3]
    let ny = mesh.vertex_data[base + 4]
    let nz = mesh.vertex_data[base + 5]
    let len = (nx * nx + ny * ny + nz * nz).sqrt()
    assert_true(approx(len, 1.0))
  }
}

///|
test "Mesh3D sphere positions on surface" {
  let r = 2.0
  let mesh = Mesh3D::sphere(r, 6, 4)
  for i in 0..<mesh.vertex_count() {
    let base = i * vertex3d_stride
    let px = mesh.vertex_data[base]
    let py = mesh.vertex_data[base + 1]
    let pz = mesh.vertex_data[base + 2]
    let dist = (px * px + py * py + pz * pz).sqrt()
    assert_true(approx(dist, r))
  }
}
