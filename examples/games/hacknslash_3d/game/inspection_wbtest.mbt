///|
test "tuning hp and guard energy respects limits and stops an empty guard" {
  let g = GameWorld::new(seed=42)
  let x = g.player.x
  let frame = g.frame_count
  g.apply_tuning("player", "hp", 1.0)
  g.arts.guarding = true
  g.apply_tuning("player", "guardEnergy", 0.0)
  assert_eq(g.player.hp, 1)
  assert_false(g.arts.guarding)
  assert_eq(g.arts.guard_energy, 0.0)
  for
    trial in [
      ("hp", 0.0),
      ("hp", 1.5),
      ("guardEnergy", 101.0),
      ("guardEnergy", 0.0 / 0.0),
      ("score", 1.0),
    ] {
    assert_true(
      try {
        g.apply_tuning("player", trial.0, trial.1)
        false
      } catch {
        _ => true
      },
    )
    assert_eq(g.player.hp, 1)
    assert_eq(g.arts.guard_energy, 0.0)
  }
  assert_eq(g.player.x, x)
  assert_eq(g.frame_count, frame)
}
