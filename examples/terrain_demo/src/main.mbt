///|
fn main {
  let state = AppState::new()
  @engine.run(
    update=fn(input) { state.update(input) },
    draw=fn(ctx) { state.draw(ctx) },
    width=screen_w,
    height=screen_h,
    title="Terrain Demo — BSP Dungeon + Instanced Enemies + Scene Transitions",
    canvas="#app",
  )
}
