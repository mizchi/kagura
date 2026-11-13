///|
test "undeclared scene transitions preserve the actual game state" {
  let g = GameWorld::new(seed=42)
  assert_true(try { g.transition_mode(GameOver); false } catch { _ => true })
  assert_true(g.mode == Title)
}
