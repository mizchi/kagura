///|
fn count_chain_arcs(events : Array[GameEvent]) -> Int {
  let mut count = 0
  for event in events {
    match event {
      ChainLightningArc(_, _, _, _) => count += 1
      _ => ()
    }
  }
  count
}

///|
fn has_fireball_burst(events : Array[GameEvent]) -> Bool {
  for event in events {
    match event {
      FireballBurst(_, _) => return true
      _ => ()
    }
  }
  false
}

///|
fn has_fireball_cast(events : Array[GameEvent]) -> Bool {
  for event in events {
    match event {
      FireballCast(_, _) => return true
      _ => ()
    }
  }
  false
}

///|
fn has_ice_nova_cast(events : Array[GameEvent]) -> Bool {
  for event in events {
    match event {
      IceNovaCast(_, _, _) => return true
      _ => ()
    }
  }
  false
}

///|
fn projectile_fireball_count(projectiles : Array[Projectile]) -> Int {
  let mut count = 0
  for projectile in projectiles {
    match projectile.kind {
      Fireball(_) => count += 1
      _ => ()
    }
  }
  count
}

///|
test "cast_chain_lightning damages multiple enemies and emits arc events" {
  let world = GameWorld::new(seed=42)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [
    make_enemy(px + 24.0, py, Basic, 12, 1.0, 10.0),
    make_enemy(px + 48.0, py + 8.0, Fast, 10, 1.0, 8.0),
    make_enemy(px + 72.0, py + 4.0, Tank, 16, 1.0, 14.0),
  ]

  let casted = cast_chain_lightning(world)

  assert_true(casted)
  assert_eq(count_chain_arcs(world.events), 3)
  assert_true(world.enemies[0].hp < 12)
  assert_true(world.enemies[1].hp < 10)
  assert_true(world.enemies[2].hp < 16)
}

///|
test "cast_chain_lightning without enemy still emits forward arc feedback" {
  let world = GameWorld::new(seed=42)
  world.player.facing_angle = 0.0

  let casted = cast_chain_lightning(world)

  assert_true(casted)
  assert_eq(count_chain_arcs(world.events), 1)
  assert_eq(world.chain_lightning_cooldown_timer, chain_lightning_cooldown)
  assert_true(world.attack_timer > 0)
}

///|
test "cast_splitting_fireball spawns fireball projectile" {
  let world = GameWorld::new(seed=42)

  let casted = cast_splitting_fireball(world)

  assert_true(casted)
  assert_eq(world.projectiles.length(), 1)
  assert_eq(projectile_fireball_count(world.projectiles), 1)
  assert_true(has_fireball_cast(world.events))
  assert_true(world.attack_timer > 0)
}

///|
test "tick_projectiles_phase splits fireball on enemy hit" {
  let world = GameWorld::new(seed=42)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [make_enemy(px + 8.0, py, Basic, 12, 1.0, 10.0)]
  world.projectiles = [
    {
      x: px + 8.0,
      y: py,
      vx: 0.0,
      vy: 0.0,
      alive: true,
      damage: 6,
      is_player: true,
      kind: Fireball(1),
    },
  ]

  world.tick_projectiles_phase()

  assert_true(has_fireball_burst(world.events))
  assert_true(projectile_fireball_count(world.projectiles) >= 2)
}

///|
test "cast_ice_nova damages nearby enemies and emits nova event" {
  let world = GameWorld::new(seed=42)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [
    make_enemy(px + 16.0, py, Basic, 12, 1.0, 10.0),
    make_enemy(px + 24.0, py + 12.0, Fast, 10, 1.0, 8.0),
    make_enemy(px + 120.0, py, Tank, 20, 1.0, 14.0),
  ]

  let casted = cast_ice_nova(world)

  assert_true(casted)
  assert_true(has_ice_nova_cast(world.events))
  assert_true(world.enemies[0].hp < 12)
  assert_true(world.enemies[1].hp < 10)
  assert_eq(world.enemies[2].hp, 20)
  assert_true(world.attack_timer > 0)
}
