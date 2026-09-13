///|
test "region portals connect both directions and prefetch starts before reaching a boundary" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  assert_eq(world.atlas.unwrap().current, 0)
  assert_eq(world.preload_regions().length(), 0)
  world.player.x = 80.0 * tile_size
  world.player.y = 40.0 * tile_size
  assert_true(world.preload_regions().contains(1))
  assert_true(world.boundary_destination() is None)
  assert_true(world.prepare_region(1))
  let region = world.atlas.unwrap().regions[1].unwrap()
  assert_false(
    check_wall_collision(region.dungeon.grid, tile_size, 40.0 * tile_size, 12.0),
  )
  world.ui_mode = UIMode::None
  world.player.x = 99.1 * tile_size
  let (id, x, y) = world.boundary_destination().unwrap()
  assert_eq(id, 1)
  assert_true((x / tile_size - 1.1).abs() < 0.001)
  assert_true(world.enter_region(id, x, y))
  assert_eq(world.atlas.unwrap().current, 1)
  assert_false(world.atlas.unwrap().unlocked[1])
  world.player.x = 0.9 * tile_size
  assert_eq(world.boundary_destination().unwrap().0, 0)
}

///|
test "waypoints unlock on arrival, reject remote and locked travel, and preserve combat state" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.ui_mode = Waypoints
  assert_false(world.request_waypoint(1))
  world.enemies[0].hp = 1
  world.enemies[1].alive = false
  world.reward_cleared_rooms[1] = true
  let hp = world.player.hp - 1
  world.player.hp = hp
  world.charge_cooldown = 80
  assert_true(world.prepare_region(1))
  let (wx, wy) = world_waypoint_position(1)
  assert_true(world.enter_region(1, wx, wy))
  assert_true(world.activate_nearby_waypoint())
  assert_true(world.atlas.unwrap().unlocked[1])
  world.ui_mode = Waypoints
  world.player.x = 60.0 * tile_size
  assert_false(world.request_waypoint(0))
  world.player.x = wx
  assert_true(world.request_waypoint(0))
  let (sx, sy) = world_waypoint_position(0)
  assert_true(world.enter_region(0, sx, sy))
  assert_eq(world.enemies[0].hp, 1)
  assert_false(world.enemies[1].alive)
  assert_true(world.reward_cleared_rooms[1])
  assert_eq(world.player.hp, hp)
  assert_eq(world.charge_cooldown, 80)
}

///|
test "open world clearing a map never regenerates or teleports the hunter" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  for enemy in world.enemies {
    enemy.alive = false
  }
  world.player.x += 20.0
  let x = world.player.x
  world.tick_floor_completion_phase()
  assert_eq(world.floor, 1)
  assert_eq(world.player.x, x)
  assert_eq(world.atlas.unwrap().current, 0)
}

///|
test "world archives retain slain enemies, ground equipment, unlocks and active coordinates" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.enemies[0].alive = false
  world.items.push({
    x: world.player.x,
    y: world.player.y,
    vx: 0.0,
    vy: 0.0,
    alive: true,
    kind: Equipment(hunter_equipment_item(Amulet)),
    spawn_frame: 0,
  })
  world.reward_cleared_rooms[2] = true
  assert_true(world.prepare_region(2))
  let (x, y) = world_waypoint_position(2)
  assert_true(world.enter_region(2, x, y))
  assert_true(world.activate_nearby_waypoint())
  let saved = world.serialize_world_progress()
  let restored = GameWorld::new(seed=100, hunting_grounds=true)
  assert_true(restored.restore_world_progress(saved))
  assert_eq(restored.atlas.unwrap().current, 2)
  assert_eq(restored.atlas.unwrap().world_seed, 42)
  assert_eq(restored.player.x, x)
  assert_eq(restored.player.y, y)
  let old = restored.atlas.unwrap().regions[0].unwrap()
  assert_false(old.enemies[0].alive)
  assert_eq(old.items.length(), 1)
  assert_true(old.items[0].kind is Equipment(_))
  assert_true(old.rewarded[2])
  assert_true(restored.atlas.unwrap().unlocked[2])
  assert_false(restored.atlas.unwrap().unlocked[1])
  assert_false(restored.restore_world_progress("{}"))
  assert_eq(restored.atlas.unwrap().current, 2)
}

///|
test "loot in a visited open-world area survives a long absence" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.items = [
    {
      x: 22.0 * tile_size,
      y: 50.0 * tile_size,
      vx: 0.0,
      vy: 0.0,
      alive: true,
      kind: Equipment(hunter_equipment_item(Weapon)),
      spawn_frame: 0,
    },
  ]
  assert_true(world.prepare_region(1))
  let (x, y) = world_waypoint_position(1)
  assert_true(world.enter_region(1, x, y))
  world.frame_count = 6000
  assert_true(world.enter_region(0, 20.5 * tile_size, 49.5 * tile_size))
  world.tick_items_phase()
  assert_eq(world.items.length(), 1)
  assert_true(world.items[0].alive)
}

///|
test "all area waypoints and boundary roads are connected in every direction" {
  for region in world_regions {
    let dungeon = generate_world_region(region_seed(42, region.id), region.id)
    let (wx, wz) = world_waypoint_position(region.id)
    let start : @terrain.Point = {
      x: (wx / tile_size).to_int(),
      y: (wz / tile_size).to_int(),
    }
    for
      (dx, dz, x, z) in [
        (-1, 0, 1, 40),
        (1, 0, 98, 40),
        (0, -1, 50, 1),
        (0, 1, 50, 78),
      ] {
      if region_neighbor(region.id, dx, dz) is Some(neighbor) {
        assert_eq(region_neighbor(neighbor, -dx, -dz).unwrap(), region.id)
        assert_true(
          @pathfind.find_path(dungeon.grid, start, { x, y: z, }) is Some(_),
        )
        assert_false(
          check_wall_collision(
            dungeon.grid,
            x.to_double() * tile_size,
            z.to_double() * tile_size,
            12.0,
          ),
        )
      }
    }
  }
}
