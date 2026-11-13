///|
test "tuned combat uses the real rules and default tuning reproduces the baseline" {
  let normal = simulate_battle(FungiPair, Smart, 42)
  let tuned = simulate_tuned_battle(FungiPair, Smart, 42, 1.0, 80)
  assert_eq(normal.won, tuned.won)
  assert_eq(normal.turns_taken, tuned.turns_taken)
  assert_eq(normal.hp_remaining, tuned.hp_remaining)
  let easier = simulate_tuned_battle(FungiPair, Smart, 42, 0.5, 100)
  assert_true(easier.hp_remaining >= normal.hp_remaining)
  assert_true(
    try {
      simulate_tuned_battle(FungiPair, Smart, 42, 0.0, 80) |> ignore
      false
    } catch {
      _ => true
    },
  )
}
