///|
test "1x1 Floor produces floor quad (4 verts, 6 indices)" {
  let grid = @terrain.Grid2D::make(1, 1, @terrain.Tile::Floor)
  let mesh = grid_to_mesh3d(grid)
  assert_eq(mesh.vertex_count(), 4)
  assert_eq(mesh.triangle_count(), 2)
}

///|
test "1x1 Wall produces box (24 verts, 36 indices)" {
  let grid = @terrain.Grid2D::make(1, 1, @terrain.Tile::Wall)
  let mesh = grid_to_mesh3d(grid)
  assert_eq(mesh.vertex_count(), 24)
  assert_eq(mesh.triangle_count(), 12)
}

///|
test "1x1 Empty produces no geometry" {
  let grid = @terrain.Grid2D::make(1, 1, @terrain.Tile::Empty)
  let mesh = grid_to_mesh3d(grid)
  assert_eq(mesh.vertex_count(), 0)
  assert_eq(mesh.triangle_count(), 0)
}

///|
test "mixed grid produces correct vertex count" {
  // 2x2 grid: Floor, Wall, Corridor, Empty
  let grid = @terrain.Grid2D::make(2, 2, @terrain.Tile::Floor)
  grid.set(1, 0, @terrain.Tile::Wall)
  grid.set(0, 1, @terrain.Tile::Corridor)
  grid.set(1, 1, @terrain.Tile::Empty)
  let mesh = grid_to_mesh3d(grid)
  // Floor(4) + Wall(24) + Corridor(4) + Empty(0) = 32 verts
  assert_eq(mesh.vertex_count(), 32)
  // Floor(2) + Wall(12) + Corridor(2) + Empty(0) = 16 tris
  assert_eq(mesh.triangle_count(), 16)
}

///|
test "Door produces half-height box" {
  let grid = @terrain.Grid2D::make(1, 1, @terrain.Tile::Door)
  let mesh = grid_to_mesh3d(grid)
  // Box: 24 verts, 12 tris
  assert_eq(mesh.vertex_count(), 24)
  assert_eq(mesh.triangle_count(), 12)
}

///|
test "Water produces floor quad" {
  let grid = @terrain.Grid2D::make(1, 1, @terrain.Tile::Water)
  let mesh = grid_to_mesh3d(grid)
  assert_eq(mesh.vertex_count(), 4)
  assert_eq(mesh.triangle_count(), 2)
}

///|
test "larger grid performance" {
  // 50x50 open grid
  let grid = @terrain.Grid2D::make(50, 50, @terrain.Tile::Floor)
  let mesh = grid_to_mesh3d(grid)
  // 2500 floor tiles, each 4 verts = 10000 verts
  assert_eq(mesh.vertex_count(), 10000)
}

///|
test "custom tile_size affects positions" {
  let grid = @terrain.Grid2D::make(1, 1, @terrain.Tile::Floor)
  let mesh = grid_to_mesh3d(grid, tile_size=2.0)
  // First vertex x should be 0.0, second should be 2.0
  assert_true(mesh.vertex_data[0] == 0.0) // px of first vert
  assert_true(mesh.vertex_data[8] == 2.0) // px of second vert
}
