///|
test "hunting grounds are open, connected, and every encounter clearing is safe to spawn in" {
  for seed in [1, 42, 2026, 9471] {
    let map = generate_hunting_grounds(seed)
    let mut walkable = 0
    let mut obstacles = 0
    for z in 0..<map.grid.height {
      for x in 0..<map.grid.width {
        if !is_wall_at(
            map.grid,
            x.to_double() * tile_size + 8.0,
            z.to_double() * tile_size + 8.0,
          ) {
          walkable += 1
        } else {
          obstacles += 1
        }
      }
    }
    assert_true(walkable > map.grid.width * map.grid.height * 7 / 10)
    assert_true(obstacles > 100)
    assert_true(!check_wall_collision(map.grid, map.start_x, map.start_y, 12.0))
    for room in map.rooms {
      assert_true(
        @pathfind.find_path(
          map.grid,
          map.rooms[0].rect.center(),
          room.rect.center(),
        )
        is Some(_),
      )
      let r = room.rect
      for z in r.y..<(r.y + r.h) {
        for x in r.x..<(r.x + r.w) {
          assert_true(
            !check_wall_collision(
              map.grid,
              x.to_double() * tile_size + 8.0,
              z.to_double() * tile_size + 8.0,
              12.0,
            ),
          )
        }
      }
    }
  }
}

///|
test "hunter expedition keeps its outdoor map and usable four-skill loadout between floors" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  assert_eq(world.dungeon.start_x, generate_hunting_grounds(42).start_x)
  for id in [PowerStrike, Whirlwind, SplittingFireball, IceNova] {
    assert_true(world.skills.get_level(id) > 0)
  }
  world.apply_dungeon(73, 2)
  assert_eq(world.dungeon.start_x, generate_hunting_grounds(73).start_x)
  for enemy in world.enemies {
    assert_true(
      !check_wall_collision(world.dungeon.grid, enemy.x, enemy.y, enemy.size),
    )
  }
}

///|
test "woodland starts with a small nearby encounter and room to react on every floor" {
  for seed in [1, 42, 2026, 9471] {
    let world = GameWorld::new(seed~, hunting_grounds=true)
    for floor in [1, 2] {
      if floor > 1 {
        world.apply_dungeon(seed, floor)
      }
      let mut nearby = 0
      for enemy in world.enemies {
        let dx = (enemy.x - world.player.x) / tile_size
        let dz = (enemy.y - world.player.y) / tile_size
        let distance = (dx * dx + dz * dz).sqrt()
        assert_true(distance >= 4.0)
        if distance <= 6.0 {
          nearby += 1
          assert_true(enemy.kind == Basic)
          assert_true(
            !check_wall_collision(
              world.dungeon.grid,
              enemy.x,
              enemy.y,
              enemy.size,
            ),
          )
        }
      }
      assert_eq(nearby, 3)
    }
  }
}
