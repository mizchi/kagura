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
