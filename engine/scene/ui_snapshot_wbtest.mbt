///|
fn snapshot_node_by_id(
  snapshot : @kagura_ui.UISnapshot,
  id : String,
) -> @kagura_ui.UISnapshotNode {
  for node in snapshot.nodes {
    if node.id == id {
      return node
    }
  }
  abort("missing snapshot node " + id)
}

///|
test "scene controls publish logical focus and explicit focus order without changing geometry" {
  let tree = fragment([
    rect(
      key="later",
      w=100.0,
      h=40.0,
      role="button",
      focusable=true,
      focus_index=2,
    ),
    rect(
      key="end",
      x=120.0,
      w=100.0,
      h=40.0,
      role="button",
      focused=true,
      focus_index=0,
    ),
    rect(key="decoration", y=50.0, w=100.0, h=40.0),
  ])
  let snapshot = ui_snapshot_from_scene(
    tree,
    screen_width=320.0,
    screen_height=240.0,
  )
  let end = snapshot_node_by_id(snapshot, "end")
  assert_eq(end.role, "button")
  assert_true(end.focused && end.focusable)
  assert_eq(end.left, 120.0)
  assert_eq(end.width, 100.0)
  assert_eq(snapshot.focus_order, ["end", "later"])
  assert_false(snapshot_node_by_id(snapshot, "decoration").focusable)
}

///|
test "scene snapshot omits unlabeled world rects and keeps labels" {
  let tree = fragment([
    rect(w=320.0, h=240.0, fill=0x112233),
    group(key="hud", x=0.0, y=0.0, children=[
      label(key="score", x=160.0, y=20.0, content="12", scale=1.0),
      label(key="hint", x=160.0, y=200.0, content="TAP", scale=2.0),
    ]),
  ])
  let snapshot = ui_snapshot_from_scene(
    tree,
    screen_width=320.0,
    screen_height=240.0,
    frame=3,
    state="title",
  )
  assert_eq(snapshot.screen_width, 320.0)
  assert_eq(snapshot.screen_height, 240.0)
  assert_eq(snapshot.frame, 3)
  assert_eq(snapshot.state, "title")
  assert_eq(snapshot.nodes.length(), 2)
  let score = snapshot_node_by_id(snapshot, "score")
  assert_eq(score.path, "hud>score")
  assert_eq(score.role, "label")
  assert_eq(score.text, Some("12"))
  let (tw, th) = @renderer2d.dot_text_size(2, scale=1.0)
  assert_eq(score.text_measured.unwrap().width, tw)
  assert_eq(score.text_measured.unwrap().height, th)
  assert_eq(score.width, tw)
  assert_eq(score.height, th)
  assert_eq(score.left, 160.0 - tw / 2.0)
  assert_eq(score.top, 20.0 - th / 2.0)
  let hint = snapshot_node_by_id(snapshot, "hint")
  assert_eq(hint.path, "hud>hint")
  assert_eq(hint.text, Some("TAP"))
  let (hw, hh) = @renderer2d.dot_text_size(3, scale=2.0)
  assert_eq(hint.text_measured.unwrap().width, hw)
  assert_eq(hint.text_measured.unwrap().height, hh)
}

///|
test "scene snapshot skips hidden show() branches" {
  let tree = fragment([
    label(key="always", x=10.0, y=10.0, content="A"),
    show(fn() { false }, fn() {
      label(key="hidden", x=10.0, y=20.0, content="B")
    }),
    show(fn() { true }, fn() {
      label(key="visible", x=10.0, y=30.0, content="C")
    }),
  ])
  let snapshot = ui_snapshot_from_scene(
    tree,
    screen_width=320.0,
    screen_height=240.0,
  )
  assert_eq(snapshot.nodes.length(), 2)
  assert_eq(snapshot.nodes[0].id, "always")
  assert_eq(snapshot.nodes[1].id, "visible")
}

