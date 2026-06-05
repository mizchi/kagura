///|
/// Frame profiler data for lightweight in-game overlays.
pub(all) struct FrameProfile {
  fps : Double
  frame_time_ms : Double
  update_ms : Double
  draw_ms : Double
  gpu_frame_ms : Double
  draw_calls : Int
  vertex_count : Int
  asset_inflight : Int
} derive(Debug)

///|
pub impl Show for FrameProfile with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn default_frame_profile() -> FrameProfile {
  {
    fps: 0.0,
    frame_time_ms: 0.0,
    update_ms: 0.0,
    draw_ms: 0.0,
    gpu_frame_ms: 0.0,
    draw_calls: 0,
    vertex_count: 0,
    asset_inflight: 0,
  }
}

///|
fn profiler_frame(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  screen_w : Double,
  screen_h : Double,
) -> @renderer2d.RenderFrame2D {
  @renderer2d.RenderFrame2D::new(
    dst~,
    shader~,
    screen_w=screen_w.to_int(),
    screen_h=screen_h.to_int(),
  )
}

///|
fn append_profiler_text(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  chars : Array[Int],
  cx : Double,
  cy : Double,
  color : @gfx.Color,
  scale : Double,
) -> Unit {
  @renderer2d.append_dot_text(
    cmds,
    frame,
    @renderer2d.DotText2D::new(chars~, cx~, cy~, color~, scale~),
  )
}

///|
fn append_profiler_number(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  number : Int,
  cx : Double,
  cy : Double,
  color : @gfx.Color,
  scale : Double,
) -> Unit {
  @renderer2d.append_number(
    cmds,
    frame,
    @renderer2d.Number2D::new(number~, cx~, cy~, color~, scale~),
  )
}

///|
pub fn build_profiler_hud(
  cmds : Array[@gfx.DrawTrianglesCommand],
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  profile : FrameProfile,
  screen_w : Double,
  screen_h : Double,
) -> Unit {
  let frame = profiler_frame(dst, shader, screen_w, screen_h)
  let scale = 1.0
  let line_h = 20.0
  let margin = 8.0
  let x = screen_w - 80.0
  let mut y = margin + 10.0
  let bg_color = @renderer2d.color_from_hex_alpha(0x000000, 0.5)
  let text_color = @renderer2d.color_from_hex_alpha(0x00FF00, 0.9)
  let warn_color = @renderer2d.color_from_hex_alpha(0xFFFF00, 0.9)
  @renderer2d.append_rect_fill(
    cmds,
    frame,
    @renderer2d.RectFill2D::new(
      x=screen_w - 160.0,
      y=0.0,
      w=160.0,
      h=margin + line_h * 8.0 + margin,
      color=bg_color,
    ),
  )
  let fps_int = profile.fps.to_int()
  let fps_color = if fps_int < 30 { warn_color } else { text_color }
  append_profiler_text(
    cmds,
    frame,
    [70, 80, 83],
    x - 30.0,
    y,
    text_color,
    scale,
  )
  append_profiler_number(cmds, frame, fps_int, x + 20.0, y, fps_color, scale)
  y = y + line_h
  append_profiler_text(cmds, frame, [70, 84], x - 30.0, y, text_color, scale)
  append_profiler_number(
    cmds,
    frame,
    profile.frame_time_ms.to_int(),
    x + 20.0,
    y,
    text_color,
    scale,
  )
  y = y + line_h
  append_profiler_text(cmds, frame, [85, 80], x - 30.0, y, text_color, scale)
  append_profiler_number(
    cmds,
    frame,
    profile.update_ms.to_int(),
    x + 20.0,
    y,
    text_color,
    scale,
  )
  y = y + line_h
  append_profiler_text(cmds, frame, [68, 82], x - 30.0, y, text_color, scale)
  append_profiler_number(
    cmds,
    frame,
    profile.draw_ms.to_int(),
    x + 20.0,
    y,
    text_color,
    scale,
  )
  y = y + line_h
  append_profiler_text(cmds, frame, [71, 80], x - 30.0, y, text_color, scale)
  append_profiler_number(
    cmds,
    frame,
    profile.gpu_frame_ms.to_int(),
    x + 20.0,
    y,
    text_color,
    scale,
  )
  y = y + line_h
  append_profiler_text(cmds, frame, [68, 67], x - 30.0, y, text_color, scale)
  append_profiler_number(
    cmds,
    frame,
    profile.draw_calls,
    x + 20.0,
    y,
    text_color,
    scale,
  )
  y = y + line_h
  append_profiler_text(cmds, frame, [86, 84], x - 30.0, y, text_color, scale)
  append_profiler_number(
    cmds,
    frame,
    profile.vertex_count,
    x + 20.0,
    y,
    text_color,
    scale,
  )
  y = y + line_h
  append_profiler_text(cmds, frame, [65, 83], x - 30.0, y, text_color, scale)
  append_profiler_number(
    cmds,
    frame,
    profile.asset_inflight,
    x + 20.0,
    y,
    text_color,
    scale,
  )
}
