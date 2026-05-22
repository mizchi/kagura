///|
impl @engine.EngineGame for DemoState with update_game(self, input) {
  self.update(input)
}

///|
impl @engine.EngineGame for DemoState with draw_game(self, ctx) {
  self.draw(ctx)
}

///|
fn main {
  let state = DemoState::new()
  @engine.run_game(
    state,
    width=screen_w,
    height=screen_h,
    title="Shadow Mapping Demo",
    canvas="#app",
  )
}
