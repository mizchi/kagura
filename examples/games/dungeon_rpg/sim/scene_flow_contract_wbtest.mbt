///|
test "undeclared scene transitions preserve the actual game state" {
  let g = new_game()
  assert_true(try { g.transition_mode(Fighting); false } catch { _ => true })
  assert_true(g.mode == Town)
}
