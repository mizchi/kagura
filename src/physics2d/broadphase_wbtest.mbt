///|
test "broadphase insert and count" {
  let grid = SpatialHashGrid2D::new(10.0)
  grid.insert(
    0,
    AABB2D::new(@vector.Vec2::new(0.0, 0.0), @vector.Vec2::new(1.0, 1.0)),
  )
  grid.insert(
    1,
    AABB2D::new(@vector.Vec2::new(5.0, 5.0), @vector.Vec2::new(6.0, 6.0)),
  )
  assert_true(grid.count() == 2)
}

///|
test "broadphase get_pairs - overlapping" {
  let grid = SpatialHashGrid2D::new(10.0)
  grid.insert(
    0,
    AABB2D::new(@vector.Vec2::new(0.0, 0.0), @vector.Vec2::new(2.0, 2.0)),
  )
  grid.insert(
    1,
    AABB2D::new(@vector.Vec2::new(1.0, 1.0), @vector.Vec2::new(3.0, 3.0)),
  )
  let pairs = grid.get_pairs()
  assert_true(pairs.length() == 1)
}

///|
test "broadphase get_pairs - separated" {
  let grid = SpatialHashGrid2D::new(2.0)
  grid.insert(
    0,
    AABB2D::new(@vector.Vec2::new(0.0, 0.0), @vector.Vec2::new(1.0, 1.0)),
  )
  grid.insert(
    1,
    AABB2D::new(
      @vector.Vec2::new(100.0, 100.0),
      @vector.Vec2::new(101.0, 101.0),
    ),
  )
  let pairs = grid.get_pairs()
  assert_true(pairs.length() == 0)
}
