// Dungeon generation, collision, height map

///|
enum DungeonGeneratorKind {
  ArenaChain
  TinyKeep
  Diablo
  BSP
  Cellular
  Rogue
} derive(Eq, Show)

///|
priv struct GeneratedDungeonLayout {
  grid : @terrain.Grid2D
  rooms : Array[@terrain.Room]
}

///|
fn clamp_prob(value : Double) -> Double {
  @cmp.maximum(0.0, @cmp.minimum(1.0, value))
}

///|
fn validated_arena_chain_config(
  config : @arena_chain.ArenaChainConfig,
) -> @arena_chain.ArenaChainConfig {
  let width = @cmp.maximum(24, config.width)
  let height = @cmp.maximum(24, config.height)
  let max_room_span = @cmp.maximum(7, @cmp.minimum(width, height) - 4)
  let arena_min_size = @cmp.maximum(
    7,
    @cmp.minimum(config.arena_min_size, max_room_span),
  )
  let arena_max_size = @cmp.maximum(
    arena_min_size,
    @cmp.minimum(config.arena_max_size, max_room_span),
  )
  let num_arenas = @cmp.maximum(3, @cmp.minimum(config.num_arenas, 8))
  let corridor_width = @cmp.maximum(2, @cmp.minimum(config.corridor_width, 4))
  let side_room_min_size = @cmp.maximum(
    3,
    @cmp.minimum(config.side_room_min_size, arena_max_size),
  )
  let side_room_max_size = @cmp.maximum(
    side_room_min_size,
    @cmp.minimum(config.side_room_max_size, arena_max_size),
  )
  {
    width,
    height,
    num_arenas,
    arena_min_size,
    arena_max_size,
    corridor_width,
    side_room_chance: clamp_prob(config.side_room_chance),
    side_room_min_size,
    side_room_max_size,
    max_placement_attempts: @cmp.maximum(10, config.max_placement_attempts),
  }
}

///|
fn validated_tinykeep_config(
  config : @tinykeep.TinyKeepConfig,
) -> @tinykeep.TinyKeepConfig {
  let width = @cmp.maximum(24, config.width)
  let height = @cmp.maximum(24, config.height)
  let max_room_span = @cmp.maximum(5, @cmp.minimum(width, height) - 4)
  let room_min_size = @cmp.maximum(
    3,
    @cmp.minimum(config.room_min_size, max_room_span),
  )
  let room_max_size = @cmp.maximum(
    room_min_size,
    @cmp.minimum(config.room_max_size, max_room_span),
  )
  {
    width,
    height,
    num_rooms: @cmp.maximum(8, @cmp.minimum(config.num_rooms, 48)),
    room_min_size,
    room_max_size,
    main_room_threshold: @cmp.maximum(
      room_min_size,
      @cmp.minimum(config.main_room_threshold, room_max_size),
    ),
    extra_edge_chance: clamp_prob(config.extra_edge_chance),
    separation_iterations: @cmp.maximum(10, config.separation_iterations),
  }
}

///|
fn dungeon_generator_kind_for_floor(
  seed~ : Int,
  floor : Int,
) -> DungeonGeneratorKind {
  // Boss floors (every 5th) use TinyKeep for large open arenas
  if floor > 1 && floor % 5 == 0 {
    return TinyKeep
  }
  // Rotate through generators based on floor + seed for variety
  let gen_roll = ((seed * 7 + floor * 13) % 6 + 6) % 6
  match gen_roll {
    0 => ArenaChain
    1 => TinyKeep
    2 => Diablo
    3 => BSP
    4 => Cellular
    5 => Rogue
    _ => ArenaChain
  }
}

///|
fn arena_chain_config_for_floor(
  seed~ : Int,
  floor : Int,
  params : BalanceParams,
) -> @arena_chain.ArenaChainConfig {
  let boss_floor = floor % 5 == 0
  let arena_min_size = if boss_floor {
    13
  } else {
    11 + @cmp.minimum(2, floor / 4)
  }
  let arena_max_size = if boss_floor {
    19
  } else {
    17 + @cmp.minimum(2, floor / 3)
  }
  let room_count_scale = @cmp.maximum(0.75, params.map_room_count_scale)
  let room_size_scale = @cmp.maximum(0.8, params.map_room_size_scale)
  let corridor_width_bonus = @cmp.maximum(0.0, params.map_corridor_width_bonus)
  validated_arena_chain_config({
    width: map_cols,
    height: map_rows,
    num_arenas: if boss_floor {
      ((3 + seed % 2).to_double() * room_count_scale).to_int()
    } else {
      ((5 + (seed + floor) % 2).to_double() * room_count_scale).to_int()
    },
    arena_min_size: @cmp.maximum(
      7,
      (arena_min_size.to_double() * room_size_scale).to_int(),
    ),
    arena_max_size: @cmp.maximum(
      @cmp.maximum(7, (arena_min_size.to_double() * room_size_scale).to_int()),
      (arena_max_size.to_double() * room_size_scale).to_int(),
    ),
    corridor_width: if boss_floor {
      (4.0 + corridor_width_bonus).to_int()
    } else {
      (3.0 + corridor_width_bonus).to_int()
    },
    side_room_chance: if boss_floor {
      0.15
    } else {
      0.25
    },
    side_room_min_size: @cmp.maximum(4, (5.0 * room_size_scale).to_int()),
    side_room_max_size: @cmp.maximum(
      @cmp.maximum(4, (5.0 * room_size_scale).to_int()),
      (8.0 * room_size_scale).to_int(),
    ),
    max_placement_attempts: 80,
  })
}

