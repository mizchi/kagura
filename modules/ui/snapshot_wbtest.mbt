///|
fn sample_snapshot() -> UISnapshot {
  {
    ..default_ui_snapshot(screen_width=640.0, screen_height=480.0),
    dpr: 2.0,
    frame: 120,
    state: "playing",
    nodes: [
      {
        ..default_ui_snapshot_node(),
        path: "hud[0]",
        id: "hud",
        role: "panel",
        classes: "hud-root",
        width: 640.0,
        height: 480.0,
      },
      {
        ..default_ui_snapshot_node(),
        path: "hud[0]>bar[0]",
        id: "hp_bar",
        role: "gauge",
        classes: "hud gauge",
        left: 16.0,
        top: 16.0,
        width: 200.0,
        height: 20.0,
        z: 3,
        clip: Some({ left: 0.0, top: 0.0, width: 640.0, height: 480.0 }),
        text: Some("HP 90/180"),
        text_measured: Some({ width: 214.0, height: 18.0 }),
        focusable: true,
        focus_index: 2,
        hit: Some({ left: 16.0, top: 16.0, width: 200.0, height: 20.0 }),
      },
    ],
    focus_order: ["start_button", "hp_bar"],
  }
}

///|
test "UISnapshot::to_json emits screen metadata" {
  let json = sample_snapshot().to_json()
  assert_true(json.contains("\"width\":640"))
  assert_true(json.contains("\"height\":480"))
  assert_true(json.contains("\"dpr\":2"))
  assert_true(json.contains("\"frame\":120"))
  assert_true(json.contains("\"state\":\"playing\""))
  assert_true(json.contains("\"safe_area\":{"))
}

///|
test "UISnapshot::to_json emits node geometry and metadata" {
  let json = sample_snapshot().to_json()
  assert_true(json.contains("\"path\":\"hud[0]>bar[0]\""))
  assert_true(json.contains("\"id\":\"hp_bar\""))
  assert_true(json.contains("\"classes\":\"hud gauge\""))
  assert_true(json.contains("\"left\":16"))
  assert_true(json.contains("\"z\":3"))
  assert_true(json.contains("\"text\":\"HP 90/180\""))
  assert_true(json.contains("\"text_measured\":{\"width\":214,\"height\":18}"))
  assert_true(json.contains("\"focusable\":true"))
  assert_true(json.contains("\"focus_index\":2"))
  assert_true(json.contains("\"focused\":false"))
  assert_true(json.contains("\"hit\":{"))
  assert_true(json.contains("\"clip\":{"))
  assert_true(json.contains("\"focus_order\":[\"start_button\",\"hp_bar\"]"))
}

///|
/// vlmkit's `--elements-json` requires `tag`; the snapshot carries `role` and
/// mirrors it into `tag` so the document is usable without a conversion step.
test "UISnapshot::to_json mirrors role into tag for vlmkit elements-json" {
  let json = sample_snapshot().to_json()
  assert_true(json.contains("\"tag\":\"gauge\""))
  assert_true(json.contains("\"role\":\"gauge\""))
}

///|
test "UISnapshot::to_json omits absent optional fields" {
  let snapshot = {
    ..default_ui_snapshot(screen_width=320.0, screen_height=240.0),
    nodes: [
      { ..default_ui_snapshot_node(), path: "a[0]", width: 10.0, height: 10.0 },
    ],
  }
  let json = snapshot.to_json()
  assert_false(json.contains("\"text\""))
  assert_false(json.contains("\"text_measured\""))
  assert_false(json.contains("\"clip\""))
  assert_false(json.contains("\"hit\""))
  assert_true(json.contains("\"nodes\":[{"))
}

///|
test "UISnapshot::to_json escapes strings" {
  let snapshot = {
    ..default_ui_snapshot(screen_width=320.0, screen_height=240.0),
    nodes: [
      {
        ..default_ui_snapshot_node(),
        path: "a[0]",
        text: Some("say \"hi\"\n\tnow\\then"),
      },
    ],
  }
  let json = snapshot.to_json()
  assert_true(json.contains("say \\\"hi\\\"\\n\\tnow\\\\then"))
}

///|
/// A hand-rolled escape covering only the obvious five characters emits a raw
/// control byte here, which is invalid JSON and would fail the consuming gate.
test "UISnapshot::to_json escapes control characters" {
  let snapshot = {
    ..default_ui_snapshot(screen_width=320.0, screen_height=240.0),
    nodes: [
      {
        ..default_ui_snapshot_node(),
        path: "a[0]",
        text: Some("bell\u{0007}and\u{0008}back"),
      },
    ],
  }
  let json = snapshot.to_json()
  assert_false(json.contains("\u{0007}"))
  assert_true(json.contains("\\b"))
}

///|
/// NaN / infinity have no JSON representation; emitting them verbatim would
/// produce a document no consumer can parse.
test "UISnapshot::to_json collapses non-finite doubles to zero" {
  let snapshot = {
    ..default_ui_snapshot(screen_width=0.0 / 0.0, screen_height=1.0 / 0.0),
    nodes: [],
  }
  let json = snapshot.to_json()
  assert_false(json.contains("NaN"))
  assert_false(json.contains("Infinity"))
  assert_true(json.contains("\"width\":0"))
  assert_true(json.contains("\"height\":0"))
}

///|
test "ui_snapshot_nodes_from_layouts carries geometry" {
  let layouts : Array[LayoutResult] = [
    {
      node_id: { value: 7 },
      rect: { x: 4.0, y: 8.0, width: 100.0, height: 20.0 },
    },
    {
      node_id: { value: 9 },
      rect: { x: 0.0, y: 0.0, width: 640.0, height: 480.0 },
    },
  ]
  let nodes = ui_snapshot_nodes_from_layouts(layouts)
  assert_eq(nodes.length(), 2)
  assert_eq(nodes[0].path, "node[0]")
  assert_eq(nodes[0].id, "node_7")
  assert_eq(nodes[0].left, 4.0)
  assert_eq(nodes[0].top, 8.0)
  assert_eq(nodes[0].width, 100.0)
  assert_eq(nodes[0].height, 20.0)
  assert_eq(nodes[0].z, 0)
  assert_eq(nodes[1].id, "node_9")
  assert_eq(nodes[1].z, 1)
}

///|
/// Layout results are the one input every UI already has, so the derived
/// snapshot has to be a valid, parseable document on its own.
test "layout-derived snapshot serializes" {
  let tree = UITree::new()
  let style = {
    ..default_node_style(),
    width: UISizing::Fixed(120.0),
    height: UISizing::Fixed(40.0),
  }
  let child = tree.add_node(style, [])
  let root_style = {
    ..default_node_style(),
    width: UISizing::Fixed(640.0),
    height: UISizing::Fixed(480.0),
  }
  let root = tree.add_node(root_style, [child])
  let engine = SimpleLayoutEngine::new(tree)
  let layouts = engine.compute_layout(
    root,
    default_layout_constraint(640.0, 480.0),
  )
  let snapshot = {
    ..default_ui_snapshot(screen_width=640.0, screen_height=480.0),
    nodes: ui_snapshot_nodes_from_layouts(layouts),
  }
  let json = snapshot.to_json()
  assert_true(json.length() > 0)
  assert_true(json.contains("\"nodes\":[{"))
  assert_true(snapshot.nodes.length() >= 2)
}
