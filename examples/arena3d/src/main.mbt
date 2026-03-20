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
  let state = GameState::new()
  @engine.run_game(
    state,
    audio_ctx=state.audio_ctx,
    width=screen_w,
    height=screen_h,
    title="3D Arena Collector",
    canvas="#app",
  )
}
