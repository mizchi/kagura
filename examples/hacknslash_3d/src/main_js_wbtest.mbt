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
