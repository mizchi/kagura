///|
test "boxes remain on a thin floor away from the floor center" {
  for x in [-6.0, -3.0, 0.0, 3.0, 6.0] {
    let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.81, 0.0), 2.0)
    world.add_body(
      RigidBody::new_static(
        0,
        @math3d.Vec3::new(0.0, -0.125, 0.0),
        AABBShape(@math3d.Vec3::new(9.0, 0.125, 9.0), @math3d.Vec3::zero()),
      ),
    )
    world.add_body(
      RigidBody::new_dynamic(
        1,
        @math3d.Vec3::new(x, 0.5, -2.0),
        1.0,
        AABBShape(@math3d.Vec3::new(0.5, 0.5, 0.5), @math3d.Vec3::zero()),
      )
      .with_restitution(0.08)
      .with_friction(0.55),
    )
    for frame in 0..<600 {
      if frame == 120 {
        world.apply_impulse(1, @math3d.Vec3::new(0.0, -12.0, 0.0))
      }
      world.step(1.0 / 60.0)
      let body = world.get_body(1).unwrap()
      assert_true(
        body.position.y >= 0.43,
        msg="box x=\{x} frame=\{frame} y=\{body.position.y}",
      )
    }
  }
}

///|
test "fast boxes cannot tunnel through a thin floor" {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.81, 0.0), 2.0)
  world.add_body(
    RigidBody::new_static(
      0,
      @math3d.Vec3::new(0.0, -0.125, 0.0),
      AABBShape(@math3d.Vec3::new(9.0, 0.125, 9.0), @math3d.Vec3::zero()),
    ),
  )
  world.add_body({
    ..RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(3.0, 1.2, -2.0),
      1.0,
      AABBShape(@math3d.Vec3::new(0.5, 0.5, 0.5), @math3d.Vec3::zero()),
    ),
    velocity: @math3d.Vec3::new(0.0, -150.0, 0.0),
  })
  for _ in 0..<60 {
    world.step(1.0 / 60.0)
  }
  assert_true(world.get_body(1).unwrap().position.y >= 0.43)
}

///|
test "fast spheres and boxes stop at thin walls without sticking to parallel motion" {
  for
    shape in [
      SphereShape(@math3d.Vec3::zero(), 0.4),
      AABBShape(@math3d.Vec3::new(0.4, 0.4, 0.4), @math3d.Vec3::zero()),
    ] {
    let world = PhysicsWorld::new(@math3d.Vec3::zero(), 2.0)
    world.add_body(
      RigidBody::new_static(
        0,
        @math3d.Vec3::zero(),
        AABBShape(@math3d.Vec3::new(0.05, 5.0, 5.0), @math3d.Vec3::zero()),
      ).with_restitution(0.0),
    )
    world.add_body({
      ..RigidBody::new_dynamic(1, @math3d.Vec3::new(-1.0, 0.0, 0.0), 1.0, shape).with_restitution(
        0.0,
      ),
      velocity: @math3d.Vec3::new(200.0, 0.0, 0.0),
    })
    for _ in 0..<30 {
      world.step(1.0 / 60.0)
      assert_true(world.get_body(1).unwrap().position.x <= -0.44)
    }
    // Moving tangentially after impact must remain free.
    world.apply_impulse(1, @math3d.Vec3::new(0.0, 0.0, 20.0))
    for _ in 0..<6 {
      world.step(1.0 / 60.0)
    }
    assert_true(world.get_body(1).unwrap().position.z > 1.0)
  }
}

///|
test "swept collision catches a fast sphere against a tilted thin box" {
  let world = PhysicsWorld::new(@math3d.Vec3::zero(), 2.0)
  let rotation = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_x(),
    0.5,
  )
  let normal = rotation.rotate_vec3(@math3d.Vec3::unit_y())
  world.add_body({
    ..RigidBody::new_static(
      0,
      @math3d.Vec3::zero(),
      BoxShape(@math3d.Vec3::new(3.0, 0.05, 3.0), @math3d.Vec3::zero()),
    ).with_restitution(0.0),
    rotation,
  })
  world.add_body({
    ..RigidBody::new_dynamic(
      1,
      normal.scale(1.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.4),
    ).with_restitution(0.0),
    velocity: normal.scale(-200.0),
  })
  world.step(1.0 / 60.0)
  let ball = world.get_body(1).unwrap()
  assert_true(ball.position.dot(normal) >= 0.44)
  assert_true(ball.velocity.dot(normal).abs() < 0.01)
}

///|
test "axis aligned boxes cannot store angular impulses without rotating their collider" {
  let floor = RigidBody::new_static(
    0,
    @math3d.Vec3::zero(),
    AABBShape(@math3d.Vec3::new(10.0, 0.1, 10.0), @math3d.Vec3::zero()),
  )
  let box = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::new(3.0, 0.59, 0.0),
    1.0,
    AABBShape(@math3d.Vec3::new(0.5, 0.5, 0.5), @math3d.Vec3::zero()),
  )
  assert_eq(box.inv_inertia, 0.0)
  let falling = { ..box, velocity: @math3d.Vec3::new(2.0, -3.0, 0.0), }
  let (_, stopped) = resolve_velocity3d(
    floor,
    falling,
    generate_contact(floor, falling).unwrap(),
  )
  assert_eq(stopped.angular_velocity.length(), 0.0)
  assert_true(stopped.velocity.y >= 0.0)
}
