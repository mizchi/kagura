///|
test "auto_play_input routes toward nearby equipment pickup when no enemy is visible" {
  let world = GameWorld::new(seed=42)
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
