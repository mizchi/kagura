///|
test "zombie shambles with dropped shoulders and an asymmetric dragging leg" {
  let start = zombie_pose(1, 0.0)
  let end = zombie_pose(1, 1.0)
  let step = zombie_pose(1, 0.25)
  for i in 0..<enemy_bone_count {
    assert_true(start[i].to_mat4().approx_eq(end[i].to_mat4(), 0.00001))
  }
  assert_true(start[2].rotation.x > 0.15)
  assert_true(
    start[3].position.y <
    shared_enemy_skeleton.bones[3].local_transform.position.y,
  )
  assert_true(
    start[5].position.y <
    shared_enemy_skeleton.bones[5].local_transform.position.y,
  )
  let left = (step[7].rotation.x - start[7].rotation.x).abs()
  let right = (step[9].rotation.x - start[9].rotation.x).abs()
  assert_true(left > right * 2.0)
  assert_eq(step[0].position.z, 0.0)
}

///|
test "zombie raises both hands before takeoff and lands at the damage frame" {
  let total = (@game.zombie_pounce_anticipation +
  @game.zombie_pounce_flight +
  @game.zombie_pounce_recovery).to_double()
  let raised = zombie_pose(
    2,
    @game.zombie_pounce_anticipation.to_double() / total,
  )
  let world = shared_enemy_skeleton.compute_world_transforms(raised)
  for hand in [4, 6] {
    assert_true(
      world[hand].mul_vec4(@math3d.Vec4::new(0.0, -0.17, 0.05, 1.0)).y >
      world[2].mul_vec4(@math3d.Vec4::new(0.0, 0.0, 0.0, 1.0)).y + 0.20,
    )
  }
  let air = zombie_pose(
    2,
    (
      @game.zombie_pounce_anticipation.to_double() +
      @game.zombie_pounce_flight.to_double() * 0.5
    ) /
    total,
  )
  assert_true(air[0].position.y > 0.4)
  let contact = zombie_pose(
    2,
    @game.Pounce.melee_profile().unwrap().windup.to_double() / total,
  )
  assert_true(contact[0].position.y.abs() < 0.001)
  let end = zombie_pose(2, 1.0)
  let idle = zombie_pose(0, 0.0)
  for i in 0..<enemy_bone_count {
    assert_true(end[i].to_mat4().approx_eq(idle[i].to_mat4(), 0.001))
  }
}

///|
test "zombie poses batch without CPU skinning and clear inactive instances" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  state.world.enemies.clear()
  for _ in 0..<40 {
    let zombie = @game.make_enemy(
      state.world.player.x,
      state.world.player.y - 32.0,
      @game.Zombie,
      100,
      0.6,
      11.0,
    )
    zombie.move_speed = 0.3
    zombie.travel_distance = 4.0
    state.world.enemies.push(zombie)
  }
  let commands = state.draw_playing(test_engine_context())
  assert_eq(state.enemy_models.zombie.active_keys.length(), 1)
  let groups = commands.filter(c => {
    c.shader.id == state.shader3d_skinned_instanced_monochrome.id &&
    c.instance_count == 40
  })
  assert_eq(groups.length(), zombie_mesh.parts.length())
  for part in zombie_mesh.parts {
    assert_eq(part.geometry.cpu_skin_count(), 0)
    for joint in part.geometry.skin_data.joint_indices {
      assert_true(joint >= 0 && joint < enemy_bone_count)
    }
  }
  assert_true(zombie_mesh.geometry.bind_mesh.vertex_count() < 5000)
  state.world.enemies.clear()
  ignore(state.draw_playing(test_engine_context()))
  assert_eq(state.enemy_models.zombie.active_keys.length(), 0)
}
