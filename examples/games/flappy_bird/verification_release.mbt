///|
fn initial_states() -> @engine.InitialStates[Game] {
  @engine.InitialStates::new(default=(width, height) => {
    let game = Game::new()
    game.set_viewport(width, height)
    game
  }) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
