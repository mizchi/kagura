///|
test "millisecond budgets round up so a frame never shortens a response window" {
  assert_eq(simulation_hz, 60)
  assert_eq(frames_from_ms(-1), 0)
  assert_eq(frames_from_ms(0), 0)
  assert_eq(frames_from_ms(1), 1)
  assert_eq(frames_from_ms(17), 2)
  assert_eq(frames_from_ms(visual_reaction_fast_ms), 11)
  assert_eq(frames_from_ms(visual_reaction_ms), 15)
  assert_eq(frames_from_ms(1000), 60)
  assert_eq(frames_from_ms(2147483647), 128849019)
}

///|
test "the visual reference is distinct from choice, device and comfort allowances" {
  let budget = default_reaction_budget
  assert_eq(visual_reaction_fast_ms, 180)
  assert_eq(budget.visual_ms, 250)
  assert_eq(budget.decision_ms, 150)
  assert_eq(budget.device_ms, 50)
  assert_eq(budget.comfort_ms, 50)
  assert_eq(budget.response_ms(), 500)
  assert_eq(budget.response_frames(), 30)
}

///|
test "changing only visual reaction time propagates to all response-dependent windows" {
  let current = default_reaction_budget
  let slower = { ..current, visual_ms: current.visual_ms + 100, }
  let extra = frames_from_ms(100)
  assert_eq(slower.response_frames(), current.response_frames() + extra)
  assert_eq(slower.windup_frames(), current.windup_frames() + extra)
  assert_eq(slower.counter_frames(), current.counter_frames() + extra)
  assert_eq(slower.spacing_frames(), current.spacing_frames() + extra)
  assert_eq(slower.guard_reset_frames(), current.guard_reset_frames() + extra)
  let fast = { ..current, visual_ms: visual_reaction_fast_ms, }
  assert_true(fast.response_frames() < current.response_frames())
  assert_true(fast.windup_frames() < current.windup_frames())
}

///|
test "the reference refactor preserves the current playable default timings" {
  let budget = default_reaction_budget
  let g = new_game()
  assert_eq(g.windup, budget.windup_frames())
  assert_eq(g.windup, 60)
  g.enemies.clear()
  for kind in [0, 1, 2, 3] {
    g.spawn(kind, 400, 372)
    let e = g.enemies[kind]
    assert_eq(e.windup_frames(g.windup), [60, 72, 60, 84][kind])
    assert_eq(e.recovery_frames(), if kind == 3 { 108 } else { 90 })
  }
  assert_eq(budget.spacing_frames(), 24)
  assert_eq(budget.guard_reset_frames(), 48)
}
