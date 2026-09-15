///|
test "segment distance clamps to endpoints and handles zero and tiny lengths" {
  let segment = Segment3::new(Vec3::zero(), Vec3::new(10, 0, 0))
  assert_eq(segment.distance_squared(Vec3::new(5, 3, 0)), 9.0)
  assert_eq(segment.distance_squared(Vec3::new(-2, 0, 0)), 4.0)
  assert_eq(segment.distance_squared(Vec3::new(12, 0, 0)), 4.0)
  let point = Segment3::new(Vec3::one(), Vec3::one())
  assert_eq(point.distance_squared(Vec3::zero()), 3.0)
  let tiny = Segment3::new(Vec3::zero(), Vec3::new(0.00001, 0, 0))
  assert_eq(tiny.distance_squared(tiny.end), 0.0)
}

///|
test "long swept segments retain their true nearest point in either direction" {
  let a = Vec3::new(-1000, -1000, -1000)
  let b = Vec3::new(1000, 1000, 1000)
  let p = Vec3::new(4, 4, 4)
  assert_true(Segment3::new(a, b).distance_squared(p) < 0.0000001)
  assert_true(Segment3::new(b, a).distance_squared(p) < 0.0000001)
}
