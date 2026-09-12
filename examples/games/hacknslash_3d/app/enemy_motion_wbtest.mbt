///|
test "generated HY clips return to bind pose and aim the spear forward on impact" {
  let models = EnemyModels::new()
  for clip in models.attack_clips {
    assert_true(clip.frame_count >= 49)
    for frame in [0, clip.frame_count - 1] {
      for i in 0..<15 {
        let matrix = clip.matrices(frame)[i]
        assert_true(matrix.approx_eq(@math3d.Mat4::identity(), 0.00001))
      }
    }
  }
  let spear = models.attack_clips[1].matrices(24)[12]
  let tip = spear.mul_vec4(@math3d.Vec4::new(0.34, 1.39, 0.14, 1.0))
  let hand = spear.mul_vec4(@math3d.Vec4::new(0.34, 0.36, 0.14, 1.0))
  assert_true(tip.z - hand.z > 1.0)
  assert_true((tip.y - hand.y).abs() < 0.001)
  assert_false(
    models.attack_clips[0].matrices(12)[6].approx_eq(
      models.attack_clips[0].matrices(24)[6],
      0.01,
    ),
  )
}

///|
test "attack poses batch by phase and never deform a CPU mesh per enemy" {
  let state = GameState::new(seed=42)
  apply_enemy_motion_preview(state, 24)
  let first = state.world.enemies[0]
  let same_pose = @game.make_enemy(
    first.x + 8.0,
    first.y,
    @game.Basic,
    100,
    0.0,
    10.0,
  )
  same_pose.begin_attack(
    @game.Punch,
    24,
    24,
    first.attack_target_x,
    first.attack_target_y,
  )
  same_pose.attack_frame = 24
  state.world.enemies.push(same_pose)
  let other_pose = @game.make_enemy(
    first.x + 4.0,
    first.y - 8.0,
    @game.Basic,
    100,
    0.0,
    10.0,
  )
  other_pose.begin_attack(
    @game.Punch,
    24,
    24,
    first.attack_target_x,
    first.attack_target_y,
  )
  other_pose.attack_frame = 12
  state.world.enemies.push(other_pose)
  let commands = state.draw_playing(test_engine_context())
  assert_false(commands.is_empty())
  assert_eq(state.enemy_models.attack_buckets.length(), 4)
  for
    data in [
      state.enemy_models.basic,
      state.enemy_models.fast,
      state.enemy_models.caster,
    ] {
    for part in data.parts {
      assert_eq(part.geometry.cpu_skin_count(), 0)
    }
  }
  let mut pairs = 0
  for command in commands {
    if command.shader.id == state.shader3d_skinned_instanced_monochrome.id &&
      command.instance_count == 2 {
      pairs += 1
    }
  }
  assert_eq(pairs, state.enemy_models.basic.parts.length())
}

///|
test "bow props stay attached and nocked arrow disappears exactly on release" {
  let models = EnemyModels::new()
  let clip = models.attack_clips[enemy_attack_clip_index(@game.BowShot)]
  let drawn = clip.matrices(clip.frame_index(23.0 / 48.0))
  let grip = drawn[13].mul_vec4(@math3d.Vec4::new(-0.275, 0.35, 0.06, 1.0))
  let left = drawn[4].mul_vec4(@math3d.Vec4::new(-0.275, 0.35, 0.06, 1.0))
  let string = drawn[14].mul_vec4(@math3d.Vec4::new(-0.275, 0.35, -0.07, 1.0))
  let right = drawn[6].mul_vec4(@math3d.Vec4::new(0.275, 0.35, 0.06, 1.0))
  assert_true(
    (grip.x - left.x).abs() < 0.001 && (grip.z - left.z).abs() < 0.001,
  )
  assert_true(
    (string.x - right.x).abs() < 0.001 &&
    (string.y - right.y).abs() < 0.001 &&
    (string.z - right.z).abs() < 0.001,
  )
  let arrow = @math3d.Vec4::new(0.0, 0.0, 1.0, 0.0)
  let before = drawn[15].mul_vec4(arrow)
  let released = clip.matrices(clip.frame_index(0.5))[15].mul_vec4(arrow)
  let walking = models.compute_skinning()[15].mul_vec4(arrow)
  assert_true(before.z > 0.9)
  assert_true(released.x.abs() + released.y.abs() + released.z.abs() < 0.001)
  assert_true(walking.x.abs() + walking.y.abs() + walking.z.abs() < 0.001)
  let mut archer_prop_vertices = 0
  let mut caster_prop_vertices = 0
  for j in models.ranged.geometry.skin_data.joint_indices {
    if j >= 13 {
      archer_prop_vertices += 1
    }
  }
  for j in models.caster.geometry.skin_data.joint_indices {
    if j >= 13 {
      caster_prop_vertices += 1
    }
  }
  assert_true(archer_prop_vertices > 100)
  assert_eq(caster_prop_vertices, 0)
}

///|
test "enemy arrows use the arrow mesh and archer casts use GPU pose batches" {
  let state = GameState::new(seed=42)
  apply_bow_motion_preview(state, 26)
  let commands = state.draw_playing(test_engine_context())
  assert_false(commands.is_empty())
  assert_eq(state.entity_instance_scratch.arrow_instances.length(), 1)
  assert_eq(
    state.entity_instance_scratch.enemy_projectile_instances.length(),
    0,
  )
  assert_eq(state.enemy_models.active_attack_keys.length(), 1)
  let buckets = state.enemy_models.attack_buckets[state.enemy_models.active_attack_keys[0]]
  assert_eq(buckets.ranged_matrices.length(), 1)
  assert_eq(buckets.caster_matrices.length(), 0)
  for part in state.enemy_models.ranged.parts {
    assert_eq(part.geometry.cpu_skin_count(), 0)
  }
}

///|
test "a single arrow retains its material tint" {
  let state = GameState::new(seed=42)
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  push_entity_instances_if_any(
    state.meshes.arrow,
    [@scene3d.InstanceData::new(color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    @math3d.Mat4::identity(),
    state.lighting,
    state.pipeline.scene_target,
    state.shader3d_colored,
    state.shader3d_instanced,
    state.shader3d_instanced_monochrome,
    1280,
    900,
    commands,
  )
  assert_eq(commands.length(), 1)
  assert_eq(commands[0].shader.id, state.shader3d_colored.id)
  assert_eq(commands[0].uniform_dwords.length(), 60)
  assert_eq(
    commands[0].uniform_dwords[56],
    (1.0 : Double).to_float().reinterpret_as_int(),
  )
  assert_eq(commands[0].uniform_dwords[57], 0)
  assert_eq(commands[0].uniform_dwords[58], 0)
}
