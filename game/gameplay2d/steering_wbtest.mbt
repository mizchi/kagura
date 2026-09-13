///|
test "homing turns at a bounded rate without changing projectile speed" {
  let (vx, vy) = turn_velocity_towards(3.0, 4.0, -10.0, 20.0, 0.1)
  assert_true((vx * vx + vy * vy - 25.0).abs() < 0.000001)
  assert_true(vx < 3.0 && vy > 4.0)
  assert_true((vx - 2.58567883).abs() < 0.000001)
  // No overshoot when already close to the target direction.
  let (x, y) = turn_velocity_towards(5.0, 0.0, 10.0, 0.1, 0.1)
  assert_true((y / x - 0.01).abs() < 0.000001)
}

///|
test "homing wraps the angle boundary and turns away from an exactly opposite heading" {
  let (x, y) = turn_velocity_towards(-3.0, -0.001, -10.0, 0.01, 0.1)
  assert_true(x < 0.0 && y > 0.0)
  assert_true((y / x + 0.001).abs() < 0.000001)
  let (x, y) = turn_velocity_towards(3.0, 0.0, -10.0, 0.0, 0.1)
  assert_true(x > 0.0 && y.abs() > 0.29)
}

///|
test "homing leaves stationary projectiles and absent aim unchanged" {
  assert_eq(turn_velocity_towards(0.0, 0.0, 4.0, 3.0, 0.1), (0.0, 0.0))
  assert_eq(turn_velocity_towards(4.0, 3.0, 0.0, 0.0, 0.1), (4.0, 3.0))
  assert_eq(turn_velocity_towards(4.0, 3.0, 2.0, 1.0, 0.0), (4.0, 3.0))
}
