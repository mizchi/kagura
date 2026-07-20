///|
fn rapprox(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-6
}

///|
test "Ray::point_at" {
  let ray = Ray::new(
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    @math3d.Vec3::new(1.0, 0.0, 0.0),
  )
  let p = ray.point_at(3.0)
  assert_true(rapprox(p.x, 3.0))
  assert_true(rapprox(p.y, 0.0))
  assert_true(rapprox(p.z, 0.0))
}

///|
test "Ray::intersects_aabb - hit" {
  let ray = Ray::new(
    @math3d.Vec3::new(-5.0, 0.0, 0.0),
    @math3d.Vec3::new(1.0, 0.0, 0.0),
  )
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let result = ray.intersects_aabb(aabb)
  assert_true(result.hit)
  assert_true(rapprox(result.distance, 4.0))
  assert_true(rapprox(result.point.x, -1.0))
}

///|
test "Ray::intersects_aabb - miss" {
  let ray = Ray::new(
    @math3d.Vec3::new(-5.0, 5.0, 0.0),
    @math3d.Vec3::new(1.0, 0.0, 0.0),
  )
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let result = ray.intersects_aabb(aabb)
  assert_false(result.hit)
}

///|
test "Ray::intersects_aabb - from inside" {
  let ray = Ray::new(
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    @math3d.Vec3::new(1.0, 0.0, 0.0),
  )
  let aabb = AABB::new(
    @math3d.Vec3::new(-1.0, -1.0, -1.0),
    @math3d.Vec3::new(1.0, 1.0, 1.0),
  )
  let result = ray.intersects_aabb(aabb)
  assert_true(result.hit)
  assert_true(rapprox(result.distance, 1.0))
  assert_true(rapprox(result.point.x, 1.0))
}

///|
test "Ray::intersects_sphere - hit" {
  let ray = Ray::new(
    @math3d.Vec3::new(-5.0, 0.0, 0.0),
    @math3d.Vec3::new(1.0, 0.0, 0.0),
  )
  let sphere = Sphere::new(@math3d.Vec3::zero(), 1.0)
  let result = ray.intersects_sphere(sphere)
  assert_true(result.hit)
  assert_true(rapprox(result.distance, 4.0))
  assert_true(rapprox(result.point.x, -1.0))
}

///|
test "Ray::intersects_sphere - miss" {
  let ray = Ray::new(
    @math3d.Vec3::new(-5.0, 5.0, 0.0),
    @math3d.Vec3::new(1.0, 0.0, 0.0),
  )
  let sphere = Sphere::new(@math3d.Vec3::zero(), 1.0)
  let result = ray.intersects_sphere(sphere)
  assert_false(result.hit)
}

///|
test "Ray::intersects_sphere - tangent" {
  let ray = Ray::new(
    @math3d.Vec3::new(-5.0, 1.0, 0.0),
    @math3d.Vec3::new(1.0, 0.0, 0.0),
  )
  let sphere = Sphere::new(@math3d.Vec3::zero(), 1.0)
  let result = ray.intersects_sphere(sphere)
  assert_true(result.hit)
  assert_true(rapprox(result.point.y, 1.0))
}

///|
test "aabb_from_mesh - cube" {
  let mesh = @mesh3d.Mesh3D::cube(2.0)
  let aabb = aabb_from_mesh(mesh)
  assert_true(rapprox(aabb.min.x, -1.0))
  assert_true(rapprox(aabb.min.y, -1.0))
  assert_true(rapprox(aabb.min.z, -1.0))
  assert_true(rapprox(aabb.max.x, 1.0))
  assert_true(rapprox(aabb.max.y, 1.0))
  assert_true(rapprox(aabb.max.z, 1.0))
}
