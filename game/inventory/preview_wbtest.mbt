///|
test "preview uses grid overlap rules without changing placements" {
  let shape = GridFootprint::new([(0, 0), (1, 0), (0, 1), (0, 2)]).unwrap()
  let single = GridFootprint::rectangle(1, 1).unwrap()
  let items = [
    { source: 0, slot: 0, footprint: shape, x: 0, y: 0, rotated: false, },
  ]
  let ring : PreviewItem = {
    source: 1,
    slot: 2,
    footprint: single,
    x: 0,
    y: 0,
    rotated: false,
  }
  assert_true(preview_placement(4, 4, items, ring, 1, 1, false).valid)
  assert_true(preview_placement(4, 4, items, ring, 0, 1, false).swap)
  assert_false(
    preview_placement(4, 4, items, { ..ring, source: -1, }, 0, 1, false).valid,
  )
  assert_false(preview_placement(4, 4, items, items[0], 3, 0, false).valid)
  assert_eq(shape.cells(), [(0, 0), (1, 0), (0, 1), (0, 2)])
}
