///|
test "every wave grows and later salvos contain denser faster bullets" {
  let g = new_game(73)
  command(g, "start")
  assert_eq(g.enemies.length(), 24)
  for wave = 2; wave <= 9; wave = wave + 1 {
    g.enemies.clear()
    spawn_wave(g)
    assert_eq(g.enemies.length(), 18 + wave * 6)
  }
  let early = new_game(73)
  command(early, "start")
  for e in early.enemies {
    e.shot_clock = 0
  }
  step(early, idle_input(), 1.0 / 60)
  command(g, "practice-swarm")
  for e in g.enemies {
    e.shot_clock = 0
  }
  step(g, idle_input(), 1.0 / 60)
  assert_true(early.shots.length() >= 24)
  assert_true(g.shots.length() > early.shots.length() * 2)
  assert_true(g.shots[0].velocity.length() > early.shots[0].velocity.length())
  assert_true(g.shots.length() <= 320)
}

///|
test "a charged boss beam commits to its aim and has a safe warning window" {
  let g = new_game(73)
  command(g, "practice-boss")
  g.boss_clock = 999
  g.next_rock = 999
  g.player = vec(0, 0, 2)
  queue_beam(g, vec(0, 0, -40), g.player, 1.0)
  for _i = 0; _i < 19; _i = _i + 1 {
    step(g, idle_input(), 0.05)
  }
  assert_eq(g.hp, 6)
  assert_true(g.beams[0].age < g.beams[0].warning)
  for _i = 0; _i < 6; _i = _i + 1 {
    step(g, idle_input(), 0.05)
  }
  assert_eq(g.hp, 4)
  command(g, "practice-boss")
  g.boss_clock = 999
  g.next_rock = 999
  g.player = vec(0, 0, 2)
  queue_beam(g, vec(0, 0, -40), g.player, 1.0)
  for _i = 0; _i < 28; _i = _i + 1 {
    step(g, { ..idle_input(), move_x: 1, }, 0.05)
  }
  assert_eq(g.hp, 6)
  assert_true(g.player.x > 3)
}

///|
test "fast rocks use swept collision while lateral movement evades them" {
  let g = new_game(5)
  command(g, "start")
  g.player = vec(0, 0, 2)
  g.rocks.push({
    position: vec(0, 0, -4),
    velocity: vec(0, 0, 240),
    radius: 1.2,
    phase: 0,
    age: 0,
  })
  step(g, idle_input(), 0.05)
  assert_eq(g.hp, 4)
  command(g, "restart")
  g.player = vec(6, 0, 2)
  g.rocks.push({
    position: vec(0, 0, -4),
    velocity: vec(0, 0, 240),
    radius: 1.2,
    phase: 0,
    age: 0,
  })
  step(g, { ..idle_input(), aim_x: 0.8, move_x: 1, }, 0.05)
  assert_eq(g.hp, 6)
}

///|
test "boss owns six lock points and victory requires its defeat" {
  let g = new_game(9)
  command(g, "practice-boss")
  let boss = g.enemies[0]
  assert_true(boss.boss)
  assert_eq(lock_targets(g).length(), 6)
  g.time = 96
  step(g, idle_input(), 1.0 / 60)
  assert_eq(g.mode, "playing")
  for target in lock_targets(g) {
    g.locks.push(target.id)
  }
  fire_volley(g)
  assert_eq(g.balls.length(), 6)
  damage(g, boss, boss_max_hp())
  assert_true(g.boss_defeated)
  assert_eq(g.score, 10000)
  assert_true(g.bowls[0].scale > 3)
  for _i = 0; _i < 180; _i = _i + 1 {
    step(g, idle_input(), 1.0 / 60)
  }
  assert_eq(g.mode, "won")
  assert_eq(g.beams.length(), 0)
  assert_eq(g.rocks.length(), 0)
}

///|
test "pause freezes hazards and retry clears boss state and every hazard" {
  let g = new_game(4)
  command(g, "practice-boss")
  queue_beam(g, vec(0, 0, -40), vec(0, 0, 2), 1.0)
  spawn_rocks(g)
  let age = g.beams[0].age
  let z = g.rocks[0].position.z
  command(g, "pause")
  step(g, idle_input(), 0.05)
  assert_eq(g.beams[0].age, age)
  assert_eq(g.rocks[0].position.z, z)
  command(g, "restart")
  assert_false(g.boss_spawned)
  assert_false(g.boss_defeated)
  assert_eq(g.beams.length(), 0)
  assert_eq(g.rocks.length(), 0)
}

///|
test "enraged boss commits three beams with a vertical escape route in portrait" {
  let g = new_game(4)
  command(g, "practice-boss")
  g.boss_clock = 0
  g.next_rock = 999
  g.enemies[0].hp = boss_max_hp() * 0.5
  let input = { ..idle_input(), aspect: 390.0 / 844, }
  step(g, input, 1.0 / 60)
  assert_eq(g.beams.length(), 3)
  assert_eq(g.shots.length(), 14)
  let aim = g.beams[0].aim
  assert_true(g.beams[1].aim.x < aim.x)
  assert_true(g.beams[2].aim.x > aim.x)
  for _i = 0; _i < 32; _i = _i + 1 {
    step(g, { ..input, move_y: 1, }, 0.05)
  }
  assert_eq(g.hp, 6)
  assert_eq(g.beam_event, 3)
}

///|
test "the killing volley cancels hazards before they can kill the player" {
  let g = new_game(4)
  command(g, "practice-boss")
  g.boss_clock = 999
  g.next_rock = 999
  g.hp = 1
  g.enemies[0].hp = 2
  let target = lock_targets(g)[0]
  g.balls.push({
    target: target.id,
    position: target.position,
    velocity: vec(0, 0, 0),
    age: 0,
    trail: [],
  })
  g.shots.push({ position: g.player, velocity: vec(0, 0, 20), age: 0, })
  step(g, idle_input(), 1.0 / 60)
  assert_true(g.boss_defeated)
  assert_eq(g.hp, 1)
  assert_eq(g.mode, "playing")
  assert_eq(g.shots.length(), 0)
}
