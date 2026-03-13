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
test "dungeon generator selection favors plaza layouts on early floors" {
  assert_eq(dungeon_generator_kind_for_floor(seed=42, 1), ArenaChain)
  assert_eq(dungeon_generator_kind_for_floor(seed=42, 3), TinyKeep)
  assert_eq(dungeon_generator_kind_for_floor(seed=42, 5), ArenaChain)
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
