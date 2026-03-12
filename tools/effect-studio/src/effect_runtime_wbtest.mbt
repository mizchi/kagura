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

///|
test "new_effect_placement stores origin target and scale" {
  let origin = @math3d.Vec3::new(1.0, 2.0, 3.0)
  let target = @math3d.Vec3::new(4.0, 5.0, 6.0)
  let placement = new_effect_placement(origin, Some(target), 2.5)
  assert_true((placement.origin.x - origin.x).abs() < 0.000001)
  assert_true((placement.origin.y - origin.y).abs() < 0.000001)
  assert_true((placement.origin.z - origin.z).abs() < 0.000001)
  assert_true(placement.target is Some(_))
  match placement.target {
    Some(actual_target) => {
      assert_true((actual_target.x - target.x).abs() < 0.000001)
      assert_true((actual_target.y - target.y).abs() < 0.000001)
      assert_true((actual_target.z - target.z).abs() < 0.000001)
    }
    None => panic()
  }
  assert_eq(placement.scale, 2.5)
}

///|
test "build_effect_runtime_window emits chain lightning bursts along line placement" {
  let doc = chain_lightning_effect_document()
  let bursts = build_effect_runtime_window(
    doc,
    0.0,
    0.12,
    new_effect_placement(
      @math3d.Vec3::new(0.0, 0.0, 0.0),
      Some(@math3d.Vec3::new(3.0, 0.0, 0.0)),
      1.0,
    ),
  )
  assert_true(bursts.length() >= 3)
  assert_true(bursts[0].config.position.x <= bursts[1].config.position.x)
  assert_true(bursts[bursts.length() - 1].config.position.x > 1.5)
}

///|
test "build_effect_runtime_window scales ice nova ring outward" {
  let doc = ice_nova_effect_document()
  let small = build_effect_runtime_window(
    doc,
    0.0,
    0.1,
    new_effect_placement(@math3d.Vec3::new(0.0, 0.0, 0.0), None, 1.0),
  )
  let large = build_effect_runtime_window(
    doc,
    0.0,
    0.1,
    new_effect_placement(@math3d.Vec3::new(0.0, 0.0, 0.0), None, 2.0),
  )
  assert_eq(small.length(), large.length())
  assert_true(large[0].config.position.length() > small[0].config.position.length())
}
