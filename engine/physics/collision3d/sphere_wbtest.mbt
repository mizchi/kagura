///|
test "Sphere::contains_point - inside" {
  let s = Sphere::new(@math3d.Vec3::zero(), 2.0)
  assert_true(s.contains_point(@math3d.Vec3::zero()))
  assert_true(s.contains_point(@math3d.Vec3::new(1.0, 0.0, 0.0)))
}

///|
test "Sphere::contains_point - boundary" {
  let s = Sphere::new(@math3d.Vec3::zero(), 1.0)
  assert_true(s.contains_point(@math3d.Vec3::new(1.0, 0.0, 0.0)))
}

///|
test "Sphere::contains_point - outside" {
  let s = Sphere::new(@math3d.Vec3::zero(), 1.0)
  assert_false(s.contains_point(@math3d.Vec3::new(2.0, 0.0, 0.0)))
  assert_false(s.contains_point(@math3d.Vec3::new(0.8, 0.8, 0.0)))
}

///|
test "Sphere::intersects_sphere - overlapping" {
  let a = Sphere::new(@math3d.Vec3::zero(), 1.0)
  let b = Sphere::new(@math3d.Vec3::new(1.5, 0.0, 0.0), 1.0)
  assert_true(a.intersects_sphere(b))
  assert_true(b.intersects_sphere(a))
}

///|
test "Sphere::intersects_sphere - touching" {
  let a = Sphere::new(@math3d.Vec3::zero(), 1.0)
  let b = Sphere::new(@math3d.Vec3::new(2.0, 0.0, 0.0), 1.0)
  assert_true(a.intersects_sphere(b))
}

///|
test "Sphere::intersects_sphere - separated" {
  let a = Sphere::new(@math3d.Vec3::zero(), 1.0)
  let b = Sphere::new(@math3d.Vec3::new(3.0, 0.0, 0.0), 1.0)
  assert_false(a.intersects_sphere(b))
}

///|
test "Sphere::intersects_aabb - consistent with AABB" {
  let s = Sphere::new(@math3d.Vec3::new(1.5, 0.0, 0.0), 1.0)
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  assert_true(s.intersects_aabb(aabb))
  assert_true(aabb.intersects_sphere(s))
}

///|
test "Sphere::intersects_aabb - separated" {
  let s = Sphere::new(@math3d.Vec3::new(5.0, 5.0, 5.0), 1.0)
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  assert_false(s.intersects_aabb(aabb))
}
