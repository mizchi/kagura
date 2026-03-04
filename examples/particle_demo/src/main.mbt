///|
fn main {
  let state = DemoState::new()
  @engine.run(
    update=fn(input) { state.update(input) },
    draw=fn(ctx) { state.draw(ctx) },
    width=screen_w,
    height=screen_h,
    title="Particle System Demo",
    canvas="#app",
  )
}
