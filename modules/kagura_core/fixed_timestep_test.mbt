///|
test "fixed step: one update with interpolation remainder" {
  let config = default_fixed_step_config()
  let state = initial_fixed_step_state()

  let result = step_fixed_timestep(state, 20.0, config)

  assert_eq(result.updates, 1)
  assert_eq(result.next_state.tick, 1)
  let diff = (result.alpha - 0.2).abs()
  assert_true(diff <= 0.0001)
}

///|
test "fixed step: remainder carries to next frame" {
  let config = default_fixed_step_config()
  let state = initial_fixed_step_state()

  let first = step_fixed_timestep(state, 10.0, config)
  assert_eq(first.updates, 0)

  let second = step_fixed_timestep(first.next_state, 10.0, config)
  assert_eq(second.updates, 1)
  assert_eq(second.next_state.tick, 1)
}

///|
test "fixed step: caps updates and drops overloaded backlog" {
  let config = new_fixed_step_config(60, 4)
  let state = initial_fixed_step_state()

  let result = step_fixed_timestep(state, 1000.0, config)

  assert_eq(result.updates, 4)
  assert_eq(result.next_state.tick, 4)
  assert_true(result.alpha < 1.0)
}
