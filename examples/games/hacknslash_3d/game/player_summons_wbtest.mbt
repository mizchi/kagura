///|
test "summoner starts with two assignable skills and casting has a cancellable windup" {
  let w = GameWorld::new(seed=42, hunting_grounds=true, archetype=Summoner)
  w.mode = Playing
  assert_eq(w.hunter_slots, [57, 48, 52, 86])
  assert_true(w.hunter_action_learned(57) && w.hunter_action_learned(48))
  assert_true(w.request_hunter_spell(RaiseZombieArt))
  for _ in 0..<17 {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  assert_eq(w.summons.zombies.length(), 0)
  w.cancel_hunter_action()
  assert_eq(w.summons.zombie_cooldown, 0)
  assert_true(w.request_hunter_spell(RaiseZombieArt))
  for _ in 0..<18 {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  assert_eq(w.summons.zombies.length(), 1)
  assert_true(w.summons.zombie_cooldown > 0)
  assert_false(w.request_hunter_spell(RaiseZombieArt))
}

///|
test "zombie taunts nearby enemies, receives committed melee hits, and releases aggro on death" {
  let w = melee_test_world()
  w.release_player_summon(RaiseZombieArt)
  let ally = w.summons.zombies[0].body
  ally.x = 180.0
  ally.y = 120.0
  let enemy = make_enemy(164.0, 120.0, Basic, 100, 0.0, 10.0)
  w.enemies = [enemy]
  w.tick_enemy_ai_phase()
  assert_eq(enemy.attack_target_x, ally.x)
  let hp = w.player.hp
  let ally_hp = ally.hp
  for _ in 0..<32 {
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
  }
  assert_eq(w.player.hp, hp)
  assert_true(ally.hp < ally_hp)
  ally.alive = false
  enemy.attack_motion = NoAttack
  enemy.attack_cooldown = 0
  enemy.x = 138.0
  w.tick_enemy_ai_phase()
  assert_eq(enemy.attack_target_x, w.player.x)
}

///|
test "flaming skulls stack, pass through walls, never taunt, and expire without an extra hit" {
  let w = melee_test_world()
  for _ in 0..<12 {
    w.release_player_summon(FlamingSkullArt)
  }
  assert_eq(w.summons.skulls.length(), flaming_skull_limit)
  let enemy = make_enemy(180.0, 120.0, Basic, 1000, 0.0, 10.0)
  w.enemies = [enemy]
  for skull in w.summons.skulls {
    skull.x = 130.0
    skull.y = 120.0
  }
  w.dungeon.grid.set(9, 7, @terrain.Wall)
  for _ in 0..<80 {
    w.tick_player_summons()
  }
  assert_true(w.summons.skulls.all(s => s.x > 160.0))
  assert_true(enemy.hp < 1000)
  for skull in w.summons.skulls {
    skull.age = flaming_skull_lifetime - 1
  }
  let hp = enemy.hp
  w.tick_player_summons()
  assert_eq(w.summons.skulls.length(), 0)
  assert_eq(enemy.hp, hp)
}

///|
test "summon cap replaces oldest, zombie body intercepts bolts, and death clears companions" {
  let w = melee_test_world()
  for _ in 0..<3 {
    w.release_player_summon(RaiseZombieArt)
  }
  assert_eq(w.summons.zombies.length(), summoned_zombie_limit)
  let ally = w.summons.zombies[0].body
  ally.x = 150.0
  ally.y = 120.0
  let hp = ally.hp
  w.projectiles = [
    {
      x: 180.0,
      y: 120.0,
      vx: -45.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 3,
      is_player: false,
      kind: EnemyBolt,
    },
  ]
  w.tick_projectiles_phase()
  assert_eq(ally.hp, hp - 3)
  assert_eq(w.projectiles.length(), 0)
  w.release_player_summon(FlamingSkullArt)
  w.deal_player_damage(10000)
  assert_eq(w.summons.zombies.length(), 0)
  assert_eq(w.summons.skulls.length(), 0)
}

///|
test "only living visible zombies taunt; skulls and zombies behind walls do not" {
  let w = melee_test_world()
  w.release_player_summon(FlamingSkullArt)
  let e = make_enemy(138.0, 120.0, Basic, 100, 0.0, 10.0)
  assert_eq(
    enemy_aggro_target(e, w.player, w.summons.zombies, w.dungeon.grid).x,
    120.0,
  )
  w.release_player_summon(RaiseZombieArt)
  let ally = w.summons.zombies[0].body
  ally.x = 180.0
  ally.y = 120.0
  w.dungeon.grid.set(9, 7, @terrain.Wall)
  assert_eq(
    enemy_aggro_target(e, w.player, w.summons.zombies, w.dungeon.grid).x,
    120.0,
  )
  w.dungeon.grid.set(9, 7, @terrain.Floor)
  assert_eq(
    enemy_aggro_target(e, w.player, w.summons.zombies, w.dungeon.grid).x,
    180.0,
  )
}

///|
test "zombie pounce deals enemy damage once, never damages its owner, and bodies separate" {
  let w = melee_test_world()
  w.release_player_summon(RaiseZombieArt)
  let ally = w.summons.zombies[0].body
  ally.x = 140.0
  ally.y = 120.0
  let e = make_enemy(180.0, 120.0, Basic, 100, 0.0, 10.0)
  w.enemies = [e]
  let hp = w.player.hp
  for _ in 0..<50 {
    w.tick_player_summons()
  }
  assert_eq(e.hp, 100)
  w.tick_player_summons()
  assert_true(e.hp < 100)
  let enemy_hp = e.hp
  for _ in 0..<40 {
    w.tick_player_summons()
  }
  assert_eq(e.hp, enemy_hp)
  assert_eq(w.player.hp, hp)
  ally.x = e.x
  ally.y = e.y
  w.resolve_summon_separation()
  assert_true((ally.x - e.x).abs() > 10.0)
}

///|
test "enemy area attacks damage zombies, skulls survive, and floor travel dismisses both" {
  let w = melee_test_world()
  w.release_player_summon(RaiseZombieArt)
  w.release_player_summon(FlamingSkullArt)
  let ally = w.summons.zombies[0].body
  let hp = ally.hp
  w.events = [MeteorImpact(ally.x, ally.y, 20.0)]
  w.tick_meteor_damage_phase()
  assert_true(ally.hp < hp)
  assert_eq(w.summons.skulls.length(), 1)
  w.apply_dungeon(43, 2)
  assert_eq(w.summons.zombies.length(), 0)
  assert_eq(w.summons.skulls.length(), 0)
}

///|
test "summon kill awards experience without owner life steal and retargets surviving enemies" {
  let w = melee_test_world()
  let e = make_enemy(140.0, 120.0, Basic, 1, 0.0, 10.0)
  let next = make_enemy(200.0, 120.0, Basic, 100, 0.0, 10.0)
  w.enemies = [e, next]
  w.player.hp = 1
  w.player_stats = { ..w.player_stats, life_steal: 1.0, }
  w.release_player_summon(FlamingSkullArt)
  let skull = w.summons.skulls[0]
  skull.x = e.x
  skull.y = e.y
  w.tick_player_summons()
  assert_false(e.alive)
  assert_true(w.level_progress.xp > 0)
  assert_eq(w.player.hp, 1)
  w.tick_player_summons()
  assert_true(skull.target is Some(enemy) && enemy.x == next.x)
}

///|
test "grounded summons respect navigation blockers and spirits ignore the same obstacle" {
  let w = melee_test_world()
  w.release_player_summon(RaiseZombieArt)
  w.release_player_summon(FlamingSkullArt)
  let ally = w.summons.zombies[0].body
  ally.x = 130.0
  ally.y = 120.0
  w.player.x = 180.0
  let nav = @terrain.Grid2D::make(
    w.dungeon.grid.width,
    w.dungeon.grid.height,
    @terrain.Floor,
  )
  for y in 0..<nav.height {
    nav.set(9, y, @terrain.Wall)
  }
  for _ in 0..<80 {
    w.tick_player_summons_with_grid(nav)
  }
  assert_true(ally.x < 144.0)
  assert_true(w.summons.skulls[0].x > 144.0)
}
