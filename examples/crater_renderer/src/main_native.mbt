///|
fn main {
  @native_hooks.install("Crater Renderer")
  // Native: no TTF font loading yet, use dot-matrix fallback
  let demo = DemoState::{ text_renderer: None }
  @engine.run(
    update=fn(_input) {  },
    draw=fn(ctx) { draw_frame(ctx, demo) },
    width=screen_w,
    height=screen_h,
    title="Crater Renderer (Native)",
    canvas="#app",
  )
}
