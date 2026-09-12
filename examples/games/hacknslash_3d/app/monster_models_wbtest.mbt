///|
test "bestiary models have readable species silhouettes and independently skinned materials" {
  let models = EnemyModels::new()
  assert_eq(enemy_bone_count, 12)
  for kind in [@game.Basic, @game.Fast, @game.Ranged] {
    let data = models.get_mesh_data(kind)
    assert_true(data.parts.length() >= 4)
    assert_true(data.geometry.bind_mesh.vertex_count() > 300)
    assert_true(data.geometry.bind_mesh.vertex_count() < 5000)
    for part in data.parts {
      assert_eq(
        part.geometry.skin_data.vertex_count,
        part.geometry.bind_mesh.vertex_count(),
      )
      assert_eq(
        part.geometry.skin_data.weights.length(),
        part.geometry.bind_mesh.vertex_count() * 4,
      )
      for joint in part.geometry.skin_data.joint_indices {
        assert_true(joint >= 0 && joint < 12)
      }
    }
  }
  let goblin = models.basic.geometry.bind_mesh.vertex_data
  let kobold = models.fast.geometry.bind_mesh.vertex_data
  let mut ear_span = 0.0
  let mut tail_reach = 0.0
  let mut muzzle_reach = 0.0
  for i in 0..<(goblin.length() / 8) {
    if goblin[i * 8 + 1] > 0.8 {
      ear_span = @cmp.maximum(ear_span, goblin[i * 8].abs())
    }
  }
  for i in 0..<(kobold.length() / 8) {
    tail_reach = @cmp.minimum(tail_reach, kobold[i * 8 + 2])
    if kobold[i * 8 + 1] > 0.8 {
      muzzle_reach = @cmp.maximum(muzzle_reach, kobold[i * 8 + 2])
    }
  }
  assert_true(ear_span > 0.42)
  assert_true(tail_reach < -0.55)
  assert_true(muzzle_reach > 0.34)
}

///|
test "enemy walk cycle articulates both legs instead of sliding a body box" {
  let models = EnemyModels::new()
  let before = models.get_skinned_mesh(@game.Basic).vertex_data.copy()
  models.update(0.13)
  let after = models.get_skinned_mesh(@game.Basic).vertex_data
  let skin = models.basic.geometry.skin_data
  for joint in [7, 8, 9, 10] {
    let mut moving = false
    for i in 0..<skin.vertex_count {
      if skin.joint_indices[i * 4] == joint &&
        (before[i * 8 + 2] - after[i * 8 + 2]).abs() > 0.01 {
        moving = true
      }
    }
    assert_true(moving)
  }
}

///|
test "rendering animated materials does not also deform unused combined meshes" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  apply_enemy_stress_scenario(state.world, 64)
  state.enemy_models.update(0.13)
  let commands = state.draw_playing(test_engine_context())
  assert_false(commands.is_empty())
  assert_eq(state.enemy_models.basic.geometry.cpu_skin_count(), 0)
}

///|
test "material poses animate on demand without preparing other species" {
  let models = EnemyModels::new()
  let before = models.basic.parts[0].geometry.skinned_mesh(
    models.pose_generation,
    models.compute_skinning(),
  ).vertex_data.copy()
  models.update(0.13)
  let after = models.basic.parts[0].geometry.skinned_mesh(
      models.pose_generation,
      models.compute_skinning(),
    ).vertex_data
  let mut moved = false
  for i in 0..<before.length() {
    if (before[i] - after[i]).abs() > 0.01 {
      moved = true
    }
  }
  assert_true(moved)
  assert_eq(models.fast.parts[0].geometry.cpu_skin_count(), 0)
  assert_eq(models.basic.geometry.cpu_skin_count(), 0)
}
