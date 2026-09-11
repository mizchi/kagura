///|
test "root facade exposes fixed timestep helpers" {
  let state = initial_fixed_step_state()
  let config = new_fixed_step_config(60, 4)
  let result = plan_fixed_updates(state, 20.0, config)
  inspect(step_result_updates(result), content="1")
  inspect(step_result_alpha(result) > 0.0, content="true")
  let next = step_result_next_state(result)
  let capped = plan_fixed_updates(next, 1000.0, config)
  inspect(step_result_updates(capped), content="4")
}
