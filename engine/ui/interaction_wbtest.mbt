///|
test "unavailable controls cannot advertise selection or accepted drops" {
  let state = UIInteractionState::new(
    available=false,
    selected=true,
    drop_target=true,
    disabled_reason=Some("Not enough gold"),
  )
  assert_false(state.available || state.selected || state.drop_target)
  assert_eq(state.disabled_reason, Some("Not enough gold"))
  let enabled = UIInteractionState::new(
    selected=true,
    drop_target=true,
    disabled_reason=Some("stale reason"),
  )
  assert_true(enabled.available && enabled.selected && enabled.drop_target)
  assert_eq(enabled.disabled_reason, None)
}

///|
test "interaction hit testing blocks disabled children instead of activating their parent" {
  let child = UINodeId::new(1)
  let parent = UINodeId::new(2)
  let layouts = [
    { node_id: child, rect: { x: 10.0, y: 10.0, width: 20.0, height: 20.0, }, },
    { node_id: parent, rect: { x: 0.0, y: 0.0, width: 100.0, height: 100.0, }, },
  ]
  let resolve = id => UIInteractionState::new(available=id == parent)
  assert_eq(hit_test_interactive(layouts, 15.0, 15.0, resolve), None)
  assert_eq(hit_test_interactive(layouts, 50.0, 50.0, resolve), Some(parent))
}

///|
test "snapshots publish action states and preserve escaped disabled reasons" {
  let state = UIInteractionState::new(
    available=false,
    disabled_reason=Some("Need \"gold\"\nfirst"),
  )
  let snapshot = {
    ..default_ui_snapshot(screen_width=100.0, screen_height=100.0),
    nodes: [
      { ..default_ui_snapshot_node(), id: "buy", interaction: Some(state), },
    ],
  }
  let json = snapshot.to_json()
  assert_true(json.contains("\"interaction\":{\"available\":false"))
  assert_true(
    json.contains("\"disabled_reason\":\"Need \\\"gold\\\"\\nfirst\""),
  )
}

///|
test "snapshot hit testing picks the topmost action and respects unavailable controls" {
  let r : UISnapshotRect = { left: 0.0, top: 0.0, width: 20.0, height: 20.0, }
  let snapshot = {
    ..default_ui_snapshot(screen_width=100.0, screen_height=100.0),
    nodes: [
      {
        ..default_ui_snapshot_node(),
        id: "under",
        hit: Some(r),
        interaction: Some(UIInteractionState::new(drop_target=true)),
      },
      { ..default_ui_snapshot_node(), id: "label", hit: Some(r), },
      {
        ..default_ui_snapshot_node(),
        id: "over",
        hit: Some(r),
        interaction: Some(UIInteractionState::new(available=false)),
      },
    ],
  }
  assert_true(snapshot.hit_test(10.0, 10.0) is None)
  assert_eq(snapshot.hit_test(10.0, 10.0, drop_only=true).unwrap().id, "under")
  assert_true(snapshot.hit_test(30.0, 30.0) is None)
  let active = { ..snapshot, nodes: [snapshot.nodes[0], snapshot.nodes[1]], }
  assert_eq(active.hit_test(10.0, 10.0).unwrap().id, "under")
}
