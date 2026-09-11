///|
test "named focus fixture starts with the last button before any update" {
  let game = initial_states().create(
    Some("last_button_focused"),
    width=360,
    height=640,
  )
  assert_eq(game.frame, 0)
  assert_eq(game.ui_snapshot().focus_order[5], "button_6")
  assert_eq(
    game.focus_mgr.current_focus().unwrap().value,
    game.focus_ids[5].value,
  )
  let fresh = initial_states().create(None, width=640, height=480)
  assert_true(fresh.focus_mgr.current_focus() is None)
}
