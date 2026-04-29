///|
test "find_path straight line" {
  // 5x1 corridor: all Floor
  let grid = @terrain.Grid2D::make(5, 1, @terrain.Tile::Floor)
  let path = find_path(grid, { x: 0, y: 0 }, { x: 4, y: 0 })
  match path {
    Some(p) => {
      assert_eq(p.length(), 5)
      assert_eq(p[0], { x: 0, y: 0 })
      assert_eq(p[4], { x: 4, y: 0 })
    }
    None => assert_true(false)
  }
}

///|
test "find_path avoids walls" {
  // 3x3 grid with wall in the middle:
  // F F F
  // F W F
  // F F F
  let grid = @terrain.Grid2D::make(3, 3, @terrain.Tile::Floor)
  grid.set(1, 1, @terrain.Tile::Wall)
  let path = find_path(grid, { x: 0, y: 0 }, { x: 2, y: 2 })
  match path {
    Some(p) => {
      // Path should go around the wall
      assert_true(p.length() >= 5)
      // Ensure no step lands on wall
      for step in p {
        let tile = grid.get(step.x, step.y)
        assert_true(tile != @terrain.Tile::Wall)
      }
    }
    None => assert_true(false)
  }
}

///|
test "find_path unreachable returns None" {
  // 3x3 grid, wall column at x=1 blocks path
  // F W F
  // F W F
  // F W F
  let grid = @terrain.Grid2D::make(3, 3, @terrain.Tile::Floor)
  grid.set(1, 0, @terrain.Tile::Wall)
  grid.set(1, 1, @terrain.Tile::Wall)
  grid.set(1, 2, @terrain.Tile::Wall)
  let path = find_path(grid, { x: 0, y: 0 }, { x: 2, y: 2 })
  assert_true(path is None)
}

///|
test "find_path same start and goal" {
  let grid = @terrain.Grid2D::make(3, 3, @terrain.Tile::Floor)
  let path = find_path(grid, { x: 1, y: 1 }, { x: 1, y: 1 })
  match path {
    Some(p) => assert_eq(p.length(), 1)
    None => assert_true(false)
  }
}

///|
test "find_path walks through doors and corridors" {
  // F D C G
  let grid = @terrain.Grid2D::make(4, 1, @terrain.Tile::Floor)
  grid.set(1, 0, @terrain.Tile::Door)
  grid.set(2, 0, @terrain.Tile::Corridor)
  grid.set(3, 0, @terrain.Tile::Goal)
  let path = find_path(grid, { x: 0, y: 0 }, { x: 3, y: 0 })
  match path {
    Some(p) => assert_eq(p.length(), 4)
    None => assert_true(false)
  }
}

///|
test "find_path on larger grid" {
  // 20x20 open grid
  let grid = @terrain.Grid2D::make(20, 20, @terrain.Tile::Floor)
  let path = find_path(grid, { x: 0, y: 0 }, { x: 19, y: 19 })
  match path {
    Some(p) =>
      // Manhattan distance = 38, path length = 39 (including start)
      assert_eq(p.length(), 39)
    None => assert_true(false)
  }
}

///|
test "find_path start on wall returns None" {
  let grid = @terrain.Grid2D::make(3, 3, @terrain.Tile::Floor)
  grid.set(0, 0, @terrain.Tile::Wall)
  let path = find_path(grid, { x: 0, y: 0 }, { x: 2, y: 2 })
  assert_true(path is None)
}

///|
test "find_path custom walkable function" {
  // Use Water as walkable
  let grid = @terrain.Grid2D::make(3, 1, @terrain.Tile::Water)
  let path = find_path(grid, { x: 0, y: 0 }, { x: 2, y: 0 }, walkable=fn(tile) {
    tile == @terrain.Tile::Water
  })
  match path {
    Some(p) => assert_eq(p.length(), 3)
    None => assert_true(false)
  }
}
