///|
fn arena() -> Game {
  let g = new_game()
  g.start()
  g.enemies.clear()
  g.spawn(0, g.player.x + 58.0, g.player.z)
  g
}

///|
test "an early evade tap is buffered into the combo recovery window" {
  let g = arena()
  g.begin_attack(false)
  g.step({ ..idle_input(), z: 1, evade: true, })
  assert_eq(g.player.action, "strike")
  for _ in 0..<18 {
    g.step(idle_input())
  }
  assert_eq(g.dodges, 1)
  assert_eq(g.player.action, "evade")
  assert_true(g.player.z > 372)
}

///|
fn counter_input(
  g : Game,
  recognition_delay~ : Int32 = default_reaction_budget.response_frames(),
) -> Input {
  let alive = g.enemies.filter(e => e.hp > 0)
  let incoming = alive
    .filter(e => {
      (
        (e.action == "windup" && e.phase_total - e.timer >= recognition_delay) ||
        e.action == "active"
      ) &&
      (e.x - g.player.x).abs() < 145
    })
    .get(0)
  if incoming is Some(threat) {
    if (threat.aim_z - g.player.z).abs() < 55 {
      return {
        ..idle_input(),
        z: if threat.aim_z < 372 {
          1.0
        } else {
          -1.0
        },
        evade: threat.action == "windup" && g.player.evade_cooldown == 0,
      }
    }
  }
  if alive.is_empty() {
    return { ..idle_input(), x: 1, }
  }
  fn priority(e : Enemy) -> Double {
    (e.x - g.player.x).abs() +
    (e.z - g.player.z).abs() * 0.5 -
    (if e.open() && e.phase_total - e.timer >= recognition_delay {
      100.0
    } else {
      0.0
    }) -
    (if e.kind != 1 && e.kind != 3 { 30.0 } else { 0.0 })
  }
  alive.sort_by((a, b) => priority(a).compare(priority(b)))
  let e = alive[0]
  let dx = e.x - g.player.x
  let dz = e.z - g.player.z
  let direction = if dx < 0 { -1.0 } else { 1.0 }
  let elite = e.kind == 1 || e.kind == 3
  let mut z = if dz.abs() > 10 { if dz < 0 { -1.0 } else { 1.0 } } else { 0.0 }
  if incoming is Some(threat) {
    if (g.player.z + z * 2.3 - threat.aim_z).abs() < 55 {
      z = 0
    }
  }
  {
    ..idle_input(),
    x: if dx.abs() > 68 || g.player.facing != direction {
      direction
    } else {
      0.0
    },
    z,
    strike: dx.abs() < 95 && dz.abs() < 27 && !elite,
    breaker: dx.abs() < 95 &&
    dz.abs() < 27 &&
    elite &&
    e.open() &&
    e.phase_total - e.timer >= recognition_delay &&
    e.timer >= 20,
  }
}

///|
test "default combat can be completed by reading windups and taking recovery windows" {
  let g = new_game()
  g.start()
  let mut input = idle_input()
  for frame = 0; frame < 16000 && g.mode == "playing"; frame = frame + 1 {
    // Windups and openings must remain visible for the configured response budget.
    // Motor steering updates every 100 ms; no combat state is modified.
    if frame % frames_from_ms(100) == 0 {
      input = counter_input(g)
    }
    g.step(input)
  }
  println(
    "read windups: mode=\{g.mode} hp=\{g.player.hp} dodges=\{g.dodges} taken=\{g.taken} frames=\{g.frames}",
  )
  assert_eq(g.mode, "cleared", msg=g.snapshot())
  assert_true(g.hits > 15)
  assert_true(g.player.hp > 0)
}

///|
test "the first attack starts immediately and diagonal movement is normalized" {
  let g = new_game()
  g.step({ ..idle_input(), strike: true, })
  assert_eq(g.mode, "playing")
  assert_eq(g.player.action, "strike")
  let a = arena()
  let b = arena()
  let start = a.player.x
  a.step({ ..idle_input(), x: 1.0, })
  b.step({ ..idle_input(), x: 1.0, z: 1.0, })
  assert_true(b.player.x - start < a.player.x - start)
  assert_true(b.player.z > a.player.z)
}

///|
test "a swing hits only in front and within its depth lane, once per action" {
  let g = arena()
  g.spawn(0, g.player.x - 50.0, g.player.z)
  g.spawn(0, g.player.x + 50.0, g.player.z + 70.0)
  let front = g.enemies[0]
  let behind = g.enemies[1]
  let deep = g.enemies[2]
  g.begin_attack(false)
  let hp = front.hp
  g.resolve_strike()
  assert_true(front.hp < hp)
  assert_eq(behind.hp, behind.max_hp)
  assert_eq(deep.hp, deep.max_hp)
  let once = front.hp
  g.resolve_strike()
  assert_eq(front.hp, once)
  assert_true(g.hit_stop > 0)
}

