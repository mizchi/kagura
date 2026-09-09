///|
impl @engine.EngineGame for GameState with fn update_game(self, input) {
  self.update(input)
}

///|
impl @engine.EngineGame for GameState with fn draw_game(self, ctx) {
  self.draw(ctx)
}

///|
fn main {
  let state = GameState::new()
  @engine.run_game(
    state,
    width=screen_w,
    height=screen_h,
    title="FPS Demo",
    canvas="#app",
  )
}
