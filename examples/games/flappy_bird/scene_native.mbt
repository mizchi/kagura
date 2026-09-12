///|
fn Game::load_editor_scene(self : Game) -> Unit {
  // Native has no live editor payload. Re-applying the baked layout calls
  // reset() and would wipe named capture fixtures such as gameover.
}
