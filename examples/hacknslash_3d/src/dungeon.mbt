// Dungeon generation using Diablo-style connected fields

struct DungeonData {
  mut grid : @terrain.Grid2D
  rooms : Array[@terrain.Room]
  mut start_x : Double
  mut start_y : Double
  // Per-tile height map (indexed by row * width + col)
  height_map : Array[Double]
}

fn generate_dungeon(seed : Int) -> DungeonData {
  let rng = @terrain.make_rng(seed.to_uint())
  let config : @diablo.DiabloConfig = {
    width: map_cols,
    height: map_rows,
    spine_length: 4 + seed % 3, // 4-6 connected areas
    branch_chance: 0.4,
    loop_chance: 0.4,
    room_min_size: 9,
    room_max_size: 19,
    room_padding: 2,
    max_placement_attempts: 100,
  }
  let result = @diablo.generate(config, rng)
  // Build height map: each room at a different elevation
  let height_map = build_height_map(result.grid, result.rooms, seed)
  // Find start room (entrance)
  let start_room = result.rooms[0]
  let center = start_room.rect.center()
  {
    grid: result.grid,
    rooms: result.rooms,
    start_x: center.x.to_double() * tile_size + tile_size / 2.0,
    start_y: center.y.to_double() * tile_size + tile_size / 2.0,
    height_map,
  }
}

// Assign each room a base elevation, corridors get interpolated height
fn build_height_map(
  grid : @terrain.Grid2D,
  rooms : Array[@terrain.Room],
  seed : Int,
) -> Array[Double] {
  let w = grid.width
  let h = grid.height
  let map : Array[Double] = Array::make(w * h, -0.5)
  // Assign room elevations: vary between 0.0 and 1.2
  let room_heights : Array[Double] = []
  for i = 0; i < rooms.length(); i = i + 1 {
    // Deterministic pseudo-random height per room
    let hash = (seed * 31 + i * 17 + 7) % 100
    let elevation = hash.to_double() / 100.0 * 1.2
    room_heights.push(elevation)
  }
  // Fill room tiles with their room's height
  for i = 0; i < rooms.length(); i = i + 1 {
    let room = rooms[i]
    let rect = room.rect
    for ry = rect.y; ry < rect.y + rect.h; ry = ry + 1 {
      for rx = rect.x; rx < rect.x + rect.w; rx = rx + 1 {
        if rx >= 0 && rx < w && ry >= 0 && ry < h {
          map[ry * w + rx] = room_heights[i]
        }
      }
    }
  }
  // Fill corridor/door tiles: find nearest room height or average
  for row = 0; row < h; row = row + 1 {
    for col = 0; col < w; col = col + 1 {
      let tile = grid.get(col, row)
      match tile {
        Corridor | Door => {
          // Average height of nearby floor tiles
          let mut sum = 0.0
          let mut count = 0
          for dy = -3; dy <= 3; dy = dy + 1 {
            for dx = -3; dx <= 3; dx = dx + 1 {
              let nx = col + dx
              let ny = row + dy
              if nx >= 0 && nx < w && ny >= 0 && ny < h {
                let idx = ny * w + nx
                if map[idx] >= 0.0 {
                  sum = sum + map[idx]
                  count = count + 1
                }
              }
            }
          }
          if count > 0 {
            map[row * w + col] = sum / count.to_double()
          } else {
            map[row * w + col] = 0.0
          }
        }
        _ => ()
      }
    }
  }
  // Wall tiles: match adjacent floor height
  for row = 0; row < h; row = row + 1 {
    for col = 0; col < w; col = col + 1 {
      if grid.get(col, row) == @terrain.Wall {
        let mut sum = 0.0
        let mut count = 0
        for dy = -1; dy <= 1; dy = dy + 1 {
          for dx = -1; dx <= 1; dx = dx + 1 {
            let nx = col + dx
            let ny = row + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let adj_tile = grid.get(nx, ny)
              match adj_tile {
                Floor | Corridor | Door | Start | Goal => {
                  sum = sum + map[ny * w + nx]
                  count = count + 1
                }
                _ => ()
              }
            }
          }
        }
        if count > 0 {
          map[row * w + col] = sum / count.to_double()
        }
      }
    }
  }
  map
}

// Get tile height at world position
fn get_tile_height(dungeon : DungeonData, x : Double, y : Double) -> Double {
  let col = (x / tile_size).to_int()
  let row = (y / tile_size).to_int()
  if col < 0 || col >= dungeon.grid.width || row < 0 || row >= dungeon.grid.height {
    return 0.0
  }
  dungeon.height_map[row * dungeon.grid.width + col]
}

fn is_wall_at(grid : @terrain.Grid2D, x : Double, y : Double) -> Bool {
  let col = (x / tile_size).to_int()
  let row = (y / tile_size).to_int()
  if col < 0 || col >= grid.width || row < 0 || row >= grid.height {
    return true
  }
  grid.get(col, row) == @terrain.Wall
}

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

fn tile_color(tile : @terrain.Tile) -> Int {
  match tile {
    Floor | Start | Goal => 0x3A4A2A
    Wall => 0x5A5040
    Corridor => 0x44503A
    Door => 0x6B5A14
    _ => 0x1A1A1E
  }
}

// Tile color with coordinate-based variation
fn tile_color_varied(tile : @terrain.Tile, col : Int, row : Int) -> Int {
  match tile {
    Floor | Start | Goal => {
      let checker = (col + row) % 2
      if checker == 0 { 0x3A4A2A } else { 0x3E4E2E }
    }
    Wall => {
      let brick_offset = if row % 2 == 0 { 0 } else { 2 }
      let brick_pos = (col + brick_offset) % 4
      if brick_pos == 0 { 0x504836 } else { 0x5A5040 }
    }
    Corridor => {
      let stripe = (col + row) % 3
      if stripe == 0 { 0x3E4A34 } else { 0x44503A }
    }
    Door => 0x6B5A14
    _ => 0x1A1A1E
  }
}
