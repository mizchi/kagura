///|
test "wolf bite warns, commits its aim and deals damage only when the jaw closes" {
  let w = melee_test_world()
  let wolf = make_enemy(136.0, 120.0, Wolf, 100, 1.0, 10.0)
  w.enemies = [wolf]
  w.tick_enemy_ai_phase()
  assert_eq(wolf.attack_motion, Bite)
  assert_true(wolf.attack_windup >= 30)
  let hp = w.player.hp
  for _ in 0..<(wolf.attack_windup - 1) {
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
  }
  assert_eq(w.player.hp, hp)
  w.tick_enemy_ai_phase()
  w.tick_enemy_movement_and_contact_phase()
  assert_true(w.player.hp < hp)
  let hp = w.player.hp
  for _ in 0..<wolf.attack_recovery {
    w.player.iframe_timer = 0
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
    assert_eq(w.player.hp, hp)
  }
}

///|
test "wolves patrol at a walk, run in pursuit and stop their gait at walls" {
  let w = melee_test_world()
  let wolf = make_enemy(136.0, 120.0, Wolf, 100, 1.0, 10.0)
  w.enemies = [wolf]
  w.player.x = 900.0
  w.tick_enemy_ai_phase()
  w.tick_enemy_movement_and_contact_phase()
  assert_true(wolf.move_speed > 0.0 && wolf.move_speed < wolf.speed * 0.5)
  w.player.x = 200.0
  w.tick_enemy_ai_phase()
  w.tick_enemy_movement_and_contact_phase()
  assert_true(wolf.move_speed > wolf.speed * 0.5)
  wolf.x = 138.99
  wolf.y = 120.0
  w.dungeon.grid.set(9, 7, @terrain.Wall)
  wolf.vx = 1.0
  wolf.vy = 0.0
  w.tick_enemy_movement_and_contact_phase()
  assert_true(wolf.move_speed < 0.02)
  assert_true(find_enemy_type_config(Wolf).spawn_weight > 0)
}

///|
test "wolf bite keeps its warned direction and can be sidestepped" {
  let w = melee_test_world()
  let wolf = make_enemy(136.0, 120.0, Wolf, 100, 1.0, 11.0)
  w.enemies = [wolf]
  w.tick_enemy_ai_phase()
  let target_y = wolf.attack_target_y
  w.player.y += 24.0
  let hp = w.player.hp
  for _ in 0..<wolf.attack_windup {
    w.tick_enemy_ai_phase()
    w.tick_enemy_movement_and_contact_phase()
  }
  assert_eq(wolf.attack_target_y, target_y)
  assert_eq(w.player.hp, hp)
}

///|
test "scene-authored wolves preserve their species and bite AI" {
  let w = melee_test_world()
  w.apply_scene_json(
    "{\"version\":1,\"rectangles\":[{\"id\":\"floor\",\"kind\":\"floor\",\"x\":8,\"z\":8,\"width\":32,\"depth\":24}],\"spawn\":[12.5,15.5],\"enemies\":[{\"id\":\"wolf\",\"x\":13.5,\"z\":15.5,\"kind\":\"wolf\",\"hp\":24}]}",
  )
  assert_true(w.enemies[0].kind == Wolf)
  w.mode = Playing
  w.tick_enemy_ai_phase()
  assert_eq(w.enemies[0].attack_motion, Bite)
}
