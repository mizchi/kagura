///|
test "grid_is_wall_at treats walls and out of bounds as blocking" {
  let grid = @terrain.Grid2D::make(4, 4, @terrain.Floor)
  grid.set(2, 1, @terrain.Wall)

  assert_true(grid_is_wall_at(grid, 2.0 * 16.0 + 1.0, 1.0 * 16.0 + 1.0, 16.0))
  assert_true(grid_is_wall_at(grid, -1.0, 0.0, 16.0))
  assert_false(grid_is_wall_at(grid, 1.0 * 16.0 + 1.0, 1.0 * 16.0 + 1.0, 16.0))
}

///|
test "grid_check_wall_collision detects box overlap with wall tiles" {
  let grid = @terrain.Grid2D::make(5, 5, @terrain.Floor)
  grid.set(3, 2, @terrain.Wall)

  assert_true(grid_check_wall_collision(grid, 3.5 * 16.0, 2.5 * 16.0, 14.0, 16.0))
  assert_false(
    grid_check_wall_collision(grid, 1.5 * 16.0, 1.5 * 16.0, 14.0, 16.0),
  )
}

///|
test "grid_segment_hits_wall detects blocking segment sweep" {
  let grid = @terrain.Grid2D::make(8, 8, @terrain.Floor)
  grid.set(3, 3, @terrain.Wall)

  assert_true(
    grid_segment_hits_wall(
      grid,
      2.5 * 16.0,
      3.5 * 16.0,
      4.5 * 16.0,
      3.5 * 16.0,
      0.0,
      16.0,
    ),
  )
  assert_false(
    grid_segment_hits_wall(
      grid,
      1.5 * 16.0,
      1.5 * 16.0,
      2.5 * 16.0,
      1.5 * 16.0,
      0.0,
      16.0,
    ),
  )
}

///|
test "grid_slide_move slides independently on x and y axes" {
  let grid = @terrain.Grid2D::make(4, 4, @terrain.Floor)
  grid.set(2, 1, @terrain.Wall)

  let (x, y) = grid_slide_move(
    grid,
    1.5 * 16.0,
    1.5 * 16.0,
    16.0,
    8.0,
    12.0,
    16.0,
  )
  assert_true((x - 1.5 * 16.0).abs() < 1.0e-9)
  assert_true(y > 1.5 * 16.0)
}

///|
test "clone_terrain_grid copies tile payloads" {
  let grid = @terrain.Grid2D::make(3, 3, @terrain.Floor)
  grid.set(1, 1, @terrain.Wall)
  let copy = clone_terrain_grid(grid)

  assert_eq(copy.get(0, 0), @terrain.Floor)
  assert_eq(copy.get(1, 1), @terrain.Wall)
}

///|
test "append_circular_wall_blocker marks nearby tiles as walls" {
  let grid = @terrain.Grid2D::make(6, 6, @terrain.Floor)
  append_circular_wall_blocker(grid, 2.5 * 16.0, 2.5 * 16.0, 8.0, 16.0)

  assert_eq(grid.get(2, 2), @terrain.Wall)
  assert_eq(grid.get(0, 0), @terrain.Floor)
}

///|
test "grid_line_of_sight_clear reflects segment blockers" {
  let grid = @terrain.Grid2D::make(8, 8, @terrain.Floor)
  grid.set(3, 3, @terrain.Wall)

  assert_false(
    grid_line_of_sight_clear(
      grid,
      2.5 * 16.0,
      3.5 * 16.0,
      4.5 * 16.0,
      3.5 * 16.0,
      0.0,
      16.0,
    ),
  )
  assert_true(
    grid_line_of_sight_clear(
      grid,
      1.5 * 16.0,
      1.5 * 16.0,
      2.5 * 16.0,
      1.5 * 16.0,
      0.0,
      16.0,
    ),
  )
}

///|
test "grid_find_nearest_visible_candidate_index chooses nearest unblocked point" {
  let grid = @terrain.Grid2D::make(8, 8, @terrain.Floor)
  grid.set(3, 3, @terrain.Wall)
  let xs = [4.5 * 16.0, 2.5 * 16.0, 5.5 * 16.0]
  let ys = [3.5 * 16.0, 1.5 * 16.0, 1.5 * 16.0]
  let alive = [true, true, false]

  let (index, dist_sq) = grid_find_nearest_visible_candidate_index(
    grid,
    1.5 * 16.0,
    1.5 * 16.0,
    0.0,
    128.0,
    xs.length(),
    fn(i) { alive[i] },
    fn(i) { xs[i] },
    fn(i) { ys[i] },
    16.0,
  )

  assert_eq(index, 1)
  assert_true(dist_sq > 0.0)
}
