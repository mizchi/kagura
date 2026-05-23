///|
let screen_w : Int = 480

///|
let screen_h : Int = 360

///|
fn main {
  @web_hooks.install("#app")
  @engine.run(
    update=fn(_input) {  },
    draw=fn(ctx) {
      let cmds : Array[@gfx.DrawTrianglesCommand] = []
      let sw = ctx.screen_w.to_double()
      let sh = ctx.screen_h.to_double()
      let scissor = @widget2d.ScissorStack::new(ctx.screen_w, ctx.screen_h)
      let ox = 40.0 // global offset x
      let oy = 20.0 // global offset y
      // Background
      push_filled_rect(cmds, ctx, scissor, 0.0, 0.0, sw, sh, 0x222222)
      // Box 1: Blue box with red uniform border + label
      push_border(
        cmds,
        ctx,
        scissor,
        ox,
        oy,
        120.0,
        60.0,
        @widget2d.BorderWidths::uniform(3.0),
        0xCC3333,
      )
      push_filled_rect(
        cmds,
        ctx,
        scissor,
        ox + 3.0,
        oy + 3.0,
        114.0,
        54.0,
        0x3355AA,
      )
      push_dot_text(cmds, ctx, "UNIFORM BORDER", ox + 8.0, oy + 25.0, 0xFFFFFF)
      // Box 2: Green box with asymmetric border + label
      push_border(
        cmds,
        ctx,
        scissor,
        ox + 150.0,
        oy,
        140.0,
        60.0,
        { top: 1.0, right: 6.0, bottom: 1.0, left: 6.0 },
        0xFFCC00,
      )
      push_filled_rect(
        cmds,
        ctx,
        scissor,
        ox + 156.0,
        oy + 1.0,
        128.0,
        58.0,
        0x225533,
      )
      push_dot_text(cmds, ctx, "ASYMMETRIC", ox + 165.0, oy + 25.0, 0xFFCC00)
      // Scissor clipping demo
      push_filled_rect(
        cmds,
        ctx,
        scissor,
        ox,
        oy + 80.0,
        140.0,
        100.0,
        0x555555,
      )
      push_dot_text(cmds, ctx, "SCISSOR CLIP", ox + 2.0, oy + 74.0, 0xCCCCCC)
      let clip_x = ox.to_int()
      let clip_y = (oy + 80.0).to_int()
      let visible = scissor.push(
        @widget2d.ScissorRect::new(clip_x, clip_y, 140, 100),
      )
      if visible {
        push_filled_rect(
          cmds,
          ctx,
          scissor,
          ox + 10.0,
          oy + 90.0,
          200.0,
          20.0,
          0x44AAFF,
        )
        push_filled_rect(
          cmds,
          ctx,
          scissor,
          ox + 40.0,
          oy + 150.0,
          60.0,
          60.0,
          0xFF6644,
        )
        let nested_x = (ox + 20.0).to_int()
        let nested_y = (oy + 100.0).to_int()
        let _ = scissor.push(
          @widget2d.ScissorRect::new(nested_x, nested_y, 80, 60),
        )
        push_filled_rect(
          cmds,
          ctx,
          scissor,
          ox + 15.0,
          oy + 95.0,
          100.0,
          70.0,
          0xAAFF44,
        )
        scissor.pop()
      }
      scissor.pop()
      // Box 3: top-only pink border
      push_border(
        cmds,
        ctx,
        scissor,
        ox + 160.0,
        oy + 90.0,
        120.0,
        40.0,
        { top: 4.0, right: 0.0, bottom: 0.0, left: 0.0 },
        0xFF4488,
      )
      push_filled_rect(
        cmds,
        ctx,
        scissor,
        ox + 160.0,
        oy + 94.0,
        120.0,
        36.0,
        0x333344,
      )
      push_dot_text(cmds, ctx, "TOP ONLY", ox + 170.0, oy + 106.0, 0xFF88CC)
      // List items with left border
      let labels = ["ALPHA", "BETA", "GAMMA", "DELTA"]
      for i = 0; i < labels.length(); i = i + 1 {
        let by = oy + 150.0 + i.to_double() * 22.0
        push_border(
          cmds,
          ctx,
          scissor,
          ox + 160.0,
          by,
          120.0,
          20.0,
          { top: 0.0, right: 0.0, bottom: 0.0, left: 3.0 },
          0x66CCFF,
        )
        let shade = 0x2A2A2A + i * 0x080808
        push_filled_rect(cmds, ctx, scissor, ox + 163.0, by, 117.0, 20.0, shade)
        push_dot_text(cmds, ctx, labels[i], ox + 168.0, by + 7.0, 0xCCCCCC)
      }
      cmds
    },
    width=screen_w,
    height=screen_h,
    title="draw2d_ui demo",
    canvas="#app",
  )
}

///|
fn push_dot_text(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  text : String,
  x : Double,
  y : Double,
  color_hex : Int,
) -> Unit {
  let chars : Array[Int] = []
  for ch in text {
    chars.push(ch.to_int())
  }
  let scale = 1.0
  let px_size = 3.0 * scale
  let char_w = 3.0 * px_size
  let gap = px_size
  let total_w = chars.length().to_double() * char_w +
    (chars.length() - 1).to_double() * gap
  let char_h = 5.0 * px_size
  // draw_dot_text expects center coords, convert from top-left
  let cx = x + total_w / 2.0
  let cy = y + char_h / 2.0
  let frame = @renderer2d.RenderFrame2D::new(
    dst=ctx.dst,
    shader=ctx.shader,
    screen_w=ctx.screen_w,
    screen_h=ctx.screen_h,
  )
  @renderer2d.append_dot_text(
    cmds,
    frame,
    @renderer2d.DotText2D::new(
      chars~,
      cx~,
      cy~,
      color=@renderer2d.color_from_hex(color_hex),
      scale~,
    ),
  )
}

///|
fn make_cmd(
  ctx : @engine.EngineContext,
  scissor : @widget2d.ScissorStack,
  vertices : Array[Double],
  indices : Array[Int],
  color_hex : Int,
) -> @gfx.DrawTrianglesCommand {
  let sc = scissor.current()
  @gfx.new_draw_triangles_command(
    ctx.dst,
    ctx.shader,
    [sc.to_dst_region(indices.length())],
    0,
    0,
    0,
    @gfx.BlendMode::from_int(1),
    vertices,
    indices,
    [],
    @renderer2d.color_to_uniform_dwords(
      @renderer2d.color_from_hex_alpha(color_hex, 1.0),
    ),
  )
}

///|
fn push_filled_rect(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  scissor : @widget2d.ScissorStack,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  color_hex : Int,
) -> Unit {
  if !scissor.is_visible() {
    return
  }
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()
  let (v, i) = @widget2d.filled_rect_vertices(x, y, w, h, sw, sh)
  cmds.push(make_cmd(ctx, scissor, v, i, color_hex))
}

///|
fn push_border(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  scissor : @widget2d.ScissorStack,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  border : @widget2d.BorderWidths,
  color_hex : Int,
) -> Unit {
  if !scissor.is_visible() || !border.has_any() {
    return
  }
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()
  let (v, i) = @widget2d.border_vertices(x, y, w, h, border, sw, sh)
  if i.length() > 0 {
    cmds.push(make_cmd(ctx, scissor, v, i, color_hex))
  }
}
