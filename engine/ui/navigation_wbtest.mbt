///|
fn nav_input(
  buttons : Array[Int],
  axes? : Array[Double] = [],
) -> @core.InputSnapshot {
  @core.new_input_snapshot_full(-1.0, -1.0, 0.0, 0.0, [], [], [], [
    @core.new_gamepad_snapshot(0, axes, buttons),
  ])
}

///|
test "controller directions and confirm are edges with controlled repeat" {
  let input = UINavigationInputAdapter::new()
  assert_eq(input.update(nav_input([15, 0])).length(), 2)
  assert_eq(input.update(nav_input([15, 0]), elapsed_ms=100.0).length(), 0)
  let repeated = input.update(nav_input([15, 0]), elapsed_ms=250.0)
  assert_eq(repeated.length(), 1)
  assert_true(repeated[0] is Move(Right))
  let _ = input.update(nav_input([]))
  assert_true(input.update(nav_input([1]))[0] is Cancel)
}

///|
test "analog stick ignores jitter and rearms after neutral" {
  let input = UINavigationInputAdapter::new()
  assert_eq(input.update(nav_input([], axes=[0.3, 0.1])).length(), 0)
  assert_true(input.update(nav_input([], axes=[0.8, 0.1]))[0] is Move(Right))
  assert_eq(input.update(nav_input([], axes=[0.5, 0.1])).length(), 0)
  let _ = input.update(nav_input([], axes=[0.0, 0.0]))
  assert_true(input.update(nav_input([], axes=[0.0, -0.8]))[0] is Move(Up))
  let _ = input.update(@core.new_input_snapshot(-1.0, -1.0, 0.0, 0.0, []))
  assert_eq(input.update(nav_input([], axes=[0.1, 0.1])).length(), 0)
}

///|
test "keyboard and gamepad share navigation events without duplicate confirm" {
  let input = UINavigationInputAdapter::new()
  let frame = @core.new_input_snapshot_full(
    -1.0,
    -1.0,
    0.0,
    0.0,
    [13, 39],
    [],
    [],
    [@core.new_gamepad_snapshot(0, [], [0])],
  )
  let events = input.update(frame)
  assert_eq(events.length(), 2)
  assert_true(events[0] is Move(Right))
  assert_true(events[1] is Confirm)
  assert_eq(input.update(frame).length(), 0)
}

///|
test "GLFW navigation maps its distinct dpad and Start numbering to the shared contract" {
  let input = UINavigationInputAdapter::new()
  let events = input.update(navigation_input_from_glfw(nav_input([12, 7, 0])))
  assert_true(events.any(e => e is Move(Right)))
  assert_true(events.any(e => e is Confirm))
  assert_true(events.any(e => e is Auxiliary(9)))
  let _ = input.update(navigation_input_from_glfw(nav_input([])))
  assert_true(
    input.update(navigation_input_from_glfw(nav_input([11])))[0] is Move(Up),
  )
}