///|
fn diablo_config_for_floor(
  seed~ : Int,
  floor : Int,
  params : BalanceParams,
) -> @diablo.DiabloConfig {
  let room_count_scale = @cmp.maximum(0.75, params.map_room_count_scale)
  let room_size_scale = @cmp.maximum(0.8, params.map_room_size_scale)
  {
    width: map_cols,
    height: map_rows,
    spine_length: ((4 + (seed + floor) % 3).to_double() * room_count_scale).to_int(),
    branch_chance: 0.5,
    loop_chance: 0.2,
    room_min_size: @cmp.maximum(4, (5.0 * room_size_scale).to_int()),
    room_max_size: @cmp.maximum(6, (12.0 * room_size_scale).to_int()),
    room_padding: 2,
    max_placement_attempts: 80,
  }
}

///|
fn bsp_config_for_floor(
  seed~ : Int,
  floor : Int,
  params : BalanceParams,
) -> @bsp.BspConfig {
  let _ = seed
  let _ = floor
  let room_size_scale = @cmp.maximum(0.8, params.map_room_size_scale)
  {
    width: map_cols,
    height: map_rows,
    min_room_size: @cmp.maximum(4, (5.0 * room_size_scale).to_int()),
    max_depth: 4,
  }
}

///|
fn cellular_config_for_floor(
  seed~ : Int,
  floor : Int,
  params : BalanceParams,
) -> @cellular.CellularConfig {
  let _ = seed
  let _ = floor
  let _ = params
  {
    width: map_cols,
    height: map_rows,
    initial_fill: 0.42,
    iterations: 5,
    birth_threshold: 5,
    survival_threshold: 4,
  }
}

///|
fn rogue_config_for_floor(
  seed~ : Int,
  floor : Int,
  params : BalanceParams,
) -> @rogue.RogueConfig {
  let _ = seed
  let _ = floor
  let room_size_scale = @cmp.maximum(0.8, params.map_room_size_scale)
  {
    width: map_cols,
    height: map_rows,
    grid_cols: 3,
    grid_rows: 3,
    room_min_ratio: 0.4 * room_size_scale,
    room_max_ratio: 0.8 * room_size_scale,
    skip_chance: 0.1,
  }
}

///|
fn extract_rooms_from_grid(grid : @terrain.Grid2D) -> Array[@terrain.Room] {
  // For cellular automata, find connected floor regions and create rooms
  let rooms : Array[@terrain.Room] = []
  let visited = Array::make(grid.width * grid.height, false)
  let mut room_id = 0
  for row = 1; row < grid.height - 1; row = row + 1 {
    for col = 1; col < grid.width - 1; col = col + 1 {
      let idx = row * grid.width + col
      if not(visited[idx]) && grid.get(col, row) == @terrain.Floor {
        // Flood fill to find region bounds
        let mut min_x = col
        let mut max_x = col
        let mut min_y = row
        let mut max_y = row
        let stack : Array[(Int, Int)] = [(col, row)]
        visited[idx] = true
        while stack.length() > 0 {
          let (cx, cy) = stack.pop_exn()
          if cx < min_x { min_x = cx }
          if cx > max_x { max_x = cx }
          if cy < min_y { min_y = cy }
          if cy > max_y { max_y = cy }
          let dx_arr = [-1, 1, 0, 0]
          let dy_arr = [0, 0, -1, 1]
          for d = 0; d < 4; d = d + 1 {
            let nx = cx + dx_arr[d]
            let ny = cy + dy_arr[d]
            if nx >= 0 &&
              nx < grid.width &&
              ny >= 0 &&
              ny < grid.height {
              let ni = ny * grid.width + nx
              if not(visited[ni]) && grid.get(nx, ny) == @terrain.Floor {
                visited[ni] = true
                stack.push((nx, ny))
              }
            }
          }
        }
        let w = max_x - min_x + 1
        let h = max_y - min_y + 1
        if w >= 3 && h >= 3 {
          rooms.push({ rect: { x: min_x, y: min_y, w, h }, id: room_id })
          room_id = room_id + 1
        }
      }
    }
  }
  // Ensure at least one room
  if rooms.is_empty() {
    rooms.push({
      rect: { x: grid.width / 4, y: grid.height / 4, w: 4, h: 4 },
      id: 0,
    })
  }
  rooms
}

