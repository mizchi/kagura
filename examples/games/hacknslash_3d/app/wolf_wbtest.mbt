///|
test "wolf gaits loop in place and articulate all four legs" {
  for kind in [0, 1] {
    let start = wolf_pose(kind, 0.0)
    let end = wolf_pose(kind, 1.0)
    let middle = wolf_pose(kind, 0.25)
    for i in 0..<15 {
      assert_true(start[i].to_mat4().approx_eq(end[i].to_mat4(), 0.00001))
    }
    for joint in [7, 9, 11, 13] {
      assert_false(
        start[joint].to_mat4().approx_eq(middle[joint].to_mat4(), 0.01),
      )
    }
    assert_eq(middle[0].position.z, 0.0)
  }
  let contact = 34.0 / 64.0
  assert_true(wolf_pose(2, 0.35)[4].rotation.x > 0.2)
  assert_true(wolf_pose(2, contact)[4].rotation.x.abs() < 0.0001)
  assert_true(wolf_pose(2, contact)[0].position.z > 0.2)
}

///|
test "wolf poses instance together without per-enemy CPU skinning" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  state.world.enemies.clear()
  for _ in 0..<40 {
    let wolf = @game.make_enemy(
      state.world.player.x,
      state.world.player.y - 32.0,
      @game.Wolf,
      100,
      1.0,
      11.0,
    )
    wolf.move_speed = 1.0
    wolf.travel_distance = 7.0
    state.world.enemies.push(wolf)
  }
  let commands = state.draw_playing(test_engine_context())
  assert_eq(state.enemy_models.wolf.active_keys.length(), 1)
  let mut groups = 0
  for command in commands {
    if command.shader.id == state.shader3d_skinned_instanced_monochrome.id &&
      command.instance_count == 40 {
      groups += 1
    }
  }
  assert_eq(groups, wolf_mesh.parts.length())
  for part in wolf_mesh.parts {
    assert_eq(part.geometry.cpu_skin_count(), 0)
    for joint in part.geometry.skin_data.joint_indices {
      assert_true(joint >= 0 && joint < 15)
    }
  }
  assert_true(wolf_mesh.geometry.bind_mesh.indices.length() / 3 < 3000)
  state.world.enemies.clear()
  ignore(state.draw_playing(test_engine_context()))
  assert_eq(state.enemy_models.wolf.active_keys.length(), 0)
}
