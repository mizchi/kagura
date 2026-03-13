///|
test "install_web_runtime_js installs web hooks" {
  @web_hooks.uninstall()
  assert_false(@web_hooks.is_ready())

  install_web_runtime_js()

  assert_true(@web_hooks.is_ready())
  @web_hooks.uninstall()
}

///|
test "apply_initial_mode_overrides starts in playing auto-play mode when autoplay is enabled" {
  let state = GameState::new(seed=42)

  apply_initial_mode_overrides(state, "", 0, true)

  let is_playing = match state.world.mode {
    @game.Playing => true
    _ => false
  }
  assert_true(is_playing)
  assert_true(state.world.auto_play)
}

///|
test "apply_initial_mode_overrides enables auto_play after snapshot playing warmup" {
  let state = GameState::new(seed=42)

  apply_initial_mode_overrides(state, "playing", 2, true)

  let is_playing = match state.world.mode {
    @game.Playing => true
    _ => false
  }
  assert_true(is_playing)
  assert_true(state.world.auto_play)
  assert_true(state.world.frame_count >= 2)
}

///|
test "apply_debug_skill_unlocks learns all spell nodes when enabled" {
  let state = GameState::new(seed=42)

  apply_debug_skill_unlocks(state, true)

  assert_eq(state.world.skills.get_level(@game.ChainLightning), 1)
  assert_eq(state.world.skills.get_level(@game.SplittingFireball), 1)
  assert_eq(state.world.skills.get_level(@game.IceNova), 1)
  assert_eq(state.world.skills.get_level(@game.HomingMissile), 1)
}

///|
test "build_initial_balance_params selects build diverse preset by name" {
  let params = build_initial_balance_params("build_diverse_hackslash")

  assert_true((params.player_speed - 2.0).abs() < 0.0001)
  assert_true((params.map_room_size_scale - 1.2253745535048524).abs() < 0.0001)
}

///|
test "build_initial_balance_params falls back to default preset" {
  let params = build_initial_balance_params("unknown")
  let default_params = @game.BalanceParams::default()

  assert_true(
    (params.player_speed - default_params.player_speed).abs() < 0.0001,
  )
  assert_true(
    (params.enemy_bolt_damage - default_params.enemy_bolt_damage).abs() < 0.0001,
  )
}
