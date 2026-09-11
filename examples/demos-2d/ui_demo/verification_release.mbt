///|
fn initial_states() -> @engine.InitialStates[DemoState] {
  @engine.InitialStates::new(default=(width, height) => {
    DemoState::new(width~, height~)
  }) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
