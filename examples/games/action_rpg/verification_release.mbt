///|
fn initial_states() -> @engine.InitialStates[ShowcaseState] {
  @engine.InitialStates::new(default=(width, height) => {
    let state = ShowcaseState::new()
    state.set_viewport(width, height)
    state
  }) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
