///|
fn room_center_world_xy(room : @terrain.Room) -> (Double, Double) {
  let center = room.rect.center()
  (
    center.x.to_double() * tile_size + tile_size / 2.0,
    center.y.to_double() * tile_size + tile_size / 2.0,
  )
}

///|
fn largest_non_start_room_center(world : @game.GameWorld) -> (Double, Double) {
  let rooms = world.dungeon.rooms
  let mut best_idx = 1
  let mut best_area = rooms[1].rect.w * rooms[1].rect.h
  for i = 2; i < rooms.length(); i = i + 1 {
    let area = rooms[i].rect.w * rooms[i].rect.h
    if area > best_area {
      best_idx = i
      best_area = area
    }
  }
  room_center_world_xy(rooms[best_idx])
}

///|
fn furthest_non_start_room_center(world : @game.GameWorld) -> (Double, Double) {
  let rooms = world.dungeon.rooms
  let mut best_idx = 1
  let mut best_dist_sq = -1.0
  for i = 1; i < rooms.length(); i = i + 1 {
    let (cx, cy) = room_center_world_xy(rooms[i])
    let dx = cx - world.dungeon.start_x
    let dy = cy - world.dungeon.start_y
    let dist_sq = dx * dx + dy * dy
    if dist_sq > best_dist_sq {
      best_idx = i
      best_dist_sq = dist_sq
    }
  }
  room_center_world_xy(rooms[best_idx])
}

///|
test "generated_prop_anchor_center_world resolves boss room anchor to largest non-start room" {
  let state = GameState::new(seed=42)
  let expected = largest_non_start_room_center(state.world)
  let actual = generated_prop_anchor_center_world(state.world, BossRoomCenter)
  assert_eq(actual, expected)
}

///|
test "generated_prop_anchor_center_world resolves treasure room anchor to furthest non-start room" {
  let state = GameState::new(seed=42)
  let expected = furthest_non_start_room_center(state.world)
  let actual = generated_prop_anchor_center_world(
    state.world,
    TreasureRoomCenter,
  )
  assert_eq(actual, expected)
}

///|
test "default_generated_prop_manifest_for_floor uses boss anchor on boss floor" {
  let config = default_generated_prop_manifest_for_floor(5)
  assert_eq(config.length(), 1)
  assert_eq(config[0].floor, 5)
  assert_eq(config[0].anchor, BossRoomCenter)
}

///|
test "generated_prop_anchor_from_string parses known anchors" {
  assert_eq(
    generated_prop_anchor_from_string("treasure_room"),
    Some(TreasureRoomCenter),
  )
  assert_eq(
    generated_prop_anchor_from_string("boss_room"),
    Some(BossRoomCenter),
  )
  assert_eq(
    generated_prop_anchor_from_string("largest_non_start_room"),
    Some(LargestNonStartRoomCenter),
  )
  assert_eq(generated_prop_anchor_from_string("unknown"), None)
}

///|
test "generated_prop_role_from_string parses known roles" {
  assert_eq(generated_prop_role_from_string("decoration"), Some(Decoration))
  assert_eq(generated_prop_role_from_string("blocking"), Some(Blocking))
  assert_eq(generated_prop_role_from_string("pickup"), Some(Pickup))
  assert_eq(generated_prop_role_from_string("unknown"), None)
}

///|
test "default_generated_prop_manifest_for_floor assigns expected roles" {
  let floor1 = default_generated_prop_manifest_for_floor(1)
  assert_eq(floor1.length(), 2)
  assert_eq(floor1[0].role, Decoration)
  assert_eq(floor1[1].role, Pickup)
  assert_eq(floor1[1].pickup_effect, HealthPickup)

  let boss_floor = default_generated_prop_manifest_for_floor(5)
  assert_eq(boss_floor.length(), 1)
  assert_eq(boss_floor[0].role, Blocking)
}

///|
test "generated_prop_role helpers classify solid and pickup roles" {
  assert_false(generated_prop_role_is_solid(Decoration))
  assert_true(generated_prop_role_is_solid(Blocking))
  assert_false(generated_prop_role_is_solid(Pickup))
  assert_false(generated_prop_role_is_pickup(Decoration))
  assert_false(generated_prop_role_is_pickup(Blocking))
  assert_true(generated_prop_role_is_pickup(Pickup))
}

