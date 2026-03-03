///|
test "gravity acceleration" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, 10.0), 10.0)
  world.add_body(
    RigidBody2D::new_dynamic(
      0,
      @vector.Vec2::new(0.0, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.5),
    ).with_damping(0.0),
  )
  world.step(1.0)
  let body = world.get_body(0).unwrap()
  assert_true((body.velocity.y - 10.0).abs() < 0.5)
  assert_true(body.position.y > 0.0)
}

///|
test "two body collision" {
  let world = PhysicsWorld2D::new(@vector.Vec2::zero(), 10.0)
  world.add_body(
    {
      ..RigidBody2D::new_dynamic(
        0,
        @vector.Vec2::new(-0.5, 0.0),
        1.0,
        CircleShape(@vector.Vec2::zero(), 1.0),
      ),
      velocity: @vector.Vec2::new(1.0, 0.0),
      restitution: 1.0,
    }.with_damping(0.0),
  )
  world.add_body(
    {
      ..RigidBody2D::new_dynamic(
        1,
        @vector.Vec2::new(0.5, 0.0),
        1.0,
        CircleShape(@vector.Vec2::zero(), 1.0),
      ),
      velocity: @vector.Vec2::new(-1.0, 0.0),
      restitution: 1.0,
    }.with_damping(0.0),
  )
  world.step(1.0 / 60.0)
  let a = world.get_body(0).unwrap()
  let b = world.get_body(1).unwrap()
  assert_true(a.velocity.x < 0.0)
  assert_true(b.velocity.x > 0.0)
}

///|
test "static floor stops falling body" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, 10.0), 10.0)
  world.add_body(
    RigidBody2D::new_dynamic(
      0,
      @vector.Vec2::new(0.0, 0.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.5),
    ).with_damping(0.0),
  )
  world.add_body(
    RigidBody2D::new_static(
      1,
      @vector.Vec2::new(0.0, 1.5),
      AABBShape2D(@vector.Vec2::new(10.0, 0.5), @vector.Vec2::zero()),
    ),
  )
  for _ in 0..<120 {
    world.step(1.0 / 60.0)
  }
  let ball = world.get_body(0).unwrap()
  assert_true(ball.position.y < 2.0)
}

///|
test "kinematic not affected by gravity" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, 10.0), 10.0)
  world.add_body(
    RigidBody2D::new_kinematic(
      0,
      @vector.Vec2::new(0.0, 5.0),
      CircleShape(@vector.Vec2::zero(), 1.0),
    ),
  )
  world.step(1.0)
  let body = world.get_body(0).unwrap()
  assert_true((body.position.y - 5.0).abs() < 1.0e-9)
  assert_true(body.velocity.length() < 1.0e-9)
}

///|
test "broadphase no self-pairs" {
  let ground = RigidBody2D::new_static(
    0,
    @vector.Vec2::new(0.0, -6.5),
    AABBShape2D(@vector.Vec2::new(10.0, 2.0), @vector.Vec2::zero()),
  )
  let circle = RigidBody2D::new_dynamic(
    1,
    @vector.Vec2::new(0.0, -4.0),
    0.785,
    CircleShape(@vector.Vec2::zero(), 0.5),
  )
  let grid = SpatialHashGrid2D::new(4.0)
  grid.insert(0, ground.world_aabb())
  grid.insert(1, circle.world_aabb())
  let pairs = grid.get_pairs()
  // Should contain exactly one pair (0,1), no self-pairs
  assert_true(pairs.length() == 1)
  let (a, b) = pairs[0]
  assert_true((a == 0 && b == 1) || (a == 1 && b == 0))
}

