///|
test "charge articulates both rigs and every player weapon while preserving GPU batches" {
  let models = EnemyModels::new()
  let index = enemy_attack_clip_index(@game.Charge)
  assert_true(index >= 0)
  let clip = models.attack_clips[index]
  let prepare = clip.matrices(clip.frame_index(0.2))
  let drive = clip.matrices(clip.frame_index(0.45))
  assert_false(prepare[1].approx_eq(drive[1], 0.01))
  assert_false(prepare[7].approx_eq(drive[7], 0.01))
  let actor = PlayerCharacter::new()
  for
    weapon in [
      @game.Cleaver,
      @game.Spear,
      @game.Knuckles,
      @game.Focus,
      @game.Bow,
    ] {
    actor.equip_weapon(weapon)
    actor.anim_state = Charging
    actor.action_time = 8.0 / 60.0
    actor.skinning_cache_dirty = true
    let before = actor.compute_skinning()
    actor.action_time = 16.0 / 60.0
    actor.skinning_cache_dirty = true
    let after = actor.compute_skinning()
    assert_false(before[1].approx_eq(after[1], 0.01))
    assert_false(before[8].approx_eq(after[8], 0.01))
    assert_eq(actor.local_poses[16].scale.x, 0.0)
    assert_eq(actor.local_poses[0].position.x, 0.0)
    assert_eq(actor.local_poses[0].position.z, 0.0)
  }
}

///|
test "charge input updates gameplay and rig on the same frame and recovery restores control" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  state.world.dungeon.grid = @terrain.Grid2D::make(40, 40, @terrain.Floor)
  state.world.player.x = 64.0
  state.world.player.y = 64.0
  state.world.enemies = [
    @game.make_enemy(300.0, 300.0, @game.Basic, 1000, 0.0, 8.0),
  ]
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [67]))
  assert_true(state.world.player_charge is Some(_))
  assert_eq(state.character.anim_state, Charging)
  for frame in 2..<@game.player_charge_profile.duration() {
    state.update(@core.empty_input_snapshot())
    assert_eq(state.world.player_charge.unwrap().frame, frame)
    assert_eq(state.character.action_time, frame.to_double() / 60.0)
  }
  state.update(@core.empty_input_snapshot())
  assert_true(state.world.player_charge is None)
  assert_eq(state.character.anim_state, Idle)
}
