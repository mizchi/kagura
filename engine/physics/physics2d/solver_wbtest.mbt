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

///|
test "angular impulse on off-center hit" {
  let a = {
    ..RigidBody2D::new_dynamic(
      0,
      @vector.Vec2::new(0.0, 0.0),
      1.0,
      OBBShape2D(@vector.Vec2::new(1.0, 1.0), @vector.Vec2::zero()),
    ),
    velocity: @vector.Vec2::new(0.0, -2.0),
    restitution: 0.5,
  }
  let floor = RigidBody2D::new_static(
    1,
    @vector.Vec2::new(0.0, -2.0),
    AABBShape2D(@vector.Vec2::new(10.0, 0.5), @vector.Vec2::zero()),
  )
  // Contact at the corner of the OBB (off-center)
  let contact : Contact2D = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @vector.Vec2::new(0.0, -1.0),
    penetration: 0.5,
    contact_point: @vector.Vec2::new(0.8, -1.0),
  }
  let (a2, _) = resolve_contact2d(a, floor, contact)
  // Off-center hit should produce angular velocity
  assert_true(a2.angular_velocity.abs() > 0.01)
}

///|
test "soft constraint gamma computation" {
  // Two unit-mass circles overlapping, sub_dt = 1/240
  let a = {
    ..RigidBody2D::new_dynamic(
      0,
      @vector.Vec2::new(-0.5, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 1.0),
    ),
    velocity: @vector.Vec2::new(1.0, 0.0),
    restitution: 0.5,
  }
  let b = {
    ..RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(0.5, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 1.0),
    ),
    velocity: @vector.Vec2::new(-1.0, 0.0),
    restitution: 0.5,
  }
  let contact : Contact2D = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @vector.Vec2::new(1.0, 0.0),
    penetration: 1.0,
    contact_point: @vector.Vec2::zero(),
  }
  let hertz = 30.0
  let damping_ratio = 1.0
  let sub_dt = 1.0 / 240.0
  let c = precompute_constraint2d(
    a, b, 0, 1, contact, hertz, damping_ratio, sub_dt,
  )
  // gamma should be positive (soft regularization)
  assert_true(c.gamma > 0.0)
  // bias_coefficient should be positive
  assert_true(c.bias_coefficient > 0.0)
  // normal_mass should be positive
  assert_true(c.normal_mass > 0.0)
  // tangent_mass should be positive
  assert_true(c.tangent_mass > 0.0)
  // normal_mass should differ from 1/k_normal due to gamma softening
  // For center contact, k_normal = inv_mass_sum = 2.0, so unsoftened = 0.5
  // softened = 1/(2.0 + gamma) < 0.5
  assert_true(c.normal_mass < 0.5)
  // Verify gamma numerically: omega=2*pi*30, gamma = 1/(sub_dt*(2*1*omega + sub_dt*omega^2))
  let omega = 2.0 * 3.14159265358979323846 * hertz
  let expected_gamma = 1.0 /
    (sub_dt * (2.0 * damping_ratio * omega + sub_dt * omega * omega))
  assert_true((c.gamma - expected_gamma).abs() < 1.0e-6)
  // acc_jn / acc_jt should start at 0
  assert_true(c.acc_jn == 0.0)
  assert_true(c.acc_jt == 0.0)
}

///|
test "soft solve separates overlapping bodies" {
  // Two circles overlapping, approaching each other
  let bodies : Array[RigidBody2D] = [
    {
      ..RigidBody2D::new_dynamic(
        0,
        @vector.Vec2::new(-0.3, 0.0),
        1.0,
        CircleShape(@vector.Vec2::zero(), 1.0),
      ),
      velocity: @vector.Vec2::new(2.0, 0.0),
      restitution: 0.5,
    },
    {
      ..RigidBody2D::new_dynamic(
        1,
        @vector.Vec2::new(0.3, 0.0),
        1.0,
        CircleShape(@vector.Vec2::zero(), 1.0),
      ),
      velocity: @vector.Vec2::new(-2.0, 0.0),
      restitution: 0.5,
    },
  ]
  let contact : Contact2D = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @vector.Vec2::new(1.0, 0.0),
    penetration: 1.4,
    contact_point: @vector.Vec2::zero(),
  }
  let sub_dt = 1.0 / 240.0
  let c = precompute_constraint2d(
    bodies[0],
    bodies[1],
    0,
    1,
    contact,
    30.0,
    1.0,
    sub_dt,
  )
  let constraints : Array[ContactConstraint2D] = [c]
  // Solve a few iterations
  for _i = 0; _i < 4; _i = _i + 1 {
    solve_constraint2d(constraints, 0, bodies)
  }
  // After solving, bodies should be pushed apart (velocity reversed)
  assert_true(bodies[0].velocity.x < 0.0)
  assert_true(bodies[1].velocity.x > 0.0)
  // Accumulated normal impulse should be negative (repulsive)
  assert_true(constraints[0].acc_jn < 0.0)
}

///|
test "relaxation reduces excess energy" {
  // Ball approaching floor with some velocity — solve then relax
  let bodies : Array[RigidBody2D] = [
    {
      ..RigidBody2D::new_dynamic(
        0,
        @vector.Vec2::new(0.0, -0.3),
        1.0,
        CircleShape(@vector.Vec2::zero(), 0.5),
      ),
      velocity: @vector.Vec2::new(0.0, 3.0),
      restitution: 0.0,
    },
    RigidBody2D::new_static(
      1,
      @vector.Vec2::new(0.0, 1.0),
      AABBShape2D(@vector.Vec2::new(10.0, 0.5), @vector.Vec2::zero()),
    ),
  ]
  let contact : Contact2D = {
    body_a_id: 0,
    body_b_id: 1,
    normal: @vector.Vec2::new(0.0, 1.0),
    penetration: 0.2,
    contact_point: @vector.Vec2::new(0.0, 0.5),
  }
  let sub_dt = 1.0 / 240.0
  let c = precompute_constraint2d(
    bodies[0],
    bodies[1],
    0,
    1,
    contact,
    30.0,
    1.0,
    sub_dt,
  )
  let constraints : Array[ContactConstraint2D] = [c]
  // Solve velocity
  solve_constraint2d(constraints, 0, bodies)
  let vy_after_solve = bodies[0].velocity.y
  // Relaxation should not add energy (velocity magnitude should not increase)
  _solve_relaxation2d(constraints, 0, bodies)
  let vy_after_relax = bodies[0].velocity.y
  // Relaxation should keep velocity bounded (not add energy)
  assert_true(vy_after_relax.abs() <= vy_after_solve.abs() + 1.0e-6)
}
