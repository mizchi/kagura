///|
test "modal background remains drawable but is absent from the active UI snapshot" {
  let tree = fragment([
    group(ui_hidden=true, children=[
      rect(key="background", w=100.0, h=40.0, focused=true),
    ]),
    rect(key="dialog", w=200.0, h=120.0, role="dialog", children=[
      rect(key="close", w=100.0, h=40.0, focused=true),
    ]),
  ])
  let snapshot = ui_snapshot_from_scene(
    tree,
    screen_width=320.0,
    screen_height=240.0,
  )
  assert_false(snapshot.nodes.any(n => n.id == "background"))
  assert_eq(snapshot.focus_order, ["close"])
  assert_eq(snapshot_node_by_id(snapshot, "dialog").role, "dialog")
}
