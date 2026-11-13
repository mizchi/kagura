///|
test "undeclared scene transitions preserve the actual game state" {
  let g = new_game(1)
  assert_true(try { g.transition_mode("won"); false } catch { _ => true })
  assert_eq(g.mode, "title")
}
