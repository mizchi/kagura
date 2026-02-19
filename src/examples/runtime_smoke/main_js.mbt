///|
fn main {
  @web_hooks.install("#app")
  let game = @core.new_noop_game(320, 240)
  let platform = @platform.create_web_canvas_platform("#app")
  let surface = platform.current_surface() catch {
    _ => @platform.create_offscreen_surface_token(320, 240)
  }
  let graphics = @gfx.create_webgpu_graphics(
    surface,
    @gfx.default_graphics_backend_options(),
  )
  @runtime.run_loop(
    game,
    platform,
    graphics,
    @core.default_run_options(),
    @runtime.default_runtime_config(),
  ) catch {
    _ => ()
  }
  let ready = @web_hooks.is_ready()
  @web_hooks.uninstall()
  if !ready {
    panic()
  }
  println("runtime_smoke(js): ok (hooked)")
}
