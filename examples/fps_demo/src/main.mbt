///|
fn main {
  let state = GameState::new()
  @engine.run(
    update=fn(input) { state.update(input) },
    draw=fn(ctx) { state.draw(ctx) },
    width=screen_w,
    height=screen_h,
    title="FPS Demo",
    canvas="#app",
  )
}
