fn main {
  let state = GameState::new(seed=42)
  @scene.run(
    view=fn() { state.view() },
    update=fn(input) { state.update(input) },
    width=screen_w,
    height=screen_h,
    title="Hack & Slash",
    canvas="#app",
  )
}
