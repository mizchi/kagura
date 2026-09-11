///|
test "release renders the graph without an inspection hierarchy" {
  let root = SceneRoot::new()
  root.render(
    group(key="world", children=[
      subject("player", group(key="body", children=[])),
    ]),
  )
  assert_eq(root.hierarchy().length(), 0)
  assert_true(root.node_id("world/body") is Some(_))
}
