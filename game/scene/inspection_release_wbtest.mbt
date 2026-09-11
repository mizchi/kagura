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
