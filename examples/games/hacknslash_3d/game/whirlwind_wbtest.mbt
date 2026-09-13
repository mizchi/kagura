///|
test "whirlwind channels every weapon without changing equipment or firing projectiles" {
  for weapon in [Cleaver, Spear, Knuckles, Focus, Bow] {
    let w = arts_world()
    assert_true(w.equip_player_weapon(weapon))
    let enemy = make_enemy(w.player.x + 10.0, w.player.y, Basic, 1000, 0.0, 8.0)
    w.enemies = [enemy]
    w.set_whirlwind(true)
    assert_true(w.arts.whirlwind.active)
    for _ in 0..<(whirlwind_contact_frame - 1) {
      w.tick_hunter_arts(w.dungeon.grid)
    }
    assert_eq(enemy.hp, 1000)
    w.tick_hunter_arts(w.dungeon.grid)
    let damage = 1000 - enemy.hp
    assert_true(damage > 0)
    for _ in 0..<whirlwind_cycle_frames {
      w.set_whirlwind(true)
      w.tick_hunter_arts(w.dungeon.grid)
    }
    assert_eq(enemy.hp, 1000 - damage * 2)
    assert_eq(w.player_weapon, weapon)
    assert_true(w.projectiles.is_empty())
    assert_false(w.request_basic_attack(0.0))
    assert_false(w.equip_player_weapon(Cleaver))
    w.set_whirlwind(false)
    assert_false(w.arts.whirlwind.active)
    for _ in 0..<60 {
      w.tick_hunter_arts(w.dungeon.grid)
    }
    assert_eq(enemy.hp, 1000 - damage * 2)
    // Rapid tapping cannot bypass the recovery or repeatedly hit on frame one.
    w.set_whirlwind(true)
    assert_false(w.arts.whirlwind.active)
  }
}

///|
test "whirlwind moves with collision and hits only visible enemies inside its displayed radius" {
  let w = arts_world()
  for x in 16..<26 {
    for y in 46..<54 {
      w.dungeon.grid.set(x, y, @terrain.Floor)
    }
  }
  let r = w.whirlwind_radius()
  let inside = make_enemy(w.player.x, w.player.y - 10.0, Basic, 1000, 0.0, 8.0)
  let outside = make_enemy(
    w.player.x,
    w.player.y + r + 1.0,
    Basic,
    1000,
    0.0,
    8.0,
  )
  let behind_wall = make_enemy(
    w.player.x + 24.0,
    w.player.y,
    Basic,
    1000,
    0.0,
    8.0,
  )
  w.enemies = [inside, outside, behind_wall]
  w.dungeon.grid.set(21, 49, @terrain.Wall)
  w.set_whirlwind(true)
  for _ in 0..<whirlwind_contact_frame {
    w.tick_hunter_arts(w.dungeon.grid)
  }
  assert_true(inside.hp < 1000)
  assert_eq(outside.hp, 1000)
  assert_eq(behind_wall.hp, 1000)
  w.enemies.clear()
  let x = w.player.x
  for _ in 0..<12 {
    w.tick(1.0, 0.0)
  }
  assert_true(w.player.x > x)
  assert_true(w.player.x < 21.0 * tile_size)
  assert_true(w.arts.whirlwind.active)
}

///|
test "dodge and death interrupt whirlwind until the held input is released" {
  let w = arts_world()
  w.set_whirlwind(true)
  start_dash(w, 1.0, 0.0)
  assert_false(w.arts.whirlwind.active)
  w.player.dash_timer = 0
  w.attack_timer = 0
  w.set_whirlwind(true)
  assert_false(w.arts.whirlwind.active)
  w.set_whirlwind(false)
  w.set_whirlwind(true)
  assert_true(w.arts.whirlwind.active)
  w.player.hp = 0
  w.tick_hunter_arts(w.dungeon.grid)
  assert_false(w.arts.whirlwind.active)
}

///|
test "a retained press resumes an interrupted channel without resetting an active contact phase" {
  let w = arts_world()
  w.set_whirlwind(true)
  w.stop_whirlwind()
  w.attack_timer = 0
  w.set_whirlwind(true, pressed=true)
  assert_true(w.arts.whirlwind.active)
  w.tick_hunter_arts(w.dungeon.grid)
  w.set_whirlwind(true, pressed=true)
  assert_eq(w.arts.whirlwind.frame, 1)
  assert_false(w.arts.guarding)
  w.set_guard(true, 0.0)
  assert_false(w.arts.guarding)
}
