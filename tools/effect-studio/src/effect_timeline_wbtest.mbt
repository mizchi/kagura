///|
test "build_timeline_view exposes lane ratios and marker counts" {
  let doc = default_effect_document()
  let view = build_timeline_view(doc, 0.5)
  assert_eq(view.lanes.length(), 3)
  assert_true((view.playhead_ratio - 0.5 / 1.8).abs() < 0.000001)
  assert_false(view.lanes[0].active)
  assert_true(view.lanes[1].active)
  assert_true(view.lanes[2].active)
  assert_eq(view.lanes[0].marker_ratios.length(), 1)
  assert_eq(view.lanes[1].marker_ratios.length(), 6)
  assert_eq(view.lanes[2].marker_ratios.length(), 6)
}
