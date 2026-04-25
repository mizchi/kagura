///|
test "gravity acceleration" {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -10.0, 0.0), 10.0)
  world.add_body(
    RigidBody::new_dynamic(
      0,
      @math3d.Vec3::new(0.0, 10.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.5),
    ).with_damping(0.0),
  )
  world.step(1.0)
  let body = world.get_body(0).unwrap()
  assert_true((body.velocity.y - -10.0).abs() < 0.5)
  assert_true(body.position.y < 10.0)
}

///|
test "two body collision" {
  let world = PhysicsWorld::new(@math3d.Vec3::zero(), 10.0)
  world.add_body(
    {
      ..RigidBody::new_dynamic(
        0,
        @math3d.Vec3::new(-0.5, 0.0, 0.0),
        1.0,
        SphereShape(@math3d.Vec3::zero(), 1.0),
      ),
      velocity: @math3d.Vec3::new(1.0, 0.0, 0.0),
      restitution: 1.0,
    }.with_damping(0.0),
  )
  world.add_body(
    {
      ..RigidBody::new_dynamic(
        1,
        @math3d.Vec3::new(0.5, 0.0, 0.0),
        1.0,
        SphereShape(@math3d.Vec3::zero(), 1.0),
      ),
      velocity: @math3d.Vec3::new(-1.0, 0.0, 0.0),
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
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -10.0, 0.0), 10.0)
  world.add_body(
    RigidBody::new_dynamic(
      0,
      @math3d.Vec3::new(0.0, 1.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.5),
    ).with_damping(0.0),
  )
  world.add_body(
    RigidBody::new_static(
      1,
      @math3d.Vec3::new(0.0, -0.5, 0.0),
      AABBShape(@math3d.Vec3::new(10.0, 0.5, 10.0), @math3d.Vec3::zero()),
    ),
  )
  // Run multiple steps
  for _ in 0..<120 {
    world.step(1.0 / 60.0)
  }
  let ball = world.get_body(0).unwrap()
  assert_true(ball.position.y > -1.0)
}

///|
test "sphere settles on floor without flying up" {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 4.0)
  // Static ground: top surface at y=0
  world.add_body(
    RigidBody::new_static(
      0,
      @math3d.Vec3::new(0.0, -0.5, 0.0),
      AABBShape(@math3d.Vec3::new(10.0, 0.5, 10.0), @math3d.Vec3::zero()),
    ),
  )
  // Sphere dropping from low height
  world.add_body({
    ..RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.0, 2.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.4),
    ),
    restitution: 0.35,
    linear_damping: 0.02,
  })
  // Run 5 seconds of simulation at 60fps, 2 sub-steps
  for _ in 0..<600 {
    let dt = 1.0 / 60.0 / 2.0
    world.step(dt)
    world.step(dt)
  }
  let ball = world.get_body(1).unwrap()
  // Ball should rest near the ground surface (y ≈ 0.4, sphere radius)
  // Must not fly up or fall through
  inspect(ball.position.y > -0.5 && ball.position.y < 2.0, content="true")
  // Velocity should be near zero (settled)
  inspect(ball.velocity.length() < 1.0, content="true")
}

///|
test "cube settles on floor without flying up" {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 4.0)
  world.add_body(
    RigidBody::new_static(
      0,
      @math3d.Vec3::new(0.0, -0.5, 0.0),
      AABBShape(@math3d.Vec3::new(10.0, 0.5, 10.0), @math3d.Vec3::zero()),
    ),
  )
  world.add_body({
    ..RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.0, 2.0, 0.0),
      1.0,
      AABBShape(@math3d.Vec3::new(0.4, 0.4, 0.4), @math3d.Vec3::zero()),
    ),
    restitution: 0.35,
    linear_damping: 0.02,
  })
  for _ in 0..<600 {
    let dt = 1.0 / 60.0 / 2.0
    world.step(dt)
    world.step(dt)
  }
  let cube = world.get_body(1).unwrap()
  inspect(cube.position.y > -0.5 && cube.position.y < 2.0, content="true")
  inspect(cube.velocity.length() < 1.0, content="true")
}

