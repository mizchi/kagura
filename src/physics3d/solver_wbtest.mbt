///|
test "symmetric bounce - equal mass" {
  let a = {
    ..RigidBody::new_dynamic(
      0,
      @math3d.Vec3::new(-0.5, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 1.0),
    ),
    velocity: @math3d.Vec3::new(1.0, 0.0, 0.0),
    restitution: 1.0,
  }
  let b = {
    ..RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.5, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 1.0),
    ),
    velocity: @math3d.Vec3::new(-1.0, 0.0, 0.0),
    restitution: 1.0,
  }
  let contact : Contact = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @math3d.Vec3::new(1.0, 0.0, 0.0),
    penetration: 1.0,
    contact_point: @math3d.Vec3::zero(),
  }
  let (a2, b2) = resolve_contact(a, b, contact)
  assert_true((a2.velocity.x - -1.0).abs() < 1.0e-6)
  assert_true((b2.velocity.x - 1.0).abs() < 1.0e-6)
}

///|
test "static floor bounce" {
  let ball = {
    ..RigidBody::new_dynamic(
      0,
      @math3d.Vec3::new(0.0, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 1.0),
    ),
    velocity: @math3d.Vec3::new(0.0, -5.0, 0.0),
    restitution: 1.0,
  }
  let floor = RigidBody::new_static(
    1,
    @math3d.Vec3::new(0.0, -1.5, 0.0),
    AABBShape(@math3d.Vec3::new(10.0, 0.5, 10.0), @math3d.Vec3::zero()),
  )
  let contact : Contact = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @math3d.Vec3::new(0.0, -1.0, 0.0),
    penetration: 0.5,
    contact_point: @math3d.Vec3::new(0.0, -1.0, 0.0),
  }
  let (ball2, _) = resolve_contact(ball, floor, contact)
  assert_true(ball2.velocity.y > 0.0)
}

///|
test "both static - no change" {
  let a = RigidBody::new_static(
    0,
    @math3d.Vec3::zero(),
    AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
  )
  let b = RigidBody::new_static(
    1,
    @math3d.Vec3::new(1.0, 0.0, 0.0),
    AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
  )
  let contact : Contact = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @math3d.Vec3::new(1.0, 0.0, 0.0),
    penetration: 1.0,
    contact_point: @math3d.Vec3::new(0.5, 0.0, 0.0),
  }
  let (a2, b2) = resolve_contact(a, b, contact)
  assert_true(a2.velocity.length() < 1.0e-9)
  assert_true(b2.velocity.length() < 1.0e-9)
}

///|
test "friction reduces tangential velocity" {
  let a = {
    ..RigidBody::new_dynamic(
      0,
      @math3d.Vec3::new(0.0, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 1.0),
    ),
    velocity: @math3d.Vec3::new(3.0, -1.0, 0.0),
    restitution: 0.0,
    friction: 0.5,
  }
  let floor = {
    ..RigidBody::new_static(
      1,
      @math3d.Vec3::new(0.0, -1.5, 0.0),
      AABBShape(@math3d.Vec3::new(10.0, 0.5, 10.0), @math3d.Vec3::zero()),
    ),
    friction: 0.5,
  }
  let contact : Contact = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @math3d.Vec3::new(0.0, -1.0, 0.0),
    penetration: 0.5,
    contact_point: @math3d.Vec3::new(0.0, -1.0, 0.0),
  }
  let (a2, _) = resolve_contact(a, floor, contact)
  assert_true(a2.velocity.x.abs() < 3.0)
}
