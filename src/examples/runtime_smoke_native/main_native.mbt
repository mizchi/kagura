///|
fn run_runtime_contract_smoke() -> Unit raise {
  let game = @core.new_noop_game(320, 240)
  let platform = @platform.create_desktop_glfw_platform()
  let surface = platform.current_surface() catch {
    _ => @platform.create_offscreen_surface_token(320, 240)
  }
  let graphics = @gfx.create_wgpu_native_graphics(
    surface,
    @gfx.default_graphics_backend_options(),
  )
  @runtime.run_loop(
    game,
    platform,
    graphics,
    @core.default_run_options(),
    @runtime.default_runtime_config(),
  )
}

///|
fn run_with_real_native_hooks() -> Bool {
  @native_hooks.install("runtime_smoke_native")
  run_runtime_contract_smoke() catch {
    _ => ()
  }
  let ready = @native_hooks.is_ready()
  @native_hooks.shutdown()
  @native_hooks.uninstall()
  ready
}

///|
fn main {
  let native_ready = run_with_real_native_hooks()
  if !native_ready {
    panic()
  }
  println("runtime_smoke_native: ok (real)")
}
