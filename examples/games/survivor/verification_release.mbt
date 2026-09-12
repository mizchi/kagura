///|
fn initial_states() -> @engine.InitialStates[SurvivorState] {
  @engine.InitialStates::new(default=(width, height) => {
    let state = SurvivorState::new()
    state.set_viewport(width, height)
    state
  }) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
