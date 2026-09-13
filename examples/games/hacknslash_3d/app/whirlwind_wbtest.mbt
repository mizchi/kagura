///|
test "whirlwind loops the entire rig with every weapon without translating or rebuilding geometry" {
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
    let vertices = actor.packed_vertex_data.copy()
    actor.anim_state = Whirling
    actor.action_time = 0.0
    actor.skinning_cache_dirty = true
    let first = actor.compute_skinning()
    actor.action_time = @game.whirlwind_cycle_frames.to_double() / 120.0
    actor.skinning_cache_dirty = true
    let half = actor.compute_skinning()
    assert_false(first[0].approx_eq(half[0], 0.01))
    actor.action_time = @game.whirlwind_cycle_frames.to_double() / 60.0
    actor.skinning_cache_dirty = true
    let looped = actor.compute_skinning()
    for i in 0..<char_num_bones {
      assert_true(first[i].approx_eq(looped[i], 0.0001))
    }
    assert_eq(actor.local_poses[0].position.x, 0.0)
    assert_eq(actor.local_poses[0].position.z, 0.0)
    assert_eq(actor.packed_vertex_data, vertices)
  }
}

///|
test "holding physical 2 spins while moving, releasing stops and pause requires a fresh press" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.mode = @game.Playing
  s.world.enemies.clear()
  let x = s.world.player.x
  for _ in 0..<10 {
    s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [50, 68]))
  }
  assert_true(s.world.arts.whirlwind.active)
  assert_eq(s.character.anim_state, Whirling)
  assert_true(s.world.player.x != x)
  s.update(@core.empty_input_snapshot())
  assert_false(s.world.arts.whirlwind.active)
  assert_true(s.character.anim_state != Whirling)
  for _ in 0..<20 {
    s.update(@core.empty_input_snapshot())
  }
  s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [50]))
  assert_true(s.world.arts.whirlwind.active)
  s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [50, 27]))
  assert_true(s.paused)
  assert_false(s.world.arts.whirlwind.active)
  s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [50]))
  s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [50, 27]))
  for _ in 0..<20 {
    s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [50]))
  }
  assert_false(s.world.arts.whirlwind.active)
  s.update(@core.empty_input_snapshot())
  s.update(@core.new_input_snapshot(320.0, 240.0, 0.0, 0.0, [50]))
  assert_true(s.world.arts.whirlwind.active)
}
