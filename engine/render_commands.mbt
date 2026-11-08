///|
pub fn[T : @gfx.GraphicsDriver] render_commands(
  graphics : T,
  cmds : Array[@gfx.DrawTrianglesCommand],
  clear_color? : @gfx.Color,
  clear_enabled? : Bool,
) -> Unit raise {
  for cmd in cmds {
    @renderer2d.validate_vertex_stride(cmd.vertex_stride_hint)
  }
  let color = match clear_color {
    Some(c) => c
    None => @gfx.new_color(0.0, 0.0, 0.0, 1.0)
  }
  let clear = match clear_enabled {
    Some(c) => c
    None => true
  }
  let pass = @gfx.new_render_pass_desc(color, clear)
  graphics.begin(pass)
  for cmd in cmds {
    graphics.draw_triangles(cmd)
  }
  graphics.end(true)
}
