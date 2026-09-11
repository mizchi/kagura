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
  let (width, height) = @engine.capture_viewport(screen_w, screen_h)
  let state = DemoState::new(width~, height~)
  @engine.run_game(
    state,
    width=state.width,
    height=state.height,
    title="UI Demo",
    canvas="#app",
  )
}
