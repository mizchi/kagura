///|
test "sweep_circle_circle hit" {
  let toi = sweep_circle_circle(
    @vector.Vec2::new(0.0, 0.0),
    @vector.Vec2::new(10.0, 0.0),
    0.5,
    @vector.Vec2::new(5.0, 0.0),
    @vector.Vec2::zero(),
    0.5,
  )
  match toi {
    Some(t) => {
      // Should hit around t = 0.4 (distance 5, closing speed 10, combined radius 1)
      assert_true(t > 0.3)
      assert_true(t < 0.5)
    }
    None => assert_true(false) // should not miss
  }
}

///|
test "sweep_circle_circle miss" {
  let toi = sweep_circle_circle(
    @vector.Vec2::new(0.0, 0.0),
    @vector.Vec2::new(10.0, 0.0),
    0.5,
    @vector.Vec2::new(0.0, 5.0), // far away on Y axis
    @vector.Vec2::zero(),
    0.5,
  )
  assert_true(toi is None)
}

///|
test "sweep_circle_circle already overlapping" {
  let toi = sweep_circle_circle(
    @vector.Vec2::new(0.0, 0.0),
    @vector.Vec2::new(1.0, 0.0),
    1.0,
    @vector.Vec2::new(0.5, 0.0),
    @vector.Vec2::zero(),
    1.0,
  )
  match toi {
    Some(t) => assert_true(t == 0.0) // already overlapping
    None => assert_true(false)
  }
}

///|
test "sweep_circle_aabb hit" {
  // Circle moving right toward a box
  let toi = sweep_circle_aabb(
    @vector.Vec2::new(-5.0, 0.0),
    @vector.Vec2::new(20.0, 0.0),
    0.5,
    @vector.Vec2::new(-1.0, -1.0), // AABB min
    @vector.Vec2::new(1.0, 1.0), // AABB max
  )
  match toi {
    Some(t) => {
      assert_true(t > 0.1)
      assert_true(t < 0.5)
    }
    None => assert_true(false)
  }
}

///|
test "bullet circle does not tunnel through thin wall" {
  let world = PhysicsWorld2D::new(@vector.Vec2::zero(), 10.0)
  // Thin static wall very close to bullet
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(2.0, 0.0),
      AABBShape2D(@vector.Vec2::new(0.05, 5.0), @vector.Vec2::zero()),
    ),
  )
  // Fast-moving bullet circle — will try to move ~16.7 units per frame
  world.add_body(
    {
      ..RigidBody2D::new_dynamic(
        1,
        @vector.Vec2::new(0.0, 0.0),
        1.0,
        CircleShape(@vector.Vec2::zero(), 0.3),
      ),
      velocity: @vector.Vec2::new(1000.0, 0.0),
    }.with_damping(0.0).with_bullet(),
  )
  world.step(1.0 / 60.0)
  let bullet = world.get_body(1).unwrap()
  // Bullet should NOT have passed through the wall (x < 2.0)
  assert_true(bullet.position.x < 2.0)
}

///|
test "non-bullet circle tunnels through thin wall" {
  let world = PhysicsWorld2D::new(@vector.Vec2::zero(), 10.0)
  // Same thin wall
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(2.0, 0.0),
      AABBShape2D(@vector.Vec2::new(0.05, 5.0), @vector.Vec2::zero()),
    ),
  )
  // Same fast-moving circle but NOT a bullet (no CCD)
  world.add_body(
    {
      ..RigidBody2D::new_dynamic(
        1,
        @vector.Vec2::new(0.0, 0.0),
        1.0,
        CircleShape(@vector.Vec2::zero(), 0.3),
      ),
      velocity: @vector.Vec2::new(1000.0, 0.0),
    }.with_damping(0.0),
  )
  world.step(1.0 / 60.0)
  let ball = world.get_body(1).unwrap()
  // Without CCD, the ball should have passed through the wall
  // At v=1000, dt=1/60, each substep moves ~4.17 units, wall at x=2
  // The ball jumps over the thin wall in 1 substep
  assert_true(ball.position.x > 2.0)
}
