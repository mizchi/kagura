///|
fn[T : @gfx.GraphicsDriver] run_draw_payload_probe(graphics : T) -> Unit raise {
  graphics.initialize()
  let pass = @gfx.new_render_pass_desc(@gfx.new_color(0.0, 0.0, 0.0, 1.0), true)
  let dst = graphics.new_image(64, 64)
  let source = @asset.new_unmanaged_atlas_draw_source(dst.id)
  let shader = graphics.new_shader("runtime_smoke_payload_probe")
  let command = @draw2d.new_atlas_quad_draw_command(
    dst,
    shader,
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    0,
    7,
    11,
    @gfx.blend_mode_from_int(1),
    source,
    -0.5,
    -0.5,
    0.5,
    0.5,
    [1, 2, 3, 4],
  )
  graphics.begin(pass)
  graphics.draw_triangles(command)
  graphics.end(true)
}

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
  run_draw_payload_probe(graphics) catch {
    _ => ()
  }
  let ready = @web_hooks.is_ready()
  @web_hooks.uninstall()
  if !ready {
    panic()
  }
  println("runtime_smoke(js): ok (hooked)")
}
