///|
fn initial_states() -> @engine.InitialStates[GameState] {
  @engine.InitialStates::new(
    default=(_width, _height) => GameState::new(seed=42),
  ) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
