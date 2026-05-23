///|
let screen_w : Int = 800

///|
let screen_h : Int = 480

///|
let demo_html : String =
  #|<div style="background: #0d1117; padding: 12px; color: #c9d1d9; display: flex; flex-direction: column; gap: 12px;">
  #|  <div style="display: flex; background: #161b22; padding: 8px 12px;">
  #|    <div style="color: #58a6ff; margin-right: 16px;">Home</div>
  #|    <div style="color: #8b949e; margin-right: 16px;">Docs</div>
  #|    <div style="color: #8b949e; margin-right: 16px;">API</div>
  #|    <div style="color: #8b949e;">About</div>
  #|  </div>
  #|  <div style="display: flex; gap: 12px;">
  #|    <div style="display: flex; flex-direction: column; gap: 8px; width: 150px;">
  #|      <div style="display: flex; flex-direction: column; background: #161b22; padding: 10px; gap: 3px;">
  #|        <div style="color: #58a6ff;">Sidebar</div>
  #|        <div style="color: #8b949e; border-left: 3px solid #58a6ff; padding-left: 6px;">Overview</div>
  #|        <div style="color: #c9d1d9; border-left: 3px solid #388bfd; padding-left: 6px; background: #1c2333;">Getting Started</div>
  #|        <div style="color: #8b949e; border-left: 3px solid #58a6ff; padding-left: 6px;">Components</div>
  #|        <div style="color: #8b949e; border-left: 3px solid #58a6ff; padding-left: 6px;">Themes</div>
  #|      </div>
  #|      <div style="display: flex; flex-direction: column; background: #161b22; padding: 10px; gap: 4px;">
  #|        <div style="color: #f0883e;">Status</div>
  #|        <div style="background: #238636; padding: 3px 6px; color: #ffffff;">Build: OK</div>
  #|        <div style="background: #1f6feb; padding: 3px 6px; color: #ffffff;">v0.9.0</div>
  #|      </div>
  #|    </div>
  #|    <div style="display: flex; flex-direction: column; gap: 10px; flex: 1;">
  #|      <div style="display: flex; flex-direction: column; background: #161b22; padding: 12px; gap: 6px;">
  #|        <div style="color: #c9d1d9;">Crater Renderer Demo</div>
  #|        <div style="color: #8b949e;">HTML/CSS to WebGPU via kagura + crater</div>
  #|        <div style="display: flex; gap: 6px;">
  #|          <div style="background: #238636; padding: 4px 10px; color: #ffffff;">Install</div>
  #|          <div style="background: #21262d; padding: 4px 10px; border-left: 2px solid #30363d; color: #c9d1d9;">Source</div>
  #|          <div style="background: #21262d; padding: 4px 10px; border-left: 2px solid #30363d; color: #c9d1d9;">Docs</div>
  #|        </div>
  #|      </div>
  #|      <div style="display: flex; gap: 6px;">
  #|        <div style="display: flex; flex-direction: column; background: #161b22; padding: 10px; flex: 1; border-top: 3px solid #238636; gap: 3px;">
  #|          <div style="color: #238636;">1243</div>
  #|          <div style="color: #8b949e;">Tests Pass</div>
  #|        </div>
  #|        <div style="display: flex; flex-direction: column; background: #161b22; padding: 10px; flex: 1; border-top: 3px solid #1f6feb; gap: 3px;">
  #|          <div style="color: #1f6feb;">35</div>
  #|          <div style="color: #8b949e;">Examples</div>
  #|        </div>
  #|        <div style="display: flex; flex-direction: column; background: #161b22; padding: 10px; flex: 1; border-top: 3px solid #f0883e; gap: 3px;">
  #|          <div style="color: #f0883e;">3</div>
  #|          <div style="color: #8b949e;">Layers</div>
  #|        </div>
  #|      </div>
  #|      <div style="display: flex; flex-direction: column; background: #161b22; padding: 10px; border-left: 4px solid #da3633; gap: 3px;">
  #|        <div style="color: #f85149;">Note</div>
  #|        <div style="color: #8b949e;">Proof-of-concept: TrueType via SVG rasterization</div>
  #|      </div>
  #|    </div>
  #|  </div>
  #|  <div style="display: flex; background: #161b22; padding: 6px 12px;">
  #|    <div style="color: #484f58; margin-right: 16px;">crater + kagura</div>
  #|    <div style="color: #484f58; margin-right: 16px;">MoonBit</div>
  #|    <div style="color: #484f58;">WebGPU</div>
  #|  </div>
  #|</div>

