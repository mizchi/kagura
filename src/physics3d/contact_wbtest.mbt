///|
test "sphere-sphere overlapping" {
  let a = RigidBody::new_dynamic(
    0,
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 1.0),
  )
  let b = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::new(1.5, 0.0, 0.0),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 1.0),
  )
  guard generate_contact(a, b) is Some(c)
  assert_true((c.penetration - 0.5).abs() < 1.0e-9)
  assert_true((c.normal.x - 1.0).abs() < 1.0e-9)
}

///|
test "sphere-sphere separated" {
  let a = RigidBody::new_dynamic(
    0,
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 1.0),
  )
  let b = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::new(3.0, 0.0, 0.0),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 1.0),
  )
  assert_true(generate_contact(a, b) is None)
}

///|
test "aabb-aabb overlapping" {
  let a = RigidBody::new_dynamic(
    0,
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    1.0,
    AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
  )
  let b = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::new(1.5, 0.0, 0.0),
    1.0,
    AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
  )
  guard generate_contact(a, b) is Some(c)
  assert_true((c.penetration - 0.5).abs() < 1.0e-9)
  assert_true((c.normal.x - 1.0).abs() < 1.0e-9)
}

///|
test "aabb-aabb separated" {
  let a = RigidBody::new_dynamic(
    0,
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    1.0,
    AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
  )
  let b = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::new(3.0, 0.0, 0.0),
    1.0,
    AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
  )
  assert_true(generate_contact(a, b) is None)
}

///|
test "sphere-aabb overlapping" {
  let a = RigidBody::new_dynamic(
    0,
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 1.0),
  )
  let b = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::new(1.5, 0.0, 0.0),
    1.0,
    AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
  )
  guard generate_contact(a, b) is Some(c)
  assert_true(c.penetration > 0.0)
}

///|
test "sphere-aabb separated" {
  let a = RigidBody::new_dynamic(
    0,
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 1.0),
  )
  let b = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::new(5.0, 0.0, 0.0),
    1.0,
    AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
  )
  assert_true(generate_contact(a, b) is None)
}
