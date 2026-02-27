///|
fn main {
  @web_hooks.install("#app")
  let state = GameState::new()
  @engine.run(
    update=fn(input) { state.update(input) },
    draw=fn(ctx) { state.draw(ctx) },
    audio_ctx=state.audio_ctx,
    width=screen_w,
    height=screen_h,
    title="arena3d",
    canvas="#app",
  )
}
