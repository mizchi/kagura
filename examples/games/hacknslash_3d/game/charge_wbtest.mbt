///|
test "player charge winds up, moves only while active and hits each target once" {
  let world = GameWorld::new(seed=42)
  world.mode = Playing
  world.manual_combat = true
  world.dungeon.grid = @terrain.Grid2D::make(20, 10, @terrain.Floor)
  world.player.x = 64.0
  world.player.y = 64.0
  let enemy = make_enemy(85.0, 64.0, Basic, 1000, 0.0, 8.0)
  world.enemies = [enemy]
  assert_true(world.request_charge(0.0))
  assert_false(world.equip_player_weapon(Bow))
  assert_false(world.request_basic_attack(0.0))
  for _ in 0..<(player_charge_profile.windup - 1) {
    world.tick_player_charge(world.dungeon.grid)
  }
  assert_eq(world.player.x, 64.0)
  assert_eq(enemy.hp, 1000)
  for _ in 0..<player_charge_profile.active {
    world.tick_player_charge(world.dungeon.grid)
  }
  assert_true(world.player.x > 100.0)
  assert_eq(enemy.hp, 1000 - (world.player_stats.atk * 2).max(1))
  let hp = enemy.hp
  let x = world.player.x
  for _ in 0..<(player_charge_profile.recovery + 2) {
    world.tick_player_charge(world.dungeon.grid)
  }
  assert_eq(world.player.x, x)
  assert_eq(enemy.hp, hp)
  assert_true(world.player_charge is None)
  assert_false(world.request_charge(0.0))
}

///|
test "player charge stops at walls and dodge cancels it without delayed damage" {
  let world = GameWorld::new(seed=42)
  world.mode = Playing
  world.dungeon.grid = @terrain.Grid2D::make(20, 10, @terrain.Floor)
  world.dungeon.grid.set(6, 5, @terrain.Wall)
  world.player.x = 64.0
  world.player.y = 80.0
  let enemy = make_enemy(112.0, 80.0, Basic, 1000, 0.0, 8.0)
  world.enemies = [enemy]
  assert_true(world.request_charge(0.0))
  for _ in 0..<60 {
    world.tick_player_charge(world.dungeon.grid)
  }
  assert_true(world.player.x <= 96.0 - world.player.size / 2.0)
  assert_eq(enemy.hp, 1000)
  world.charge_cooldown = 0
  assert_true(world.request_charge(0.0))
  world.player.dash_timer = 6
  world.tick_player_charge(world.dungeon.grid)
  assert_true(world.player_charge is None)
  assert_eq(enemy.hp, 1000)
}

///|
test "enemy tackle has anticipation, committed travel and a motion recovery" {
  let world = GameWorld::new(seed=42)
  world.dungeon.grid = @terrain.Grid2D::make(20, 10, @terrain.Floor)
  world.player.x = 100.0
  world.player.y = 64.0
  let enemy = make_enemy(64.0, 64.0, Fast, 100, 1.2, 8.0)
  world.enemies = [enemy]
  start_enemy_tackle(enemy, world.player.combat_target(), world.events)
  assert_eq(enemy.attack_motion, Charge)
  for _ in 0..<(enemy_tackle_telegraph_frames - 1) {
    tick_enemy_attack(enemy)
    assert_true(update_enemy_tackle(enemy))
    assert_eq(enemy.vx, 0.0)
  }
  tick_enemy_attack(enemy)
  assert_true(update_enemy_tackle(enemy))
  assert_true(enemy.vx > 0.0)
  world.player.y += 64.0
  tick_enemy_attack(enemy)
  assert_true(update_enemy_tackle(enemy))
  assert_eq(enemy.vy, 0.0)
  enemy.attack_frame = enemy_tackle_telegraph_frames +
    enemy_tackle_active_frames
  assert_true(update_enemy_tackle(enemy))
  assert_eq(enemy.vx, 0.0)
  assert_eq(enemy.attack_motion, Charge)
}
