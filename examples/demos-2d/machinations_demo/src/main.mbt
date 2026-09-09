///|
impl @engine.EngineGame for DemoState with fn update_game(self, input) {
  self.update(input)
}

///|
impl @engine.EngineGame for DemoState with fn draw_game(self, ctx) {
  self.draw(ctx)
}

///|
fn main {
  @web_hooks.install("#app")
  let state = DemoState::new()
  @engine.run_game(
    state,
    width=screen_w,
    height=screen_h,
    title="Machinations Demo",
    canvas="#app",
  )
}
