///|
test "svg_path_to_vector_path simple line" {
  let path = svg_path_to_vector_path("M 0 0 L 10 0 L 10 10 Z")
  assert_eq(path.command_count(), 4) // MoveTo, LineTo, LineTo, Close
  let points = path.flatten(1.0)
  assert_eq(points.length(), 4) // 3 points + close back to start
}

///|
test "svg_path_to_vector_path relative commands" {
  let path = svg_path_to_vector_path("M 10 10 l 20 0 l 0 20 z")
  let points = path.flatten(1.0)
  assert_eq(points.length(), 4)
  // First point at (10, 10)
  assert_eq(points[0].x, 10.0)
  assert_eq(points[0].y, 10.0)
  // Second point at (30, 10) (10 + 20)
  assert_eq(points[1].x, 30.0)
  assert_eq(points[1].y, 10.0)
  // Third point at (30, 30) (30 + 0, 10 + 20)
  assert_eq(points[2].x, 30.0)
  assert_eq(points[2].y, 30.0)
}

///|
test "svg_path_to_vector_path with curves" {
  let path = svg_path_to_vector_path("M 0 0 C 10 30 30 30 40 0")
  let points = path.flatten(1.0)
  // Cubic curve should produce multiple points
  assert_true(points.length() > 2)
  // First point
  assert_eq(points[0].x, 0.0)
  assert_eq(points[0].y, 0.0)
}

///|
test "svg_path_to_vector_path H and V commands" {
  let path = svg_path_to_vector_path("M 0 0 H 50 V 30")
  let points = path.flatten(1.0)
  assert_eq(points.length(), 3)
  assert_eq(points[1].x, 50.0)
  assert_eq(points[1].y, 0.0)
  assert_eq(points[2].x, 50.0)
  assert_eq(points[2].y, 30.0)
}

///|
test "svg_path_to_stroke_vertices" {
  let (vertices, indices) = svg_path_to_stroke_vertices(
    "M 0 0 L 10 0 L 10 10", 2.0, 1.0,
  )
  // 3 points -> 2 segments -> 8 verts (32 doubles), 12 indices
  assert_eq(vertices.length(), 32)
  assert_eq(indices.length(), 12)
}

///|
test "svg_path_to_fill_vertices triangle" {
  let (vertices, indices) = svg_path_to_fill_vertices(
    "M 0 0 L 10 0 L 5 10 Z", 1.0,
  )
  // 4 points (triangle + close) -> fan triangulation
  // 4 vertices * 4 components = 16
  assert_eq(vertices.length(), 16)
  // 2 triangles (from 4 points) = 6 indices
  assert_eq(indices.length(), 6)
}

///|
test "render_svg simple circle" {
  let svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"32\" height=\"32\"><circle cx=\"16\" cy=\"16\" r=\"10\" fill=\"red\"/></svg>"
  match render_svg(svg, 32, 32) {
    Some(result) => {
      assert_eq(result.width, 32)
      assert_eq(result.height, 32)
      // 32*32 pixels * 4 channels = 4096
      assert_eq(result.pixels.length(), 4096)
      // Center pixel should be red (or near red)
      let center_idx = (16 * 32 + 16) * 4
      assert_true(result.pixels[center_idx] > 200) // R > 200
    }
    None => fail("expected SVG render result")
  }
}

///|
test "render_svg invalid returns None" {
  let result = render_svg("not valid svg", 32, 32)
  match result {
    None => ()
    Some(_) => fail("expected None for invalid SVG")
  }
}

///|
test "svg_path_to_vector_path empty path returns empty" {
  let path = svg_path_to_vector_path("")
  let points = path.flatten(1.0)
  assert_eq(points.length(), 0)
}

///|
test "render_svg_to_rgba returns pixel tuple" {
  let svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"4\" height=\"4\"><rect width=\"4\" height=\"4\" fill=\"blue\"/></svg>"
  match render_svg_to_rgba(svg, 4, 4) {
    Some((w, h, pixels)) => {
      assert_eq(w, 4)
      assert_eq(h, 4)
      // 4*4*4 = 64 bytes
      assert_eq(pixels.length(), 64)
    }
    None => fail("expected render result")
  }
}

///|
test "svg_path_to_stroke_vertices closed path" {
  let (vertices, indices) = svg_path_to_stroke_vertices(
    "M 0 0 L 10 0 L 10 10 Z", 1.0, 1.0,
  )
  assert_true(vertices.length() > 0)
  assert_true(indices.length() > 0)
}

///|
test "svg_path_to_vector_path smooth cubic (S command)" {
  let path = svg_path_to_vector_path("M 0 0 C 10 30 30 30 40 0 S 70 -30 80 0")
  let points = path.flatten(1.0)
  assert_true(points.length() > 4)
  // Last point should be near (80, 0)
  let last = points[points.length() - 1]
  assert_true((last.x - 80.0).abs() < 0.01)
  assert_true(last.y.abs() < 0.01)
}

///|
test "svg_path_to_vector_path h/v relative commands" {
  let path = svg_path_to_vector_path("M 10 10 h 20 v 30")
  let points = path.flatten(1.0)
  assert_eq(points.length(), 3)
  assert_eq(points[0].x, 10.0)
  assert_eq(points[0].y, 10.0)
  assert_eq(points[1].x, 30.0)
  assert_eq(points[1].y, 10.0)
  assert_eq(points[2].x, 30.0)
  assert_eq(points[2].y, 40.0)
}

///|
test "svg_path_to_fill_vertices quadrilateral" {
  let (vertices, indices) = svg_path_to_fill_vertices(
    "M 0 0 L 100 0 L 100 100 L 0 100 Z", 1.0,
  )
  // 5 points (quad + close) -> fan triangulation
  assert_true(vertices.length() > 0)
  assert_true(indices.length() > 0)
}

///|
test "svg_path_to_stroke_vertices single line segment" {
  let (vertices, indices) = svg_path_to_stroke_vertices(
    "M 0 0 L 50 0", 4.0, 1.0,
  )
  // 2 points -> 1 segment -> 4 verts (16 doubles), 6 indices
  assert_eq(vertices.length(), 16)
  assert_eq(indices.length(), 6)
}

///|
test "svg_path_to_vector_path quadratic" {
  let path = svg_path_to_vector_path("M 0 0 Q 50 100 100 0")
  let points = path.flatten(1.0)
  assert_true(points.length() > 2)
  // Last point should be near (100, 0)
  let last = points[points.length() - 1]
  assert_true((last.x - 100.0).abs() < 0.01)
  assert_true(last.y.abs() < 0.01)
}
