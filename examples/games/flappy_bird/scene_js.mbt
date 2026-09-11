///|
extern "js" fn editor_scene_source() -> String =
  #| () => globalThis.__kaguraScene?.game === "flappy_bird" ? JSON.stringify(globalThis.__kaguraScene.data) : ""

///|
fn Game::load_editor_scene(self : Game) -> Unit {
  let source = editor_scene_source()
  if source != "" {
    self.apply_scene(@json.from_json(@json.parse(source))) catch {
      error => abort(error.to_string())
    }
  }
  self.setup_inspection()
}
