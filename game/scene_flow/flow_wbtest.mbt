///|
test "scene transitions commit only their live request and failure keeps the old scene" {
  let flow = Flow::new(["a", "b"], "a")
  let ticket = flow.request("b")
  assert_eq(flow.current(), "a")
  assert_true(flow.cancel(ticket))
  assert_false(flow.commit(ticket))
  let next = flow.request("b")
  assert_false(flow.commit(ticket))
  assert_true(flow.commit(next))
  assert_eq(flow.current(), "b")
  let invalid = try {
    ignore(flow.request("missing"))
    false
  } catch {
    _ => true
  }
  assert_true(invalid)
  assert_eq(flow.current(), "b")
}

///|
test "portal intersection is gameplay logic and does not require a renderer" {
  let portal = Portal::{ x: 2.0, z: 3.0, radius: 0.75, target: "next", }
  assert_true(portal.contains(2.5, 3.0))
  assert_false(portal.contains(4.0, 3.0))
}
