///|
test "RigidBody::new_dynamic - mass and inv_mass" {
  let body = RigidBody::new_dynamic(
    0,
    @math3d.Vec3::zero(),
    2.0,
    SphereShape(@math3d.Vec3::zero(), 1.0),
  )
  assert_eq(body.mass, 2.0)
  assert_true((body.inv_mass - 0.5).abs() < 1.0e-9)
  assert_true(body.is_dynamic())
}

///|
test "RigidBody::new_static - inv_mass is zero" {
  let body = RigidBody::new_static(
    1,
    @math3d.Vec3::zero(),
    AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
  )
  assert_eq(body.inv_mass, 0.0)
  assert_false(body.is_dynamic())
}

///|
test "RigidBody::world_aabb - sphere" {
  let body = RigidBody::new_dynamic(
    0,
    @math3d.Vec3::new(1.0, 2.0, 3.0),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 0.5),
  )
  let aabb = body.world_aabb()
  assert_true((aabb.min.x - 0.5).abs() < 1.0e-9)
  assert_true((aabb.min.y - 1.5).abs() < 1.0e-9)
  assert_true((aabb.min.z - 2.5).abs() < 1.0e-9)
  assert_true((aabb.max.x - 1.5).abs() < 1.0e-9)
  assert_true((aabb.max.y - 2.5).abs() < 1.0e-9)
  assert_true((aabb.max.z - 3.5).abs() < 1.0e-9)
}
