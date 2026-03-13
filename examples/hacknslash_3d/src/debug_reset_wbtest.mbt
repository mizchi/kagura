///|
fn debug_reset_test_input(
  cursor_x : Double,
  cursor_y : Double,
  pressed_keys : Array[Int],
  pressed_mouse_buttons : Array[Int],
) -> @core.InputSnapshot {
  @core.new_input_snapshot_full(
    cursor_x,
    cursor_y,
    0.0,
    0.0,
    pressed_keys,
    pressed_mouse_buttons,
    [],
    [],
  )
}

///|
test "input_snapshot_requests_debug_reset accepts keyboard shortcut" {
  let input = debug_reset_test_input(0.0, 0.0, [key_r], [])

  assert_true(input_snapshot_requests_debug_reset(input, @game.Title))
  assert_true(input_snapshot_requests_debug_reset(input, @game.GameOver))
  assert_false(input_snapshot_requests_debug_reset(input, @game.Playing))
}

///|
test "input_snapshot_requests_debug_reset accepts title button click" {
  let (x, y, w, h) = match
    debug_reset_button_rect(
      @game.Title,
      screen_w.to_double(),
      screen_h.to_double(),
    ) {
    Some(rect) => rect
    None => panic()
  }
  let input = debug_reset_test_input(x + w / 2.0, y + h / 2.0, [], [0])

  assert_true(input_snapshot_requests_debug_reset(input, @game.Title))
}

///|
test "reset_save_and_restart clears progression and restarts playing" {
  let state = GameState::new(seed=99)
  state.world.mode = @game.GameOver
  state.world.floor = 5
  state.world.score = 123
  state.world.seed = 1234
  state.world.auto_play = true
  state.world.ui_mode = @game.Inventory
  state.world.ui_cursor = 2
  state.world.inventory.items[0] = Some({
    name: "Old Sword",
    rarity: @game.Common,
    slot: @game.Weapon,
    atk_bonus: 3,
    def_bonus: 0,
    hp_bonus: 0,
    str_bonus: 0,
    int_bonus: 0,
    dex_bonus: 0,
    str_scaling: 0.0,
    int_scaling: 0.0,
    dex_scaling: 0.0,
    prefix: None,
    suffix: None,
    icon_id: 0,
  })
  state.world.equipment.weapon = state.world.inventory.items[0]
  state.world.skills.nodes[0].level = 2
  state.world.skills.skill_points = 3
  state.world.level_progress.level = 4
  state.world.level_progress.pending_choices = 1
  state.audio_last_played_cue = "sfx/test"
  state.audio_last_played_state = "played"

  state.reset_save_and_restart()

  assert_true(
    match state.world.mode {
      @game.Playing => true
      _ => false
    },
  )
  assert_eq(state.world.floor, 1)
  assert_eq(state.world.score, 0)
  assert_eq(state.world.seed, 42)
  assert_true(state.world.auto_play)
  assert_true(
    match state.world.ui_mode {
      @game.UIMode::None => true
      _ => false
    },
  )
  assert_eq(state.world.ui_cursor, 0)
  assert_true(
    match state.world.inventory.items[0] {
      None => true
      _ => false
    },
  )
  assert_true(
    match state.world.equipment.weapon {
      None => true
      _ => false
    },
  )
  assert_eq(state.world.skills.nodes[0].level, 0)
  assert_eq(state.world.skills.skill_points, 0)
  assert_eq(state.world.level_progress.level, 1)
  assert_eq(state.world.level_progress.pending_choices, 0)
  assert_eq(state.world.player.hp, state.world.player_stats.max_hp)
  assert_eq(state.active_effects.length(), 0)
  assert_eq(state.particle_manager.emitters.length(), 0)
  assert_eq(state.audio_last_played_cue, "")
  assert_eq(state.audio_last_played_state, "")
}

///|
test "update_title resets save and starts game on debug reset input" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Title
  state.world.floor = 3
  state.world.score = 77

  let input = debug_reset_test_input(0.0, 0.0, [key_r], [])
  state.update(input)

  assert_true(
    match state.world.mode {
      @game.Playing => true
      _ => false
    },
  )
  assert_eq(state.world.floor, 1)
  assert_eq(state.world.score, 0)
}
