///|
impl @scene.SceneGame for SurvivorState with fn update_game(self, input) {
  self.update(input)
}

///|
impl @scene.SceneGame for SurvivorState with fn view_game(self) {
  self.view()
}

///|
fn main {
  let state = initial_states().create_for_capture(width=320, height=240)
  @scene.run_game(
    state,
    width=320,
    height=240,
    title="Survivor",
    canvas="#app",
    snapshot_state=fn() { state.snapshot_state() },
    apply_viewport=fn(width, height) { state.set_viewport(width, height) },
  )
}