///|
test "generated_prop_pickup_effect_from_string parses known effects" {
  assert_eq(
    generated_prop_pickup_effect_from_string("score"),
    Some(ScorePickup),
  )
  assert_eq(
    generated_prop_pickup_effect_from_string("health"),
    Some(HealthPickup),
  )
  assert_eq(
    generated_prop_pickup_effect_from_string("equipment"),
    Some(EquipmentPickup),
  )
  assert_eq(generated_prop_pickup_effect_from_string("unknown"), None)
}

///|
test "generated_prop_item_rarity_from_string parses known rarities" {
  match generated_prop_item_rarity_from_string("common") {
    Some(@game.Common) => ()
    _ => fail("expected common rarity")
  }
  match generated_prop_item_rarity_from_string("uncommon") {
    Some(@game.Uncommon) => ()
    _ => fail("expected uncommon rarity")
  }
  match generated_prop_item_rarity_from_string("rare") {
    Some(@game.Rare) => ()
    _ => fail("expected rare rarity")
  }
  match generated_prop_item_rarity_from_string("epic") {
    Some(@game.Epic) => ()
    _ => fail("expected epic rarity")
  }
  match generated_prop_item_rarity_from_string("unknown") {
    None => ()
    _ => fail("expected unknown rarity to be none")
  }
}

///|
test "generated_prop_item_slot_from_string parses known slots" {
  match generated_prop_item_slot_from_string("weapon") {
    Some(@game.Weapon) => ()
    _ => fail("expected weapon slot")
  }
  match generated_prop_item_slot_from_string("armor") {
    Some(@game.Armor) => ()
    _ => fail("expected armor slot")
  }
  match generated_prop_item_slot_from_string("accessory") {
    Some(@game.Accessory) => ()
    _ => fail("expected accessory slot")
  }
  match generated_prop_item_slot_from_string("unknown") {
    None => ()
    _ => fail("expected unknown slot to be none")
  }
}

///|
test "resolve_generated_prop_player_block pushes player out on exact overlap" {
  let out = resolve_generated_prop_player_block(
    32.0, 48.0, 12.0, 32.0, 48.0, 8.0,
  )
  let (px, py) = match out {
    Some(pair) => pair
    None => panic()
  }
  assert_true(px > 32.0)
  assert_eq(py, 48.0)
}

///|
test "generated_prop_player_can_pickup returns true inside pickup radius" {
  assert_true(generated_prop_player_can_pickup(32.0, 48.0, 36.0, 48.0))
  assert_false(generated_prop_player_can_pickup(32.0, 48.0, 64.0, 48.0))
}

///|
test "update_playing collects pickup generated prop and adds score" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.5)))),
  )
  state.set_generated_prop_asset(
    { scene_graph: graph, source_path: "./assets/generated/pickup.glb" },
    generated_prop_placement(
      "./assets/generated/pickup.glb",
      floor=1,
      anchor=StartRoomCenter,
      role=Pickup,
      x_offset_tiles=0.0,
      z_offset_tiles=0.0,
    ),
  )
  let score0 = state.world.score
  state.update_playing()
  assert_eq(state.world.score, score0 + 5)
  assert_eq(state.generated_props.length(), 0)
}

///|
test "update_playing collects health pickup generated prop and heals player" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  state.world.player.hp = state.world.player.hp - 3
  let hp0 = state.world.player.hp
  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.5)))),
  )
  state.set_generated_prop_asset(
    { scene_graph: graph, source_path: "./assets/generated/health.glb" },
    generated_prop_placement(
      "./assets/generated/health.glb",
      floor=1,
      anchor=StartRoomCenter,
      role=Pickup,
      pickup_effect=HealthPickup,
      x_offset_tiles=0.0,
      z_offset_tiles=0.0,
    ),
  )
  state.update_playing()
  assert_eq(state.world.player.hp, hp0 + 2)
  assert_eq(state.generated_props.length(), 0)
}

///|
test "update_playing collects equipment pickup generated prop and adds inventory item" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let inv0 = state.world.inventory.count()
  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.5)))),
  )
  state.set_generated_prop_asset(
    { scene_graph: graph, source_path: "./assets/generated/equipment.glb" },
    generated_prop_placement(
      "./assets/generated/equipment.glb",
      floor=1,
      anchor=StartRoomCenter,
      role=Pickup,
      pickup_effect=EquipmentPickup,
      x_offset_tiles=0.0,
      z_offset_tiles=0.0,
    ),
  )
  state.update_playing()
  assert_eq(state.world.inventory.count(), inv0 + 1)
  assert_eq(state.generated_props.length(), 0)
}

