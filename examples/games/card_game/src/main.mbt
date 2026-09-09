///|
fn main {
  let game = @lib.Game::new()
  @scene.run_game(
    game,
    width=@lib.screen_w,
    height=@lib.screen_h,
    title="Card Battle",
    canvas="#app",
  )
}
