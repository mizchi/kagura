///|
fn gameover_fixture(width : Int, height : Int) -> ShowcaseState {
  let state = ShowcaseState::new()
  state.set_viewport(width, height)
  state.as_gameover()
  state
}

///|
fn initial_states() -> @engine.InitialStates[ShowcaseState] {
  @engine.InitialStates::new(
    default=(width, height) => {
      let state = ShowcaseState::new()
      state.set_viewport(width, height)
      state
    },
    named=[("gameover", gameover_fixture)],
  ) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
