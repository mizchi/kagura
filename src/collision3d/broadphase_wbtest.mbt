test "SpatialHashGrid::new creates empty grid" {
  let grid = SpatialHashGrid::new(2.0)
  assert_eq(grid.count(), 0)
}

test "SpatialHashGrid::insert and count" {
  let grid = SpatialHashGrid::new(2.0)
  let a = AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0))
  let b = AABB::new(@math3d.Vec3::new(3.0, 3.0, 3.0), @math3d.Vec3::new(4.0, 4.0, 4.0))
  let c = AABB::new(@math3d.Vec3::new(6.0, 6.0, 6.0), @math3d.Vec3::new(7.0, 7.0, 7.0))
  grid.insert(0, a)
  grid.insert(1, b)
  grid.insert(2, c)
  assert_eq(grid.count(), 3)
}

test "SpatialHashGrid::clear resets grid" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(2.0, 2.0, 2.0), @math3d.Vec3::new(3.0, 3.0, 3.0)))
  grid.clear()
  assert_eq(grid.count(), 0)
  let results = grid.query_aabb(AABB::new(@math3d.Vec3::new(-10.0, -10.0, -10.0), @math3d.Vec3::new(10.0, 10.0, 10.0)))
  assert_eq(results.length(), 0)
}

test "query_aabb finds nearby objects" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(0.5, 0.5, 0.5), @math3d.Vec3::new(1.5, 1.5, 1.5)))
  let results = grid.query_aabb(AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  assert_eq(results.length(), 2)
  assert_true(results.contains(0))
  assert_true(results.contains(1))
}

test "query_aabb excludes distant objects" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(100.0, 100.0, 100.0), @math3d.Vec3::new(101.0, 101.0, 101.0)))
  let results = grid.query_aabb(AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  assert_eq(results.length(), 1)
  assert_true(results.contains(0))
}

test "query_aabb deduplicates multi-cell objects" {
  let grid = SpatialHashGrid::new(2.0)
  // Large AABB spanning multiple cells
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(5.0, 5.0, 5.0)))
  let results = grid.query_aabb(AABB::new(@math3d.Vec3::new(1.0, 1.0, 1.0), @math3d.Vec3::new(4.0, 4.0, 4.0)))
  assert_eq(results.length(), 1)
  assert_true(results.contains(0))
}

test "query_sphere finds intersecting objects" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(0.5, 0.5, 0.5), @math3d.Vec3::new(1.5, 1.5, 1.5)))
  let sphere = Sphere::new(@math3d.Vec3::new(0.5, 0.5, 0.5), 1.0)
  let results = grid.query_sphere(sphere)
  assert_eq(results.length(), 2)
  assert_true(results.contains(0))
  assert_true(results.contains(1))
}

test "query_sphere excludes distant objects" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(50.0, 50.0, 50.0), @math3d.Vec3::new(51.0, 51.0, 51.0)))
  let sphere = Sphere::new(@math3d.Vec3::new(0.5, 0.5, 0.5), 2.0)
  let results = grid.query_sphere(sphere)
  assert_eq(results.length(), 1)
  assert_true(results.contains(0))
}

test "query_ray finds hit objects" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(3.0, -0.5, -0.5), @math3d.Vec3::new(4.0, 0.5, 0.5)))
  let ray = Ray::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 0.0, 0.0))
  let results = grid.query_ray(ray, 10.0)
  assert_eq(results.length(), 1)
  assert_true(results.contains(0))
}

test "query_ray respects max_distance" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(10.0, -0.5, -0.5), @math3d.Vec3::new(11.0, 0.5, 0.5)))
  let ray = Ray::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 0.0, 0.0))
  let results = grid.query_ray(ray, 5.0)
  assert_eq(results.length(), 0)
}

test "get_pairs finds adjacent overlapping objects" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(0.5, 0.5, 0.5), @math3d.Vec3::new(1.5, 1.5, 1.5)))
  let pairs = grid.get_pairs()
  assert_eq(pairs.length(), 1)
  assert_true(pairs.contains((0, 1)))
}

test "get_pairs excludes distant objects" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(100.0, 100.0, 100.0), @math3d.Vec3::new(101.0, 101.0, 101.0)))
  let pairs = grid.get_pairs()
  assert_eq(pairs.length(), 0)
}

test "get_pairs three mutual objects" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(0.5, 0.5, 0.5), @math3d.Vec3::new(1.5, 1.5, 1.5)))
  grid.insert(2, AABB::new(@math3d.Vec3::new(0.3, 0.3, 0.3), @math3d.Vec3::new(1.3, 1.3, 1.3)))
  let pairs = grid.get_pairs()
  assert_eq(pairs.length(), 3)
  assert_true(pairs.contains((0, 1)))
  assert_true(pairs.contains((0, 2)))
  assert_true(pairs.contains((1, 2)))
}

test "get_pairs deduplicates across cells" {
  let grid = SpatialHashGrid::new(2.0)
  // Both span multiple cells and overlap
  grid.insert(0, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(3.0, 3.0, 3.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(1.0, 1.0, 1.0), @math3d.Vec3::new(4.0, 4.0, 4.0)))
  let pairs = grid.get_pairs()
  assert_eq(pairs.length(), 1)
  assert_true(pairs.contains((0, 1)))
}

test "negative coordinates" {
  let grid = SpatialHashGrid::new(2.0)
  grid.insert(0, AABB::new(@math3d.Vec3::new(-3.0, -3.0, -3.0), @math3d.Vec3::new(-2.0, -2.0, -2.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(-2.5, -2.5, -2.5), @math3d.Vec3::new(-1.5, -1.5, -1.5)))
  let pairs = grid.get_pairs()
  assert_eq(pairs.length(), 1)
  assert_true(pairs.contains((0, 1)))
  let results = grid.query_aabb(AABB::new(@math3d.Vec3::new(-3.0, -3.0, -3.0), @math3d.Vec3::new(-1.0, -1.0, -1.0)))
  assert_eq(results.length(), 2)
}

test "origin crossing objects" {
  let grid = SpatialHashGrid::new(2.0)
  // Object crossing the origin
  grid.insert(0, AABB::new(@math3d.Vec3::new(-1.0, -1.0, -1.0), @math3d.Vec3::new(1.0, 1.0, 1.0)))
  grid.insert(1, AABB::new(@math3d.Vec3::new(0.0, 0.0, 0.0), @math3d.Vec3::new(2.0, 2.0, 2.0)))
  let pairs = grid.get_pairs()
  assert_eq(pairs.length(), 1)
  assert_true(pairs.contains((0, 1)))
}
