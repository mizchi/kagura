///|
fn flat_ground() -> GroundContact {
  {
    body_id: 0,
    normal: @math3d.Vec3::unit_y(),
    velocity: @math3d.Vec3::zero(),
  }
}

///|
test "input counters a knockback with bounded acceleration while idle brakes gently" {
  let config = MotorConfig::default()
  let velocity = @math3d.Vec3::new(8.0, 2.0, 0.0)
  let gravity = @math3d.Vec3::new(0.0, -9.81, 0.0)
  let idle = motor_acceleration(
    config,
    velocity,
    @math3d.Vec3::zero(),
    Some(flat_ground()),
    gravity,
    1.0 / 60.0,
  )
  let counter = motor_acceleration(
    config,
    velocity,
    @math3d.Vec3::new(-1.0, 0.0, 0.0),
    Some(flat_ground()),
    gravity,
    1.0 / 60.0,
  )
  assert_true(idle.x < 0.0)
  assert_true(counter.x < idle.x)
  assert_true(counter.length() <= config.ground_acceleration + 0.0001)
  assert_true(velocity.x + counter.x / 60.0 > 7.0)
  assert_eq(counter.y, 0.0)
}

///|
test "air control preserves vertical momentum and is weaker than ground control" {
  let config = MotorConfig::default()
  let air = motor_acceleration(
    config,
    @math3d.Vec3::new(0.0, -9.0, 0.0),
    @math3d.Vec3::unit_x(),
    None,
    @math3d.Vec3::new(0.0, -9.81, 0.0),
    1.0 / 60.0,
  )
  assert_true(air.x > 0.0 && air.x <= config.air_acceleration)
  assert_true(air.x < config.ground_acceleration)
  assert_eq(air.y, 0.0)
}

///|
test "motor follows a slope and cancels tangential gravity without cancelling a launch" {
  let config = MotorConfig::default()
  let normal = @math3d.Vec3::new(0.0, 0.8, 0.6)
  let support = { ..flat_ground(), normal, }
  let gravity = @math3d.Vec3::new(0.0, -9.81, 0.0)
  let a = motor_acceleration(
    config,
    @math3d.Vec3::zero(),
    @math3d.Vec3::zero(),
    Some(support),
    gravity,
    1.0 / 60.0,
  )
  let net = a.add(gravity).sub(normal.scale(a.add(gravity).dot(normal)))
  assert_true(net.length() < 0.0001)
  assert_true(a.dot(normal).abs() < 0.0001)
  let launch = motor_acceleration(
    config,
    normal.scale(8.0),
    @math3d.Vec3::zero(),
    Some(support),
    gravity,
    1.0 / 60.0,
  )
  assert_true(launch.sub(a).length() < 0.0001)
}

///|
test "motor uses support velocity and converges consistently at different timesteps" {
  let config = MotorConfig::default()
  let support = { ..flat_ground(), velocity: @math3d.Vec3::new(2.0, 0.0, 0.0), }
  let idle = motor_acceleration(
    config,
    support.velocity,
    @math3d.Vec3::zero(),
    Some(support),
    @math3d.Vec3::zero(),
    1.0 / 60.0,
  )
  assert_true(idle.length() < 0.0001)
  for hz in [30, 60, 120] {
    let dt = 1.0 / hz.to_double()
    let mut velocity = @math3d.Vec3::zero()
    for _ in 0..<hz {
      let a = motor_acceleration(
        config,
        velocity,
        @math3d.Vec3::new(1.0, 0.0, 1.0),
        Some(flat_ground()),
        @math3d.Vec3::zero(),
        dt,
      )
      velocity = velocity.add(a.scale(dt))
      assert_true(velocity.length() <= config.speed + 0.0001)
    }
    assert_true((velocity.length() - config.speed).abs() < 0.02)
    assert_true((velocity.x - velocity.z).abs() < 0.0001)
  }
}
