///|
test "player weapons release once at their motion contact and cannot swap during an attack" {
  for weapon in [Bow, Focus] {
    let world = GameWorld::new(seed=42)
    world.mode = Playing
    world.manual_combat = true
    world.enemies.clear()
    assert_true(world.equip_player_weapon(weapon))
    let profile = weapon.profile()
    assert_true(world.request_basic_attack(0.0))
    assert_eq(world.projectiles.length(), 0)
    assert_false(world.equip_player_weapon(Spear))
    for _ in 0..<(profile.windup - 1) {
      world.tick_player_weapon_attack()
    }
    assert_eq(world.projectiles.length(), 0)
    world.tick_player_weapon_attack()
    assert_eq(world.projectiles.length(), 1)
    assert_eq(
      world.projectiles[0].kind,
      if weapon == Bow {
        Arrow
      } else {
        Fireball(0)
      },
    )
    for _ in 0..<(profile.recovery + 2) {
      world.tick_player_weapon_attack()
    }
    assert_eq(world.projectiles.length(), 1)
    assert_true(world.equip_player_weapon(Spear))
  }
}

///|
test "dodging cancels an unreleased player attack" {
  let world = GameWorld::new(seed=42)
  world.mode = Playing
  assert_true(world.equip_player_weapon(Bow))
  assert_true(world.request_basic_attack(0.0))
  world.player.dash_timer = 6
  for _ in 0..<80 {
    world.tick_player_weapon_attack()
  }
  assert_eq(world.projectiles.length(), 0)
  assert_true(world.weapon_attack is None)
}

///|
test "spear and fists have directional contact damage instead of circular slashes" {
  for weapon in [Spear, Knuckles] {
    let world = GameWorld::new(seed=42)
    world.mode = Playing
    let x = world.player.x
    let y = world.player.y
    let front = make_enemy(x + 10.0, y, Basic, 1000, 0.0, 8.0)
    let behind = make_enemy(x - 10.0, y, Basic, 1000, 0.0, 8.0)
    world.enemies = [front, behind]
    assert_true(world.equip_player_weapon(weapon))
    assert_true(world.request_basic_attack(0.0))
    assert_eq(front.hp, 1000)
    for _ in 0..<weapon.profile().windup {
      world.tick_player_weapon_attack()
    }
    assert_true(front.hp < 1000)
    assert_eq(behind.hp, 1000)
    let hp = front.hp
    for _ in 0..<60 {
      world.tick_player_weapon_attack()
    }
    assert_eq(front.hp, hp)
  }
}

///|
test "hunter autoplay uses the equipped weapon and cancels attacks when changing floors" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.manual_combat = true
  world.auto_play = true
  for node in world.skills.nodes {
    node.level = 0
  }
  let x = world.player.x
  let y = world.player.y
  world.enemies = [make_enemy(x + 12.0, y, Basic, 1000, 0.0, 8.0)]
  assert_true(world.equip_player_weapon(Spear))
  world.tick(0.0, 0.0)
  assert_true(world.weapon_attack is Some({ weapon: Spear, .. }))
  world.apply_dungeon(43, 2)
  assert_true(world.weapon_attack is None)
  assert_eq(world.player_weapon, Spear)
}

///|
test "all three cleaver cuts reach farther while a spear reaches twice as far in a narrow line" {
  for weapon in [Cleaver, Spear] {
    for combo in [Opening, Return, Finisher] {
      let w = melee_test_world()
      let far = if weapon == Spear { 76.0 } else { 38.0 }
      let front = make_enemy(120.0 + far, 120.0, Basic, 1000, 0.0, 8.0)
      let beyond = make_enemy(
        120.0 + (if weapon == Spear { 85.0 } else { 45.0 }),
        120.0,
        Basic,
        1000,
        0.0,
        8.0,
      )
      let side = make_enemy(150.0, 138.0, Basic, 1000, 0.0, 8.0)
      w.enemies = [front, beyond, side]
      // Commit the contact pose so auto aim and the earlier step cannot inflate range.
      w.weapon_attack = Some({
        weapon,
        combo,
        angle: 0.0,
        frame: (if weapon == Cleaver {
          combo.profile()
        } else {
          weapon.profile()
        }).windup -
        1,
      })
      w.tick_player_weapon_attack()
      assert_true(front.hp < 1000)
      assert_eq(beyond.hp, 1000)
      assert_eq(side.hp < 1000, weapon == Cleaver)
      let hp = front.hp
      for _ in 0..<40 {
        w.tick_player_weapon_attack()
      }
      assert_eq(front.hp, hp)
    }
  }
  assert_true(Spear.profile().reach >= Cleaver.profile().reach * 2.0)
}

///|
test "extended spear contact and target assist both respect intervening walls" {
  let w = melee_test_world()
  let e = make_enemy(196.0, 120.0, Basic, 1000, 0.0, 8.0)
  w.enemies = [e]
  assert_true(w.melee_lock_target(0.0, Spear) is Some(_))
  w.dungeon.grid.set(9, 7, @terrain.Wall)
  assert_true(w.melee_lock_target(0.0, Spear) is None)
  w.weapon_attack = Some({
    weapon: Spear,
    combo: Opening,
    angle: 0.0,
    frame: Spear.profile().windup - 1,
  })
  w.tick_player_weapon_attack()
  assert_eq(e.hp, 1000)
}
