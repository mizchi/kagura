///|
fn playing_fixture(_width : Int, _height : Int) -> GameState {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  state
}

///|
fn initial_states() -> @engine.InitialStates[GameState] {
  @engine.InitialStates::new(
    default=(_width, _height) => GameState::new(seed=42),
    named=[("playing", playing_fixture)],
  ) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