///|
test "update_playing collects equipment pickup with forced rarity and slot" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.5)))),
  )
  state.set_generated_prop_asset(
    {
      scene_graph: graph,
      source_path: "./assets/generated/equipment-forced.glb",
    },
    generated_prop_placement(
      "./assets/generated/equipment-forced.glb",
      floor=1,
      anchor=StartRoomCenter,
      role=Pickup,
      pickup_effect=EquipmentPickup,
      pickup_rarity=Some(@game.Epic),
      pickup_slot=Some(@game.Accessory),
      x_offset_tiles=0.0,
      z_offset_tiles=0.0,
    ),
  )
  state.update_playing()
  let item = match state.world.inventory.items[0] {
    Some(item) => item
    None => panic()
  }
  match item.rarity {
    @game.Epic => ()
    _ => fail("expected epic rarity")
  }
  match item.slot {
    @game.Accessory => ()
    _ => fail("expected accessory slot")
  }
}

///|
test "update_playing pushes player away from blocking generated prop" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.5)))),
  )
  let (prop_x, prop_y) = generated_prop_anchor_center_world(
    state.world,
    StartRoomCenter,
  )
  state.world.player.x = prop_x
  state.world.player.y = prop_y
  state.set_generated_prop_asset(
    { scene_graph: graph, source_path: "./assets/generated/blocking.glb" },
    generated_prop_placement(
      "./assets/generated/blocking.glb",
      floor=1,
      anchor=StartRoomCenter,
      role=Blocking,
      x_offset_tiles=0.0,
      z_offset_tiles=0.0,
    ),
  )

  state.update_playing()

  let dx = state.world.player.x - prop_x
  let dy = state.world.player.y - prop_y
  let min_dist = state.world.player.size / 2.0 +
    generated_prop_blocking_radius(state.generated_props[0].placement)
  assert_eq(state.generated_props.length(), 1)
  assert_true(dx * dx + dy * dy >= min_dist * min_dist - 0.0001)
}

///|
test "update_playing pushes enemy away from blocking generated prop" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.5)))),
  )
  let (prop_x, prop_y) = generated_prop_anchor_center_world(
    state.world,
    StartRoomCenter,
  )
  state.world.enemies = [
    @game.make_enemy(prop_x, prop_y, @game.Basic, 3, 0.0, 12.0),
  ]
  state.set_generated_prop_asset(
    { scene_graph: graph, source_path: "./assets/generated/blocking-enemy.glb" },
    generated_prop_placement(
      "./assets/generated/blocking-enemy.glb",
      floor=1,
      anchor=StartRoomCenter,
      role=Blocking,
      x_offset_tiles=0.0,
      z_offset_tiles=0.0,
    ),
  )

  state.update_playing()

  let enemy = state.world.enemies[0]
  let dx = enemy.x - prop_x
  let dy = enemy.y - prop_y
  let min_dist = enemy.size / 2.0 +
    generated_prop_blocking_radius(state.generated_props[0].placement)
  assert_true(dx * dx + dy * dy >= min_dist * min_dist - 0.0001)
}

///|
test "update_playing routes enemy pathfinding around blocking generated prop" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.5)))),
  )
  let (prop_x, prop_y) = generated_prop_anchor_center_world(
    state.world,
    StartRoomCenter,
  )
  state.world.player.x = prop_x - 48.0
  state.world.player.y = prop_y
  state.world.enemies = [
    @game.make_enemy(prop_x + 48.0, prop_y, @game.Basic, 3, 1.0, 12.0),
  ]
  state.set_generated_prop_asset(
    { scene_graph: graph, source_path: "./assets/generated/blocking-path.glb" },
    generated_prop_placement(
      "./assets/generated/blocking-path.glb",
      floor=1,
      anchor=StartRoomCenter,
      role=Blocking,
      x_offset_tiles=0.0,
      z_offset_tiles=0.0,
    ),
  )

  state.update_playing()

  assert_true(state.world.enemies[0].path_cache.length() > 0)
  assert_true(state.world.enemies[0].path_index >= 1)
}
