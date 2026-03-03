///|
test "distance joint maintains length" {
  let world = PhysicsWorld2D::new(@vector.Vec2::zero(), 10.0)
  // Two dynamic bodies, 2 units apart
  world.add_body(
    RigidBody2D::new_dynamic(
      0,
      @vector.Vec2::new(-1.0, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.2),
    ).with_damping(0.0),
  )
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(1.0, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.2),
    ).with_damping(0.0),
  )
  world.add_distance_joint(
    {
      body_a_id: 0,
      body_b_id: 1,
      local_anchor_a: @vector.Vec2::zero(),
      local_anchor_b: @vector.Vec2::zero(),
      rest_length: 2.0,
      hertz: 30.0,
      damping_ratio: 1.0,
    },
  )
  // Push them apart
  world.apply_impulse(0, @vector.Vec2::new(-5.0, 0.0))
  world.apply_impulse(1, @vector.Vec2::new(5.0, 0.0))
  let dt = 1.0 / 60.0
  for _frame in 0..<120 {
    world.step(dt)
  }
  let a = world.get_body(0).unwrap()
  let b = world.get_body(1).unwrap()
  let dist = b.position.sub(a.position).length()
  // Should return close to rest length (2.0)
  assert_true((dist - 2.0).abs() < 0.3)
}

///|
test "distance joint with gravity pendulum" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 10.0)
  // Static anchor point
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(0.0, 5.0),
      CircleShape(@vector.Vec2::zero(), 0.1),
    ),
  )
  // Dynamic ball hanging below
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(2.0, 5.0), // offset to the side to swing
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.2),
    ).with_damping(0.02),
  )
  world.add_distance_joint(
    {
      body_a_id: 0,
      body_b_id: 1,
      local_anchor_a: @vector.Vec2::zero(),
      local_anchor_b: @vector.Vec2::zero(),
      rest_length: 2.0,
      hertz: 30.0,
      damping_ratio: 1.0,
    },
  )
  let dt = 1.0 / 60.0
  // Run for 3 seconds
  for _frame in 0..<180 {
    world.step(dt)
  }
  let ball = world.get_body(1).unwrap()
  let anchor = world.get_body(0).unwrap()
  let dist = ball.position.sub(anchor.position).length()
  // Distance should stay approximately at rest length
  assert_true((dist - 2.0).abs() < 0.5)
  // Ball should be below the anchor (gravity pulling down)
  assert_true(ball.position.y < anchor.position.y)
}

///|
test "revolute joint keeps points together" {
  let world = PhysicsWorld2D::new(@vector.Vec2::zero(), 10.0)
  // Two dynamic bodies at the same point
  world.add_body(
    RigidBody2D::new_dynamic(
      0,
      @vector.Vec2::new(0.0, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.2),
    ).with_damping(0.0),
  )
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(0.0, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.2),
    ).with_damping(0.0),
  )
  world.add_revolute_joint(
    {
      body_a_id: 0,
      body_b_id: 1,
      local_anchor_a: @vector.Vec2::new(0.5, 0.0),
      local_anchor_b: @vector.Vec2::new(-0.5, 0.0),
      hertz: 30.0,
      damping_ratio: 1.0,
    },
  )
  // Push them apart
  world.apply_impulse(0, @vector.Vec2::new(-2.0, 0.5))
  world.apply_impulse(1, @vector.Vec2::new(2.0, -0.5))
  let dt = 1.0 / 60.0
  for _frame in 0..<180 {
    world.step(dt)
  }
  let a = world.get_body(0).unwrap()
  let b = world.get_body(1).unwrap()
  // The anchor points in world space should be close (accounting for rotation)
  let cos_a = @math.cos(a.angle)
  let sin_a = @math.sin(a.angle)
  let anchor_a = a.position.add(
    @vector.Vec2::new(0.5 * cos_a, 0.5 * sin_a),
  )
  let cos_b = @math.cos(b.angle)
  let sin_b = @math.sin(b.angle)
  let anchor_b = b.position.add(
    @vector.Vec2::new(-0.5 * cos_b, -0.5 * sin_b),
  )
  let gap = anchor_b.sub(anchor_a).length()
  assert_true(gap < 1.0)
}

///|
test "revolute joint with gravity chain" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 10.0)
  // Fixed point at top
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(0.0, 5.0),
      CircleShape(@vector.Vec2::zero(), 0.1),
    ),
  )
  // Link 1
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(0.0, 3.5),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.2),
    ).with_damping(0.05),
  )
  // Link 2
  world.add_body(
    RigidBody2D::new_dynamic(
      2,
      @vector.Vec2::new(0.0, 2.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.2),
    ).with_damping(0.05),
  )
  // Joint 0-1: fixed point to link 1
  world.add_revolute_joint(
    {
      body_a_id: 0,
      body_b_id: 1,
      local_anchor_a: @vector.Vec2::zero(),
      local_anchor_b: @vector.Vec2::new(0.0, 0.75),
      hertz: 30.0,
      damping_ratio: 1.0,
    },
  )
  // Joint 1-2: link 1 to link 2
  world.add_revolute_joint(
    {
      body_a_id: 1,
      body_b_id: 2,
      local_anchor_a: @vector.Vec2::new(0.0, -0.75),
      local_anchor_b: @vector.Vec2::new(0.0, 0.75),
      hertz: 30.0,
      damping_ratio: 1.0,
    },
  )
  let dt = 1.0 / 60.0
  for _frame in 0..<300 {
    world.step(dt)
  }
  // All links should hang below the fixed point
  let l1 = world.get_body(1).unwrap()
  let l2 = world.get_body(2).unwrap()
  assert_true(l1.position.y < 5.0)
  assert_true(l2.position.y < l1.position.y)
  // Velocities should be low (settled)
  assert_true(l1.velocity.length() < 2.0)
  assert_true(l2.velocity.length() < 2.0)
}
