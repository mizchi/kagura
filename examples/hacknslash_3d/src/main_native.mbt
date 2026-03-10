///|
fn main {
  let state = GameState::new(seed=42)
  @engine.run(
    update=fn(input) { state.update(input) },
    draw=fn(ctx) { state.draw(ctx) },
    width=screen_w,
    height=screen_h,
    title="Hack & Slash 3D",
  )
}