///|
test "scene snapshot applies group offsets to labels" {
  let tree = group(key="hud", x=8.0, y=4.0, children=[
    label(key="hp", x=10.0, y=6.0, content="HP"),
  ])
  let snapshot = ui_snapshot_from_scene(
    tree,
    screen_width=320.0,
    screen_height=240.0,
  )
  let hp = snapshot_node_by_id(snapshot, "hp")
  let (tw, th) = @renderer2d.dot_text_size(2)
  assert_eq(hp.left, 18.0 - tw / 2.0)
  assert_eq(hp.top, 10.0 - th / 2.0)
}

///|
test "scene snapshot assigns generated ids when labels have no key" {
  let tree = fragment([
    label(x=4.0, y=4.0, content="X"),
    label(x=8.0, y=8.0, content="Y"),
  ])
  let snapshot = ui_snapshot_from_scene(
    tree,
    screen_width=64.0,
    screen_height=64.0,
  )
  assert_eq(snapshot.nodes.length(), 2)
  assert_eq(snapshot.nodes[0].id, "label_0")
  assert_eq(snapshot.nodes[1].id, "label_1")
  assert_eq(snapshot.nodes[0].path, "label[0]")
  assert_eq(snapshot.nodes[1].path, "label[1]")
}

///|
test "scene snapshot publishes keyed rects with the drawn hit box" {
  let tree = fragment([
    rect(w=320.0, h=240.0, fill=0x112233),
    group(key="hud", x=8.0, y=4.0, children=[
      rect(key="hp_bar", x=10.0, y=6.0, w=100.0, h=12.0, fill=0x333333),
      rect_outline(
        key="end_turn",
        x=20.0,
        y=30.0,
        w=80.0,
        h=24.0,
        color=0xAA7744,
      ),
      label(key="hp", x=60.0, y=12.0, content="HP"),
    ]),
  ])
  let snapshot = ui_snapshot_from_scene(
    tree,
    screen_width=320.0,
    screen_height=240.0,
  )
  assert_eq(snapshot.nodes.length(), 3)
  let bar = snapshot_node_by_id(snapshot, "hp_bar")
  assert_eq(bar.path, "hud>hp_bar")
  assert_eq(bar.role, "rect")
  assert_eq(bar.left, 18.0)
  assert_eq(bar.top, 10.0)
  assert_eq(bar.width, 100.0)
  assert_eq(bar.height, 12.0)
  assert_eq(bar.hit.unwrap().left, 18.0)
  assert_eq(bar.hit.unwrap().top, 10.0)
  assert_eq(bar.hit.unwrap().width, 100.0)
  assert_eq(bar.hit.unwrap().height, 12.0)
  let button = snapshot_node_by_id(snapshot, "end_turn")
  assert_eq(button.path, "hud>end_turn")
  assert_eq(button.role, "outline")
  assert_eq(button.left, 28.0)
  assert_eq(button.top, 34.0)
  assert_eq(button.width, 80.0)
  assert_eq(button.height, 24.0)
  assert_eq(button.hit.unwrap().width, 80.0)
  assert_eq(snapshot_node_by_id(snapshot, "hp").path, "hud>hp")
}
///|
test "UI identity overrides inspector identity and updates without duplicates" {
  let tree = ui_key(
    "controls",
    group(key="debug-group", children=[
      ui_key("button", ui_key("old-id", rect(key="debug-rect", w=20.0, h=12.0, focused=true))),
      ui_key("caption", label(key="debug-label", content="PLAY")),
    ]),
  )
  let snapshot = ui_snapshot_from_scene(tree, screen_width=100.0, screen_height=100.0)
  assert_eq(snapshot.nodes.length(), 2)
  assert_eq(snapshot.nodes[0].path, "controls>button")
  assert_eq(snapshot.nodes[1].path, "controls>caption")
  assert_eq(snapshot.focus_order, ["button"])
}
