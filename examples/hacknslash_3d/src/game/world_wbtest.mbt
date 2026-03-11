///|
fn enemy_overlap_pair_count(enemies : Array[Enemy]) -> Int {
  let mut count = 0
  for i = 0; i < enemies.length(); i = i + 1 {
    let a = enemies[i]
    if not(a.alive) {
      continue
    }
    for j = i + 1; j < enemies.length(); j = j + 1 {
      let b = enemies[j]
      if not(b.alive) {
        continue
      }
      let dx = a.x - b.x
      let dy = a.y - b.y
      let min_dist = (a.size + b.size) / 2.0
      if dx * dx + dy * dy < min_dist * min_dist {
        count = count + 1
      }
    }
  }
  count
}

///|
test "enemy separation grid index clamps into 2d bounds" {
  let cols = enemy_separation_grid_cols()
  let rows = enemy_separation_grid_rows()
  let start = enemy_separation_grid_index(-10.0, -10.0, cols, rows)
  let end = enemy_separation_grid_index(10000.0, 10000.0, cols, rows)
  assert_eq(start, 0)
  assert_eq(end, cols * rows - 1)
}

///|
test "enemy separation grid index changes by row and column" {
  let cols = enemy_separation_grid_cols()
  let rows = enemy_separation_grid_rows()
  let a = enemy_separation_grid_index(0.0, 0.0, cols, rows)
  let b = enemy_separation_grid_index(20.0, 0.0, cols, rows)
  let c = enemy_separation_grid_index(0.0, 20.0, cols, rows)
  assert_eq(b, a + 1)
  assert_eq(c, a + cols)
}

///|
test "resolve_enemy_enemy_separation reduces overlap count in dense cluster" {
  let world = GameWorld::new(seed=42)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [
    make_enemy(px, py, Basic, 3, 1.0, 10.0),
    make_enemy(px + 1.0, py, Fast, 2, 1.0, 8.0),
    make_enemy(px + 2.0, py, Tank, 5, 1.0, 14.0),
  ]
  let before = enemy_overlap_pair_count(world.enemies)
  world.resolve_enemy_enemy_separation()
  let after = enemy_overlap_pair_count(world.enemies)
  assert_true(before > after)
}

///|
test "resolve_enemy_enemy_separation keeps distant enemies unchanged" {
  let world = GameWorld::new(seed=42)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [
    make_enemy(px, py, Basic, 3, 1.0, 10.0),
    make_enemy(px + 64.0, py + 64.0, Fast, 2, 1.0, 8.0),
  ]
  let before0 = world.enemies[0].x
  let before1 = world.enemies[1].x
  world.resolve_enemy_enemy_separation()
  assert_eq(enemy_overlap_pair_count(world.enemies), 0)
  assert_eq(world.enemies[0].x, before0)
  assert_eq(world.enemies[1].x, before1)
}

///|
test "tick_projectiles_phase applies enemy projectile damage and compacts" {
  let world = GameWorld::new(seed=42)
  let before_hp = world.player.hp
  world.projectiles = [
    {
      x: world.player.x,
      y: world.player.y,
      vx: 0.0,
      vy: 0.0,
      alive: true,
      damage: 2,
      is_player: false,
    },
  ]
  world.tick_projectiles_phase()
  assert_true(world.player.hp < before_hp)
  assert_eq(world.projectiles.length(), 0)
}

///|
test "tick_enemy_movement_and_contact_phase applies contact damage once" {
  let world = GameWorld::new(seed=42)
  let before_hp = world.player.hp
  world.enemies = [
    make_enemy(world.player.x, world.player.y, Basic, 3, 1.0, 10.0),
    make_enemy(world.player.x + 1.0, world.player.y, Fast, 2, 1.0, 8.0),
  ]
  world.tick_enemy_movement_and_contact_phase()
  assert_true(world.player.hp < before_hp)
  assert_true(world.player.iframe_timer > 0)
}

///|
test "tick_items_phase collects score item and compacts" {
  let world = GameWorld::new(seed=42)
  let before_score = world.score
  world.items = [
    {
      x: world.player.x,
      y: world.player.y,
      vx: 0.0,
      vy: 0.0,
      kind: Score,
      alive: true,
      spawn_frame: world.frame_count,
    },
  ]
  world.tick_items_phase()
  assert_eq(world.score, before_score + 5)
  assert_eq(world.items.length(), 0)
}
