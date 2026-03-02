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
  world.add_body(
    {
      ..RigidBody::new_dynamic(
        1,
        @math3d.Vec3::new(0.0, 2.0, 0.0),
        1.0,
        SphereShape(@math3d.Vec3::zero(), 0.4),
      ),
      restitution: 0.35,
      linear_damping: 0.02,
    },
  )
  // Run 5 seconds of simulation at 60fps, 2 sub-steps
  for _ in 0..<600 {
    let dt = 1.0 / 60.0 / 2.0
    world.step(dt)
    world.step(dt)
  }
  let ball = world.get_body(1).unwrap()
  // Ball should rest near the ground surface (y ≈ 0.4, sphere radius)
  // Must not fly up or fall through
  inspect!(
    ball.position.y > -0.5 && ball.position.y < 2.0,
    content="true",
  )
  // Velocity should be near zero (settled)
  inspect!(ball.velocity.length() < 1.0, content="true")
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
  world.add_body(
    {
      ..RigidBody::new_dynamic(
        1,
        @math3d.Vec3::new(0.0, 2.0, 0.0),
        1.0,
        AABBShape(@math3d.Vec3::new(0.4, 0.4, 0.4), @math3d.Vec3::zero()),
      ),
      restitution: 0.35,
      linear_damping: 0.02,
    },
  )
  for _ in 0..<600 {
    let dt = 1.0 / 60.0 / 2.0
    world.step(dt)
    world.step(dt)
  }
  let cube = world.get_body(1).unwrap()
  inspect!(
    cube.position.y > -0.5 && cube.position.y < 2.0,
    content="true",
  )
  inspect!(cube.velocity.length() < 1.0, content="true")
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
