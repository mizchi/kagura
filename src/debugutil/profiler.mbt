///|
/// Frame profiler data. Collect timing in update/draw and pass to `build_profiler_hud`.
pub(all) struct FrameProfile {
  fps : Double
  frame_time_ms : Double
  update_ms : Double
  draw_ms : Double
  draw_calls : Int
  vertex_count : Int
  asset_inflight : Int
} derive(Show)

///|
pub fn default_frame_profile() -> FrameProfile {
  {
    fps: 0.0,
    frame_time_ms: 0.0,
    update_ms: 0.0,
    draw_ms: 0.0,
    draw_calls: 0,
    vertex_count: 0,
    asset_inflight: 0,
  }
}

///|
/// Build a profiler HUD overlay in the top-right corner.
/// Uses dot-matrix glyphs — no font dependency.
pub fn build_profiler_hud(
  cmds : Array[@gfx.DrawTrianglesCommand],
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  profile : FrameProfile,
  screen_w : Double,
  screen_h : Double,
) -> Unit {
  let scale = 1.0
  let line_h = 20.0
  let margin = 8.0
  let x = screen_w - 80.0
  let mut y = margin + 10.0
  let bg_color = color_from_hex_alpha(0x000000, 0.5)
  let text_color = color_from_hex_alpha(0x00FF00, 0.9)
  let warn_color = color_from_hex_alpha(0xFFFF00, 0.9)
  // Background
  cmds.push(
    new_ndc_rect_fill_command(
      dst,
      shader,
      screen_w - 160.0,
      0.0,
      160.0,
      margin + line_h * 7.0 + margin,
      screen_w,
      screen_h,
      bg_color,
      0,
    ),
  )
  // FPS (yellow if < 30)
  let fps_int = profile.fps.to_int()
  let fps_color = if fps_int < 30 { warn_color } else { text_color }
  // "FPS" label + number
  draw_dot_text(
    cmds,
    dst,
    shader,
    [70, 80, 83],
    x - 30.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  draw_number(
    cmds,
    dst,
    shader,
    fps_int,
    x + 20.0,
    y,
    screen_w,
    screen_h,
    fps_color,
    scale,
  )
  y = y + line_h
  // Frame time
  draw_dot_text(
    cmds,
    dst,
    shader,
    [70, 84],
    x - 30.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  draw_number(
    cmds,
    dst,
    shader,
    profile.frame_time_ms.to_int(),
    x + 20.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  y = y + line_h
  // Update ms
  draw_dot_text(
    cmds,
    dst,
    shader,
    [85, 80],
    x - 30.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  draw_number(
    cmds,
    dst,
    shader,
    profile.update_ms.to_int(),
    x + 20.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  y = y + line_h
  // Draw ms
  draw_dot_text(
    cmds,
    dst,
    shader,
    [68, 82],
    x - 30.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  draw_number(
    cmds,
    dst,
    shader,
    profile.draw_ms.to_int(),
    x + 20.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  y = y + line_h
  // Draw calls
  draw_dot_text(
    cmds,
    dst,
    shader,
    [68, 67],
    x - 30.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  draw_number(
    cmds,
    dst,
    shader,
    profile.draw_calls,
    x + 20.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  y = y + line_h
  // Vertices
  draw_dot_text(
    cmds,
    dst,
    shader,
    [86, 84],
    x - 30.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  draw_number(
    cmds,
    dst,
    shader,
    profile.vertex_count,
    x + 20.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  y = y + line_h
  // Asset inflight
  draw_dot_text(
    cmds,
    dst,
    shader,
    [65, 83],
    x - 30.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
  draw_number(
    cmds,
    dst,
    shader,
    profile.asset_inflight,
    x + 20.0,
    y,
    screen_w,
    screen_h,
    text_color,
    scale,
  )
}
