///|
test "BorderWidths::uniform creates equal sides" {
  let b = BorderWidths::uniform(2.0)
  assert_eq(b.top, 2.0)
  assert_eq(b.right, 2.0)
  assert_eq(b.bottom, 2.0)
  assert_eq(b.left, 2.0)
  assert_true(b.has_any())
}

///|
test "BorderWidths::zero has no border" {
  let b = BorderWidths::zero()
  assert_true(not(b.has_any()))
}

///|
test "border_vertices generates 4 trapezoids for uniform border" {
  let border = BorderWidths::uniform(5.0)
  let (vertices, indices) = border_vertices(
    10.0, 20.0, 100.0, 50.0, border, 640.0, 480.0,
  )
  assert_eq(vertices.length(), 64) // 4 sides × 4 verts × 4 floats
  assert_eq(indices.length(), 24) // 4 sides × 6 indices
}

///|
test "border_vertices skips sides with zero width" {
  let border = BorderWidths::{ top: 3.0, right: 0.0, bottom: 3.0, left: 0.0 }
  let (vertices, indices) = border_vertices(
    0.0, 0.0, 100.0, 100.0, border, 640.0, 480.0,
  )
  assert_eq(vertices.length(), 32)
  assert_eq(indices.length(), 12)
}

///|
test "border_vertices empty border produces no geometry" {
  let border = BorderWidths::zero()
  let (vertices, indices) = border_vertices(
    0.0, 0.0, 100.0, 100.0, border, 640.0, 480.0,
  )
  assert_eq(vertices.length(), 0)
  assert_eq(indices.length(), 0)
}

///|
test "filled_rect_vertices generates single quad in NDC" {
  let (vertices, indices) = filled_rect_vertices(
    0.0, 0.0, 640.0, 480.0, 640.0, 480.0,
  )
  assert_eq(vertices.length(), 16)
  assert_eq(indices.length(), 6)
  // Full screen: top-left = (-1, 1), bottom-right = (1, -1)
  assert_eq(vertices[0], -1.0)
  assert_eq(vertices[1], 1.0)
  assert_eq(vertices[8], 1.0)
  assert_eq(vertices[9], -1.0)
}

///|
test "filled_rect_vertices center pixel maps to NDC origin" {
  let (vertices, _) = filled_rect_vertices(
    320.0, 240.0, 0.0, 0.0, 640.0, 480.0,
  )
  assert_true((vertices[0] - 0.0).abs() < 1.0e-10)
  assert_true((vertices[1] - 0.0).abs() < 1.0e-10)
}
