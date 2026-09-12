///|
fn gameover_fixture(width : Int, height : Int) -> GameState {
  let state = GameState::new(seed=42)
  state.set_viewport(width, height)
  state.as_gameover()
  state
}

///|
fn initial_states() -> @engine.InitialStates[GameState] {
  @engine.InitialStates::new(
    default=(width, height) => {
      let state = GameState::new(seed=42)
      state.set_viewport(width, height)
      state
    },
    named=[("gameover", gameover_fixture)],
  ) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
