// Room-based occlusion culling
// Determines visible region based on player's room + adjacent rooms

///|
struct VisibleRegion {
  min_col : Int
  max_col : Int
  min_row : Int
  max_row : Int
}

///|
fn find_player_room(
  rooms : Array[@terrain.Room],
  player_x : Double,
  player_y : Double,
) -> Int {
  let col = (player_x / tile_size).to_int()
  let row = (player_y / tile_size).to_int()
  for i, room in rooms {
    let r = room.rect
    if col >= r.x && col < r.x + r.w && row >= r.y && row < r.y + r.h {
      return i
    }
  }
  -1
}

///|
fn compute_visible_region(
  rooms : Array[@terrain.Room],
  player_x : Double,
  player_y : Double,
  grid_w : Int,
  grid_h : Int,
) -> VisibleRegion {
  let pcol = (player_x / tile_size).to_int()
  let prow = (player_y / tile_size).to_int()
  let player_room = find_player_room(rooms, player_x, player_y)
  // Base visibility: 10 tile radius around player
  let mut min_col = pcol - 10
  let mut max_col = pcol + 10
  let mut min_row = prow - 10
  let mut max_row = prow + 10
  // Expand to include player's room fully
  if player_room >= 0 {
    let r = rooms[player_room].rect
    min_col = @cmp.minimum(min_col, r.x - 2)
    max_col = @cmp.maximum(max_col, r.x + r.w + 2)
    min_row = @cmp.minimum(min_row, r.y - 2)
    max_row = @cmp.maximum(max_row, r.y + r.h + 2)
  }
  // Include nearby rooms (Chebyshev distance < 18 tiles from player)
  for i, room in rooms {
    if i == player_room {
      continue
    }
    let r = room.rect
    let cx = r.x + r.w / 2
    let cy = r.y + r.h / 2
    let dist = @cmp.maximum((cx - pcol).abs(), (cy - prow).abs())
    if dist < 18 {
      min_col = @cmp.minimum(min_col, r.x - 1)
      max_col = @cmp.maximum(max_col, r.x + r.w + 1)
      min_row = @cmp.minimum(min_row, r.y - 1)
      max_row = @cmp.maximum(max_row, r.y + r.h + 1)
    }
  }
  {
    min_col: @cmp.maximum(0, min_col),
    max_col: @cmp.minimum(grid_w - 1, max_col),
    min_row: @cmp.maximum(0, min_row),
    max_row: @cmp.minimum(grid_h - 1, max_row),
  }
}

///|
fn is_entity_visible(region : VisibleRegion, x : Double, y : Double) -> Bool {
  let col = (x / tile_size).to_int()
  let row = (y / tile_size).to_int()
  col >= region.min_col &&
  col <= region.max_col &&
  row >= region.min_row &&
  row <= region.max_row
}
