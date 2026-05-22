///|
impl @scene.SceneGame for GameState with update_game(self, input) {
  self.update(input)
}

///|
impl @scene.SceneGame for GameState with view_game(self) {
  self.view()
}

///|
fn main {
  let state = GameState::new(seed=42)
  @scene.run_game(
    state,
    width=screen_w,
    height=screen_h,
    title="Hack & Slash",
    canvas="#app",
  )
}
