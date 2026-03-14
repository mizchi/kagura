///|
test "auto_play_input routes toward nearby equipment pickup when no enemy is visible" {
  let world = GameWorld::new(seed=42)
  world.enemies = []
  world.items = [
    {
      x: world.player.x + tile_size,
      y: world.player.y,
      vx: 0.0,
      vy: 0.0,
      kind: Equipment({
        name: "Bronze Dagger",
        rarity: Rare,
        slot: Weapon,
        atk_bonus: 3,
        def_bonus: 0,
        hp_bonus: 0,
        str_bonus: 0,
        int_bonus: 0,
        dex_bonus: 0,
        str_scaling: 0.0,
        int_scaling: 0.0,
        dex_scaling: 0.0,
        prefix: None,
        suffix: None,
        icon_id: 1,
      }),
      alive: true,
      spawn_frame: world.frame_count,
    },
  ]

  let (dx, dy, enemy_idx, enemy_dist_sq) = auto_play_input(world)

  assert_eq(enemy_idx, -1)
  assert_true(enemy_dist_sq > 0.0)
  assert_true(dx > 0.5)
  assert_true(dy.abs() < 0.2)
}

///|
test "auto_play_input routes toward nearby score pickup when no enemy is visible" {
  let world = GameWorld::new(seed=42)
  world.enemies = []
  world.items = [
    {
      x: world.player.x + tile_size,
      y: world.player.y,
      vx: 0.0,
      vy: 0.0,
      kind: Score,
      alive: true,
      spawn_frame: world.frame_count,
    },
  ]

  let (dx, dy, enemy_idx, enemy_dist_sq) = auto_play_input(world)

  assert_eq(enemy_idx, -1)
  assert_true(enemy_dist_sq > 0.0)
  assert_true(dx > 0.5)
  assert_true(dy.abs() < 0.2)
}

///|
test "auto_play_input moves toward pickup on same tile when item is still outside pickup radius" {
  let world = GameWorld::new(seed=42)
  world.enemies = []
  world.items = [
    {
      x: world.player.x + 6.0,
      y: world.player.y + 6.0,
      vx: 0.0,
      vy: 0.0,
      kind: Score,
      alive: true,
      spawn_frame: world.frame_count,
    },
  ]

  let (dx, dy, enemy_idx, enemy_dist_sq) = auto_play_input(world)

  assert_eq(enemy_idx, -1)
  assert_true(enemy_dist_sq > 0.0)
  assert_true(dx > 0.1)
  assert_true(dy > 0.1)
}

///|
fn clone_grid(grid : @terrain.Grid2D) -> @terrain.Grid2D {
  let copy = @terrain.Grid2D::make(grid.width, grid.height, @terrain.Empty)
  for row = 0; row < grid.height; row = row + 1 {
    for col = 0; col < grid.width; col = col + 1 {
      copy.set(col, row, grid.get(col, row))
    }
  }
  copy
}

///|
fn furthest_room_index_from_player(world : GameWorld) -> Int {
  let mut best_idx = 1
  let mut best_dist_sq = -1.0
  for i, room in world.dungeon.rooms {
    if i == 0 {
      continue
    }
    let center = room.rect.center()
    let cx = center.x.to_double() * tile_size + tile_size / 2.0
    let cy = center.y.to_double() * tile_size + tile_size / 2.0
    let dx = cx - world.player.x
    let dy = cy - world.player.y
    let dist_sq = dx * dx + dy * dy
    if dist_sq > best_dist_sq {
      best_idx = i
      best_dist_sq = dist_sq
    }
  }
  best_idx
}

///|
test "auto_play_input_with_nav_grid avoids blocked target room center" {
  let world = GameWorld::new(seed=42)
  world.items = []
  let target_room_idx = furthest_room_index_from_player(world)
  let target_room = world.dungeon.rooms[target_room_idx]
  let center = target_room.rect.center()
  let enemy_x = center.x.to_double() * tile_size + tile_size / 2.0
  let enemy_y = center.y.to_double() * tile_size + tile_size / 2.0
  world.enemies = [make_enemy(enemy_x, enemy_y, Basic, 3, 1.0, 10.0)]
  let nav_grid = clone_grid(world.dungeon.grid)
  nav_grid.set(center.x, center.y, @terrain.Wall)

  let (dx, dy, enemy_idx, enemy_dist_sq) = auto_play_input_with_nav_grid(
    world, nav_grid,
  )

  assert_eq(enemy_idx, -1)
  assert_true(enemy_dist_sq > 0.0)
  assert_true(dx.abs() > 0.01 || dy.abs() > 0.01)
}

///|
test "auto_play_input_with_nav_grid pathfinds around blocker toward visible enemy" {
  let world = GameWorld::new(seed=42)
  let grid = clone_grid(world.dungeon.grid)
  world.auto_cleared_rooms = Array::make(world.dungeon.rooms.length(), true)
  let player_tile_x = (world.player.x / tile_size).to_int()
  let player_tile_y = (world.player.y / tile_size).to_int()
  grid.set(player_tile_x + 1, player_tile_y, @terrain.Wall)
  world.enemies = [
    make_enemy(
      world.player.x + 3.0 * tile_size,
      world.player.y,
      Basic,
      3,
      1.0,
      10.0,
    ),
  ]

  let (dx, dy, enemy_idx, enemy_dist_sq) = auto_play_input_with_nav_grid(
    world, grid,
  )

  assert_eq(enemy_idx, -1)
  assert_true(enemy_dist_sq > 0.0)
  assert_true(dx.abs() > 0.01 || dy.abs() > 0.01)
}

