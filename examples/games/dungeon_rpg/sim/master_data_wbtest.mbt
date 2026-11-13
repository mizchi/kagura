///|
test "master tables drive enemy names stats and encounter composition without changing active battles" {
  let g = new_game()
  let source = default_master_source
    .replace(old="\"hp\": 54", new="\"hp\": 70")
    .replace(old="深淵の守護者", new="赤い守護者")
  g.configure_master_data(source)
  g.command("enter", -1)
  g.begin_battle(true)
  assert_eq(g.battle.unwrap().foes[0].hp, 70)
  assert_eq(g.battle.unwrap().foes[0].name, "赤い守護者")
  let before = g.snapshot()
  assert_true(
    try {
      g.configure_master_data(default_master_source)
      false
    } catch {
      _ => true
    },
  )
  assert_eq(g.snapshot(), before)
}

///|
test "invalid master references and bounds are rejected before any state changes" {
  let g = new_game()
  let before = g.snapshot()
  for
    source in [
      default_master_source.replace(old="\"hp\": 54", new="\"hp\": 0"),
      default_master_source.replace(
        old="\"enemy1\": \"rat\"",
        new="\"enemy1\": \"missing\"",
      ),
    ] {
    assert_true(
      try {
        g.configure_master_data(source)
        false
      } catch {
        _ => true
      },
    )
    assert_eq(g.snapshot(), before)
  }
}
