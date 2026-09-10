///|
test "deployment ring is a flat annulus with source radii and upward winding" {
  let mesh = ring_mesh()
  assert_eq(mesh.indices.length(), 64 * 6)
  for i in 0..<(mesh.vertex_data.length() / 8) {
    let p = i * 8
    let x = mesh.vertex_data[p]
    let z = mesh.vertex_data[p + 2]
    let radius = (x * x + z * z).sqrt()
    assert_true((radius - 5.4).abs() < 1.0e-8 || (radius - 5.58).abs() < 1.0e-8)
    assert_eq(mesh.vertex_data[p + 1], 0.0)
    assert_eq(mesh.vertex_data[p + 4], 1.0)
  }
  for i in 0..<(mesh.indices.length() / 3) {
    let a = mesh.indices[i * 3] * 8
    let b = mesh.indices[i * 3 + 1] * 8
    let c = mesh.indices[i * 3 + 2] * 8
    let abx = mesh.vertex_data[b] - mesh.vertex_data[a]
    let abz = mesh.vertex_data[b + 2] - mesh.vertex_data[a + 2]
    let acx = mesh.vertex_data[c] - mesh.vertex_data[a]
    let acz = mesh.vertex_data[c + 2] - mesh.vertex_data[a + 2]
    assert_true(abz * acx - abx * acz > 0.0)
  }
}

///|
test "shadow camera matches the original directional light" {
  let c = shadow_config()
  assert_eq(c.near, 0.5)
  assert_eq(c.far, 180.0)
  assert_eq(c.bias, 0.0)
  assert_true(
    (c.distance - (35.0 * 35.0 + 65.0 * 65.0 + 25.0 * 25.0).sqrt()).abs() <
    1.0e-8,
  )
}
