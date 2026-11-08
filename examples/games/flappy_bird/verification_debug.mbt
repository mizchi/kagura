///|
fn gameover_fixture(width : Int32, height : Int32) -> Game {
  let game = Game::new()
  game.set_viewport(width, height)
  game.as_gameover()
  game
}

///|
fn initial_states() -> @engine.InitialStates[Game] {
  @engine.InitialStates::new(
    default=(width, height) => {
      let game = Game::new()
      game.set_viewport(width, height)
      game
    },
    named=[("gameover", gameover_fixture)],
  ) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
