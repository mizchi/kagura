///|
fn main {
  // Native: TTF font loading requires native_runtime_hooks which is
  // incompatible with JS target in the same package. Use dot-matrix fallback.
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
