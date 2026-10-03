///|
fn initial_states() -> @engine.InitialStates[@lib.Game] {
  @engine.InitialStates::new(default=(width, height) => {
    let game = @lib.Game::new_app()
    game.set_viewport(width, height)
    game
  }) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
