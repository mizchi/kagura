// Dungeon generation using BSP algorithm

///|
struct DungeonData {
  mut grid : @terrain.Grid2D
  rooms : Array[@terrain.Room]
  mut start_x : Double
  mut start_y : Double
}

///|
fn generate_dungeon(seed : Int) -> DungeonData {
  let rng = @terrain.make_rng(seed.reinterpret_as_uint())
  let config : @bsp.BspConfig = {
    width: map_cols,
    height: map_rows,
    min_room_size: 4,
    max_depth: 5,
  }
  let result = @bsp.generate(config, rng)
  let start_room = result.rooms[0]
  let center = start_room.rect.center()
  {
    grid: result.grid,
    rooms: result.rooms,
    start_x: center.x.to_double() * tile_size + tile_size / 2.0,
    start_y: center.y.to_double() * tile_size + tile_size / 2.0,
  }
}

///|
fn is_wall_at(grid : @terrain.Grid2D, x : Double, y : Double) -> Bool {
  let col = (x / tile_size).to_int()
  let row = (y / tile_size).to_int()
  if col < 0 || col >= grid.width || row < 0 || row >= grid.height {
    return true
  }
  grid.get(col, row) == @terrain.Wall
}

///|
fn check_wall_collision(
  grid : @terrain.Grid2D,
  x : Double,
  y : Double,
  size : Double,
) -> Bool {
  let half = size / 2.0
  let left_col = ((x - half) / tile_size).to_int()
  let right_col = ((x + half) / tile_size).to_int()
  let top_row = ((y - half) / tile_size).to_int()
  let bottom_row = ((y + half) / tile_size).to_int()
  for row = top_row; row <= bottom_row; row = row + 1 {
    for col = left_col; col <= right_col; col = col + 1 {
      if col < 0 || col >= grid.width || row < 0 || row >= grid.height {
        return true
      }
      if grid.get(col, row) == @terrain.Wall {
        return true
      }
    }
  }
  false
}

///|
fn tile_color(tile : @terrain.Tile) -> Int {
  match tile {
    Floor => 0x2A2A3A
    Wall => 0x6B4226
    Corridor => 0x333344
    Door => 0x8B6914
    _ => 0x1A1A2E
  }
}

// Tile color with coordinate-based variation

///|
fn tile_color_varied(tile : @terrain.Tile, col : Int, row : Int) -> Int {
  match tile {
    Floor => {
      // Checker pattern with subtle variation
      let checker = (col + row) % 2
      if checker == 0 {
        0x2A2A3A
      } else {
        0x2E2E3E
      }
    }
    Wall => {
      // Brick pattern: offset every other row
      let brick_offset = if row % 2 == 0 { 0 } else { 2 }
      let brick_pos = (col + brick_offset) % 4
      if brick_pos == 0 {
        0x5B3216
      } else {
        0x6B4226
      }
    }
    Corridor => {
      // Directional stripe
      let stripe = (col + row) % 3
      if stripe == 0 {
        0x2D2D3E
      } else {
        0x333344
      }
    }
    Door => 0x8B6914
    _ => 0x1A1A2E
  }
}
