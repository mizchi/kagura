///|
impl @scene.SceneGame for SurvivorState with update_game(self, input) {
  self.update(input)
}

///|
impl @scene.SceneGame for SurvivorState with view_game(self) {
  self.view()
}

///|
fn main {
  let state = SurvivorState::new()
  @scene.run_game(state, width=320, height=240, title="Survivor", canvas="#app")
}
