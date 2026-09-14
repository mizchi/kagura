///|
test "item grid preserves placement on collision and can move over its own cells" {
  let grid = ItemGrid::new(4, 4)
  let tall = GridFootprint::rectangle(1, 3).unwrap()
  let square = GridFootprint::rectangle(2, 2).unwrap()
  assert_true(grid.place(1, tall, 0, 0))
  assert_true(grid.place(2, square, 1, 0))
  assert_false(grid.place(1, tall, 1, 1))
  assert_eq(grid.placement(1).unwrap().x, 0)
  assert_true(grid.place(1, tall, 0, 1))
  assert_false(grid.place(1, tall, -1, 0))
  assert_false(grid.place(1, tall, 0, 2))
  assert_eq(grid.placement(1).unwrap().y, 1)
  assert_eq(grid.used_cells(), 7)
}

///|
test "irregular footprints leave usable holes and rotate around their bounding box" {
  let grid = ItemGrid::new(3, 3)
  let shape = GridFootprint::new([(0, 0), (0, 1), (0, 2), (1, 2)]).unwrap()
  assert_true(grid.place(0, shape, 0, 0))
  let dot = GridFootprint::rectangle(1, 1).unwrap()
  assert_true(grid.place(1, dot, 1, 0))
  assert_false(grid.place(2, dot, 1, 2))
  grid.remove(1)
  assert_true(grid.place(0, shape, 0, 0, rotated=true))
  assert_true(grid.placement(0).unwrap().rotated)
  assert_eq(grid.occupied_by(2, 0).unwrap(), 0)
  assert_true(grid.occupied_by(1, 1) is None)
  assert_eq(grid.find_space(dot).unwrap(), (1, 1))
  let copy = grid.clone()
  copy.remove(0)
  assert_eq(copy.used_cells(), 0)
  assert_eq(grid.used_cells(), 4)
}

///|
test "footprints reject empty, duplicate and negative cells" {
  assert_true(GridFootprint::new([]) is None)
  assert_true(GridFootprint::new([(0, 0), (0, 0)]) is None)
  assert_true(GridFootprint::new([(-1, 0)]) is None)
  assert_true(GridFootprint::rectangle(0, 3) is None)
}
