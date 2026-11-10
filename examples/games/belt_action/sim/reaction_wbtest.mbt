///|
fn incoming_attack(kind : Int32) -> Game {
  let g = arena()
  g.enemies.clear()
  g.spawn(kind, g.player.x + 72, g.player.z)
  // A committed attack in the other direction must not prevent a late dodge.
  g.player.facing = -1
  g.begin_attack(true)
  g.begin_enemy_attack(g.enemies[0])
  g
}

///|
test "500 ms recognition delay leaves time to walk or evade out of every default attack" {
  for kind in [0, 1, 2, 3] {
    for use_evade in [false, true] {
      let g = incoming_attack(kind)
      let e = g.enemies[0]
      for _ in 0..<30 {
        g.step(idle_input())
      }
      assert_eq(
        e.action,
        "windup",
        msg="The attack landed before a 500 ms recognition delay",
      )
      for i in 0..<100 {
        g.step({ ..idle_input(), z: -1, evade: use_evade && i == 0, })
        if e.action == "recover" {
          break
        }
      }
      assert_eq(g.player.hp, g.player.max_hp)
      assert_eq(e.action, "recover")
    }
  }
}

///|
test "a missed elite attack leaves time to recognize OPEN, close the lane and counter" {
  for kind in [1, 3] {
    let g = incoming_attack(kind)
    let e = g.enemies[0]
    for _ in 0..<30 {
      g.step(idle_input())
    }
    for i in 0..<100 {
      g.step({ ..idle_input(), z: -1, evade: i == 0, })
      if e.action == "recover" {
        break
      }
    }
    assert_eq(g.player.hp, g.player.max_hp)
    // Recognize the opening only after 500 ms, then return from the dodge.
    for _ in 0..<30 {
      g.step(idle_input())
    }
    for step = 0; step < 100 && (e.z - g.player.z).abs() > 24; step = step + 1 {
      g.step({ ..idle_input(), z: 1, })
    }
    let hp = e.hp
    g.step({ ..idle_input(), x: 1, breaker: true, })
    for _ in 0..<14 {
      g.step(idle_input())
    }
    assert_true(e.hp < hp)
    assert_true(e.open())
    assert_eq(g.player.hp, g.player.max_hp)
  }
}

///|
test "breaker recovery can be canceled into a deliberate evade" {
  let g = arena()
  g.begin_attack(true)
  g.player.age = 20
  g.step({ ..idle_input(), z: -1, evade: true, })
  assert_eq(g.player.action, "evade")
  assert_eq(g.dodges, 1)
}

///|
test "the crowd leaves a quiet beat after a swing" {
  let g = elite_arena(1)
  g.spawn(2, g.player.x + 70, g.player.z)
  let first = g.enemies[0]
  let next = g.enemies[1]
  first.action = "active"
  first.timer = 1
  next.timer = 0
  g.update_enemies()
  for _ in 0..<24 {
    g.update_enemies()
    assert_eq(next.action, "approach")
  }
  g.update_enemies()
  assert_eq(next.action, "windup")
}

///|
test "landing an elite attack closes its guard instead of granting a free counter" {
  for kind in [1, 3] {
    let g = elite_arena(kind)
    let e = g.enemies[0]
    g.begin_enemy_attack(e)
    for _ in 0..<150 {
      g.step(idle_input())
      if e.action == "active" {
        break
      }
    }
    assert_eq(g.player.hp, 5)
    for _ in 0..<24 {
      g.step(idle_input())
      if e.action == "reset" {
        break
      }
    }
    assert_eq(e.action, "reset")
    assert_true(e.braced())
    assert_false(e.open())
    let hp = e.hp
    g.begin_attack(true)
    g.resolve_strike()
    assert_eq(e.hp, hp)
  }
}
