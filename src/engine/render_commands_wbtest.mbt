///|
fn test_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> @gfx.DrawTrianglesCommand {
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [@gfx.new_dst_region(0, 0, 64, 64, 3)],
    0,
    0,
    0,
    @gfx.blend_mode_from_int(1),
    [],
    [],
    [],
    [],
  )
}

///|
test "render_commands flushes draw commands through graphics driver" {
  let graphics = @gfx.create_null_graphics(320, 240)
  graphics.initialize()
  let dst = graphics.new_image(64, 64)
  let shader = graphics.new_shader("engine-render-command")
  render_commands(graphics, [test_draw_command(dst, shader)]) catch {
    _ => panic()
  }
  assert_eq(graphics.begin_count, 1)
  assert_eq(graphics.draw_count, 1)
  assert_eq(graphics.end_count, 1)
}