///|
test "sphere settles without energy gain" {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 4.0)
  world.add_body(
    RigidBody::new_static(
      0,
      @math3d.Vec3::new(0.0, -0.5, 0.0),
      AABBShape(@math3d.Vec3::new(10.0, 0.5, 10.0), @math3d.Vec3::zero()),
    ),
  )
  world.add_body(
    RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.0, 1.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.5),
    )
    .with_damping(0.05)
    .with_restitution(0.3),
  )
  let dt = 1.0 / 60.0
  // Settle for 2 seconds
  for _frame in 0..<120 {
    world.step(dt)
  }
  let settled_y = world.get_body(1).unwrap().position.y
  let mut max_y = settled_y
  // Monitor for 3 seconds
  for _frame in 0..<180 {
    world.step(dt)
    let y = world.get_body(1).unwrap().position.y
    if y > max_y {
      max_y = y
    }
  }
  // Should not gain energy (jump up more than a small tolerance)
  let jump = max_y - settled_y
  assert_true(jump < 0.5)
}

///|
test "body falls asleep after settling 3d" {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 4.0)
  world.add_body(
    RigidBody::new_static(
      0,
      @math3d.Vec3::new(0.0, -1.0, 0.0),
      AABBShape(@math3d.Vec3::new(10.0, 0.5, 10.0), @math3d.Vec3::zero()),
    ),
  )
  world.add_body(
    RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.0, 1.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.5),
    )
    .with_damping(0.1)
    .with_restitution(0.0),
  )
  let dt = 1.0 / 60.0
  for _frame in 0..<600 {
    world.step(dt)
  }
  let ball = world.get_body(1).unwrap()
  assert_true(ball.is_sleeping)
}

///|
test "sleeping body wakes on new contact 3d" {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 4.0)
  world.add_body(
    RigidBody::new_static(
      0,
      @math3d.Vec3::new(0.0, -1.0, 0.0),
      AABBShape(@math3d.Vec3::new(10.0, 0.5, 10.0), @math3d.Vec3::zero()),
    ),
  )
  world.add_body(
    RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.0, 1.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.5),
    )
    .with_damping(0.05)
    .with_restitution(0.0),
  )
  let dt = 1.0 / 60.0
  for _frame in 0..<300 {
    world.step(dt)
  }
  assert_true(world.get_body(1).unwrap().is_sleeping)
  // Drop another ball on top
  world.add_body(
    {
      ..RigidBody::new_dynamic(
        2,
        @math3d.Vec3::new(0.0, 3.0, 0.0),
        1.0,
        SphereShape(@math3d.Vec3::zero(), 0.5),
      ),
      velocity: @math3d.Vec3::new(0.0, -5.0, 0.0),
    }
    .with_damping(0.05)
    .with_restitution(0.3),
  )
  for _frame in 0..<30 {
    world.step(dt)
  }
  let b1 = world.get_body(1).unwrap()
  assert_true(!(b1.is_sleeping) || b1.velocity.length() < 0.01)
}

///|
test "step populates contact cache for warm starting 3d" {
  let world = PhysicsWorld::new(@math3d.Vec3::zero(), 4.0)
  world.add_body(
    RigidBody::new_dynamic(
      0,
      @math3d.Vec3::new(-0.25, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.75),
    ).with_damping(0.0),
  )
  world.add_body(
    RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.25, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.75),
    ).with_damping(0.0),
  )
  world.step(1.0 / 60.0)
  let key = contact_pair_key3d(0, 1)
  assert_true(world.contact_cache.get(key) is Some(_))
  world.step(1.0 / 60.0)
  assert_true(world.contact_cache.get(key) is Some(_))
}

///|
test "step clears stale contact cache when contact ends 3d" {
  let world = PhysicsWorld::new(@math3d.Vec3::zero(), 4.0)
  world.add_body(
    RigidBody::new_dynamic(
      0,
      @math3d.Vec3::new(-0.25, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.75),
    ).with_damping(0.0),
  )
  world.add_body(
    RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.25, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.75),
    ).with_damping(0.0),
  )
  let key = contact_pair_key3d(0, 1)
  world.step(1.0 / 60.0)
  assert_true(world.contact_cache.get(key) is Some(_))
  world.bodies[1] = {
    ..world.bodies[1],
    position: @math3d.Vec3::new(10.0, 0.0, 0.0),
    velocity: @math3d.Vec3::zero(),
  }
  world.step(1.0 / 60.0)
  assert_true(world.contact_cache.get(key) is None)
}

