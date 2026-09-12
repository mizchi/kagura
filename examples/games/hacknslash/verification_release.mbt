///|
fn initial_states() -> @engine.InitialStates[GameState] {
  @engine.InitialStates::new(default=(width, height) => {
    let state = GameState::new(seed=42)
    state.set_viewport(width, height)
    state
  }) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
