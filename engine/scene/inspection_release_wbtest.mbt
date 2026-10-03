///|
test "release wrapper adds no subject, key or name attributes" {
  let node = subject("bird", rect(key="body", name="Bird", w=12.0, h=12.0))
  guard node is Element(el) else { fail("Expected drawable rect") }
  assert_eq(el.tag, "rect")
  assert_eq(el.attrs.length(), 6)
  assert_true(
    el.attrs.all(pair => {
      pair.0 != "subject" && pair.0 != "key" && pair.0 != "name"
    }),
  )
}

///|
test "release UI identity retains dialog controls without inspector metadata" {
  let node = ui_key(
    "modal",
    rect(key="debug-modal", w=80.0, h=40.0, role="dialog", children=[
      ui_key("close", rect(w=20.0, h=12.0, role="button", focused=true)),
      ui_key("title", label(content="DECK")),
    ]),
  )
  let snapshot = ui_snapshot_from_scene(
    node, screen_width=100.0, screen_height=100.0,
  )
  assert_eq(snapshot.nodes.length(), 3)
  assert_eq(snapshot.nodes[0].id, "modal")
  assert_eq(snapshot.nodes[0].role, "dialog")
  assert_eq(snapshot.nodes[1].path, "modal>close")
  assert_true(snapshot.nodes[1].focused)
  assert_eq(snapshot.nodes[2].id, "title")
  assert_eq(snapshot.focus_order, ["close"])
  guard node is Element(el) else { fail("Expected drawable rect") }
  assert_true(el.attrs.all(pair => pair.0 != "key" && pair.0 != "name"))
}
