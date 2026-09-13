///|
test "physical Q rotates camera right and E rotates left in both views" {
  let camera = @camera3d.OrbitCamera::default().with_distance(8.0)
  for tps in [false, true] {
    let q = hunter_camera_input(
      camera,
      @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [81]),
      0.0,
      0.0,
      false,
      1.0,
      1.0,
      tps~,
    )
    let e = hunter_camera_input(
      camera,
      @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [69]),
      0.0,
      0.0,
      false,
      1.0,
      1.0,
      tps~,
    )
    assert_true(q.yaw > camera.yaw)
    assert_true(e.yaw < camera.yaw)
    let both = hunter_camera_input(
      camera,
      @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [81, 69]),
      0.0,
      0.0,
      false,
      1.0,
      1.0,
      tps~,
    )
    assert_eq(both.yaw, camera.yaw)
  }
}

///|
test "camera presets retain independent framing and reject invalid preferences" {
  let s = aim_test_state()
  assert_true(s.apply_camera_command([1.0, 58.0]))
  assert_true(s.apply_camera_command([3.0, -0.8]))
  assert_true(s.apply_camera_command([0.0, 1.0]))
  assert_eq(s.camera_settings.active().distance, 4.5)
  assert_true(s.apply_camera_command([1.0, 16.0]))
  assert_true(s.apply_camera_command([0.0, 0.0]))
  assert_eq(s.camera_settings.active().tilt, 58.0)
  assert_eq(s.camera_settings.active().side, -0.8)
  let saved = s.camera_settings.serialize()
  let restored = HunterCameraSettings::new()
  assert_true(restored.restore(saved))
  assert_eq(restored.serialize(), saved)
  assert_false(restored.restore("{\"version\":9}"))
  assert_eq(restored.serialize(), saved)
  assert_false(s.apply_camera_command([1.0]))
  assert_false(s.apply_camera_command([9.0, 1.0]))
  assert_true(s.apply_camera_command([1.0, 200.0]))
  assert_eq(s.camera_settings.active().tilt, 80.0)
}

///|
test "camera framing is relative to the camera and TPS focus cannot drift with the pointer" {
  let s = aim_test_state()
  ignore(s.apply_camera_command([0.0, 1.0]))
  ignore(s.apply_camera_command([3.0, 0.7]))
  s.camera = s.camera.orbit(0.5, 0.0)
  s.aim.pointer = Some((0.1, 0.1))
  s.update_combat_camera()
  let target = s.camera.target
  let angle = s.pointer_aim_angle().unwrap()
  s.aim.pointer = Some((0.9, 0.9))
  for _ in 0..<60 {
    s.update_combat_camera()
  }
  assert_true(s.camera.target.sub(target).length() < 0.0001)
  assert_true((s.pointer_aim_angle().unwrap() - angle).abs() < 0.0001)
  let dx = target.x - s.world.player.x / tile_size
  let dz = target.z - s.world.player.y / tile_size
  assert_true(
    (dx * @math.cos(s.camera.yaw) - dz * @math.sin(s.camera.yaw) - 0.7).abs() <
    0.001,
  )
  s.aim.pointer = None
  assert_true(s.pointer_aim_angle() is None)
}

///|
test "TPS camera retracts before a wall and restores requested distance after leaving" {
  let s = aim_test_state()
  ignore(s.apply_camera_command([0.0, 1.0]))
  ignore(s.apply_camera_command([3.0, 0.0]))
  ignore(s.apply_camera_command([5.0, 0.0]))
  s.camera = s.camera.orbit(-s.camera.yaw, 0.0)
  for x in 2..<14 {
    s.world.dungeon.grid.set(x, 9, @terrain.Wall)
  }
  s.update_combat_camera()
  assert_true(s.camera.position().z < 8.9)
  assert_eq(s.camera_settings.active().distance, 4.5)
  for x in 2..<14 {
    s.world.dungeon.grid.set(x, 9, @terrain.Floor)
  }
  s.update_combat_camera()
  assert_eq(s.camera.distance, 4.5)
}

///|
test "camera editor previews while simulation is paused and Escape returns to pause" {
  let s = aim_test_state()
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [79]))
  assert_true(s.paused)
  assert_true(s.camera_settings.editing)
  let frame = s.world.frame_count
  let x = s.world.player.x
  ignore(s.apply_camera_command([0.0, 1.0]))
  ignore(s.apply_camera_command([1.0, 25.0]))
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [87, 90, 74]))
  assert_eq(s.world.frame_count, frame)
  assert_eq(s.world.player.x, x)
  assert_eq(s.camera_settings.mode, 1)
  assert_true((s.camera.pitch - 25.0 * @math.PI / 180.0).abs() < 0.001)
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_true(s.paused)
  assert_false(s.camera_settings.editing)
  s.update(@core.empty_input_snapshot())
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_false(s.paused)
}
