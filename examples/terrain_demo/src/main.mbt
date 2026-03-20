///|
impl @engine.EngineGame for AppState with update_game(self, input) {
  self.update(input)
}

///|
impl @engine.EngineGame for AppState with draw_game(self, ctx) {
  self.draw(ctx)
}

///|
fn main {
  let state = AppState::new()
  @engine.run_game(
    state,
    width=screen_w,
    height=screen_h,
    title="Terrain Demo — BSP Dungeon + Instanced Enemies + Scene Transitions",
    canvas="#app",
  )
}