///|
test "frontal guarding blocks light attacks, breaker opens a counter window" {
  let g = arena()
  let e = g.enemies[0]
  e.kind = 1
  e.facing = -1.0
  g.begin_attack(false)
  g.resolve_strike()
  assert_eq(e.hp, e.max_hp)
  assert_eq(g.blocks, 1)
  g.player.action = "idle"
  g.begin_attack(true)
  g.resolve_strike()
  assert_true(e.hp < e.max_hp)
  assert_eq(e.action, "stunned")
  assert_true(e.timer >= 30)
}

///|
test "windup locks its lane so a depth dodge avoids an otherwise connecting attack" {
  let hit = arena()
  let miss = arena()
  for g in [hit, miss] {
    let e = g.enemies[0]
    e.facing = -1.0
    e.action = "windup"
    e.aim_z = g.player.z
    e.timer = 1
  }
  miss.player.z += 65.0
  hit.update_enemies()
  miss.update_enemies()
  assert_true(hit.player.hp < hit.player.max_hp)
  assert_eq(miss.player.hp, miss.player.max_hp)
}

///|
test "evade has invulnerability and a cooldown, and hitstop buffers input without advancing combat" {
  let g = arena()
  g.step({ ..idle_input(), evade: true, z: -1.0, })
  assert_eq(g.player.action, "evade")
  assert_true(g.player.invulnerable > 0)
  assert_true(g.player.evade_cooldown > 0)
  let hp = g.player.hp
  g.hurt_player(1, -1.0)
  assert_eq(g.player.hp, hp)
  g.hit_stop = 4
  let tick = g.tick
  let x = g.player.x
  g.step({ ..idle_input(), strike: true, x: 1.0, })
  assert_eq(g.tick, tick)
  assert_eq(g.player.x, x)
  assert_true(g.player.buffer > 0)
}

///|
test "enemy crowd attacks are serialized and live encounters lock the next gate" {
  let g = arena()
  g.spawn(0, g.player.x + 65.0, g.player.z)
  for _ in 0..<100 {
    g.step(idle_input())
    assert_true(
      g.enemies
      .filter(e => e.action == "windup" || e.action == "active")
      .length() <=
      1,
    )
  }
  g.player.x = g.gate_x() - 22.0
  g.step({ ..idle_input(), x: 1.0, })
  assert_true(g.player.x <= g.gate_x() - 20.0)
}

///|
test "gates advance to the boss, victory and retry need no timer or menu traversal" {
  let g = new_game()
  g.start()
  for stage in 0..<3 {
    assert_eq(g.stage, stage)
    for e in g.enemies {
      e.hp = 0
      e.action = "down"
    }
    g.player.x = g.gate_x() - 40.0
    g.step({ ..idle_input(), x: 1.0, })
  }
  assert_eq(g.mode, "cleared")
  let generation = g.generation
  g.step({ ..idle_input(), retry: true, })
  assert_eq(g.mode, "playing")
  assert_eq(g.stage, 0)
  assert_eq(g.player.hp, g.player.max_hp)
  assert_true(g.generation > generation)
  g.player.hp = 0
  g.mode = "lost"
  g.step({ ..idle_input(), start: true, })
  assert_eq(g.mode, "playing")
}

///|
test "tuning rejects invalid state atomically and preserves encounter progression" {
  let g = arena()
  g.apply_tuning("player", "hp", 3.0)
  g.apply_tuning("combat", "damage", 2.0)
  g.apply_tuning("combat", "windup", 36.0)
  assert_eq(g.player.hp, 3)
  assert_eq(g.damage, 2)
  assert_eq(g.windup, 36)
  let before = g.snapshot()
  for
    t in [
      ("player", "hp", 0.0),
      ("player", "hp", 2.5),
      ("player", "x", -100.0),
      ("combat", "damage", 0.0 / 0.0),
      ("combat", "windup", 0.0),
      ("combat", "score", 999.0),
    ] {
    assert_true(
      try {
        g.apply_tuning(t.0, t.1, t.2)
        false
      } catch {
        _ => true
      },
    )
    assert_eq(g.snapshot(), before)
  }
}

///|
test "holding an attack cannot skip the result screen" {
  let g = arena()
  let input = { ..idle_input(), strike: true, }
  g.step(input)
  g.mode = "cleared"
  g.step(input)
  assert_eq(g.mode, "cleared")
  g.step(idle_input())
  g.step(input)
  assert_eq(g.mode, "playing")
}
