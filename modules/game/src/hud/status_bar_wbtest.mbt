///|
test "default_status_bar fields" {
  let bar = default_status_bar()
  assert_eq(bar.width, 120.0)
  assert_eq(bar.height, 16.0)
  assert_eq(bar.ratio, 1.0)
  assert_eq(bar.fill_color, 0x00CC00)
  assert_eq(bar.label, "")
}

///|
test "StatusBar render produces commands" {
  let ctx : HudContext = {
    dst: @gfx.new_image_handle(0, 320, 240),
    shader: @gfx.new_shader_handle(0, ""),
    screen_w: 320.0,
    screen_h: 240.0,
    text_renderer: None,
  }
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let bar : StatusBar = { ..default_status_bar(), x: 10.0, y: 10.0, ratio: 0.5 }
  bar.render(ctx, cmds)
  // bg + fill = 2 commands (no border, no label)
  assert_eq(cmds.length(), 2)
}

///|
test "StatusBar render with border and label" {
  let ctx : HudContext = {
    dst: @gfx.new_image_handle(0, 320, 240),
    shader: @gfx.new_shader_handle(0, ""),
    screen_w: 320.0,
    screen_h: 240.0,
    text_renderer: None,
  }
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let bar : StatusBar = {
    ..default_status_bar(),
    x: 10.0,
    y: 10.0,
    ratio: 0.75,
    border_color: Some(0xFFFFFF),
    label: "HP",
  }
  bar.render(ctx, cmds)
  // bg(1) + fill(1) + border(4) + label_text(dot-matrix generates commands) >= 6
  assert_true(cmds.length() >= 6)
}

///|
test "StatusBar zero ratio no fill" {
  let ctx : HudContext = {
    dst: @gfx.new_image_handle(0, 320, 240),
    shader: @gfx.new_shader_handle(0, ""),
    screen_w: 320.0,
    screen_h: 240.0,
    text_renderer: None,
  }
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let bar : StatusBar = { ..default_status_bar(), ratio: 0.0 }
  bar.render(ctx, cmds)
  // bg only, no fill (ratio=0)
  assert_eq(cmds.length(), 1)
}

///|
test "clamp method" {
  assert_eq(0.5.clamp(min=0.0, max=1.0), 0.5)
  assert_eq((-0.1).clamp(min=0.0, max=1.0), 0.0)
  assert_eq(1.5.clamp(min=0.0, max=1.0), 1.0)
}
