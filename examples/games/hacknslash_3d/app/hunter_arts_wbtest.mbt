///|
test "guard and art samples articulate the rig without mutating geometry or translating gameplay" {
  let actor = PlayerCharacter::new()
  let vertices = actor.packed_vertex_data.copy()
  for
    state in [
      Guarding,
      Casting(@game.LightningArt),
      Casting(@game.FlameArt),
      Casting(@game.AstralArt),
      Casting(@game.DashArt),
    ] {
    actor.anim_state = state
    actor.action_time = 2.0 / 60.0
    actor.skinning_cache_dirty = true
    let before = actor.compute_skinning()
    actor.action_time = 16.0 / 60.0
    actor.skinning_cache_dirty = true
    let after = actor.compute_skinning()
    assert_false(before[7].approx_eq(after[7], 0.01))
    assert_eq(actor.local_poses[0].position.x, 0.0)
    assert_eq(actor.local_poses[0].position.z, 0.0)
  }
  assert_eq(actor.packed_vertex_data, vertices)
}

///|
test "target cancellation and guard respect pause and preserve skill cooldowns" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.mode = @game.Playing
  s.world.enemies.clear()
  s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [84]))
  assert_true(s.ground_targeting)
  s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [27]))
  assert_false(s.ground_targeting)
  assert_false(s.paused)
  assert_eq(s.world.arts.ground_cooldown, 0)
  s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [70]))
  assert_true(s.world.arts.guarding)
  assert_eq(s.character.anim_state, Guarding)
  s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [27]))
  let energy = s.world.arts.guard_energy
  for _ in 0..<10 {
    s.update(@core.empty_input_snapshot())
  }
  assert_eq(s.world.arts.guard_energy, energy)
}
