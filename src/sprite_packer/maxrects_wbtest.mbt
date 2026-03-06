///|
test "single allocation fits" {
  let alloc = new_maxrects_allocator(64, 64)
  let result = alloc.insert(16, 16)
  assert_true(not(result is None))
  let pos = result.unwrap()
  assert_true(pos.x >= 0)
  assert_true(pos.y >= 0)
}

///|
test "multiple allocations no overlap" {
  let alloc = new_maxrects_allocator(64, 64)
  let positions : Array[AllocResult] = []
  let size = 16
  // Should fit at least 4x4 = 16 rects of 16x16 in 64x64
  for _ in 0..<16 {
    let r = alloc.insert(size, size)
    assert_true(not(r is None))
    positions.push(r.unwrap())
  }
  // Verify no overlaps
  for i in 0..<positions.length() {
    for j in (i + 1)..<positions.length() {
      let a = positions[i]
      let b = positions[j]
      let no_overlap = a.x + size <= b.x ||
        b.x + size <= a.x ||
        a.y + size <= b.y ||
        b.y + size <= a.y
      assert_true(no_overlap)
    }
  }
}

///|
test "allocation returns None when full" {
  let alloc = new_maxrects_allocator(32, 32)
  // Fill completely
  let r1 = alloc.insert(32, 32)
  assert_true(not(r1 is None))
  // No more space
  let r2 = alloc.insert(1, 1)
  assert_true(r2 is None)
}

///|
test "allocation too large returns None" {
  let alloc = new_maxrects_allocator(32, 32)
  let r = alloc.insert(33, 33)
  assert_true(r is None)
}

///|
test "mixed sizes pack correctly" {
  let alloc = new_maxrects_allocator(128, 128)
  let r1 = alloc.insert(64, 64)
  assert_true(not(r1 is None))
  let r2 = alloc.insert(32, 32)
  assert_true(not(r2 is None))
  let r3 = alloc.insert(16, 16)
  assert_true(not(r3 is None))
  // All within bounds
  let p1 = r1.unwrap()
  let p2 = r2.unwrap()
  let p3 = r3.unwrap()
  assert_true(p1.x + 64 <= 128 && p1.y + 64 <= 128)
  assert_true(p2.x + 32 <= 128 && p2.y + 32 <= 128)
  assert_true(p3.x + 16 <= 128 && p3.y + 16 <= 128)
}
