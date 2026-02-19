///|
fn snapshot_with_pressed_keys(keys : Array[Int]) -> @core.InputSnapshot {
  @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, keys)
}

///|
test "inpututil tracks just pressed released and duration" {
  let state = new_key_input_state()

  update_key_input_state(state, snapshot_with_pressed_keys([10]))
  assert_true(is_key_pressed(state, 10))
  assert_true(is_key_just_pressed(state, 10))
  assert_true(!is_key_just_released(state, 10))
  assert_eq(key_press_duration(state, 10), 1)

  update_key_input_state(state, snapshot_with_pressed_keys([10]))
  assert_true(is_key_pressed(state, 10))
  assert_true(!is_key_just_pressed(state, 10))
  assert_true(!is_key_just_released(state, 10))
  assert_eq(key_press_duration(state, 10), 2)

  update_key_input_state(state, snapshot_with_pressed_keys([]))
  assert_true(!is_key_pressed(state, 10))
  assert_true(!is_key_just_pressed(state, 10))
  assert_true(is_key_just_released(state, 10))
  assert_eq(key_press_duration(state, 10), 0)
}

///|
test "inpututil append APIs return deduplicated key sets" {
  let state = new_key_input_state()

  update_key_input_state(state, snapshot_with_pressed_keys([1, 1, 2]))
  let pressed = append_pressed_keys(state, [99])
  let just_pressed = append_just_pressed_keys(state, [])
  let just_released = append_just_released_keys(state, [])

  assert_eq(pressed.length(), 3)
  assert_eq(pressed[0], 99)
  assert_eq(pressed[1], 1)
  assert_eq(pressed[2], 2)
  assert_eq(just_pressed.length(), 2)
  assert_eq(just_pressed[0], 1)
  assert_eq(just_pressed[1], 2)
  assert_eq(just_released.length(), 0)

  update_key_input_state(state, snapshot_with_pressed_keys([2, 3]))
  let just_pressed2 = append_just_pressed_keys(state, [])
  let just_released2 = append_just_released_keys(state, [])
  assert_eq(just_pressed2.length(), 1)
  assert_eq(just_pressed2[0], 3)
  assert_eq(just_released2.length(), 1)
  assert_eq(just_released2[0], 1)
}
