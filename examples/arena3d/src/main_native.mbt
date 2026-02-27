///|
fn main {
  @native_hooks.install("arena3d")
  let state = GameState::new()
  @engine.run(
    update=fn(input) { state.update(input) },
    draw=fn(ctx) { state.draw(ctx) },
    audio_ctx=state.audio_ctx,
    width=screen_w,
    height=screen_h,
    title="3D Arena Collector",
  )
  @native_hooks.shutdown()
  @native_hooks.uninstall()
}
