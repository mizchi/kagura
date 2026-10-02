///|
fn main {
  let (width, height) = default_viewport()
  let game = initial_states().create_for_capture(width~, height~)
  @scene.run_game(
    game,
    width~,
    height~,
    title="Ember Ascent",
    canvas="#app",
    snapshot_state=fn() { game.snapshot_state() },
    apply_viewport=fn(width, height) { game.set_viewport(width, height) },
  )
}
