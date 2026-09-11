///|
test "navigation routes around expanded footprints and enemy shells damage player" {
  let stage = {
    ..default_stage(),
    solids: [solid("cover", vec(0.0, 2.0, 0.0), vec(8.0, 4.0, 8.0), 0)],
  }
  let start = vec(0.0, 0.0, -12.0)
  let goal = vec(0.0, 0.0, 12.0)
  let route = find_route(start, goal, stage)
  assert_true(route.length() >= 3)
  let mut previous = start
  for point in route {
    assert_true(clear_segment(previous, point, stage))
    previous = point
  }
  let g = { ..new_game(), stage: { ..default_stage(), solids: [] } }
  g.phase = "playing"
  for _ in 0..<1200 {
    advance_enemies(g, 1.0 / 60.0)
  }
  assert_true(g.enemy_shots > 0)
  assert_true(g.hp < 1000.0)
}

///|
test "pause freezes gameplay and mission waves culminate in victory" {
  let g = new_game()
  let position = g.pilot.position
  advance_motion(g, input(forward=1.0), 0.1)
  assert_true(g.pilot.position.approx_eq(position, 0.000000001))
  start_playing(g)
  for wave in 0..<3 {
    for e in g.units {
      e.hp = 0.0
    }
    finish_mission(g, 0.1)
    assert_eq(g.wave, if wave < 2 { wave + 1 } else { 2 })
  }
  assert_eq(g.phase, "won")
  let lost = new_game()
  start_playing(lost)
  lost.hp = 0.0
  finish_mission(lost, 0.1)
  assert_eq(lost.phase, "lost")
}
