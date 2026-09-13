///|
fn finish_test_strike(w : GameWorld) -> Int raise {
  let mut frames = 0
  while w.weapon_attack is Some(_) || w.attack_timer > 0 {
    w.tick_player_weapon_attack()
    w.attack_timer = (w.attack_timer - 1).max(0)
    frames += 1
    assert_true(frames < 100)
  }
  frames
}

///|
test "cleaver advances once per attack with distinct damage and a committed heavy recovery" {
  let w = melee_test_world()
  w.player_stats = { ..w.player_stats, atk: 10, crit_chance: 0.0, }
  let e = make_enemy(136.0, 120.0, Basic, 1000, 0.0, 8.0)
  w.enemies = [e]
  let damage : Array[Int] = []
  let durations : Array[Int] = []
  for _ in 0..<4 {
    let hp = e.hp
    assert_true(w.request_basic_attack(0.0))
    assert_false(w.request_basic_attack(0.0))
    durations.push(finish_test_strike(w))
    damage.push(hp - e.hp)
  }
  assert_true(damage[0] < damage[1])
  assert_true(damage[1] < damage[2])
  assert_eq(damage[3], damage[0])
  assert_eq(durations, [19, 22, 48, 19])
  // Damage is applied once, then the finisher holds its full recovery.
  ignore(w.request_basic_attack(0.0))
  ignore(finish_test_strike(w))
  assert_true(w.request_basic_attack(0.0))
  for _ in 0..<16 {
    w.tick_player_weapon_attack()
    w.attack_timer -= 1
  }
  let hp = e.hp
  for _ in 0..<31 {
    assert_false(w.request_basic_attack(0.0))
    w.tick_player_weapon_attack()
    w.attack_timer -= 1
    assert_eq(e.hp, hp)
  }
  assert_false(w.request_basic_attack(0.0))
  assert_eq(finish_test_strike(w), 1)
  assert_true(w.request_basic_attack(0.0))
}

///|
test "both opening cuts step forward even on a whiff and stop before enemies and walls" {
  let w = melee_test_world()
  for angle in [0.0, @math.PI / 2.0] {
    let x = w.player.x
    let y = w.player.y
    assert_true(w.request_basic_attack(angle))
    ignore(finish_test_strike(w))
    let forward = (w.player.x - x) * @math.cos(angle) +
      (w.player.y - y) * @math.sin(angle)
    let sideways = (w.player.x - x) * @math.sin(angle) -
      (w.player.y - y) * @math.cos(angle)
    assert_true(forward >= 9.0)
    assert_true(sideways.abs() < 0.001)
  }
  let w = melee_test_world()
  w.enemies = [make_enemy(130.0, 120.0, Basic, 100, 0.0, 8.0)]
  ignore(w.request_basic_attack(0.0))
  ignore(finish_test_strike(w))
  assert_true(w.player.x <= 122.0)
  w.enemies.clear()
  w.player.x = 134.0
  w.dungeon.grid.set(9, 7, @terrain.Wall)
  ignore(w.request_basic_attack(0.0))
  ignore(finish_test_strike(w))
  assert_true(w.player.x + w.player.size / 2.0 < 144.0)
}

///|
test "combo continuation expires after recovery and resets on weapon swap or dodge" {
  let w = melee_test_world()
  ignore(w.request_basic_attack(0.0))
  ignore(finish_test_strike(w))
  for _ in 0..<44 {
    w.tick_player_weapon_attack()
  }
  assert_true(w.request_basic_attack(0.0))
  assert_true(w.weapon_attack is Some({ combo: Return, .. }))
  ignore(finish_test_strike(w))
  for _ in 0..<45 {
    w.tick_player_weapon_attack()
  }
  ignore(w.request_basic_attack(0.0))
  assert_true(w.weapon_attack is Some({ combo: Opening, .. }))
  ignore(finish_test_strike(w))
  assert_true(w.equip_player_weapon(Spear))
  assert_true(w.equip_player_weapon(Cleaver))
  ignore(w.request_basic_attack(0.0))
  assert_true(w.weapon_attack is Some({ combo: Opening, .. }))
  w.player.dash_timer = 5
  w.tick_player_weapon_attack()
  assert_true(w.weapon_attack is None)
  assert_eq(w.cleaver_next, Opening)
  assert_eq(w.cleaver_combo_timer, 0)
}
