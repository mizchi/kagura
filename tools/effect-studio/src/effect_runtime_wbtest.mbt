///|
test "build_effect_runtime_plan schedules deterministic bursts for looped preview time" {
  let doc = default_effect_document()
  let plan = build_effect_runtime_plan(doc, 2.05)
  assert_true((plan.normalized_time - 0.25).abs() < 0.000001)
  assert_eq(plan.active_track_ids.length(), 2)
  assert_true(plan.active_track_ids.contains("embers_ring"))
  assert_true(plan.active_track_ids.contains("smoke_column"))
  assert_eq(plan.scheduled_bursts.length(), 3)
  assert_eq(plan.total_particles, 28)
  assert_eq(plan.scheduled_bursts[0].track_id, "embers_ring")
  assert_eq(plan.scheduled_bursts[2].track_id, "smoke_column")
}

///|
test "build_effect_runtime_plan filters expired flash burst" {
  let doc = default_effect_document()
  let plan = build_effect_runtime_plan(doc, 0.5)
  for burst in plan.scheduled_bursts {
    assert_false(burst.track_id == "core_flash")
  }
}
