///|
test "Escape freezes simulation clock, actor motion, cooldowns and camera until resume" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  assert_true(state.world.request_charge(0.0))
  state.character.anim_state = Charging
  let frame = state.world.frame_count
  let x = state.world.player.x
  let yaw = state.camera.yaw
  let distance = state.camera.distance
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_true(state.paused)
  assert_eq(state.world.frame_count, frame)
  for _ in 0..<60 {
    state.update(
      @core.new_input_snapshot_full(
        300.0,
        280.0,
        0.0,
        -10.0,
        [87, 81, 82, 74, 67, 49],
        [0, 2],
        [],
        [],
      ),
    )
  }
  assert_eq(state.world.frame_count, frame)
  assert_eq(state.world.player.x, x)
  assert_eq(state.camera.yaw, yaw)
  assert_eq(state.camera.distance, distance)
  assert_eq(state.character.action_time, 0.0)
  assert_eq(state.world.player_charge.unwrap().frame, 0)
  assert_eq(state.world.charge_cooldown, @game.player_charge_cooldown)
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_false(state.paused)
  assert_eq(state.world.frame_count, frame)
  state.update(@core.empty_input_snapshot())
  assert_true(state.world.frame_count > frame)
  assert_eq(state.world.player_charge.unwrap().frame, 1)
}

///|
test "pause submenus return to pause and level-up choices survive Escape" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  state.world.ui_mode = @game.LevelUp
  state.world.ui_cursor = 1
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_true(state.paused)
  assert_true(state.world.ui_mode == @game.UIMode::None)
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [73]))
  assert_true(state.world.ui_mode == @game.Inventory)
  state.world.ui_cursor = 7
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_true(state.paused)
  assert_true(state.world.ui_mode == @game.UIMode::None)
  state.update(@core.empty_input_snapshot())
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_false(state.paused)
  assert_true(state.world.ui_mode == @game.LevelUp)
  assert_eq(state.world.ui_cursor, 1)
}

///|
test "pause freezes playing audio without changing mute preference" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let clip = @audio.new_audio_clip(
    @audio.default_audio_format(),
    Bytes::make(4410 * 4, 16),
    false,
  )
  state.audio_bank.register(SfxAttack, clip)
  state.play_sound_cue(SfxAttack)
  let voice = state.audio_bank.player(SfxAttack).unwrap()
  let output : FixedArray[Float] = FixedArray::make(882, 0.0)
  state.audio_ctx.render(441, output)
  let position = state.audio_ctx.current_position(voice)
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_true(state.audio_bank.is_paused())
  assert_false(state.audio_bank.is_muted())
  for _ in 0..<20 {
    state.audio_ctx.render(441, output)
  }
  assert_eq(state.audio_ctx.current_position(voice), position)
  assert_eq(state.playing_audio_player_count(), 0)
  assert_eq(state.ui_snapshot().state, "pause")
  assert_true(state.ui_snapshot().nodes.any(n => n.id == "pause_title"))
  state.update(@core.empty_input_snapshot())
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_false(state.audio_bank.is_paused())
  state.audio_ctx.render(441, output)
  assert_true(state.audio_ctx.current_position(voice) > position)
}
