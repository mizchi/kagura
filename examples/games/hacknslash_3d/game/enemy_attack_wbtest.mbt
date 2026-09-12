///|
test "melee anticipates, hits once, and leaves a recovery window" {
  let world = GameWorld::new(seed=42)
  let e = make_enemy(
    world.player.x - 10.0,
    world.player.y,
    Basic,
    100,
    0.0,
    10.0,
  )
  world.enemies = [e]
  let hp = world.player.hp
  world.tick_enemy_ai_phase()
  assert_eq(e.attack_motion, Punch)
  assert_eq(e.attack_frame, 0)
  world.tick_enemy_movement_and_contact_phase()
  assert_eq(world.player.hp, hp)
  for _ in 0..<e.attack_windup {
    world.tick_enemy_ai_phase()
    world.tick_enemy_movement_and_contact_phase()
  }
  assert_true(world.player.hp < hp)
  let hurt = world.player.hp
  world.player.iframe_timer = 0
  for _ in 0..<10 {
    world.tick_enemy_ai_phase()
    world.tick_enemy_movement_and_contact_phase()
  }
  assert_eq(world.player.hp, hurt)
  assert_true(e.attack_frame > e.attack_windup)
  assert_eq(e.vx, 0.0)
}

///|
test "spear locks aim so stepping behind avoids impact" {
  let world = GameWorld::new(seed=42)
  let e = make_enemy(world.player.x - 24.0, world.player.y, Fast, 100, 0.0, 8.0)
  world.enemies = [e]
  world.tick_enemy_ai_phase()
  assert_eq(e.attack_motion, SpearThrust)
  world.player.x = e.x - 10.0
  let hp = world.player.hp
  for _ in 0..<(e.attack_windup + 1) {
    world.tick_enemy_ai_phase()
    world.tick_enemy_movement_and_contact_phase()
  }
  assert_eq(world.player.hp, hp)
}

///|
test "melee cannot hit across a wall and a dead attacker cannot finish" {
  let world = GameWorld::new(seed=42)
  let e = make_enemy(
    world.player.x - 10.0,
    world.player.y,
    Basic,
    100,
    0.0,
    10.0,
  )
  world.enemies = [e]
  world.tick_enemy_ai_phase()
  e.alive = false
  let hp = world.player.hp
  for _ in 0..<40 {
    world.tick_enemy_ai_phase()
    world.tick_enemy_movement_and_contact_phase()
  }
  assert_eq(world.player.hp, hp)
  e.alive = true
  e.attack_frame = e.attack_windup
  e.attack_hit_pending = true
  world.dungeon.grid.set(
    (e.x / tile_size).to_int(),
    (e.y / tile_size).to_int(),
    @terrain.Wall,
  )
  world.tick_enemy_movement_and_contact_phase()
  assert_eq(world.player.hp, hp)
}

///|
test "archer locks aim, releases one arrow on contact, and never deals melee damage" {
  let world = GameWorld::new(seed=42)
  let e = make_enemy(
    world.player.x + 80.0,
    world.player.y,
    Ranged,
    100,
    0.0,
    10.0,
  )
  world.enemies = [e]
  world.tick_enemy_ai_phase()
  assert_eq(e.attack_motion, BowShot)
  assert_eq(e.attack_frame, 0)
  let target_y = world.player.y
  world.player.y += 30.0
  for _ in 0..<(e.attack_windup - 1) {
    world.tick_enemy_ai_phase()
    assert_false(e.attack_hit_pending)
  }
  assert_eq(world.projectiles.length(), 0)
  assert_true(e.attack_phase() < 0.5)
  world.tick_enemy_ai_phase()
  assert_eq(world.projectiles.length(), 1)
  assert_eq(e.attack_phase(), 0.5)
  assert_false(e.attack_hit_pending)
  let arrow = world.projectiles[0]
  assert_eq(arrow.kind, Arrow)
  assert_false(arrow.is_player)
  assert_true(arrow.vx < 0.0)
  assert_eq(arrow.vy, 0.0)
  assert_eq(e.attack_target_y, target_y)
  for _ in 0..<e.attack_recovery {
    world.tick_enemy_ai_phase()
    assert_false(e.attack_hit_pending)
    assert_eq(e.vx, 0.0)
  }
  assert_eq(world.projectiles.length(), 1)
}

///|
test "killing an archer during the draw cancels its arrow" {
  let world = GameWorld::new(seed=42)
  let e = make_enemy(
    world.player.x + 80.0,
    world.player.y,
    Ranged,
    100,
    0.0,
    10.0,
  )
  world.enemies = [e]
  world.tick_enemy_ai_phase()
  assert_eq(e.attack_motion, BowShot)
  e.alive = false
  for _ in 0..<80 {
    world.tick_enemy_ai_phase()
  }
  assert_eq(world.projectiles.length(), 0)
}

///|
test "summoner gathers energy before a minion appears" {
  let world = GameWorld::new(seed=42)
  let e = make_enemy(
    world.player.x + 64.0,
    world.player.y,
    Summoner,
    100,
    0.0,
    10.0,
  )
  world.enemies = [e]
  world.tick_enemy_ai_phase()
  assert_eq(e.attack_motion, CastSpell)
  assert_eq(world.enemies.length(), 1)
  for _ in 0..<29 {
    world.tick_enemy_ai_phase()
  }
  assert_eq(world.enemies.length(), 1)
  world.tick_enemy_ai_phase()
  assert_eq(world.enemies.length(), 2)
  assert_eq(e.attack_phase(), 0.5)
}
