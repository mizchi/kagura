///|
test "symmetric bounce - equal mass" {
  let a = {
    ..RigidBody2D::new_dynamic(
      0,
      @vector.Vec2::new(-0.5, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 1.0),
    ),
    velocity: @vector.Vec2::new(1.0, 0.0),
    restitution: 1.0,
  }
  let b = {
    ..RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(0.5, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 1.0),
    ),
    velocity: @vector.Vec2::new(-1.0, 0.0),
    restitution: 1.0,
  }
  let contact : Contact2D = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @vector.Vec2::new(1.0, 0.0),
    penetration: 1.0,
    contact_point: @vector.Vec2::zero(),
  }
  let (a2, b2) = resolve_contact2d(a, b, contact)
  assert_true((a2.velocity.x - -1.0).abs() < 1.0e-6)
  assert_true((b2.velocity.x - 1.0).abs() < 1.0e-6)
}

///|
test "static floor bounce" {
  let ball = {
    ..RigidBody2D::new_dynamic(
      0,
      @vector.Vec2::new(0.0, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 1.0),
    ),
    velocity: @vector.Vec2::new(0.0, 5.0),
    restitution: 1.0,
  }
  let floor = RigidBody2D::new_static(
    1,
    @vector.Vec2::new(0.0, 1.5),
    AABBShape2D(@vector.Vec2::new(10.0, 0.5), @vector.Vec2::zero()),
  )
  let contact : Contact2D = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @vector.Vec2::new(0.0, 1.0),
    penetration: 0.5,
    contact_point: @vector.Vec2::new(0.0, 1.0),
  }
  let (ball2, _) = resolve_contact2d(ball, floor, contact)
  assert_true(ball2.velocity.y < 0.0)
}

///|
test "both static - no change" {
  let a = RigidBody2D::new_static(
    0,
    @vector.Vec2::zero(),
    AABBShape2D(@vector.Vec2::one(), @vector.Vec2::zero()),
  )
  let b = RigidBody2D::new_static(
    1,
    @vector.Vec2::new(1.0, 0.0),
    AABBShape2D(@vector.Vec2::one(), @vector.Vec2::zero()),
  )
  let contact : Contact2D = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @vector.Vec2::new(1.0, 0.0),
    penetration: 1.0,
    contact_point: @vector.Vec2::new(0.5, 0.0),
  }
  let (a2, b2) = resolve_contact2d(a, b, contact)
  assert_true(a2.velocity.length() < 1.0e-9)
  assert_true(b2.velocity.length() < 1.0e-9)
}

///|
test "friction reduces tangential velocity" {
  let a = {
    ..RigidBody2D::new_dynamic(
      0,
      @vector.Vec2::new(0.0, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 1.0),
    ),
    velocity: @vector.Vec2::new(3.0, 5.0),
    restitution: 0.0,
    friction: 0.5,
  }
  let floor = {
    ..RigidBody2D::new_static(
      1,
      @vector.Vec2::new(0.0, 1.5),
      AABBShape2D(@vector.Vec2::new(10.0, 0.5), @vector.Vec2::zero()),
    ),
    friction: 0.5,
  }
  let contact : Contact2D = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @vector.Vec2::new(0.0, 1.0),
    penetration: 0.5,
    contact_point: @vector.Vec2::new(0.0, 1.0),
  }
  let (a2, _) = resolve_contact2d(a, floor, contact)
  assert_true(a2.velocity.x.abs() < 3.0)
}
