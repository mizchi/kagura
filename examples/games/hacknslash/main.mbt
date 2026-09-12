///|
impl @scene.SceneGame for GameState with fn update_game(self, input) {
  self.update(input)
}

///|
impl @scene.SceneGame for GameState with fn view_game(self) {
  self.view()
}

///|
fn main {
  let state = initial_states().create_for_capture(
    width=screen_w,
    height=screen_h,
  )
  @scene.run_game(
    state,
    width=screen_w,
    height=screen_h,
    title="Hack & Slash",
    canvas="#app",
    snapshot_state=fn() { state.snapshot_state() },
    apply_viewport=fn(width, height) { state.set_viewport(width, height) },
  )
}
