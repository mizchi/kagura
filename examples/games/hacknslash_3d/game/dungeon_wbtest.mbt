///|
test "validated arena chain config clamps toward broad-room safe values" {
  let validated = validated_arena_chain_config({
    width: 8,
    height: 8,
    num_arenas: 1,
    arena_min_size: 1,
    arena_max_size: 99,
    corridor_width: 0,
    side_room_chance: 9.0,
    side_room_min_size: 1,
    side_room_max_size: 99,
    max_placement_attempts: 0,
  })
  assert_true(validated.width >= 24)
  assert_true(validated.height >= 24)
  assert_true(validated.num_arenas >= 3)
  assert_true(validated.arena_min_size >= 7)
  assert_true(validated.arena_max_size >= validated.arena_min_size)
  assert_true(validated.corridor_width >= 2)
  assert_true(validated.side_room_chance <= 1.0)
  assert_true(validated.side_room_min_size >= 3)
  assert_true(validated.side_room_max_size >= validated.side_room_min_size)
  assert_true(validated.max_placement_attempts >= 10)
}

///|
test "validated tinykeep config clamps room thresholds and counts" {
  let validated = validated_tinykeep_config({
    width: 8,
    height: 8,
    num_rooms: 1,
    room_min_size: 1,
    room_max_size: 99,
    main_room_threshold: 0,
    extra_edge_chance: 9.0,
    separation_iterations: 0,
  })
  assert_true(validated.width >= 24)
  assert_true(validated.height >= 24)
  assert_true(validated.num_rooms >= 8)
  assert_true(validated.room_min_size >= 3)
  assert_true(validated.room_max_size >= validated.room_min_size)
  assert_true(validated.main_room_threshold >= validated.room_min_size)
  assert_true(validated.extra_edge_chance <= 1.0)
  assert_true(validated.separation_iterations >= 10)
}

///|
test "dungeon generator selection uses boss floors for TinyKeep" {
  // Boss floors (multiples of 5, after floor 1) always use TinyKeep
  assert_eq(dungeon_generator_kind_for_floor(seed=42, 5), TinyKeep)
  assert_eq(dungeon_generator_kind_for_floor(seed=42, 10), TinyKeep)
  // Non-boss floors use varied generators
  let kind = dungeon_generator_kind_for_floor(seed=42, 1)
  assert_true(
    kind == ArenaChain ||
    kind == TinyKeep ||
    kind == Diablo ||
    kind == BSP ||
    kind == Cellular ||
    kind == Rogue,
  )
}

///|
test "generate_dungeon floor 1 creates a broad arena layout" {
  let dungeon = generate_dungeon(42, floor=1)
  let mut largest_room_area = 0
  for room in dungeon.rooms {
    largest_room_area = @cmp.maximum(
      largest_room_area,
      room.rect.w * room.rect.h,
    )
  }
  assert_true(dungeon.rooms.length() >= 4)
  assert_true(largest_room_area >= 100)
}

///|
test "generate_dungeon floor 3 creates multiple roomy spaces" {
  let dungeon = generate_dungeon(42, floor=3)
  let mut large_room_count = 0
  for room in dungeon.rooms {
    let area = room.rect.w * room.rect.h
    if area >= 64 {
      large_room_count = large_room_count + 1
    }
  }
  assert_true(dungeon.rooms.length() >= 5)
  assert_true(large_room_count >= 2)
}

///|
test "generate_dungeon with roominess params keeps early floors broad and wide" {
  let params = {
    ..BalanceParams::default(),
    map_room_count_scale: 1.2,
    map_room_size_scale: 1.35,
    map_corridor_width_bonus: 1.0,
  }
  let dungeon = generate_dungeon(42, floor=1, params~)
  let mut widest_room = 0
  for room in dungeon.rooms {
    widest_room = @cmp.maximum(widest_room, room.rect.w)
  }
  assert_true(widest_room >= 12)
}

///|
test "segment_hits_wall detects blocking wall between points" {
  let grid = @terrain.Grid2D::make(8, 8, @terrain.Empty)
  grid.set(3, 3, @terrain.Wall)

  assert_true(
    segment_hits_wall(
      grid,
      2.5 * tile_size,
      3.5 * tile_size,
      4.5 * tile_size,
      3.5 * tile_size,
      0.0,
    ),
  )
  assert_false(
    segment_hits_wall(
      grid,
      1.5 * tile_size,
      1.5 * tile_size,
      2.5 * tile_size,
      1.5 * tile_size,
      0.0,
    ),
  )
}

///|
test "walkable room and corridor tiles share a continuous floor without unsupported ledges" {
  for seed in [42, 17, 99] {
    for floor in [1, 2, 3, 5] {
      let dungeon = generate_dungeon(seed, floor~)
      for row in 1..<(dungeon.grid.height - 1) {
        for col in 1..<(dungeon.grid.width - 1) {
          let tile = dungeon.grid.get(col, row)
          if tile == @terrain.Wall || tile == @terrain.Empty {
            continue
          }
          let height = get_tile_height(
            dungeon,
            (col.to_double() + 0.5) * tile_size,
            (row.to_double() + 0.5) * tile_size,
          )
          for (dx, dy) in [(1, 0), (0, 1)] {
            let next = dungeon.grid.get(col + dx, row + dy)
            if next != @terrain.Wall && next != @terrain.Empty {
              assert_true(
                (height -
                dungeon.height_map[(row + dy) * dungeon.grid.width + col + dx]).abs() <
                0.001,
              )
            }
          }
        }
      }
    }
  }
}

///|
test "slide move reaches the wall surface and preserves tangent motion even during a fast dash" {
  let grid = @terrain.Grid2D::make(12, 8, @terrain.Floor)
  for y in 0..<8 {
    grid.set(5, y, @terrain.Wall)
  }
  let (x, y) = slide_move(grid, 60.0, 40.0, 80.0, 5.0, 12.0)
  assert_true((x - 74.0).abs() < 0.02)
  assert_true(!check_wall_collision(grid, x, y, 12.0))
  assert_eq(y, 45.0)
  let (again_x, again_y) = slide_move(grid, x, y, 7.0, 2.0, 12.0)
  assert_true((again_x - x).abs() < 0.02)
  assert_eq(again_y, 47.0)
}
