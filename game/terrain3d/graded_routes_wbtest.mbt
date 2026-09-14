///|
test "route grading preserves elevated pads and the ramp between them" {
  let field = HeightField::new(32, 16, Array::make(33 * 17, -3.0))
  let pads : Array[TerrainPad] = [
    { x: 4.0, z: 8.0, height: 0.0, radius: 3.0, },
    { x: 28.0, z: 8.0, height: 6.0, radius: 3.0, },
  ]
  let routes : Array[TerrainRoute] = [
    { ax: 4.0, az: 8.0, ah: 0.0, bx: 28.0, bz: 8.0, bh: 6.0, width: 2.5, },
  ]
  field.grade_routes(pads, routes, blend=3.0)
  assert_eq(field.sample(4.0, 8.0), 0.0)
  assert_eq(field.sample(28.0, 8.0), 6.0)
  assert_true((field.sample(16.0, 8.0) - 3.0).abs() < 0.01)
  assert_eq(field.sample(16.0, 0.0), -3.0)
  assert_true(field.cell_slope(16, 8) <= 0.5)
  assert_true(field.cell_slope(16, 11) > 0.5)
}

///|
test "grading is deterministic and zero length routes are finite" {
  let a = HeightField::new(8, 8, Array::make(81, 0.0))
  let b = HeightField::new(8, 8, Array::make(81, 0.0))
  let paths : Array[TerrainRoute] = [
    { ax: 4.0, az: 4.0, ah: 2.0, bx: 4.0, bz: 4.0, bh: 2.0, width: 1.0, },
  ]
  a.grade_routes([], paths, blend=2.0)
  b.grade_routes([], paths, blend=2.0)
  assert_eq(a.values, b.values)
  assert_eq(a.sample(4.0, 4.0), 2.0)
  assert_false(a.values.any(v => v.is_nan()))
}
