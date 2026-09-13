///|
test "roadside ruins and camps have reachable treasure and collision-safe guards" {
  for seed in [1, 42, 2026, 9471] {
    let w = GameWorld::new(seed~, hunting_grounds=true)
    assert_eq(w.chests.length(), 4)
    assert_true(w.enemies.filter(e => e.kind == Wolf).length() >= 6)
    for chest in w.chests {
      assert_false(
        check_wall_collision(w.dungeon.grid, chest.x, chest.y + tile_size, 12.0),
      )
      assert_true(
        @pathfind.find_path(
          w.dungeon.grid,
          {
            x: (w.player.x / tile_size).to_int(),
            y: (w.player.y / tile_size).to_int(),
          },
          {
            x: (chest.x / tile_size).to_int(),
            y: (chest.y / tile_size).to_int() + 1,
          },
        )
        is Some(_),
      )
    }
    for enemy in w.enemies {
      assert_false(
        check_wall_collision(w.dungeon.grid, enemy.x, enemy.y, enemy.size),
      )
    }
    for site in hunting_sites {
      assert_true(site.kind == Ruins || site.kind == Encampment)
    }
  }
}

///|
test "chests open once, leave equipment on the ground and survive travel and saves" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  let chest = w.chests[0]
  assert_false(w.open_nearby_chest())
  w.player.x = chest.x
  w.player.y = chest.y + 12.0
  w.ui_mode = Inventory
  assert_false(w.open_nearby_chest())
  w.ui_mode = UIMode::None
  assert_true(w.open_nearby_chest())
  assert_true(chest.opened)
  assert_eq(w.items.length(), 3)
  assert_eq(w.items.filter(i => i.kind is Equipment(_)).length(), 2)
  assert_false(w.open_nearby_chest())
  assert_true(w.prepare_region(1))
  let (x, y) = world_waypoint_position(1)
  assert_true(w.enter_region(1, x, y))
  let restored = GameWorld::new(seed=1, hunting_grounds=true)
  assert_true(restored.restore_world_progress(w.serialize_world_progress()))
  let (x, y) = world_waypoint_position(0)
  assert_true(restored.enter_region(0, x, y))
  assert_true(restored.chests[0].opened)
  assert_eq(restored.items.length(), 3)
}

///|
test "legacy world saves gain camp wolves once and move actors out of new masonry" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.enemies = w.enemies.filter(e => e.kind != Wolf)
  w.enemies[0].alive = false
  w.enemies[1].x = 34.5 * tile_size
  w.enemies[1].y = 22.5 * tile_size
  let json = @json.parse(w.serialize_world_progress())
  guard json is Object(root) else { fail("object") }
  root["version"] = 1
  guard root["regions"] is Array(regions) else { fail("regions") }
  for region in regions {
    if region is Object(fields) {
      fields.remove("opened_chests")
    }
  }
  let restored = GameWorld::new(seed=1, hunting_grounds=true)
  assert_true(restored.restore_world_progress(json.stringify()))
  assert_false(restored.enemies[0].alive)
  assert_false(
    check_wall_collision(
      restored.dungeon.grid,
      restored.enemies[1].x,
      restored.enemies[1].y,
      restored.enemies[1].size,
    ),
  )
  let wolves = restored.enemies.filter(e => e.kind == Wolf).length()
  assert_true(wolves >= 4)
  assert_true(
    restored.restore_world_progress(restored.serialize_world_progress()),
  )
  assert_eq(restored.enemies.filter(e => e.kind == Wolf).length(), wolves)
}

///|
test "closed treasure blocks movement and cannot be opened through masonry" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  let chest = w.chests[0]
  assert_true(check_wall_collision(w.dungeon.grid, chest.x, chest.y, 12.0))
  w.player.x = chest.x
  w.player.y = chest.y + 36.0
  w.dungeon.grid.set(
    (chest.x / tile_size).to_int(),
    (chest.y / tile_size).to_int() + 1,
    @terrain.Wall,
  )
  assert_false(w.open_nearby_chest())
  assert_false(chest.opened)
  assert_true(w.items.is_empty())
}

///|
test "every region retains a walkable route from its waypoint to all chest fronts" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  for id in 0..<4 {
    assert_true(w.prepare_region(id))
    let region = w.atlas.unwrap().regions[id].unwrap()
    let (wx, wy) = world_waypoint_position(id)
    for chest in region.chests {
      assert_true(
        @pathfind.find_path(
          region.dungeon.grid,
          { x: (wx / tile_size).to_int(), y: (wy / tile_size).to_int(), },
          {
            x: (chest.x / tile_size).to_int(),
            y: (chest.y / tile_size).to_int() + 1,
          },
        )
        is Some(_),
      )
    }
  }
}

///|
test "map migration never adds guards on top of the saved hunter" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.enemies = []
  w.player.x = 29.5 * tile_size
  w.player.y = 34.5 * tile_size
  let json = @json.parse(w.serialize_world_progress())
  guard json is Object(root) else { fail("object") }
  root["version"] = 1
  assert_true(w.restore_world_progress(json.stringify()))
  assert_false(w.enemies.is_empty())
  for enemy in w.enemies {
    let dx = enemy.x - w.player.x
    let dy = enemy.y - w.player.y
    assert_true(dx * dx + dy * dy > tile_size * tile_size * 16.0)
  }
}
