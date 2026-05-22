///|
impl @scene.SceneGame for Game with update_game(self, input) {
  self.update(input)
}

///|
impl @scene.SceneGame for Game with view_game(self) {
  self.view()
}

///|
fn main {
  let game = Game::new()
  @scene.run_game(
    game,
    width=screen_w,
    height=screen_h,
    title="Flappy Bird",
    canvas="#app",
  )
}
