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
  let state = initial_states().create_for_capture(
    width=screen_w,
    height=screen_h,
  )
  @engine.run_game(
    state,
    width=state.width,
    height=state.height,
    title="UI Demo",
    canvas="#app",
  )
}
