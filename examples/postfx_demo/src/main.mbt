///|
fn main {
  let state = DemoState::new()
  @engine.run(
    update=fn(input) { state.update(input) },
    draw=fn(ctx) { state.draw(ctx) },
    width=screen_w,
    height=screen_h,
    title="Post-Processing Effects Demo",
    canvas="#app",
  )
}
