///|
fn main {
  let game = @lib.Game::new()
  @scene.run_game(
    game,
    width=@lib.screen_w,
    height=@lib.screen_h,
    title="Card Battle",
    canvas="#app",
    snapshot_state=fn() { game.snapshot_state() },
    apply_viewport=fn(width, height) { game.set_viewport(width, height) },
  )
}
