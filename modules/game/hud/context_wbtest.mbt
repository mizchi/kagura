///|
test "hex_color basic" {
  let c = hex_color(0xFF8800)
  assert_eq(c.r, 1.0)
  assert_true(c.g > 0.53 && c.g < 0.54)
  assert_eq(c.b, 0.0)
  assert_eq(c.a, 1.0)
}

///|
test "hex_color with alpha" {
  let c = hex_color(0x000000, alpha=0.5)
  assert_eq(c.r, 0.0)
  assert_eq(c.a, 0.5)
}

///|
test "hex_color white" {
  let c = hex_color(0xFFFFFF)
  assert_eq(c.r, 1.0)
  assert_eq(c.g, 1.0)
  assert_eq(c.b, 1.0)
}

///|
test "measure_text fallback" {
  let ctx : HudContext = {
    dst: @gfx.new_image_handle(0, 320, 240),
    shader: @gfx.new_shader_handle(0, ""),
    screen_w: 320.0,
    screen_h: 240.0,
    text_renderer: None,
  }
  let (w, h) = ctx.measure_text("HELLO", 20.0)
  // (12*5 - 3) * scale(2.0) = 57 * 2.0 = 114.0
  assert_eq(w, 114.0)
  // 15 * scale(2.0) = 30.0
  assert_eq(h, 30.0)
}

///|
test "measure_text empty" {
  let ctx : HudContext = {
    dst: @gfx.new_image_handle(0, 320, 240),
    shader: @gfx.new_shader_handle(0, ""),
    screen_w: 320.0,
    screen_h: 240.0,
    text_renderer: None,
  }
  let (w, h) = ctx.measure_text("", 10.0)
  assert_eq(w, 0.0)
  assert_eq(h, 0.0)
}

///|
test "append_rect_batch_geometry rebases indices" {
  let ctx : HudContext = {
    dst: @gfx.new_image_handle(1, 320, 240),
    shader: @gfx.new_shader_handle(2, "ui"),
    screen_w: 320.0,
    screen_h: 240.0,
    text_renderer: None,
  }
  let vertices : Array[Double] = []
  let indices : Array[Int] = []

  ctx.append_rect_batch_geometry(vertices, indices, 8.0, 16.0, 24.0, 32.0)
  ctx.append_rect_batch_geometry(vertices, indices, 40.0, 48.0, 12.0, 20.0)

  assert_eq(vertices.length(), 32)
  assert_eq(indices, [0, 1, 2, 2, 3, 0, 4, 5, 6, 6, 7, 4])
}

///|
test "push_rect_batch_command skips empty geometry" {
  let ctx : HudContext = {
    dst: @gfx.new_image_handle(1, 320, 240),
    shader: @gfx.new_shader_handle(2, "ui"),
    screen_w: 320.0,
    screen_h: 240.0,
    text_renderer: None,
  }
  let cmds : Array[@gfx.DrawTrianglesCommand] = []

  ctx.push_rect_batch_command(cmds, [], [], hex_color(0x00FF00))

  assert_eq(cmds.length(), 0)
}

///|
test "push_rect_batch_command builds single draw command" {
  let ctx : HudContext = {
    dst: @gfx.new_image_handle(1, 320, 240),
    shader: @gfx.new_shader_handle(2, "ui"),
    screen_w: 320.0,
    screen_h: 240.0,
    text_renderer: None,
  }
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let vertices : Array[Double] = []
  let indices : Array[Int] = []

  ctx.append_rect_batch_geometry(vertices, indices, 8.0, 16.0, 24.0, 32.0)
  ctx.append_rect_batch_geometry(vertices, indices, 40.0, 48.0, 12.0, 20.0)
  ctx.push_rect_batch_command(
    cmds,
    vertices,
    indices,
    hex_color(0x336699, alpha=0.5),
  )

  assert_eq(cmds.length(), 1)
  let cmd = cmds[0]
  assert_eq(cmd.dst.id, 1)
  assert_eq(cmd.shader.id, 2)
  assert_eq(cmd.vertex_data.length(), 32)
  assert_eq(cmd.indices.length(), 12)
  assert_eq(cmd.uniform_dwords, [51, 102, 153, 127])
}
