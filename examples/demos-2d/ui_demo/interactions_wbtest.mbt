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

///|
test "portrait capture uses portrait layout and logical pointer coordinates" {
  let game = DemoState::new(width=360, height=640)
  let snapshot = game.ui_snapshot()
  assert_eq(snapshot.screen_width, 360.0)
  assert_eq(snapshot.screen_height, 640.0)
  let right = game.layouts.filter(layout => {
      layout.node_id.value == game.focus_ids[1].value
    })[0]
  assert_true(right.rect.x + right.rect.width <= 360.0)
  assert_eq(snapshot.focus_order[1], "button_4")
  game.update(
    @core.new_input_snapshot_full(
      right.rect.x + right.rect.width / 2.0,
      right.rect.y + right.rect.height / 2.0,
      0.0,
      0.0,
      [],
      [0],
      [],
      [],
    ),
  )
  assert_eq(game.focus_mgr.current_focus().unwrap().value, right.node_id.value)
}
