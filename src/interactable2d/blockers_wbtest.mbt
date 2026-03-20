///|
test "stamp_circular_blockers_on_grid appends only solid interactables" {
  let grid = @terrain.Grid2D::make(8, 8, @terrain.Empty)
  let interactables : Array[CircularInteractable] = [
    CircularInteractable::new(24.0, 24.0, 8.0, Blocking),
    CircularInteractable::new(88.0, 88.0, 8.0, Pickup),
  ]
  stamp_circular_blockers_on_grid(grid, interactables, 16.0)
  assert_eq(grid.get(1, 1), @terrain.Wall)
  assert_eq(grid.get(5, 5), @terrain.Empty)
}

///|
test "stamp_circular_blockers_on_grid leaves empty input unchanged" {
  let grid = @terrain.Grid2D::make(4, 4, @terrain.Empty)
  stamp_circular_blockers_on_grid(grid, [], 16.0)
  for row = 0; row < grid.height; row = row + 1 {
    for col = 0; col < grid.width; col = col + 1 {
      assert_eq(grid.get(col, row), @terrain.Empty)
    }
  }
}
