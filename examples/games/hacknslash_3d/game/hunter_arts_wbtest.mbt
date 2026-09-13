///|
fn arts_world() -> GameWorld {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.manual_combat = true
  world.enemies.clear()
  world.player.x = 20.5 * tile_size
  world.player.y = 49.5 * tile_size
  world.player_stats = { ..world.player_stats, def: 0, }
  world
}

///|
test "shield guards the front, perfect blocks only on raise and leaves the rear exposed" {
  let w = arts_world()
  let hp = w.player.hp
  w.set_guard(true, 0.0)
  w.deal_player_damage(5, source=(w.player.x + 20.0, w.player.y))
  assert_eq(w.player.hp, hp)
  assert_true(w.events.any(e => e is GuardBlocked(_, _, true)))
  for _ in 0..<10 {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  w.set_guard(true, 0.0)
  w.deal_player_damage(5, source=(w.player.x + 20.0, w.player.y))
  assert_eq(w.player.hp, hp - 1)
  w.deal_player_damage(5, source=(w.player.x - 20.0, w.player.y))
  assert_eq(w.player.hp, hp - 6)
  assert_false(w.request_basic_attack(0.0))
  assert_false(w.request_charge(0.0))
  assert_false(w.request_dash_strike(0.0))
}

///|
test "guard breaks on exhaustion and releasing regenerates its reserve" {
  let w = arts_world()
  w.set_guard(true, 0.0)
  w.arts.guard_energy = 1.0
  w.deal_player_damage(5, source=(w.player.x + 20.0, w.player.y))
  assert_false(w.arts.guarding)
  w.set_guard(true, 0.0)
  assert_false(w.arts.guarding)
  for _ in 0..<160 {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  assert_true(w.arts.guard_energy > 60.0)
  w.set_guard(true, 0.0)
  assert_true(w.arts.guarding)
}

///|
test "ground strike waits for impact then damages each visible enemy in its exact circle once" {
  let w = arts_world()
  let x = w.player.x + 16.0
  let y = w.player.y
  let inside = make_enemy(x + 4.0, y, Basic, 100, 0.0, 8.0)
  let outside = make_enemy(
    x + ground_strike_radius + 1.0,
    y,
    Basic,
    100,
    0.0,
    8.0,
  )
  w.enemies = [inside, outside]
  assert_true(w.request_ground_strike(x, y))
  assert_false(w.request_ground_strike(x, y))
  for _ in 0..<(ground_strike_delay - 1) {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  assert_eq(inside.hp, 100)
  w.tick_hunter_arts(w.dungeon.grid)
  assert_true(inside.hp < 100)
  assert_eq(outside.hp, 100)
  let remaining = inside.hp
  for _ in 0..<40 {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  assert_eq(inside.hp, remaining)
  assert_eq(
    w.events.filter(e => e is CombatImpact(AstralBlast, _, _, _, _)).length(),
    1,
  )
}

///|
test "ground targeting clamps range and rejects terrain without spending cooldown" {
  let w = arts_world()
  let (x, y) = w.ground_strike_target(w.player.x + 500.0, w.player.y)
  assert_true((x - w.player.x - ground_strike_range).abs() < 0.001)
  assert_eq(y, w.player.y)
  w.dungeon.grid.set(21, 49, @terrain.Wall)
  assert_false(w.request_ground_strike(21.5 * tile_size, 49.5 * tile_size))
  assert_eq(w.arts.ground_cooldown, 0)
}

///|
test "dash strike moves then cuts once and cannot cross solid obstacles" {
  let w = arts_world()
  for x in 15..<35 {
    for y in 45..<55 {
      w.dungeon.grid.set(x, y, @terrain.Floor)
    }
  }
  let enemy = make_enemy(w.player.x + 60.0, w.player.y, Basic, 100, 0.0, 8.0)
  w.enemies = [enemy]
  assert_true(w.request_dash_strike(0.0))
  let start = w.player.x
  for _ in 0..<40 {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  assert_true(w.player.x > start + 32.0)
  assert_true(enemy.hp < 100)
  assert_eq(w.events.filter(e => e is EnemyDamageNumber(_, _, _)).length(), 1)
  let wall = arts_world()
  wall.dungeon.grid.set(22, 49, @terrain.Wall)
  assert_true(wall.request_dash_strike(0.0))
  for _ in 0..<40 {
    wall.tick_hunter_arts(wall.dungeon.grid)
  }
  assert_true(wall.player.x + wall.player.size / 2.0 <= 22.0 * tile_size)
}

///|
test "lightning and flame gestures release their spells at the authored contact frame" {
  let w = arts_world()
  let index = w.skills.find_index(ChainLightning)
  w.skills.nodes[index].level = 1
  let enemy = make_enemy(w.player.x + 16.0, w.player.y, Basic, 100, 0.0, 8.0)
  w.enemies = [enemy]
  assert_true(w.request_hunter_spell(LightningArt))
  for _ in 0..<9 {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  assert_eq(enemy.hp, 100)
  w.tick_hunter_arts(w.dungeon.grid)
  assert_true(enemy.hp < 100)
  assert_eq(
    w.events.filter(e => e is ChainLightningArc(_, _, _, _)).length(),
    1,
  )
  let fire = arts_world()
  assert_true(fire.request_hunter_spell(FlameArt))
  for _ in 0..<13 {
    fire.tick_hunter_arts(fire.dungeon.grid)
  }
  assert_eq(fire.projectiles.length(), 0)
  fire.tick_hunter_arts(fire.dungeon.grid)
  assert_eq(fire.projectiles.length(), 1)
}

///|
test "fire explosion deals one area hit per enemy and reports confirmed hit count" {
  let w = arts_world()
  let x = w.player.x
  let y = w.player.y
  let a = make_enemy(x + 2.0, y, Basic, 100, 0.0, 8.0)
  let b = make_enemy(x + 15.0, y, Basic, 100, 0.0, 8.0)
  w.enemies = [a, b]
  let p : Projectile = {
    x,
    y,
    vx: 1.0,
    vy: 0.0,
    age: 0,
    alive: true,
    damage: 5,
    is_player: true,
    kind: Fireball(0),
  }
  w.projectiles = [p]
  process_player_projectiles(w, [])
  assert_eq(a.hp, 95)
  assert_eq(b.hp, 95)
  assert_true(w.events.any(e => e is CombatImpact(FlameBlast, _, _, _, 2)))
}

///|
test "guard uses projectile approach direction and consumes the blocked bolt" {
  let w = arts_world()
  w.set_guard(true, 0.0)
  let hp = w.player.hp
  w.projectiles = [
    {
      x: w.player.x + 17.0,
      y: w.player.y,
      vx: -10.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 4,
      is_player: false,
      kind: EnemyBolt,
    },
  ]
  w.tick_projectiles_phase()
  assert_eq(w.player.hp, hp)
  assert_eq(w.projectiles.length(), 0)
  assert_true(w.events.any(e => e is GuardBlocked(_, _, true)))
}

///|
test "dodging out of a dash strike cancels its future contact without refunding cooldown" {
  let w = arts_world()
  assert_true(w.request_dash_strike(0.0))
  for _ in 0..<3 {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  start_dash(w, 0.0, 1.0)
  assert_true(w.arts.action is None)
  for _ in 0..<40 {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  assert_false(w.events.any(e => e is CombatImpact(DashCut, _, _, _, _)))
  assert_true(w.arts.dash_cooldown > 0)
}
