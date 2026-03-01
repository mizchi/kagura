///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-9
}

///|
test "AABB::contains_point - inside" {
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  assert_true(aabb.contains_point(@math3d.Vec3::zero()))
  assert_true(aabb.contains_point(@math3d.Vec3::new(0.5, 0.5, 0.5)))
}

///|
test "AABB::contains_point - boundary" {
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  assert_true(aabb.contains_point(@math3d.Vec3::new(1.0, 1.0, 1.0)))
  assert_true(aabb.contains_point(@math3d.Vec3::new(-1.0, -1.0, -1.0)))
}

///|
test "AABB::contains_point - outside" {
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  assert_false(aabb.contains_point(@math3d.Vec3::new(2.0, 0.0, 0.0)))
  assert_false(aabb.contains_point(@math3d.Vec3::new(0.0, -2.0, 0.0)))
  assert_false(aabb.contains_point(@math3d.Vec3::new(0.0, 0.0, 1.1)))
}

///|
test "AABB::intersects_aabb - overlapping" {
  let a = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let b = AABB::new(
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    @math3d.Vec3::new(2.0, 2.0, 2.0),
  )
  assert_true(a.intersects_aabb(b))
  assert_true(b.intersects_aabb(a))
}

///|
test "AABB::intersects_aabb - separated" {
  let a = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let b = AABB::new(
    @math3d.Vec3::new(2.0, 2.0, 2.0),
    @math3d.Vec3::new(3.0, 3.0, 3.0),
  )
  assert_false(a.intersects_aabb(b))
}

///|
test "AABB::intersects_aabb - contained" {
  let outer = AABB::new(
    @math3d.Vec3::new(-2.0, -2.0, -2.0),
    @math3d.Vec3::new(2.0, 2.0, 2.0),
  )
  let inner = AABB::new(
    @math3d.Vec3::new(-0.5, -0.5, -0.5),
    @math3d.Vec3::new(0.5, 0.5, 0.5),
  )
  assert_true(outer.intersects_aabb(inner))
  assert_true(inner.intersects_aabb(outer))
}

///|
test "AABB::intersects_sphere - overlapping" {
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let sphere = Sphere::new(@math3d.Vec3::new(1.5, 0.0, 0.0), 1.0)
  assert_true(aabb.intersects_sphere(sphere))
}

///|
test "AABB::intersects_sphere - separated" {
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let sphere = Sphere::new(@math3d.Vec3::new(5.0, 0.0, 0.0), 1.0)
  assert_false(aabb.intersects_sphere(sphere))
}

///|
test "AABB::merge" {
  let a = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let b = AABB::new(
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    @math3d.Vec3::new(3.0, 2.0, 4.0),
  )
  let merged = a.merge(b)
  assert_eq(merged.min.x, -1.0)
  assert_eq(merged.min.y, -1.0)
  assert_eq(merged.min.z, -1.0)
  assert_eq(merged.max.x, 3.0)
  assert_eq(merged.max.y, 2.0)
  assert_eq(merged.max.z, 4.0)
}

///|
test "AABB::from_center_extents roundtrip" {
  let center = @math3d.Vec3::new(1.0, 2.0, 3.0)
  let extents = @math3d.Vec3::new(0.5, 1.0, 1.5)
  let aabb = AABB::from_center_extents(center, extents)
  let c = aabb.center()
  let e = aabb.extents()
  assert_true(approx(c.x, center.x))
  assert_true(approx(c.y, center.y))
  assert_true(approx(c.z, center.z))
  assert_true(approx(e.x, extents.x))
  assert_true(approx(e.y, extents.y))
  assert_true(approx(e.z, extents.z))
}

///|
test "AABB::closest_point - inside" {
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let p = aabb.closest_point(@math3d.Vec3::new(0.5, 0.5, 0.5))
  assert_true(approx(p.x, 0.5))
  assert_true(approx(p.y, 0.5))
  assert_true(approx(p.z, 0.5))
}

///|
test "AABB::closest_point - outside" {
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let p = aabb.closest_point(@math3d.Vec3::new(3.0, 0.0, -5.0))
  assert_true(approx(p.x, 1.0))
  assert_true(approx(p.y, 0.0))
  assert_true(approx(p.z, -1.0))
}
