///|
fn Game::load_editor_scene(self : Game) -> Unit {
  self.apply_scene(self.layout) catch { error => abort(error.to_string()) }
}
