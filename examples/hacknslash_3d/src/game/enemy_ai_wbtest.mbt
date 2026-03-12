///|
test "tick_enemy_ai_phase uses direct chase for same-room basic enemy" {
  let world = GameWorld::new(seed=42)
  world.enemies = [
    make_enemy(world.player.x + 32.0, world.player.y, Basic, 3, 1.0, 10.0),
  ]
  world.tick_enemy_ai_phase()
  assert_eq(world.enemies[0].path_cache.length(), 0)
  assert_true(world.enemies[0].vx < 0.0)
  assert_true(world.enemies[0].vy.abs() < 1.0e-9)
}

///|
test "update_enemy_ai falls back to pathfinding when same-room direct chase is blocked" {
  let grid = @terrain.Grid2D::make(5, 3, @terrain.Floor)
  grid.set(2, 1, @terrain.Wall)
  let rooms : Array[@terrain.Room] = [
    { rect: { x: 0, y: 0, w: 5, h: 3 }, id: 0 },
  ]
  let player : Player = {
    x: 0.5 * tile_size,
    y: 1.5 * tile_size,
    hp: 10,
    max_hp: 10,
    size: 12.0,
    damage_timer: 0,
    iframe_timer: 0,
    facing_angle: 0.0,
    dash_timer: 0,
    dash_cooldown_timer: 0,
    dash_vx: 0.0,
    dash_vy: 0.0,
  }
  let enemies = [
    make_enemy(4.5 * tile_size, 1.5 * tile_size, Basic, 3, 1.0, 10.0),
  ]
  let projectiles : Array[Projectile] = []
  let events : Array[GameEvent] = []

  update_enemy_ai(enemies, player, grid, rooms, 0, projectiles, events)

  assert_true(enemies[0].path_cache.length() > 0)
  assert_true(enemies[0].path_index >= 1)
}

///|
test "update_enemy_ai telegraphs ranged bolt before spawning projectile" {
  let grid = @terrain.Grid2D::make(8, 3, @terrain.Floor)
  let rooms : Array[@terrain.Room] = [
    { rect: { x: 0, y: 0, w: 8, h: 3 }, id: 0 },
  ]
  let player : Player = {
    x: 1.5 * tile_size,
    y: 1.5 * tile_size,
    hp: 10,
    max_hp: 10,
    size: 12.0,
    damage_timer: 0,
    iframe_timer: 0,
    facing_angle: 0.0,
    dash_timer: 0,
    dash_cooldown_timer: 0,
    dash_vx: 0.0,
    dash_vy: 0.0,
  }
  let enemies = [
    make_enemy(6.5 * tile_size, 1.5 * tile_size, Ranged, 3, 1.0, 10.0),
  ]
  let projectiles : Array[Projectile] = []
  let events : Array[GameEvent] = []

  update_enemy_ai(enemies, player, grid, rooms, 0, projectiles, events)

  assert_eq(projectiles.length(), 0)
  assert_true(enemies[0].pending_bolt_timer > 0)
  let mut saw_ring = false
  let mut saw_line = false
  for event in events {
    match event {
      GroundTelegraphRing(_, _, _) => saw_ring = true
      GroundTelegraphLine(_, _, _, _) => saw_line = true
      _ => ()
    }
  }
  assert_true(saw_ring)
  assert_true(saw_line)

  let settle_events : Array[GameEvent] = []
  for frame = 0; frame < enemy_bolt_telegraph_frames; frame = frame + 1 {
    update_enemy_ai(
      enemies,
      player,
      grid,
      rooms,
      frame + 1,
      projectiles,
      settle_events,
    )
  }
  assert_eq(projectiles.length(), 1)
  assert_eq(projectiles[0].kind, EnemyBolt)
}
