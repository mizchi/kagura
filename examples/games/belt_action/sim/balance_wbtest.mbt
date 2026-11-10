///|
fn chase(g : Game) -> Input {
  let targets = g.enemies.filter(e => e.hp > 0)
  if targets.is_empty() {
    return { ..idle_input(), x: 1, }
  }
  targets.sort_by((a, b) => {
    (a.x - g.player.x).abs().compare((b.x - g.player.x).abs())
  })
  let e = targets[0]
  let dx = e.x - g.player.x
  let dz = e.z - g.player.z
  let direction = if dx < 0 { -1.0 } else { 1.0 }
  {
    ..idle_input(),
    x: if dx.abs() > 68 || g.player.facing != direction {
      direction
    } else {
      0.0
    },
    z: if dz.abs() > 10 {
      if dz < 0 {
        -1.0
      } else {
        1.0
      }
    } else {
      0.0
    },
  }
}

///|
fn elite_arena(kind : Int32) -> Game {
  let g = arena()
  g.enemies.clear()
  g.spawn(kind, g.player.x + 58, g.player.z)
  g
}

///|
test "neutral evade retreats, taking an enemy's back requires a direction" {
  let retreat = arena()
  let advance = arena()
  let origin = retreat.player.x
  retreat.step({ ..idle_input(), evade: true, })
  advance.step({ ..idle_input(), evade: true, x: 1, })
  assert_true(retreat.player.x < origin)
  assert_true(advance.player.x > origin)
}

///|
test "attack-only mashing loses while blind evasion outcomes are measured separately" {
  // Movement still tracks the nearest target, so a loss cannot be explained by
  // standing out of range. These policies never read telegraphs or recovery.
  let winners : Array[Int32] = []
  for policy in 0..<17 {
    let g = new_game()
    g.start()
    for frame = 0; frame < 12000 && g.mode == "playing"; frame = frame + 1 {
      let moving = chase(g)
      let input = match policy {
        0 => { ..moving, strike: true, }
        1 => { ..moving, breaker: true, }
        2 => { ..moving, strike: true, breaker: true, }
        3 | 4 | 5 => { ..moving, strike: frame % ((policy - 2) * 12) < 2, }
        6 | 7 | 8 => { ..moving, breaker: frame % ((policy - 5) * 12) < 2, }
        9 | 10 | 11 =>
          {
            ..moving,
            strike: frame % ((policy - 8) * 12) < 2,
            breaker: frame % ((policy - 8) * 12) < 2,
          }
        12 => { ..moving, strike: frame % 48 < 24, breaker: frame % 48 >= 24, }
        13 => { ..moving, strike: true, breaker: true, evade: true, }
        _ =>
          {
            ..moving,
            strike: frame % ((policy - 13) * 12) < 2,
            breaker: frame % ((policy - 13) * 12) < 2,
            evade: frame % ((policy - 13) * 12) < 2,
          }
      }
      g.step(input)
    }
    println(
      "blind policy \{policy}: mode=\{g.mode} sector=\{g.stage + 1} hp=\{g.player.hp} hits=\{g.hits} taken=\{g.taken} frames=\{g.frames}",
    )
    if policy < 13 && g.mode != "lost" {
      winners.push(policy)
    }
    if policy >= 13 {
      assert_true(g.dodges > 0)
    }
  }
  assert_eq(
    winners.length(),
    0,
    msg="Blind policies that did not lose: " +
      winners.map(n => n.to_string()).join(","),
  )
}

///|
test "repeated hits cannot indefinitely extend the same stagger" {
  let g = elite_arena(1)
  let e = g.enemies[0]
  g.begin_attack(true)
  g.resolve_strike()
  e.timer = 3
  g.begin_attack(true)
  g.resolve_strike()
  assert_true(e.timer <= 3)
  for _ in 0..<3 {
    g.update_enemies()
  }
  assert_eq(e.action, "windup")
  assert_eq(e.timer, e.windup_frames(g.windup))
  assert_eq(g.player.hp, g.player.max_hp)
}

///|
test "committed elite attacks survive frontal attack spam but expose a recovery window" {
  for kind in [1, 3] {
    let g = elite_arena(kind)
    let e = g.enemies[0]
    let hp = e.hp
    e.facing = -1
    e.action = "windup"
    e.timer = 8
    g.begin_attack(true)
    g.resolve_strike()
    assert_eq(e.action, "windup")
    assert_eq(e.hp, hp)
    assert_eq(e.timer, 8)
    e.action = "recover"
    e.timer = 40
    g.begin_attack(true)
    g.resolve_strike()
    assert_true(e.hp < hp)
  }
}

///|
test "taking an elite's back bypasses its frontal brace" {
  for kind in [1, 3] {
    let g = elite_arena(kind)
    let e = g.enemies[0]
    e.action = "windup"
    e.facing = -1
    e.timer = 20
    let hp = e.hp
    g.player.x = e.x + 58
    g.player.facing = -1
    g.begin_attack(true)
    g.resolve_strike()
    assert_true(e.hp < hp)
  }
}

///|
test "light enemies stay interruptible while the foreman cannot be stagger locked" {
  let grunt = arena()
  grunt.enemies[0].action = "windup"
  grunt.begin_attack(false)
  grunt.resolve_strike()
  assert_eq(grunt.enemies[0].action, "stunned")
  let boss = elite_arena(3)
  let e = boss.enemies[0]
  e.facing = -1
  e.timer = 1
  boss.begin_attack(true)
  boss.resolve_strike()
  assert_eq(e.action, "approach")
  boss.update_enemies()
  assert_eq(e.action, "windup")
}
