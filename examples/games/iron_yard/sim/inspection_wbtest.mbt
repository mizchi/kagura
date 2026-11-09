///|
test "tuning hp and weapon cooldowns leaves mission and combat objects intact" {
  let g = new_game(ai=false)
  let before = g.pilot.position
  g.apply_tuning("player", "hp", 500.0)
  g.apply_tuning("weapons", "rifleCooldown", 0.5)
  g.apply_tuning("weapons", "missileCooldown", 1.5)
  assert_eq(g.hp, 500.0)
  assert_eq(g.rifle_cooldown, 0.5)
  assert_eq(g.missile_cooldown, 1.5)
  assert_eq(g.pilot.position.sub(before).length_squared(), 0.0)
  let state = snapshot(g)
  for
    trial in [
      ("player", "hp", 0.0),
      ("player", "hp", 1001.0),
      ("weapons", "rifleCooldown", -1.0),
      ("game", "kills", 1.0),
      ("player", "hp", 1.0 / 0.0),
    ] {
    assert_true(
      try {
        g.apply_tuning(trial.0, trial.1, trial.2)
        false
      } catch {
        _ => true
      },
    )
    assert_eq(snapshot(g), state)
  }
}
