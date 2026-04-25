///|
fn tile_index_at(value : Double, tile_size : Double) -> Int {
  @math.floor(value / tile_size).to_int()
}

///|
pub fn clone_terrain_grid(grid : @terrain.Grid2D) -> @terrain.Grid2D {
  let copy = @terrain.Grid2D::make(grid.width, grid.height, @terrain.Empty)
  for row = 0; row < grid.height; row = row + 1 {
    for col = 0; col < grid.width; col = col + 1 {
      copy.set(col, row, grid.get(col, row))
    }
  }
  copy
}

///|
pub fn grid_is_wall_at(
  grid : @terrain.Grid2D,
  x : Double,
  y : Double,
  tile_size : Double,
) -> Bool {
  let col = tile_index_at(x, tile_size)
  let row = tile_index_at(y, tile_size)
  if col < 0 || col >= grid.width || row < 0 || row >= grid.height {
    return true
  }
  grid.get(col, row) == @terrain.Wall
}

///|
pub fn grid_check_wall_collision(
  grid : @terrain.Grid2D,
  x : Double,
  y : Double,
  size : Double,
  tile_size : Double,
) -> Bool {
  let half = size / 2.0
  let left_col = tile_index_at(x - half, tile_size)
  let right_col = tile_index_at(x + half, tile_size)
  let top_row = tile_index_at(y - half, tile_size)
  let bottom_row = tile_index_at(y + half, tile_size)
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
pub fn grid_segment_hits_wall(
  grid : @terrain.Grid2D,
  start_x : Double,
  start_y : Double,
  end_x : Double,
  end_y : Double,
  size : Double,
  tile_size : Double,
) -> Bool {
  let dx = end_x - start_x
  let dy = end_y - start_y
  let max_delta = if dx.abs() > dy.abs() { dx.abs() } else { dy.abs() }
  let steps = @cmp.maximum(1, (max_delta / (tile_size * 0.25)).ceil().to_int())
  for step = 1; step <= steps; step = step + 1 {
    let t = step.to_double() / steps.to_double()
    let sample_x = start_x + dx * t
    let sample_y = start_y + dy * t
    if size > 0.0 {
      if grid_check_wall_collision(grid, sample_x, sample_y, size, tile_size) {
        return true
      }
    } else if grid_is_wall_at(grid, sample_x, sample_y, tile_size) {
      return true
    }
  }
  false
}

///|
pub fn grid_line_of_sight_clear(
  grid : @terrain.Grid2D,
  start_x : Double,
  start_y : Double,
  end_x : Double,
  end_y : Double,
  size : Double,
  tile_size : Double,
) -> Bool {
  !grid_segment_hits_wall(
    grid, start_x, start_y, end_x, end_y, size, tile_size,
  )
}

///|
pub fn grid_find_nearest_visible_candidate_index(
  grid : @terrain.Grid2D,
  origin_x : Double,
  origin_y : Double,
  viewer_size : Double,
  max_range : Double,
  candidate_count : Int,
  is_candidate_valid : (Int) -> Bool,
  get_candidate_x : (Int) -> Double,
  get_candidate_y : (Int) -> Double,
  tile_size : Double,
) -> (Int, Double) {
  let mut nearest_idx = -1
  let mut nearest_dist_sq = max_range * max_range
  for idx = 0; idx < candidate_count; idx = idx + 1 {
    if !(is_candidate_valid(idx)) {
      continue
    }
    let candidate_x = get_candidate_x(idx)
    let candidate_y = get_candidate_y(idx)
    let dx = candidate_x - origin_x
    let dy = candidate_y - origin_y
    let dist_sq = dx * dx + dy * dy
    if dist_sq < nearest_dist_sq &&
      grid_line_of_sight_clear(
        grid, origin_x, origin_y, candidate_x, candidate_y, viewer_size, tile_size,
      ) {
      nearest_dist_sq = dist_sq
      nearest_idx = idx
    }
  }
  (nearest_idx, nearest_dist_sq)
}

///|
pub fn grid_slide_move(
  grid : @terrain.Grid2D,
  x : Double,
  y : Double,
  vx : Double,
  vy : Double,
  size : Double,
  tile_size : Double,
) -> (Double, Double) {
  let nx = if !(grid_check_wall_collision(grid, x + vx, y, size, tile_size)) {
    x + vx
  } else {
    x
  }
  let ny = if !(grid_check_wall_collision(grid, nx, y + vy, size, tile_size)) {
    y + vy
  } else {
    y
  }
  (nx, ny)
}

///|
pub fn append_circular_wall_blocker(
  grid : @terrain.Grid2D,
  center_x : Double,
  center_y : Double,
  radius : Double,
  tile_size : Double,
) -> Unit {
  let tile_half = tile_size / 2.0
  let effective_radius = radius + tile_half
  let min_col = @cmp.maximum(
    0,
    tile_index_at(center_x - effective_radius, tile_size) - 1,
  )
  let max_col = @cmp.minimum(
    grid.width - 1,
    tile_index_at(center_x + effective_radius, tile_size) + 1,
  )
  let min_row = @cmp.maximum(
    0,
    tile_index_at(center_y - effective_radius, tile_size) - 1,
  )
  let max_row = @cmp.minimum(
    grid.height - 1,
    tile_index_at(center_y + effective_radius, tile_size) + 1,
  )
  let effective_radius_sq = effective_radius * effective_radius
  for row = min_row; row <= max_row; row = row + 1 {
    for col = min_col; col <= max_col; col = col + 1 {
      let tile_center_x = col.to_double() * tile_size + tile_half
      let tile_center_y = row.to_double() * tile_size + tile_half
      let dx = tile_center_x - center_x
      let dy = tile_center_y - center_y
      if dx * dx + dy * dy <= effective_radius_sq {
        grid.set(col, row, @terrain.Wall)
      }
    }
  }
}
