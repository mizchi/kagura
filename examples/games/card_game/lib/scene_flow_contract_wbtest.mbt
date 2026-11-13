///|
test "undeclared scene transitions preserve the actual game state" {
  let g = Game::new_app()
  assert_true(try { g.transition_scene(Playing); false } catch { _ => true })
  assert_true(g.scene == Title)
}

///|
test "playing can open settings and return to the same run" {
  let g = Game::new()
  let run = g.run.get()
  g.update(key_input([80]))
  settle_presentation(g)
  assert_true(g.scene == Settings)
  g.scene_back()
  settle_presentation(g)
  assert_true(g.scene == Playing)
  assert_eq(g.run.get().floor, run.floor)
}