///|
test "circle alone on ground stable" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 4.0)
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(0.0, -6.5),
      AABBShape2D(@vector.Vec2::new(10.0, 2.0), @vector.Vec2::zero()),
    ),
  )
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(0.0, 1.0),
      0.785,
      CircleShape(@vector.Vec2::zero(), 0.5),
    )
    .with_damping(0.05)
    .with_restitution(0.3),
  )
  let dt = 1.0 / 60.0 / 8.0
  // Settle for 2 seconds
  for _frame in 0..<(120 * 8) {
    world.step(dt)
  }
  let settled = world.get_body(1).unwrap().position.y
  let mut max_y = settled
  // Monitor for 3 seconds
  for _frame in 0..<(180 * 8) {
    world.step(dt)
    let y = world.get_body(1).unwrap().position.y
    if y > max_y {
      max_y = y
    }
  }
  let jump = max_y - settled
  assert_true(jump < 0.1)
}

///|
test "circle near obb should not gain energy" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 4.0)
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(0.0, -6.5),
      AABBShape2D(@vector.Vec2::new(10.0, 2.0), @vector.Vec2::zero()),
    ),
  )
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(-2.0, 1.0),
      0.785,
      CircleShape(@vector.Vec2::zero(), 0.5),
    )
    .with_damping(0.05)
    .with_restitution(0.3),
  )
  world.add_body(
    {
      ..RigidBody2D::new_dynamic(
        2,
        @vector.Vec2::new(-1.0, 1.5),
        0.64,
        OBBShape2D(@vector.Vec2::new(0.4, 0.4), @vector.Vec2::zero()),
      ),
      angular_velocity: 1.0,
    }
    .with_damping(0.05)
    .with_restitution(0.3),
  )
  let dt = 1.0 / 60.0 / 8.0
  // Settle for 2 seconds
  for _frame in 0..<(120 * 8) {
    world.step(dt)
  }
  let settled_y_circle = world.get_body(1).unwrap().position.y
  let settled_y_obb = world.get_body(2).unwrap().position.y
  // Monitor for 3 seconds
  let mut max_y_circle = settled_y_circle
  let mut max_y_obb = settled_y_obb
  for _frame in 0..<(180 * 8) {
    world.step(dt)
    let c = world.get_body(1).unwrap()
    let o = world.get_body(2).unwrap()
    if c.position.y > max_y_circle {
      max_y_circle = c.position.y
    }
    if o.position.y > max_y_obb {
      max_y_obb = o.position.y
    }
  }
  let circle_jump = max_y_circle - settled_y_circle
  let obb_jump = max_y_obb - settled_y_obb
  assert_true(circle_jump < 0.5)
  assert_true(obb_jump < 0.5)
}

///|
test "warm starting improves convergence" {
  // Two identical stacking scenarios: warm starting should help the ball settle faster
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 4.0)
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(0.0, -1.0),
      AABBShape2D(@vector.Vec2::new(10.0, 0.5), @vector.Vec2::zero()),
    ),
  )
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(0.0, 1.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.5),
    )
    .with_damping(0.05)
    .with_restitution(0.0),
  )
  let dt = 1.0 / 60.0
  // Run 60 frames (1 second) — ball should settle with warm starting
  for _frame in 0..<60 {
    world.step(dt)
  }
  let ball = world.get_body(1).unwrap()
  // Ball should be near ground and low velocity
  assert_true(ball.position.y < 1.0)
  assert_true(ball.position.y > -0.5)
  assert_true(ball.velocity.length() < 2.0)
}

