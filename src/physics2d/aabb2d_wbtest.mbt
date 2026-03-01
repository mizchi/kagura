///|
test "AABB2D intersects - overlapping" {
  let a = AABB2D::new(@vector.Vec2::new(0.0, 0.0), @vector.Vec2::new(2.0, 2.0))
  let b = AABB2D::new(@vector.Vec2::new(1.0, 1.0), @vector.Vec2::new(3.0, 3.0))
  assert_true(a.intersects(b))
  assert_true(b.intersects(a))
}

///|
test "AABB2D intersects - separated" {
  let a = AABB2D::new(@vector.Vec2::new(0.0, 0.0), @vector.Vec2::new(1.0, 1.0))
  let b = AABB2D::new(@vector.Vec2::new(2.0, 2.0), @vector.Vec2::new(3.0, 3.0))
  assert_true(not(a.intersects(b)))
}

///|
test "AABB2D closest_point - outside" {
  let aabb = AABB2D::new(
    @vector.Vec2::new(0.0, 0.0),
    @vector.Vec2::new(2.0, 2.0),
  )
  let point = @vector.Vec2::new(3.0, 3.0)
  let closest = aabb.closest_point(point)
  assert_true((closest.x - 2.0).abs() < 1.0e-9)
  assert_true((closest.y - 2.0).abs() < 1.0e-9)
}

///|
test "AABB2D closest_point - inside" {
  let aabb = AABB2D::new(
    @vector.Vec2::new(0.0, 0.0),
    @vector.Vec2::new(4.0, 4.0),
  )
  let point = @vector.Vec2::new(1.0, 1.0)
  let closest = aabb.closest_point(point)
  assert_true((closest.x - 1.0).abs() < 1.0e-9)
  assert_true((closest.y - 1.0).abs() < 1.0e-9)
}
