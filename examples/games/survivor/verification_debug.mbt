///|
fn gameover_fixture(width : Int, height : Int) -> SurvivorState {
  let state = SurvivorState::new()
  state.set_viewport(width, height)
  state.as_gameover()
  state
}

///|
fn initial_states() -> @engine.InitialStates[SurvivorState] {
  @engine.InitialStates::new(
    default=(width, height) => {
      let state = SurvivorState::new()
      state.set_viewport(width, height)
      state
    },
    named=[("gameover", gameover_fixture)],
  ) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
