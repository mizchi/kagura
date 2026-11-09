///|
test "tuning hp and heat maintains overheat hysteresis and preserves encounters" {
  let g = new_game(73)
  command(g, "start")
  let count = g.enemies.length()
  g.apply_tuning("player", "hp", 4.0)
  g.apply_tuning("player", "heat", 1.0)
  assert_eq(g.hp, 4)
  assert_true(g.overheated)
  assert_false(g.breathing)
  g.apply_tuning("player", "heat", 0.5)
  assert_true(g.overheated)
  g.apply_tuning("player", "heat", 0.1)
  assert_false(g.overheated)
  for
    trial in [
      ("hp", 0.0),
      ("hp", 2.5),
      ("heat", 1.1),
      ("heat", 0.0 / 0.0),
      ("score", 100.0),
    ] {
    assert_true(
      try {
        g.apply_tuning("player", trial.0, trial.1)
        false
      } catch {
        _ => true
      },
    )
    assert_eq(g.hp, 4)
    assert_eq(g.heat, 0.1)
  }
  assert_eq(g.time, 0.0)
  assert_eq(g.enemies.length(), count)
}
