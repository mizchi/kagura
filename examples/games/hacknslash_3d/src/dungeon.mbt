// Dungeon rendering helpers (tile color functions)
// Logic (generate_dungeon, collision, height map) is now in @game

///|
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

///|
fn tile_color_varied(tile : @terrain.Tile, col : Int, row : Int) -> Int {
  match tile {
    Floor | Start | Goal => {
      let checker = (col + row) % 2
      if checker == 0 {
        0x3A4A2A
      } else {
        0x3E4E2E
      }
    }
    Wall => {
      let brick_offset = if row % 2 == 0 { 0 } else { 2 }
      let brick_pos = (col + brick_offset) % 4
      if brick_pos == 0 {
        0x504836
      } else {
        0x5A5040
      }
    }
    Corridor => {
      let stripe = (col + row) % 3
      if stripe == 0 {
        0x3E4A34
      } else {
        0x44503A
      }
    }
    Door => 0x6B5A14
    _ => 0x1A1A1E
  }
}
