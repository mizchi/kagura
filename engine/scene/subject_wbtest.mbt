///|
test "subject identity follows its declaration independently of render path" {
  let scene = resolve(
    group(key="world", children=[
      subject("bird", rect(key="body", w=12.0, h=12.0)),
    ]),
  )
  assert_eq(scene.hierarchy[0].children[0].id, "world/body")
  assert_eq(scene.hierarchy[0].children[0].subject, Some("bird"))
  assert_eq(scene.hierarchy[0].subject, None)
}
