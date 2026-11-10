///|
test "keyboard and touch share movement normalization and independent actions" {
  let raw = @core.new_input_snapshot(0, 0, 0, 0, [65, 87, 74, 32])
  let input = read_input(raw, { ..@sim.idle_input(), breaker: true, })
  assert_eq(input.x, -1)
  assert_eq(input.z, -1)
  assert_true(input.strike && input.breaker && input.evade)
  assert_false(input.pause)
}

///|
test "gamepad deadzone and independent start pause evade bindings" {
  let pad = @core.new_gamepad_snapshot(0, [0.12, -0.85], [0, 1, 8])
  let raw = @core.new_input_snapshot_full(0, 0, 0, 0, [], [], [], [pad])
  let input = read_input(raw, @sim.idle_input())
  assert_eq(input.x, 0)
  assert_eq(input.z, -0.85)
  assert_true(input.strike && input.evade && input.pause)
  assert_false(input.start)
}

///|
test "a tap between simulation frames is consumed exactly once" {
  let app : App = {
    game: @sim.new_game(),
    control: @inspection.new_field_control(),
    web: @sim.idle_input(),
    queued: @sim.idle_input(),
    previous: -1,
    accumulator: 0,
  }
  app.game.start()
  app.accept_input(0, 0, false, false, true)
  app.advance(@core.empty_input_snapshot(), 8)
  app.accept_input(0, 0, false, false, false)
  app.advance(@core.empty_input_snapshot(), 9)
  assert_eq(app.game.dodges, 1)
  for _ in 0..<70 {
    app.advance(@core.empty_input_snapshot(), 17)
  }
  assert_eq(app.game.dodges, 1)
}
