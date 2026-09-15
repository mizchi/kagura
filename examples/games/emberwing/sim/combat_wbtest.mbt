///|
test "multi lock is unique, capped, and only release fires the volley" {
  let g = new_game(42)
  command(g, "start")
  g.enemies.clear()
  for i = 0; i < 20; i = i + 1 {
    spawn_enemy(g, vec(0, 0, -32 - i.to_double() * 0.1), i)
  }
  let input = { ..idle_input(), locking: true, }
  for _i = 0; _i < 120; _i = _i + 1 {
    step(g, input, 1.0 / 60)
  }
  assert_eq(g.locks.length(), 12)
  assert_eq(g.balls.length(), 0)
  step(g, idle_input(), 1.0 / 60)
  assert_eq(g.balls.length(), 12)
  assert_eq(g.locks.length(), 0)
  step(g, idle_input(), 1.0 / 60)
  assert_eq(g.balls.length(), 12)
}

///|
test "homing hits moving targets and a defeated kawaiiko becomes falling kamonanban" {
  let g = new_game(1)
  command(g, "start")
  g.enemies.clear()
  spawn_enemy(g, vec(0, 0, -22), 0)
  let id = g.enemies[0].id
  g.locks.push(id)
  g.was_locking = true
  step(g, idle_input(), 1.0 / 60)
  for _i = 0; _i < 100; _i = _i + 1 {
    step(g, idle_input(), 1.0 / 60)
  }
  assert_eq(g.kills, 1)
  assert_true(g.bowls.length() > 0)
  let y = g.bowls[0].position.y
  for _i = 0; _i < 30; _i = _i + 1 {
    step(g, idle_input(), 1.0 / 60)
  }
  assert_true(g.bowls[0].position.y < y)
  assert_eq(g.score, 100)
}

///|
test "flame has range and heat limits; pause and restart clear held inputs" {
  let g = new_game(3)
  command(g, "start")
  g.enemies.clear()
  spawn_enemy(g, vec(0, 0, -18), 0)
  for _i = 0; _i < 50; _i = _i + 1 {
    step(g, { ..idle_input(), flame: true, }, 1.0 / 60)
  }
  assert_eq(g.kills, 1)
  assert_true(g.heat > 0)
  g.was_locking = true
  let time = g.time
  command(g, "pause")
  step(g, { ..idle_input(), locking: true, }, 1.0)
  assert_eq(g.time, time)
  assert_eq(g.balls.length(), 0)
  command(g, "resume")
  step(g, idle_input(), 1.0 / 60)
  assert_eq(g.balls.length(), 0)
  for _i = 0; _i < 360; _i = _i + 1 {
    step(g, { ..idle_input(), flame: true, }, 1.0 / 60)
  }
  assert_true(g.heat <= 1 && g.heat >= 0)
  command(g, "restart")
  assert_eq(g.score, 0)
  assert_eq(g.hp, 6)
  assert_eq(g.mode, "playing")
}

///|
test "fixed seeded encounters and bounded entities survive a full unattended mission" {
  let a = new_game(9)
  let b = new_game(9)
  command(a, "start")
  command(b, "start")
  for _i = 0; _i < 7200; _i = _i + 1 {
    step(a, idle_input(), 1.0 / 60)
    step(b, idle_input(), 1.0 / 60)
    assert_true(
      a.enemies.length() <= 120 &&
      a.balls.length() <= 96 &&
      a.bowls.length() <= 48 &&
      a.shots.length() <= 320,
    )
  }
  assert_eq(a.score, b.score)
  assert_eq(a.hp, b.hp)
  assert_eq(a.mode, b.mode)
  assert_true(a.mode == "won" || a.mode == "lost")
}

///|
test "flame under the cursor hits a close off-center target despite camera parallax" {
  let g = new_game(3)
  command(g, "start")
  g.enemies.clear()
  spawn_enemy(g, vec(10, 7, -16), 0)
  for _i = 0; _i < 45; _i = _i + 1 {
    if g.enemies.length() > 0 {
      let p = project(
        camera(16.0 / 9).view_projection_matrix(),
        g.enemies[0].position.add(vec(0, 0.6, 0)),
      )
      step(
        g,
        { ..idle_input(), aim_x: p.x, aim_y: p.y, flame: true, },
        1.0 / 60,
      )
    }
  }
  assert_eq(g.kills, 1)
}

///|
test "failure and mission completion stop the world and restart a fresh flight" {
  let g = new_game(5)
  command(g, "start")
  g.hp = 1
  g.shots.push({ position: g.player, velocity: vec(0, 0, 0), age: 0, })
  step(g, idle_input(), 1.0 / 60)
  assert_eq(g.mode, "lost")
  let ended = g.time
  step(g, { ..idle_input(), flame: true, locking: true, }, 1.0 / 60)
  assert_eq(g.time, ended)
  command(g, "restart")
  assert_eq(g.hp, 6)
  assert_eq(g.shots.length(), 0)
  g.time = 95.99
  step(g, idle_input(), 1.0 / 60)
  assert_eq(g.mode, "playing")
  assert_true(g.boss_spawned)
  command(g, "restart")
  assert_eq(g.time, 0)
  assert_eq(g.score, 0)
  assert_eq(g.wave, 1)
}
