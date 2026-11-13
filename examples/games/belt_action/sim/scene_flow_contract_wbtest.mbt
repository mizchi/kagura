///|
test "undeclared scene transitions preserve the actual game state" {
  let g = new_game()
  assert_true(try { g.transition_mode("lost"); false } catch { _ => true })
  assert_eq(g.mode, "title")
}
