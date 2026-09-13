///|
fn homing_test_world() -> GameWorld {
  let w = arts_world()
  for x in 8..<64 {
    for y in 36..<64 {
      w.dungeon.grid.set(x, y, @terrain.Floor)
    }
  }
  w
}

///|
fn homing_test_projectile(
  w : GameWorld,
  kind : ProjectileKind,
  is_player? : Bool = true,
) -> Projectile {
  {
    x: w.player.x,
    y: w.player.y,
    vx: 3.0,
    vy: 0.0,
    age: 4,
    alive: true,
    damage: 5,
    is_player,
    kind,
  }
}

///|
test "both magic projectile kinds gently steer without accelerating; arrows and enemy shots stay straight" {
  for
    (kind, player, turns) in [
      (Fireball(0), true, true),
      (Fireball(1), true, true),
      (Arrow, true, false),
      (EnemyBolt, true, false),
      (Fireball(0), false, false),
      (EnemyBolt, false, false),
    ] {
    let w = homing_test_world()
    w.enemies = [
      make_enemy(w.player.x + 60.0, w.player.y + 24.0, Basic, 100, 0.0, 8.0),
    ]
    let p = homing_test_projectile(w, kind, is_player=player)
    w.player.iframe_timer = 100
    w.projectiles = [p]
    w.tick_projectiles_phase()
    assert_eq(p.vy > 0.0, turns)
    assert_true(p.vy <= 0.20)
    assert_true((p.vx * p.vx + p.vy * p.vy - 9.0).abs() < 0.000001)
  }
}

///|
test "a focus shot corrects its launch direction and hits a moving enemy" {
  let w = homing_test_world()
  assert_true(w.equip_player_weapon(Focus))
  assert_true(w.request_basic_attack(0.0))
  for _ in 0..<Focus.profile().windup {
    w.tick_player_weapon_attack()
  }
  let p = w.projectiles[0]
  let enemy = make_enemy(
    w.player.x + 70.0,
    w.player.y + 26.0,
    Basic,
    100,
    0.0,
    8.0,
  )
  w.enemies = [enemy]
  for _ in 0..<50 {
    enemy.y += 0.15
    w.tick_projectiles_phase()
    if !p.alive {
      break
    }
  }
  assert_true(enemy.hp < 100)
  assert_false(p.alive)
}

///|
test "homing ignores dead, hidden, out-of-range and rear targets and reacquires after a kill" {
  let w = homing_test_world()
  let rear = make_enemy(
    w.player.x - 12.0,
    w.player.y + 12.0,
    Basic,
    100,
    0.0,
    8.0,
  )
  let far = make_enemy(
    w.player.x + 150.0,
    w.player.y + 30.0,
    Basic,
    100,
    0.0,
    8.0,
  )
  let dead = make_enemy(
    w.player.x + 24.0,
    w.player.y + 15.0,
    Basic,
    100,
    0.0,
    8.0,
  )
  dead.alive = false
  let blocked = make_enemy(w.player.x + 32.0, w.player.y, Basic, 100, 0.0, 8.0)
  w.dungeon.grid.set(21, 49, @terrain.Wall)
  let p = homing_test_projectile(w, Fireball(0))
  w.projectiles = [p]
  w.enemies = [rear, far, dead, blocked]
  w.tick_projectiles_phase()
  assert_eq(p.vy, 0.0)
  w.dungeon.grid.set(21, 49, @terrain.Floor)
  blocked.alive = false
  let first = make_enemy(p.x + 50.0, p.y + 30.0, Basic, 100, 0.0, 8.0)
  w.enemies.push(first)
  w.tick_projectiles_phase()
  assert_true(p.vy > 0.0)
  first.alive = false
  let next = make_enemy(p.x + 60.0, p.y - 40.0, Basic, 100, 0.0, 8.0)
  w.enemies.push(next)
  for _ in 0..<3 {
    w.tick_projectiles_phase()
  }
  assert_true(p.vy < 0.0)
}

///|
test "split fireballs retain their fan briefly then home toward survivors" {
  let w = homing_test_world()
  let parent = homing_test_projectile(w, Fireball(1))
  spawn_split_fireball_projectiles(w, parent, w.projectiles, 1)
  let middle = w.projectiles[w.projectiles.length() / 2]
  w.enemies = [
    make_enemy(parent.x + 70.0, parent.y + 28.0, Basic, 100, 0.0, 8.0),
  ]
  for _ in 0..<4 {
    w.tick_projectiles_phase()
  }
  assert_eq(middle.vy, 0.0)
  w.tick_projectiles_phase()
  assert_true(middle.vy > 0.0)
}

///|
test "a magic shot is consumed by walls without damaging the enemy beyond" {
  let w = homing_test_world()
  let p = homing_test_projectile(w, Fireball(0))
  let enemy = make_enemy(p.x + 32.0, p.y, Basic, 100, 0.0, 8.0)
  w.enemies = [enemy]
  w.dungeon.grid.set(21, 49, @terrain.Wall)
  w.projectiles = [p]
  for _ in 0..<8 {
    w.tick_projectiles_phase()
  }
  assert_false(p.alive)
  assert_eq(enemy.hp, 100)
  assert_true(w.projectiles.is_empty())
}

///|
test "untargeted magic expires without splitting or dealing phantom damage" {
  let w = homing_test_world()
  let p = homing_test_projectile(w, Fireball(1))
  p.age = 89
  w.projectiles = [p]
  w.tick_projectiles_phase()
  assert_true(p.alive)
  w.tick_projectiles_phase()
  assert_false(p.alive)
  assert_true(w.projectiles.is_empty())
  assert_false(w.events.any(e => e is CombatImpact(_, _, _, _, _)))
}
