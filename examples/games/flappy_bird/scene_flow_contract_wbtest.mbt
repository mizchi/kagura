///|
test "undeclared scene transitions preserve the actual game state" {
  let g = Game::new()
  assert_true(try { g.transition_mode(2); false } catch { _ => true })
  assert_eq(g.game_mode.get(), 0)
}