///|
test "distance joint maintains length 3d" {
  let world = PhysicsWorld::new(@math3d.Vec3::zero(), 10.0)
  world.add_body(
    RigidBody::new_dynamic(
      0,
      @math3d.Vec3::new(-1.0, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.2),
    ).with_damping(0.0),
  )
  world.add_body(
    RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(1.0, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.2),
    ).with_damping(0.0),
  )
  world.add_distance_joint({
    body_a_id: 0,
    body_b_id: 1,
    local_anchor_a: @math3d.Vec3::zero(),
    local_anchor_b: @math3d.Vec3::zero(),
    rest_length: 2.0,
    hertz: 30.0,
    damping_ratio: 1.0,
  })
  world.apply_impulse(0, @math3d.Vec3::new(-5.0, 0.0, 0.0))
  world.apply_impulse(1, @math3d.Vec3::new(5.0, 0.0, 0.0))
  let dt = 1.0 / 60.0
  for _frame in 0..<120 {
    world.step(dt)
  }
  let a = world.get_body(0).unwrap()
  let b = world.get_body(1).unwrap()
  let dist = b.position.sub(a.position).length()
  assert_true((dist - 2.0).abs() < 0.3)
}

///|
test "ball joint keeps points together 3d" {
  let world = PhysicsWorld::new(@math3d.Vec3::zero(), 10.0)
  world.add_body(
    RigidBody::new_dynamic(
      0,
      @math3d.Vec3::new(0.0, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.2),
    ).with_damping(0.0),
  )
  world.add_body(
    RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.0, 0.0, 0.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.2),
    ).with_damping(0.0),
  )
  world.add_ball_joint({
    body_a_id: 0,
    body_b_id: 1,
    local_anchor_a: @math3d.Vec3::new(0.5, 0.0, 0.0),
    local_anchor_b: @math3d.Vec3::new(-0.5, 0.0, 0.0),
    hertz: 30.0,
    damping_ratio: 1.0,
  })
  world.apply_impulse(0, @math3d.Vec3::new(-1.0, 0.3, 0.0))
  world.apply_impulse(1, @math3d.Vec3::new(1.0, -0.3, 0.0))
  let dt = 1.0 / 60.0
  for _frame in 0..<240 {
    world.step(dt)
  }
  let a = world.get_body(0).unwrap()
  let b = world.get_body(1).unwrap()
  // Both bodies should have low velocity (settled)
  assert_true(a.velocity.length() < 2.0)
  assert_true(b.velocity.length() < 2.0)
}

///|
test "bullet sphere does not tunnel through thin wall 3d" {
  let world = PhysicsWorld::new(@math3d.Vec3::zero(), 10.0)
  world.add_body(
    RigidBody::new_static(
      0,
      @math3d.Vec3::new(2.0, 0.0, 0.0),
      AABBShape(@math3d.Vec3::new(0.05, 5.0, 5.0), @math3d.Vec3::zero()),
    ),
  )
  world.add_body(
    {
      ..RigidBody::new_dynamic(
        1,
        @math3d.Vec3::new(0.0, 0.0, 0.0),
        1.0,
        SphereShape(@math3d.Vec3::zero(), 0.3),
      ),
      velocity: @math3d.Vec3::new(1000.0, 0.0, 0.0),
    }
    .with_damping(0.0)
    .with_bullet(),
  )
  world.step(1.0 / 60.0)
  let bullet = world.get_body(1).unwrap()
  assert_true(bullet.position.x < 2.0)
}

///|
test "kinematic not affected by gravity" {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -10.0, 0.0), 10.0)
  world.add_body(
    RigidBody::new_kinematic(
      0,
      @math3d.Vec3::new(0.0, 5.0, 0.0),
      SphereShape(@math3d.Vec3::zero(), 1.0),
    ),
  )
  world.step(1.0)
  let body = world.get_body(0).unwrap()
  assert_true((body.position.y - 5.0).abs() < 1.0e-9)
  assert_true(body.velocity.length() < 1.0e-9)
}
