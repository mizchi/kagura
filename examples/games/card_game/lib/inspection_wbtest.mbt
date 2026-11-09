///|
test "tuning synchronizes run and battle hp and preserves draw order and turn" {
  let g = Game::new()
  let run = g.run.get()
  let battle = run.battle.unwrap()
  let hand = battle.hand.copy()
  let turn = battle.turn
  g.set_inspection_paused(true)
  g.apply_tuning("player", "hp", 40.0)
  g.apply_tuning("player", "energy", 2.0)
  g.apply_tuning("run", "gold", 123.0)
  assert_eq(run.player_hp, 40)
  assert_eq(battle.player.hp, 40)
  assert_eq(battle.player.energy, 2)
  assert_eq(run.gold, 123)
  g.update(@core.empty_input_snapshot())
  assert_eq(battle.hand, hand)
  assert_eq(battle.turn, turn)
  for
    trial in [
      ("player", "hp", 0.0),
      ("player", "hp", 3.5),
      ("player", "energy", -1.0),
      ("run", "gold", 0.0 / 0.0),
      ("run", "floor", 8.0),
    ] {
    assert_true(
      try {
        g.apply_tuning(trial.0, trial.1, trial.2)
        false
      } catch {
        _ => true
      },
    )
    assert_eq(run.player_hp, 40)
    assert_eq(battle.player.energy, 2)
    assert_eq(run.gold, 123)
  }
}

///|
test "headless inspection guards pause revision and scope before applying resources" {
  let g = Game::new()
  g.set_inspection_paused(true)
  guard @json.parse(g.read_inspection())
    is { "revision": Number(revision, ..), "scope": String(scope), .. } else {
    fail("Missing token")
  }
  g.edit_inspection("player", "hp", 40.0, revision.to_int(), scope)
  assert_true(
    try {
      g.edit_inspection("player", "hp", 1.0, revision.to_int(), scope)
      false
    } catch {
      _ => true
    },
  )
  guard @json.parse(g.observe_inspection()) is { "state": { "hp": 40, .. }, .. } else {
    fail("Missing state")
  }
  g.set_inspection_paused(false)
  assert_true(
    try {
      g.edit_inspection("player", "hp", 1.0, g.inspection.revision, scope)
      false
    } catch {
      _ => true
    },
  )
  assert_eq(g.run.get().player_hp, 40)
}

///|
test "battle resources are read only during enemy turns and presentation blocks tuning" {
  let g = Game::new()
  let battle = g.run.get().battle.unwrap()
  battle.phase = EnemyTurn
  let energy = battle.player.energy
  assert_true(
    try {
      g.apply_tuning("player", "energy", 99.0)
      false
    } catch {
      _ => true
    },
  )
  assert_eq(battle.player.energy, energy)
  g.travel(SwitchScene(Settings))
  let hp = g.run.get().player_hp
  assert_true(
    try {
      g.apply_tuning("player", "hp", 1.0)
      false
    } catch {
      _ => true
    },
  )
  assert_eq(g.run.get().player_hp, hp)
}
