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
