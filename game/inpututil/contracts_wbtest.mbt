///|
fn snapshot_with_pressed_keys(keys : Array[Int]) -> @core.InputSnapshot {
  @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, keys)
}

///|
test "InputHelper initial state" {
  let helper = new_input_helper()
  let empty = @core.empty_input_snapshot()
  assert_true(!is_any_action_just_pressed(helper, empty))
}

///|
test "InputHelper key press detected" {
  let helper = new_input_helper()
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [32])
  update_input_helper(helper, input)
  assert_true(is_any_action_just_pressed(helper, input))
  // Second frame: same key held → not just pressed
  update_input_helper(helper, input)
  assert_true(!is_any_action_just_pressed(helper, input))
}

///|
test "InputHelper mouse click detected" {
  let helper = new_input_helper()
  let input = @core.new_input_snapshot_full(0.0, 0.0, 0.0, 0.0, [], [0], [], [])
  update_input_helper(helper, input)
  assert_true(is_any_action_just_pressed(helper, input))
}

///|
test "InputHelper touch detected" {
  let helper = new_input_helper()
  let empty = @core.empty_input_snapshot()
  update_input_helper(helper, empty)
  let input_with_touch = @core.new_input_snapshot_full(
    0.0,
    0.0,
    0.0,
    0.0,
    [],
    [],
    [@core.new_touch_point(1, 10.0, 20.0)],
    [],
  )
  update_input_helper(helper, input_with_touch)
  assert_true(is_any_action_just_pressed(helper, input_with_touch))
}

///|
test "InputHelper touch held not just pressed on second frame" {
  let helper = new_input_helper()
  let empty = @core.empty_input_snapshot()
  update_input_helper(helper, empty)
  let input_with_touch = @core.new_input_snapshot_full(
    0.0,
    0.0,
    0.0,
    0.0,
    [],
    [],
    [@core.new_touch_point(1, 10.0, 20.0)],
    [],
  )
  // Frame 1: just pressed
  update_input_helper(helper, input_with_touch)
  assert_true(is_any_action_just_pressed(helper, input_with_touch))
  // Frame 2: same touch held → NOT just pressed
  update_input_helper(helper, input_with_touch)
  assert_true(!is_any_action_just_pressed(helper, input_with_touch))
}

///|
test "is_move_up detects W key" {
  let state = @inputstate.new_key_input_state()
  @inputstate.update_key_input_state(state, snapshot_with_pressed_keys([87]))
  assert_true(is_move_up(state))
}

///|
test "is_move_up detects arrow up web" {
  let state = @inputstate.new_key_input_state()
  @inputstate.update_key_input_state(state, snapshot_with_pressed_keys([38]))
  assert_true(is_move_up(state))
}

///|
test "is_move_up detects arrow up glfw" {
  let state = @inputstate.new_key_input_state()
  @inputstate.update_key_input_state(state, snapshot_with_pressed_keys([265]))
  assert_true(is_move_up(state))
}

///|
test "is_move_down detects S key" {
  let state = @inputstate.new_key_input_state()
  @inputstate.update_key_input_state(state, snapshot_with_pressed_keys([83]))
  assert_true(is_move_down(state))
}

///|
test "is_move_left detects A key" {
  let state = @inputstate.new_key_input_state()
  @inputstate.update_key_input_state(state, snapshot_with_pressed_keys([65]))
  assert_true(is_move_left(state))
}

///|
test "is_move_right detects D key" {
  let state = @inputstate.new_key_input_state()
  @inputstate.update_key_input_state(state, snapshot_with_pressed_keys([68]))
  assert_true(is_move_right(state))
}

///|
test "physical E O and comma are not movement or menu aliases" {
  for key in [key_e, key_o, key_comma] {
    let helper = new_input_helper()
    update_input_helper(helper, snapshot_with_pressed_keys([key]))
    assert_true(!is_move_up(helper.key_state))
    assert_true(!is_move_down(helper.key_state))
    assert_true(!is_move_left(helper.key_state))
    assert_true(!is_move_right(helper.key_state))
    assert_true(!is_up_just_pressed(helper))
    assert_true(!is_down_just_pressed(helper))
  }
}

///|
test "is_confirm_just_pressed detects space" {
  let helper = new_input_helper()
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [32])
  update_input_helper(helper, input)
  assert_true(is_confirm_just_pressed(helper))
}

///|
test "is_confirm_just_pressed detects enter web" {
  let helper = new_input_helper()
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [13])
  update_input_helper(helper, input)
  assert_true(is_confirm_just_pressed(helper))
}

///|
test "is_confirm_just_pressed detects enter glfw" {
  let helper = new_input_helper()
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [257])
  update_input_helper(helper, input)
  assert_true(is_confirm_just_pressed(helper))
}

///|
test "is_up_just_pressed detects W" {
  let helper = new_input_helper()
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [87])
  update_input_helper(helper, input)
  assert_true(is_up_just_pressed(helper))
}

///|
test "is_down_just_pressed detects S" {
  let helper = new_input_helper()
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [83])
  update_input_helper(helper, input)
  assert_true(is_down_just_pressed(helper))
}

///|
test "direction not detected without matching key" {
  let state = @inputstate.new_key_input_state()
  @inputstate.update_key_input_state(state, snapshot_with_pressed_keys([99]))
  assert_true(!is_move_up(state))
  assert_true(!is_move_down(state))
  assert_true(!is_move_left(state))
  assert_true(!is_move_right(state))
}
