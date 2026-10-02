///|
fn initial_states() -> @engine.InitialStates[@lib.Game] {
  let named : Array[(String, (Int, Int) -> @lib.Game)] = []
  for
    name in [
      "card_reward", "complex_reward", "inspect_card", "rest", "victory", "defeat",
      "battle_victory", "deck", "large_hand", "low_energy", "dragging",
    ] {
    named.push(
      (name, (width, height) => @lib.Game::preview(name, width, height)),
    )
  }
  @engine.InitialStates::new(
    default=(width, height) => {
      let game = @lib.Game::new()
      game.set_viewport(width, height)
      game
    },
    named~,
  ) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