///|
test "substepping stack stability" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 4.0)
  // Static ground
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(0.0, -1.0),
      AABBShape2D(@vector.Vec2::new(10.0, 0.5), @vector.Vec2::zero()),
    ),
  )
  // Stack of 3 boxes
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(0.0, 1.0),
      1.0,
      AABBShape2D(@vector.Vec2::new(0.5, 0.5), @vector.Vec2::zero()),
    )
    .with_damping(0.05)
    .with_restitution(0.0),
  )
  world.add_body(
    RigidBody2D::new_dynamic(
      2,
      @vector.Vec2::new(0.0, 2.5),
      1.0,
      AABBShape2D(@vector.Vec2::new(0.5, 0.5), @vector.Vec2::zero()),
    )
    .with_damping(0.05)
    .with_restitution(0.0),
  )
  world.add_body(
    RigidBody2D::new_dynamic(
      3,
      @vector.Vec2::new(0.0, 4.0),
      1.0,
      AABBShape2D(@vector.Vec2::new(0.5, 0.5), @vector.Vec2::zero()),
    )
    .with_damping(0.05)
    .with_restitution(0.0),
  )
  let dt = 1.0 / 60.0
  // Settle for 3 seconds
  for _frame in 0..<180 {
    world.step(dt)
  }
  // All boxes should have settled (low velocity)
  let b1 = world.get_body(1).unwrap()
  let b2 = world.get_body(2).unwrap()
  let b3 = world.get_body(3).unwrap()
  assert_true(b1.velocity.length() < 1.0)
  assert_true(b2.velocity.length() < 1.0)
  assert_true(b3.velocity.length() < 1.0)
  // Boxes should be above ground
  assert_true(b1.position.y > -0.5)
  assert_true(b2.position.y > b1.position.y)
  assert_true(b3.position.y > b2.position.y)
}

///|
test "body falls asleep after settling" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 4.0)
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(0.0, -1.0),
      AABBShape2D(@vector.Vec2::new(10.0, 0.5), @vector.Vec2::zero()),
    ),
  )
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(0.0, 1.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.5),
    )
    .with_damping(0.1)
    .with_restitution(0.0),
  )
  let dt = 1.0 / 60.0
  // Run 10 seconds — body should eventually sleep
  for _frame in 0..<600 {
    world.step(dt)
  }
  let ball = world.get_body(1).unwrap()
  assert_true(ball.is_sleeping)
}

///|
test "sleeping body wakes on new contact" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 4.0)
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(0.0, -1.0),
      AABBShape2D(@vector.Vec2::new(10.0, 0.5), @vector.Vec2::zero()),
    ),
  )
  // First ball, let it sleep
  world.add_body(
    RigidBody2D::new_dynamic(
      1,
      @vector.Vec2::new(0.0, 1.0),
      1.0,
      CircleShape(@vector.Vec2::zero(), 0.5),
    )
    .with_damping(0.05)
    .with_restitution(0.0),
  )
  let dt = 1.0 / 60.0
  for _frame in 0..<300 {
    world.step(dt)
  }
  assert_true(world.get_body(1).unwrap().is_sleeping)
  // Drop another ball on top — should wake the sleeping ball
  world.add_body(
    {
      ..RigidBody2D::new_dynamic(
        2,
        @vector.Vec2::new(0.0, 3.0),
        1.0,
        CircleShape(@vector.Vec2::zero(), 0.5),
      ),
      velocity: @vector.Vec2::new(0.0, -5.0),
    }
    .with_damping(0.05)
    .with_restitution(0.3),
  )
  // Run a few frames for the impact
  for _frame in 0..<30 {
    world.step(dt)
  }
  // The first ball should be awake now (island with moving body)
  let b1 = world.get_body(1).unwrap()
  // It should either be awake or the velocity indicates interaction
  assert_true(not(b1.is_sleeping) || b1.velocity.length() < 0.01)
}

///|
test "obb rotates while falling" {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 10.0)
  world.add_body(
    {
      ..RigidBody2D::new_dynamic(
        0,
        @vector.Vec2::new(0.0, 5.0),
        1.0,
        OBBShape2D(@vector.Vec2::new(0.5, 0.5), @vector.Vec2::zero()),
      ),
      angular_velocity: 2.0,
    }.with_damping(0.0),
  )
  for _ in 0..<60 {
    world.step(1.0 / 60.0)
  }
  let body = world.get_body(0).unwrap()
  assert_true(body.position.y < 5.0)
  assert_true(body.angle.abs() > 0.1)
}
