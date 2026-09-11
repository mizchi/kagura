///|
/// Resolve once for drawing and retain that frame's hierarchy for inspection.
fn Game::resolved_view(self : Game) -> @scene.SceneNode {
  let scene = @scene.resolve(self.view()) catch {
    error => abort(error.to_string())
  }
  self._inspection.hierarchy = scene.hierarchy
  scene.node
}

///|
fn Game::scene_hierarchy(self : Game) -> String {
  self._inspection.hierarchy.to_json().stringify()
}

///|
fn Game::update(self : Game, input : @core.InputSnapshot) -> Unit {
  if self._inspection.paused {
    return
  }
  self._inspection.revision += 1
  self.update_tick(input)
}
