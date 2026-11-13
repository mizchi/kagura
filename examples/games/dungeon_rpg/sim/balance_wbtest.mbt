///|
test "balance profiles validate atomically and only apply before an expedition" {
  let g = new_game()
  let original = g.balance
  assert_true(
    try {
      g.configure_balance("{\"enemyHpScale\":0}")
      false
    } catch {
      _ => true
    },
  )
  assert_eq(g.balance, original)
  g.configure_balance(
    "{\"enemyHpScale\":2,\"enemyDamageScale\":1.5,\"encounterSteps\":12}",
  )
  assert_eq(g.balance.enemy_hp_scale, 2.0)
  g.command("enter", -1)
  assert_eq(g.encounter_steps(), 12)
  assert_true(
    try {
      g.configure_balance("{}")
      false
    } catch {
      _ => true
    },
  )
  g.begin_battle(true)
  assert_eq(g.battle.unwrap().foes[0].max_hp, 108)
  assert_eq(g.battle.unwrap().foes[0].attack, 12)
}

///|
test "default balance preserves existing combat and encounter pacing" {
  let g = new_game()
  g.enter()
  assert_eq(g.encounter_steps(), 8)
  g.floor = 1
  assert_eq(g.encounter_steps(), 7)
  g.begin_battle(true)
  assert_eq(g.battle.unwrap().foes[0].max_hp, 54)
  assert_eq(g.battle.unwrap().foes[0].attack, 8)
}
