///|
fn melee_test_world() -> GameWorld {
  let world = GameWorld::new(seed=42)
  world.mode = Playing
  world.manual_combat = true
  world.enemies.clear()
  for y in 2..<14 {
    for x in 2..<14 {
      world.dungeon.grid.set(x, y, @terrain.Floor)
    }
  }
  world.player.x = 120.0
  world.player.y = 120.0
  world
}

///|
test "soft melee lock chooses a visible nearby target in the aim cone" {
  let w = melee_test_world()
  let target = make_enemy(144.0, 132.0, Basic, 100, 0.0, 8.0)
  w.enemies = [make_enemy(112.0, 120.0, Basic, 100, 0.0, 8.0), target]
  assert_true(
    (w.assist_melee_angle(0.0, Cleaver) - @math.atan2(12.0, 24.0)).abs() < 0.001,
  )
  assert_eq(w.assist_melee_angle(0.0, Bow), 0.0)
  target.alive = false
  assert_eq(w.assist_melee_angle(0.0, Cleaver), 0.0)
  target.alive = true
  w.dungeon.grid.set(8, 8, @terrain.Wall)
  assert_eq(w.assist_melee_angle(0.0, Cleaver), 0.0)
}

///|
test "melee recoil survives AI, interrupts a light enemy and never crosses walls" {
  let w = melee_test_world()
  let e = make_enemy(140.0, 120.0, Basic, 100, 1.0, 8.0)
  w.enemies = [e]
  e.begin_attack(Punch, 32, 28, w.player.x, w.player.y)
  apply_player_damage_to_enemy(w, e, 2, w.player.x, w.player.y)
  apply_melee_reaction(e, Cleaver, 0.0)
  assert_eq(e.attack_motion, NoAttack)
  assert_true(e.stagger_frames > 0)
  let x = e.x
  w.tick_enemy_ai_phase()
  w.tick_enemy_movement_and_contact_phase()
  assert_true(e.x > x)
  w.dungeon.grid.set(9, 7, @terrain.Wall)
  for _ in 0..<20 {
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
  }
  assert_true(e.x < 144.0)
}

///|
test "contact emits one impact for a group and a whiff emits no impact" {
  let w = melee_test_world()
  w.enemies = [
    make_enemy(136.0, 120.0, Basic, 100, 0.0, 8.0),
    make_enemy(140.0, 125.0, Basic, 100, 0.0, 8.0),
  ]
  assert_true(w.request_basic_attack(0.0))
  assert_eq(
    w.attack_timer,
    Cleaver.profile().windup + Cleaver.profile().recovery,
  )
  for _ in 0..<Cleaver.profile().windup {
    w.tick_player_weapon_attack()
  }
  let impacts = w.events.filter(e => {
    match e {
      MeleeImpact(_, _, _, _, _, _) => true
      _ => false
    }
  })
  assert_eq(impacts.length(), 1)
  assert_true(impacts[0] is MeleeImpact(Cleaver, _, _, _, _, 2))
  w.events.clear()
  for _ in 0..<30 {
    w.tick_player_weapon_attack()
  }
  assert_eq(w.events.length(), 0)
  w.attack_timer = 0
  w.enemies.clear()
  assert_true(w.request_basic_attack(0.0))
  for _ in 0..<Cleaver.profile().windup {
    w.tick_player_weapon_attack()
  }
  assert_false(
    w.events.any(e => {
      match e {
        MeleeImpact(_, _, _, _, _, _) => true
        _ => false
      }
    }),
  )
}

///|
test "enemy melee shows a warning for at least half a second and commits its aim" {
  let w = melee_test_world()
  let e = make_enemy(134.0, 120.0, Basic, 100, 0.0, 8.0)
  w.enemies = [e]
  w.tick_enemy_ai_phase()
  assert_true(e.attack_windup >= 30)
  assert_true(
    w.events.any(e => {
      match e {
        EnemyMeleeWarning(_, _) => true
        _ => false
      }
    }),
  )
  let hp = w.player.hp
  for _ in 0..<(e.attack_windup - 1) {
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
  }
  assert_eq(w.player.hp, hp)
  w.player.y += 32.0
  w.tick_enemy_ai_phase()
  w.tick_enemy_movement_and_contact_phase()
  assert_eq(w.player.hp, hp)
  assert_true(e.attack_recovery >= 24)
}
