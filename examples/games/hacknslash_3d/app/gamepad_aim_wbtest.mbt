///|
test "right stick aim is camera relative and independent of movement or mouse position" {
  let s = aim_test_state()
  s.aim.stick = Some((1.0, 0.0))
  s.camera = s.camera.orbit(0.7 - s.camera.yaw, 0.0)
  let angle = s.pointer_aim_angle().unwrap()
  assert_true((angle + 0.7).abs() < 0.00001)
  s.world.player.facing_angle = 2.0
  assert_eq(s.pointer_aim_angle().unwrap(), angle)
  for _ in 0..<30 {
    s.update_combat_camera()
  }
  assert_true(s.combat_feedback.look_x > 0.0)
  assert_true(s.combat_feedback.look_y < 0.0)
  s.aim.stick = None
  assert_true(s.pointer_aim_angle() is None)
}

///|
test "TPS gamepad aim uses the reticle regardless of right stick direction" {
  let s = aim_test_state()
  ignore(s.apply_camera_command([0.0, 1.0]))
  s.aim.stick = Some((1.0, 0.0))
  let angle = s.pointer_aim_angle().unwrap()
  s.aim.stick = Some((-0.7, 0.2))
  assert_eq(s.pointer_aim_angle().unwrap(), angle)
  assert_true(s.hunter_camera_view().crosshair)
}
