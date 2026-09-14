///|
test "resting packs remain still and a hit wakes only their own group before attacking" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.player.x = 90.0 * tile_size
  w.player.y = 70.0 * tile_size
  let a = make_enemy(
    20.5 * tile_size,
    50.5 * tile_size,
    Basic,
    10,
    1.0,
    10.0,
    room_index=0,
  )
  let b = make_enemy(
    22.5 * tile_size,
    50.5 * tile_size,
    Ranged,
    10,
    1.0,
    10.0,
    room_index=0,
  )
  let c = make_enemy(
    60.5 * tile_size,
    30.5 * tile_size,
    Basic,
    10,
    1.0,
    10.0,
    room_index=2,
  )
  let enemies = [a, b, c]
  configure_enemy_camps(enemies, 42)
  for frame in 0..<90 {
    update_enemy_ai(
      enemies,
      w.player,
      w.dungeon.grid,
      w.dungeon.rooms,
      frame,
      [],
      [],
    )
  }
  assert_eq(a.camp.unwrap().awareness, Resting)
  assert_eq(a.vx, 0.0)
  assert_eq(b.attack_motion, NoAttack)
  a.hp -= 1
  update_enemy_ai(enemies, w.player, w.dungeon.grid, w.dungeon.rooms, 91, [], [])
  assert_true(a.camp.unwrap().awareness is Waking(_))
  assert_true(b.camp.unwrap().awareness is Waking(_))
  assert_eq(c.camp.unwrap().awareness, Resting)
  assert_eq(a.vx, 0.0)
  for frame in 92..<140 {
    update_enemy_ai(
      enemies,
      w.player,
      w.dungeon.grid,
      w.dungeon.rooms,
      frame,
      [],
      [],
    )
  }
  assert_eq(a.camp.unwrap().awareness, Alert)
  assert_eq(b.camp.unwrap().awareness, Alert)
}

///|
test "pack sight respects walls and alert state survives a save" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  let enemy = w.enemies[0]
  assert_true(enemy.camp is Some(_))
  enemy.camp.unwrap().awareness = Alert
  let copy = GameWorld::new(seed=43, hunting_grounds=true)
  assert_true(copy.restore_world_progress(w.serialize_world_progress()))
  assert_eq(copy.enemies[0].camp.unwrap().awareness, Alert)
  let grid = @terrain.Grid2D::make(20, 20, @terrain.Floor)
  let a = make_enemy(
    5.5 * tile_size,
    5.5 * tile_size,
    Basic,
    10,
    1.0,
    10.0,
    room_index=0,
  )
  configure_enemy_camps([a], 42)
  w.player.x = 9.5 * tile_size
  w.player.y = 5.5 * tile_size
  for z in 0..<20 {
    grid.set(7, z, @terrain.Wall)
  }
  update_enemy_ai([a], w.player, grid, [], 1, [], [])
  assert_eq(a.camp.unwrap().awareness, Resting)
  grid.set(7, 5, @terrain.Floor)
  update_enemy_ai([a], w.player, grid, [], 2, [], [])
  assert_true(a.camp.unwrap().awareness is Waking(_))
}
