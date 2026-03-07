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
  // 5 chars * 4.0 * scale(2.0) = 40.0
  assert_eq(w, 40.0)
  // 5.0 * scale(2.0) = 10.0
  assert_eq(h, 10.0)
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
  assert_eq(h, 5.0)
}
