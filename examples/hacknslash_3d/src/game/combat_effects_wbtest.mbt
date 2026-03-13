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
fn count_ground_telegraph_rings(events : Array[GameEvent]) -> Int {
  let mut count = 0
  for event in events {
    match event {
      GroundTelegraphRing(_, _, _) => count += 1
      _ => ()
    }
  }
  count
}

///|
fn count_ground_telegraph_lines(events : Array[GameEvent]) -> Int {
  let mut count = 0
  for event in events {
    match event {
      GroundTelegraphLine(_, _, _, _) => count += 1
      _ => ()
    }
  }
  count
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
fn count_homing_missile_launches(events : Array[GameEvent]) -> Int {
  let mut count = 0
  for event in events {
    match event {
      HomingMissileLaunch(_, _, _, _) => count += 1
      _ => ()
    }
  }
  count
}

///|
fn count_homing_missile_trails(events : Array[GameEvent]) -> Int {
  let mut count = 0
  for event in events {
    match event {
      HomingMissileTrail(_, _, _, _) => count += 1
      _ => ()
    }
  }
  count
}

///|
fn has_homing_missile_impact(events : Array[GameEvent]) -> Bool {
  for event in events {
    match event {
      HomingMissileImpact(_, _) => return true
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
fn projectile_homing_missile_count(projectiles : Array[Projectile]) -> Int {
  let mut count = 0
  for projectile in projectiles {
    match projectile.kind {
      HomingMissile => count += 1
      _ => ()
    }
  }
  count
}

///|
fn unlock_spell_for_combat_test(world : GameWorld, id : SkillId) -> Unit {
  ignore(world.skills.learn_from_levelup(id))
}

///|
test "cast_chain_lightning fails before unlock" {
  let world = GameWorld::new(seed=42)

  let casted = cast_chain_lightning(world)

  assert_false(casted)
  assert_eq(count_chain_arcs(world.events), 0)
}

///|
test "cast_chain_lightning damages multiple enemies and emits arc events" {
  let world = GameWorld::new(seed=42)
  unlock_spell_for_combat_test(world, ChainLightning)
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
  assert_eq(count_ground_telegraph_lines(world.events), 1)
  assert_eq(count_ground_telegraph_rings(world.events), 1)
  assert_true(world.enemies[0].hp < 12)
  assert_true(world.enemies[1].hp < 10)
  assert_true(world.enemies[2].hp < 16)
}

///|
test "cast_chain_lightning without enemy still emits forward arc feedback" {
  let world = GameWorld::new(seed=42)
  unlock_spell_for_combat_test(world, ChainLightning)
  world.player.facing_angle = 0.0

  let casted = cast_chain_lightning(world)

  assert_true(casted)
  assert_eq(count_chain_arcs(world.events), 1)
  assert_eq(count_ground_telegraph_lines(world.events), 1)
  assert_eq(count_ground_telegraph_rings(world.events), 1)
  assert_eq(
    world.chain_lightning_cooldown_timer,
    world.params.chain_lightning_cooldown_frames(),
  )
  assert_true(world.attack_timer > 0)
}

///|
test "spell multipliers affect cooldowns and spell damage" {
  let world = GameWorld::new(
    seed=42,
    params={
      ..BalanceParams::default(),
      spell_cooldown_mult: 2.0,
      spell_damage_mult: 0.5,
    },
  )
  unlock_spell_for_combat_test(world, ChainLightning)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [make_enemy(px + 24.0, py, Basic, 12, 1.0, 10.0)]

  let casted = cast_chain_lightning(world)

  assert_true(casted)
  assert_eq(
    world.chain_lightning_cooldown_timer,
    world.params.chain_lightning_cooldown_frames(),
  )
  assert_eq(world.enemies[0].hp, 11)
}

///|
test "cast_splitting_fireball spawns fireball projectile" {
  let world = GameWorld::new(seed=42)
  unlock_spell_for_combat_test(world, SplittingFireball)

  let casted = cast_splitting_fireball(world)

  assert_true(casted)
  assert_eq(world.projectiles.length(), 1)
  assert_eq(projectile_fireball_count(world.projectiles), 1)
  assert_true(has_fireball_cast(world.events))
  assert_eq(count_ground_telegraph_lines(world.events), 1)
  assert_eq(count_ground_telegraph_rings(world.events), 1)
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
      age: 0,
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
  unlock_spell_for_combat_test(world, IceNova)
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
  assert_eq(count_ground_telegraph_rings(world.events), 1)
  assert_true(world.enemies[0].hp < 12)
  assert_true(world.enemies[1].hp < 10)
  assert_eq(world.enemies[2].hp, 20)
  assert_true(world.attack_timer > 0)
}

///|
test "cast_homing_missile spawns projectile and telegraph events" {
  let world = GameWorld::new(seed=42)
  unlock_spell_for_combat_test(world, HomingMissile)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [make_enemy(px + 128.0, py + 8.0, Basic, 12, 1.0, 10.0)]

  let casted = cast_homing_missile(world)

  assert_true(casted)
  assert_eq(projectile_homing_missile_count(world.projectiles), 2)
  assert_eq(count_homing_missile_launches(world.events), 2)
  assert_eq(count_ground_telegraph_lines(world.events), 1)
  assert_eq(count_ground_telegraph_rings(world.events), 1)
  assert_eq(
    world.homing_missile_cooldown_timer,
    world.params.homing_missile_cooldown_frames(),
  )
  assert_true(world.attack_timer > 0)
  let left = world.projectiles[0]
  let right = world.projectiles[1]
  assert_true((left.x + right.x - px * 2.0).abs() < 0.0001)
  assert_true((left.y + right.y - py * 2.0).abs() < 0.0001)
  assert_true((left.x - px).abs() > 0.01 || (left.y - py).abs() > 0.01)
}

///|
test "enemy death rewards xp and opens level up offers" {
  let world = GameWorld::new(
    seed=42,
    params={ ..BalanceParams::default(), levelup_xp_base: 1.0, levelup_xp_growth: 0.0 },
  )
  let enemy = make_enemy(world.player.x + 8.0, world.player.y, Basic, 1, 1.0, 10.0)
  world.enemies = [enemy]

  apply_player_damage_to_enemy(world, world.enemies[0], 2, world.player.x, world.player.y)

  assert_eq(world.level_progress.level, 2)
  assert_eq(world.level_progress.pending_choices, 1)
  assert_eq(world.level_progress.current_offers.length(), 3)
  assert_true(world.ui_mode == LevelUp)
}

///|
test "tick_projectiles_phase steers and impacts homing missile" {
  let world = GameWorld::new(seed=42)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [make_enemy(px + 36.0, py, Basic, 12, 1.0, 10.0)]
  world.projectiles = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: homing_missile_speed,
      alive: true,
      damage: 7,
      is_player: true,
      age: 0,
      kind: HomingMissile,
    },
  ]

  world.tick_projectiles_phase()

  assert_true(count_homing_missile_trails(world.events) >= 1)
  assert_true(world.projectiles[0].vx > 1.4)
  assert_true(world.projectiles[0].vy < homing_missile_speed)

  world.projectiles[0].x = world.enemies[0].x
  world.projectiles[0].y = world.enemies[0].y
  world.tick_projectiles_phase()

  assert_true(has_homing_missile_impact(world.events))
}
