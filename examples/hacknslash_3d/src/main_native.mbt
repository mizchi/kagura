///|
impl @engine.EngineGame for GameState with update_game(self, input) {
  self.update(input)
}

///|
impl @engine.EngineGame for GameState with draw_game(self, ctx) {
  self.draw(ctx)
}

///|
fn initialize_native_runtime_state(state : GameState) -> Unit {
  // Native builds keep these shared fields unset, but we still want the
  // mutable contract to match the JS runtime that fills them asynchronously.
  state.dungeon_floor_texture_image_id = None
  state.dungeon_wall_texture_image_id = None
}

///|
fn main {
  let state = GameState::new(seed=42)
  initialize_native_runtime_state(state)
  @engine.run_game(
    state,
    width=screen_w,
    height=screen_h,
    title="Hack & Slash 3D",
  )
}
