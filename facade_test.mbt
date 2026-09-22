///|
test "root facade exposes fixed timestep helpers" {
  let state = @kagura.initial_fixed_step_state()
  let config = @kagura.new_fixed_step_config(60, 4)
  let result = @kagura.plan_fixed_updates(state, 20.0, config)
  inspect(@kagura.step_result_updates(result), content="1")
  inspect(@kagura.step_result_alpha(result) > 0.0, content="true")
  let next = @kagura.step_result_next_state(result)
  let capped = @kagura.plan_fixed_updates(next, 1000.0, config)
  inspect(@kagura.step_result_updates(capped), content="4")
}
