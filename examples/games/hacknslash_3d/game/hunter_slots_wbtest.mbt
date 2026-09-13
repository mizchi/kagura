///|
test "hunter slots replace execution, swap assignments and reject invalid or unlearned actions" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  assert_eq(w.hunter_slots, [74, 50, 86, 70])
  assert_true(w.assign_hunter_slot(0, 50))
  assert_eq(w.hunter_slots, [50, 74, 86, 70])
  assert_false(w.assign_hunter_slot(4, 74))
  assert_false(w.assign_hunter_slot(0, 49))
  assert_false(w.assign_hunter_slot(0, 53))
  assert_true(w.assign_hunter_slot(0, 84))
  assert_true(w.apply_hunter_preset(StormPreset))
  assert_eq(w.hunter_slots, [53, 84, 51, 52])
}

///|
test "hunter charge and dash strike are one action with one cooldown" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  assert_true(w.request_charge(0.0))
  assert_true(w.arts.action is Some({ kind: DashArt, .. }))
  assert_true(w.player_charge is None)
  w.cancel_hunter_action()
  assert_false(w.request_dash_strike(0.0))
  let hp = w.player.hp
  activate_skill(w, 0)
  assert_eq(w.attack_timer, 0)
  assert_eq(w.player.hp, hp)
}

///|
test "melee focus catches diagonal enemies further away without turning backwards" {
  let w = melee_test_world()
  let target = make_enemy(136.0, 162.0, Basic, 100, 0.0, 8.0)
  w.enemies = [target]
  assert_true(w.melee_lock_target(0.0, Cleaver) is Some(_))
  target.x = 104.0
  assert_true(w.melee_lock_target(0.0, Cleaver) is None)
  assert_true(w.melee_lock_target(0.0, Focus) is None)
}

///|
test "expanded focus steps into contact and still damages only at the hit frame" {
  let w = melee_test_world()
  let e = make_enemy(168.0, 120.0, Basic, 100, 0.0, 8.0)
  w.enemies = [e]
  assert_true(w.request_basic_attack(0.0))
  for _ in 0..<(Cleaver.profile().windup - 1) {
    w.tick_player_weapon_attack()
  }
  assert_eq(e.hp, 100)
  w.tick_player_weapon_attack()
  assert_true(e.hp < 100)
  assert_true(w.player.x < e.x)
}
