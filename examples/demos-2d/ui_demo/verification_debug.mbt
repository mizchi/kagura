///|
/// Named fixtures are ordinary MoonBit constructors, removed from release builds.
fn last_button_focused_fixture(width : Int, height : Int) -> DemoState {
  let game = DemoState::new(width~, height~)
  let _ = game.focus_mgr.focus(game.focus_ids[game.focus_ids.length() - 1])
  game
}

///|
fn initial_states() -> @engine.InitialStates[DemoState] {
  @engine.InitialStates::new(
    default=(width, height) => DemoState::new(width~, height~),
    named=[("last_button_focused", last_button_focused_fixture)],
  ) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
