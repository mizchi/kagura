///|
test "zombie pounce raises its arms before moving and hits only once on landing" {
  let w = melee_test_world()
  let zombie = make_enemy(164.0, 120.0, Zombie, 100, 0.6, 11.0)
  w.enemies = [zombie]
  w.tick_enemy_ai_phase()
  assert_eq(zombie.attack_motion, Pounce)
  assert_true(w.events.any(e => e is EnemyMeleeWarning(_, _)))
  let hp = w.player.hp
  let landing = zombie.pounce.unwrap()
  assert_eq(landing.landing_x, 130.0)
  assert_eq(landing.landing_y, 120.0)
  for _ in 0..<(zombie.attack_windup - 1) {
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
    if zombie.attack_frame <= zombie_pounce_anticipation {
      assert_eq(zombie.x, 164.0)
    }
    assert_eq(w.player.hp, hp)
  }
  assert_true(zombie.x < 145.0)
  w.tick_enemy_ai_phase()
  w.tick_enemy_movement_and_contact_phase()
  assert_true(w.player.hp < hp)
  assert_true((zombie.x - landing.landing_x).abs() < 0.001)
  assert_true((zombie.y - landing.landing_y).abs() < 0.001)
  let hp = w.player.hp
  for _ in 0..<zombie.attack_recovery {
    w.player.iframe_timer = 0
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
    assert_eq(w.player.hp, hp)
  }
}

///|
test "zombie pounce commits its direction and cannot pass walls or damage during cancellation" {
  let w = melee_test_world()
  let zombie = make_enemy(164.0, 120.0, Zombie, 100, 0.6, 11.0)
  w.enemies = [zombie]
  w.tick_enemy_ai_phase()
  let target = zombie.attack_target_y
  let hp = w.player.hp
  w.player.y += 32.0
  for _ in 0..<(zombie.attack_windup + zombie.attack_recovery) {
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
  }
  assert_eq(zombie.attack_target_y, target)
  assert_eq(w.player.hp, hp)
  zombie.x = 164.0
  zombie.y = 120.0
  zombie.attack_motion = NoAttack
  zombie.attack_cooldown = 0
  w.player.y = 120.0
  w.tick_enemy_ai_phase()
  assert_eq(zombie.attack_motion, Pounce)
  w.dungeon.grid.set(9, 7, @terrain.Wall)
  for _ in 0..<90 {
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
    assert_true(zombie.x >= 165.0 || zombie.x == 164.0)
  }
  assert_eq(w.player.hp, hp)
}

///|
test "zombies appear in ruins and scene authoring, with durable population migration" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  assert_true(w.enemies.any(e => e.kind == Zombie))
  assert_true(
    find_enemy_type_config(Zombie).speed_param <
    find_enemy_type_config(Basic).speed_param,
  )
  assert_true(enemy_species(Zombie) == EnemySpecies::Zombie)
  let old = @json.parse(w.serialize_world_progress())
  guard old is Object(fields) else { fail("world") }
  fields["version"] = 2
  guard fields["regions"] is Array(regions) else { fail("regions") }
  for region in regions {
    guard region is Object(region) else { continue }
    guard region["enemies"] is Array(enemies) else { continue }
    region["enemies"] = enemies
      .filter(enemy => {
        match enemy {
          Object(e) => e["kind"] != EnemyKind::Zombie.to_json()
          _ => true
        }
      })
      .to_json()
  }
  assert_true(w.restore_world_progress(old.stringify()))
  let zombies = w.enemies.filter(e => e.kind == Zombie)
  assert_true(zombies.length() > 0)
  zombies[0].alive = false
  let saved = w.serialize_world_progress()
  assert_true(w.restore_world_progress(saved))
  assert_eq(w.enemies.filter(e => e.kind == Zombie).length(), zombies.length())
  assert_eq(w.enemies.filter(e => e.kind == Zombie && !e.alive).length(), 1)
  assert_true(scene_enemy_kind("zombie") == Zombie)
}
