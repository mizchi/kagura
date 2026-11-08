///|
test "disabled scene actions are absent from focus order but explain their state" {
  let state = @kagura_ui.UIInteractionState::new(
    available=false,
    selected=true,
    disabled_reason=Some("Bench is full"),
  )
  let tree = ui_key(
    "buy",
    rect(w=100.0, h=40.0, focused=true, interaction=state),
  )
  let snapshot = ui_snapshot_from_scene(
    tree,
    screen_width=320.0,
    screen_height=240.0,
  )
  let node = snapshot_node_by_id(snapshot, "buy")
  assert_false(node.focusable || node.focused)
  assert_eq(node.interaction.unwrap().disabled_reason, Some("Bench is full"))
  assert_eq(snapshot.focus_order, [])
}

///|
test "shared panels publish selected drop targets and keep release identities" {
  let tree = control_panel(
    "target",
    @kagura_ui.LayoutRect::new(10.0, 20.0, 100.0, 40.0),
    @kagura_ui.UIInteractionState::new(selected=true, drop_target=true),
    fill=0x223630,
    border=0x455A60,
    children=[],
  )
  let snapshot = ui_snapshot_from_scene(
    tree,
    screen_width=320.0,
    screen_height=240.0,
  )
  let node = snapshot_node_by_id(snapshot, "target")
  assert_true(node.interaction.unwrap().drop_target)
  assert_true(node.interaction.unwrap().selected)
  assert_eq(snapshot.hit_test(60.0, 40.0).unwrap().id, "target")
  assert_true(snapshot.nodes.any(n => n.id == "target_actionable"))
}
