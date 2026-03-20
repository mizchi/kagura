///|
impl @engine.EngineGame for GameState with update_game(self, input) {
  self.update(input)
}

///|
impl @engine.EngineGame for GameState with draw_game(self, ctx) {
  self.draw(ctx)
}

///|
fn main {
  let state = GameState::new(seed=42)
  @engine.run_game(
    state,
    width=screen_w,
    height=screen_h,
    title="Hack & Slash 3D",
  )
}
