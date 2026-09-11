///|
impl @scene.SceneGame for Game with fn update_game(self, input) {
  self.update(input)
}

///|
impl @scene.SceneGame for Game with fn view_game(self) {
  self.resolved_view()
}

///|
fn main {
  let game = Game::new()
  game.load_editor_scene()
  @scene.run_game(
    game,
    width=screen_w,
    height=screen_h,
    title="Flappy Bird",
    canvas="#app",
  )
}
