///|
test "fullscreen_quad_vertex_data has 16 floats" {
  let data = fullscreen_quad_vertex_data()
  assert_eq(data.length(), 16)
}

///|
test "fullscreen_quad_indices has 6 indices" {
  let indices = fullscreen_quad_indices()
  assert_eq(indices.length(), 6)
}

///|
test "fullscreen_quad_vertex_data NDC range" {
  let data = fullscreen_quad_vertex_data()
  // Check all x,y coordinates are in [-1, 1] and u,v in [0, 1]
  for i = 0; i < 4; i = i + 1 {
    let x = data[i * 4]
    let y = data[i * 4 + 1]
    let u = data[i * 4 + 2]
    let v = data[i * 4 + 3]
    assert_true(x >= -1.0 && x <= 1.0)
    assert_true(y >= -1.0 && y <= 1.0)
    assert_true(u >= 0.0 && u <= 1.0)
    assert_true(v >= 0.0 && v <= 1.0)
  }
}
