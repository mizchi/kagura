///|
test "ScissorRect::intersect returns overlap" {
  let a = ScissorRect::new(10, 10, 100, 100)
  let b = ScissorRect::new(50, 50, 100, 100)
  let c = a.intersect(b).unwrap()
  assert_eq(c.x, 50)
  assert_eq(c.y, 50)
  assert_eq(c.width, 60)
  assert_eq(c.height, 60)
}

///|
test "ScissorRect::intersect returns None when no overlap" {
  let a = ScissorRect::new(0, 0, 50, 50)
  let b = ScissorRect::new(100, 100, 50, 50)
  assert_true(a.intersect(b) is None)
}

///|
test "ScissorRect::intersect handles adjacent rects as non-overlapping" {
  let a = ScissorRect::new(0, 0, 50, 50)
  let b = ScissorRect::new(50, 0, 50, 50)
  assert_true(a.intersect(b) is None)
}

///|
test "ScissorStack starts with full screen" {
  let stack = ScissorStack::new(640, 480)
  let c = stack.current()
  assert_eq(c.x, 0)
  assert_eq(c.y, 0)
  assert_eq(c.width, 640)
  assert_eq(c.height, 480)
  assert_eq(stack.depth(), 1)
}

///|
test "ScissorStack push narrows clip region" {
  let stack = ScissorStack::new(640, 480)
  let visible = stack.push(ScissorRect::new(100, 100, 200, 200))
  assert_true(visible)
  let c = stack.current()
  assert_eq(c.x, 100)
  assert_eq(c.y, 100)
  assert_eq(c.width, 200)
  assert_eq(c.height, 200)
  assert_eq(stack.depth(), 2)
}

///|
test "ScissorStack nested push intersects with parent" {
  let stack = ScissorStack::new(640, 480)
  let _ = stack.push(ScissorRect::new(100, 100, 200, 200))
  let _ = stack.push(ScissorRect::new(150, 150, 300, 300))
  let c = stack.current()
  // Intersection: max(100,150)=150, min(300,450)=300 → width=150
  assert_eq(c.x, 150)
  assert_eq(c.y, 150)
  assert_eq(c.width, 150)
  assert_eq(c.height, 150)
  assert_eq(stack.depth(), 3)
}

///|
test "ScissorStack pop restores previous clip" {
  let stack = ScissorStack::new(640, 480)
  let _ = stack.push(ScissorRect::new(100, 100, 200, 200))
  stack.pop()
  let c = stack.current()
  assert_eq(c.width, 640)
  assert_eq(c.height, 480)
  assert_eq(stack.depth(), 1)
}

///|
test "ScissorStack push returns false when fully clipped" {
  let stack = ScissorStack::new(640, 480)
  let _ = stack.push(ScissorRect::new(0, 0, 100, 100))
  let visible = stack.push(ScissorRect::new(200, 200, 50, 50))
  assert_true(!visible)
  assert_true(!stack.is_visible())
  // Pop still works
  stack.pop()
  assert_true(stack.is_visible())
}

///|
test "ScissorStack pop on root is no-op" {
  let stack = ScissorStack::new(640, 480)
  stack.pop()
  assert_eq(stack.depth(), 1)
  assert_eq(stack.current().width, 640)
}

///|
test "ScissorRect::to_dst_region converts correctly" {
  let r = ScissorRect::new(10, 20, 100, 200)
  let dst = r.to_dst_region(36)
  assert_eq(dst.x, 10)
  assert_eq(dst.y, 20)
  assert_eq(dst.width, 100)
  assert_eq(dst.height, 200)
  assert_eq(dst.index_count, 36)
}