///|
struct DemoState {
  text_renderer : @text.TextRenderer?
}

///|
fn draw_frame(
  engine_ctx : @engine.EngineContext,
  demo : DemoState,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let sw = engine_ctx.screen_w.to_double()
  let sh = engine_ctx.screen_h.to_double()
  let scissor = @widget2d.ScissorStack::new(
    engine_ctx.screen_w,
    engine_ctx.screen_h,
  )
  let render_ctx : @renderer.RenderContext = {
    viewport_width: sw,
    viewport_height: sh,
    root_font_size: 16.0,
    color_scheme: Light,
  }
  let node = @renderer.render_to_node(demo_html, render_ctx)
  let layout = @renderer.render(demo_html, render_ctx)
  let paint_root = @paint.from_node_and_layout(node, layout)
  let (bg_v, bg_i) = @widget2d.filled_rect_vertices(0.0, 0.0, sw, sh, sw, sh)
  cmds.push(make_cmd(engine_ctx, scissor, bg_v, bg_i, 0x000000))
  render_paint_node(cmds, engine_ctx, demo, scissor, paint_root, 0.0, 0.0)
  cmds
}

///|
fn render_paint_node(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  demo : DemoState,
  scissor : @widget2d.ScissorStack,
  node : @paint.PaintNode,
  parent_x : Double,
  parent_y : Double,
) -> Unit {
  if !scissor.is_visible() {
    return
  }
  let x = parent_x + node.x
  let y = parent_y + node.y
  let w = node.width
  let h = node.height
  let paint = node.paint
  if w > 0.0 && h > 0.0 {
    let bg = paint.background_color
    if bg.a > 0.0 {
      let sw = ctx.screen_w.to_double()
      let sh = ctx.screen_h.to_double()
      let (v, i) = @widget2d.filled_rect_vertices(x, y, w, h, sw, sh)
      cmds.push(make_cmd(ctx, scissor, v, i, crater_color_to_hex(bg)))
    }
  }
  match node.text {
    Some(text) =>
      if text.length() > 0 {
        let text_color = crater_color_to_hex(paint.color)
        push_text(cmds, ctx, demo, text, 10.0, x + 2.0, y + 2.0, text_color)
      }
    None => ()
  }
  let clips = w > 0.0 &&
    h > 0.0 &&
    (
      node.overflow_x != @crater_types.Visible ||
      node.overflow_y != @crater_types.Visible
    )
  if clips {
    let clipped = scissor.push(
      @widget2d.ScissorRect::new(
        x.to_int(),
        y.to_int(),
        w.to_int(),
        h.to_int(),
      ),
    )
    if !clipped {
      scissor.pop()
      return
    }
  }
  for child in node.children {
    render_paint_node(cmds, ctx, demo, scissor, child, x, y)
  }
  if clips {
    scissor.pop()
  }
}

///|
fn crater_color_to_hex(color : @crater_types.Color) -> Int {
  let r = if color.r > 255 { 255 } else if color.r < 0 { 0 } else { color.r }
  let g = if color.g > 255 { 255 } else if color.g < 0 { 0 } else { color.g }
  let b = if color.b > 255 { 255 } else if color.b < 0 { 0 } else { color.b }
  (r << 16) | (g << 8) | b
}

///|
fn push_text(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  demo : DemoState,
  text : String,
  size_px : Double,
  x : Double,
  y : Double,
  color_hex : Int,
) -> Unit {
  match demo.text_renderer {
    Some(tr) => {
      let sw = ctx.screen_w.to_double()
      let sh = ctx.screen_h.to_double()
      let text_cmds = @widget2d.render_text(
        tr,
        text,
        size_px,
        x,
        y,
        ctx.dst,
        ctx.shader,
        color_hex,
        sw,
        sh,
      )
      for cmd in text_cmds {
        cmds.push(cmd)
      }
    }
    None => {
      let chars : Array[Int] = []
      for ch in text {
        let mut code = ch.to_int()
        if code >= 97 && code <= 122 {
          code = code - 32
        }
        if code >= 32 && code < 128 {
          chars.push(code)
        }
      }
      if chars.length() == 0 {
        return
      }
      let scale = 2.0
      let px_size = 3.0 * scale
      let char_w = 3.0 * px_size
      let gap = px_size
      let total_w = chars.length().to_double() * char_w +
        (chars.length() - 1).to_double() * gap
      let char_h = 5.0 * px_size
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
  }
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
