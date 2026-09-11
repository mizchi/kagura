///|
test "keyboard and gamepad navigate the same visual order and require a new press" {
  let game = DemoState::new()
  let idle = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
  let next = @core.new_input_snapshot_full(0.0, 0.0, 0.0, 0.0, [], [], [], [
    @core.new_gamepad_snapshot(0, [], [13]),
  ])
  game.update(next)
  assert_eq(
    game.focus_mgr.current_focus().unwrap().value,
    game.focus_ids[0].value,
  )
  game.update(next)
  assert_eq(
    game.focus_mgr.current_focus().unwrap().value,
    game.focus_ids[0].value,
  )
  game.update(idle)
  game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [9]))
  assert_eq(
    game.focus_mgr.current_focus().unwrap().value,
    game.focus_ids[1].value,
  )
  let snapshot = game.ui_snapshot()
  assert_eq(
    snapshot.focus_order[1],
    "button_" + game.focus_ids[1].value.to_string(),
  )
}
