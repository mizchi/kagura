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
  let state = DemoState::new(
    width=initial_screen_w(),
    height=initial_screen_h(),
  )
  @engine.run_game(
    state,
    width=state.width,
    height=state.height,
    title="UI Demo",
    canvas="#app",
  )
}