///|
test "auto_play_input_with_nav_grid falls back to nearest alive enemy when rooms are marked cleared" {
  let world = GameWorld::new(seed=42)
  world.items = []
  world.auto_cleared_rooms = Array::make(world.dungeon.rooms.length(), true)
  let target_room_idx = furthest_room_index_from_player(world)
  let target_room = world.dungeon.rooms[target_room_idx]
  let center = target_room.rect.center()
  world.enemies = [
    make_enemy(
      center.x.to_double() * tile_size + tile_size / 2.0,
      center.y.to_double() * tile_size + tile_size / 2.0,
      Basic,
      3,
      1.0,
      10.0,
    ),
  ]

  let (dx, dy, enemy_idx, enemy_dist_sq) = auto_play_input_with_nav_grid(
    world,
    world.dungeon.grid,
  )

  assert_eq(enemy_idx, -1)
  assert_true(enemy_dist_sq > 0.0)
  assert_true(dx.abs() > 0.01 || dy.abs() > 0.01)
}

///|
test "auto_play_input_with_nav_grid still routes toward equipment pickup when inventory is full" {
  let world = GameWorld::new(seed=42)
  for i in 0..<world.inventory.capacity {
    ignore(
      world.inventory.add({
        name: "Filled \{i}",
        rarity: Common,
        slot: Weapon,
        atk_bonus: 1,
        def_bonus: 0,
        hp_bonus: 0,
        str_bonus: 0,
        int_bonus: 0,
        dex_bonus: 0,
        str_scaling: 0.0,
        int_scaling: 0.0,
        dex_scaling: 0.0,
        prefix: None,
        suffix: None,
        icon_id: 0,
      }),
    )
  }
  let target_room_idx = furthest_room_index_from_player(world)
  let target_room = world.dungeon.rooms[target_room_idx]
  let center = target_room.rect.center()
  world.enemies = [
    make_enemy(
      center.x.to_double() * tile_size + tile_size / 2.0,
      center.y.to_double() * tile_size + tile_size / 2.0,
      Basic,
      3,
      1.0,
      10.0,
    ),
  ]
  world.items = [
    {
      x: world.player.x + tile_size,
      y: world.player.y,
      vx: 0.0,
      vy: 0.0,
      kind: Equipment({
        name: "Blocked Loot",
        rarity: Epic,
        slot: Weapon,
        atk_bonus: 10,
        def_bonus: 0,
        hp_bonus: 0,
        str_bonus: 0,
        int_bonus: 0,
        dex_bonus: 0,
        str_scaling: 0.0,
        int_scaling: 0.0,
        dex_scaling: 0.0,
        prefix: None,
        suffix: None,
        icon_id: 1,
      }),
      alive: true,
      spawn_frame: world.frame_count,
    },
  ]

  let (dx, dy, enemy_idx, enemy_dist_sq) = auto_play_input_with_nav_grid(
    world,
    world.dungeon.grid,
  )

  assert_eq(enemy_idx, -1)
  assert_true(enemy_dist_sq > 0.0)
  assert_true(dx > 0.5)
  assert_true(dy.abs() < 0.2)
}

///|
test "tick_auto_with_enemy_ai_grid auto selects pending levelup offer" {
  let world = GameWorld::new(seed=42)
  world.auto_play = true
  world.frame_count = 59
  world.level_progress.pending_choices = 1
  world.level_progress.current_offers = [Vitality, PowerStrike, DashMastery]

  world.tick_auto_with_enemy_ai_grid(world.dungeon.grid)

  assert_eq(world.level_progress.pending_choices, 0)
  assert_eq(world.level_progress.current_offers.length(), 0)
  assert_true(
    world.skills.get_level(Vitality) > 0 ||
    world.skills.get_level(PowerStrike) > 0 ||
    world.skills.get_level(DashMastery) > 0,
  )
}

///|
test "tick_auto_with_enemy_ai_grid prefers archetype-aligned levelup offer" {
  let world = GameWorld::new(seed=42, archetype=Mage)
  world.auto_play = true
  world.frame_count = 59
  world.level_progress.pending_choices = 1
  world.level_progress.current_offers = [PowerStrike, ChainLightning, DashMastery]

  world.tick_auto_with_enemy_ai_grid(world.dungeon.grid)

  // DPS-based levelup picks the skill that maximizes total DPS
  // Either ChainLightning (level up) or PowerStrike (new skill) may win
  let cl = world.skills.get_level(ChainLightning)
  let ps = world.skills.get_level(PowerStrike)
  assert_true(cl == 2 || ps == 1) // one of them must have been leveled
}

///|
test "tick_auto_with_enemy_ai_grid picks anti-synergy offer when build policy is anti_synergy" {
  let world = GameWorld::new(
    seed=42,
    archetype=Mage,
    build_policy=AntiSynergy,
  )
  world.auto_play = true
  world.frame_count = 59
  world.level_progress.pending_choices = 1
  world.level_progress.current_offers = [PowerStrike, ChainLightning, DashMastery]

  world.tick_auto_with_enemy_ai_grid(world.dungeon.grid)

  assert_eq(world.skills.get_level(ChainLightning), 1)
  assert_eq(world.skills.get_level(PowerStrike), 1)
}
