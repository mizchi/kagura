///|
test "inspection pauses updates and tunes player and weapons without resetting progress" {
  let s = SurvivorState::new()
  s.game_mode = 1
  s.update(@core.empty_input_snapshot())
  s.set_inspection_paused(true)
  let frame = s.frame_count
  s.update(@core.empty_input_snapshot())
  assert_eq(s.frame_count, frame)
  s.apply_tuning("player", "hp", 5.0)
  s.apply_tuning("player", "position.x", 400.0)
  s.apply_tuning("weapon", "damage", 4.0)
  assert_eq(s.player.hp, 5)
  assert_eq(s.player.x, 400.0)
  assert_eq(s.projectile_weapon.damage, 4)
  let revision = s.inspection.revision
  for
    trial in [
      ("player", "hp", 0.0),
      ("player", "hp", 3.5),
      ("player", "position.x", -1.0),
      ("weapon", "interval", 0.0),
      ("game", "score", 99.0),
    ] {
    assert_true(
      try {
        s.apply_tuning(trial.0, trial.1, trial.2)
        false
      } catch {
        _ => true
      },
    )
    assert_eq(s.player.hp, 5)
    assert_eq(s.inspection.revision, revision)
  }
  s.set_inspection_paused(false)
  s.update(@core.empty_input_snapshot())
  assert_eq(s.frame_count, frame + 1)
  let scope = s.inspection.scope("survivor")
  s.reset()
  assert_true(s.inspection.scope("survivor") != scope)
}