///|
fn tinykeep_config_for_floor(
  seed~ : Int,
  floor : Int,
  params : BalanceParams,
) -> @tinykeep.TinyKeepConfig {
  let room_count_scale = @cmp.maximum(0.75, params.map_room_count_scale)
  let room_size_scale = @cmp.maximum(0.8, params.map_room_size_scale)
  validated_tinykeep_config({
    width: map_cols,
    height: map_rows,
    num_rooms: ((22 + (seed + floor) % 8).to_double() * room_count_scale).to_int(),
    room_min_size: @cmp.maximum(4, (6.0 * room_size_scale).to_int()),
    room_max_size: @cmp.maximum(
      @cmp.maximum(4, (6.0 * room_size_scale).to_int()),
      (14.0 * room_size_scale).to_int(),
    ),
    main_room_threshold: @cmp.maximum(5, (8.0 * room_size_scale).to_int()),
    extra_edge_chance: 0.08,
    separation_iterations: 60,
  })
}

///|
fn generate_layout_for_kind(
  kind : DungeonGeneratorKind,
  seed : Int,
  floor : Int,
  params : BalanceParams,
  rng : @terrain.RNG,
) -> GeneratedDungeonLayout {
  match kind {
    ArenaChain => {
      let config = arena_chain_config_for_floor(seed~, floor, params)
      let generated = @arena_chain.generate(config, rng)
      { grid: generated.grid, rooms: generated.rooms }
    }
    TinyKeep => {
      let config = tinykeep_config_for_floor(seed~, floor, params)
      let generated = @tinykeep.generate(config, rng)
      { grid: generated.grid, rooms: generated.rooms }
    }
    Diablo => {
      let generated = @diablo.generate(
        diablo_config_for_floor(seed~, floor, params),
        rng,
      )
      { grid: generated.grid, rooms: generated.rooms }
    }
    BSP => {
      let generated = @bsp.generate(
        bsp_config_for_floor(seed~, floor, params),
        rng,
      )
      { grid: generated.grid, rooms: generated.rooms }
    }
    Cellular => {
      let generated = @cellular.generate(
        cellular_config_for_floor(seed~, floor, params),
        rng,
      )
      let rooms = extract_rooms_from_grid(generated.grid)
      { grid: generated.grid, rooms }
    }
    Rogue => {
      let generated = @rogue.generate(
        rogue_config_for_floor(seed~, floor, params),
        rng,
      )
      { grid: generated.grid, rooms: generated.rooms }
    }
  }
}

///|
fn is_layout_traversable(layout : GeneratedDungeonLayout) -> Bool {
  if layout.rooms.length() < 2 {
    return false
  }
  // Check pathfinding from room 0 center to room 1 center
  let start = layout.rooms[0].rect.center()
  let goal = layout.rooms[1].rect.center()
  match @pathfind.find_path(layout.grid, start, goal) {
    Some(_) => true
    None => false
  }
}

///|
pub fn generate_dungeon(
  seed : Int,
  floor? : Int = 1,
  params? : BalanceParams = BalanceParams::default(),
) -> DungeonData {
  let kind = dungeon_generator_kind_for_floor(seed~, floor)
  let rng = @terrain.make_rng(seed.to_uint())
  let mut result = generate_layout_for_kind(kind, seed, floor, params, rng)
  // Validate: must have rooms and be traversable
  if not(is_layout_traversable(result)) {
    // Retry with different seed
    let rng2 = @terrain.make_rng((seed + 9999).to_uint())
    result = generate_layout_for_kind(kind, seed + 9999, floor, params, rng2)
    if not(is_layout_traversable(result)) {
      // Fallback to ArenaChain (always produces connected layouts)
      let rng3 = @terrain.make_rng((seed + 7777).to_uint())
      result = generate_layout_for_kind(
        ArenaChain, seed + 7777, floor, params, rng3,
      )
    }
  }
  let height_map = build_height_map(result.grid, result.rooms, seed)
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

///|
pub fn build_height_map(
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

///|
pub fn get_tile_height(dungeon : DungeonData, x : Double, y : Double) -> Double {
  let col = (x / tile_size).to_int()
  let row = (y / tile_size).to_int()
  if col < 0 ||
    col >= dungeon.grid.width ||
    row < 0 ||
    row >= dungeon.grid.height {
    return 0.0
  }
  dungeon.height_map[row * dungeon.grid.width + col]
}

///|
pub fn is_wall_at(grid : @terrain.Grid2D, x : Double, y : Double) -> Bool {
  @physics2d.grid_is_wall_at(grid, x, y, tile_size)
}

///|
pub fn check_wall_collision(
  grid : @terrain.Grid2D,
  x : Double,
  y : Double,
  size : Double,
) -> Bool {
  @physics2d.grid_check_wall_collision(grid, x, y, size, tile_size)
}

///|
pub fn segment_hits_wall(
  grid : @terrain.Grid2D,
  start_x : Double,
  start_y : Double,
  end_x : Double,
  end_y : Double,
  size : Double,
) -> Bool {
  @physics2d.grid_segment_hits_wall(
    grid, start_x, start_y, end_x, end_y, size, tile_size,
  )
}

///|
pub fn slide_move(
  grid : @terrain.Grid2D,
  x : Double,
  y : Double,
  vx : Double,
  vy : Double,
  size : Double,
) -> (Double, Double) {
  @physics2d.grid_slide_move(grid, x, y, vx, vy, size, tile_size)
}
