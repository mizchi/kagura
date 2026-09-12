///|
test "PlayerCharacter::compute_skinning caches unchanged pose" {
  let character = PlayerCharacter::new()
  let first = character.compute_skinning()
  let second = character.compute_skinning()
  assert_eq(first.length(), char_num_bones)
  assert_eq(second.length(), char_num_bones)
  assert_eq(character.skinning_cache_builds, 1)
}

///|
test "PlayerCharacter::update invalidates skinning cache" {
  let character = PlayerCharacter::new()
  let _ = character.compute_skinning()
  let _ = character.compute_skinning()
  assert_eq(character.skinning_cache_builds, 1)

  character.update(1.0 / 60.0)
  let _ = character.compute_skinning()
  assert_eq(character.skinning_cache_builds, 2)
}

///|
test "hunter silhouette is two heads tall with a wide brim and grounded boots" {
  let parts = build_hunter_parts()
  let mut min_y = 100.0
  let mut max_y = -100.0
  let mut hat_width = 0.0
  let mut triangles = 0
  for part in parts {
    triangles += part.mesh.indices.length() / 3
    for i in 0..<part.skin.vertex_count {
      let y = part.mesh.vertex_data[i * 8 + 1]
      if part.name != "weapon" {
        min_y = @cmp.minimum(min_y, y)
        max_y = @cmp.maximum(max_y, y)
      }
      if part.name == "hat" {
        hat_width = @cmp.maximum(
          hat_width,
          part.mesh.vertex_data[i * 8].abs() * 2.0,
        )
      }
      assert_true(part.skin.joint_indices[i * 4] < char_num_bones)
      assert_eq(part.skin.weights[i * 4], 1.0)
    }
  }
  assert_true(min_y.abs() < 0.0001)
  assert_true(((max_y - min_y) / hunter_head_height - 2.0).abs() < 0.01)
  assert_true(hat_width > 1.0)
  assert_true(triangles > 300 && triangles < 3000)
}

///|
test "hunter keeps running legs during an attack and returns to running" {
  let character = PlayerCharacter::new()
  character.set_moving(true)
  character.update(0.05)
  let before = character.compute_skinning()[8]
  character.trigger_attack()
  character.update(0.08)
  let after = character.compute_skinning()[8]
  assert_true(!before.approx_eq(after, 0.0001))
  assert_eq(character.anim_state, Attacking)
  character.update(0.5)
  assert_eq(character.anim_state, Running)
}

///|
test "hunter locomotion loops and dodge recovers without leaving a rotated root" {
  let character = PlayerCharacter::new()
  character.set_moving(true)
  character.update(0.1)
  let pose = character.compute_skinning()[8]
  character.update(run_anim_duration)
  assert_true(pose.approx_eq(character.compute_skinning()[8], 0.0001))
  character.trigger_dodge()
  character.update(0.1)
  assert_eq(character.anim_state, Dodging)
  character.update(0.5)
  assert_eq(character.anim_state, Running)
  character.set_moving(false)
  character.update(0.1)
  assert_eq(character.anim_state, Idle)
  assert_true(
    character.compute_skinning()[0].approx_eq(@math3d.Mat4::identity(), 0.0001),
  )
}

///|
test "hunter camera drag starts without a jump, zoom clamps, reset restores quarter view" {
  let camera = @camera3d.OrbitCamera::default().with_distance(18.0)
  let drag = @core.new_input_snapshot_full(
    100.0,
    60.0,
    0.0,
    -10000.0,
    [],
    [2],
    [],
    [],
  )
  let first = hunter_camera_input(camera, drag, 0.0, 0.0, false, 1.0, 1.0)
  assert_eq(first.yaw, camera.yaw)
  assert_eq(first.distance, 8.0)
  let second = hunter_camera_input(first, drag, 80.0, 60.0, true, 1.0, 1.0)
  assert_true(second.yaw > first.yaw)
  let reset = hunter_camera_input(
    second,
    @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [82]),
    0.0,
    0.0,
    false,
    1.0,
    1.0,
  )
  assert_eq(reset.distance, 18.0)
  assert_eq(reset.pitch, 0.78)
}
