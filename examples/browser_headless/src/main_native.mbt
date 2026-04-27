///|
/// Headless browser: HTML + <script> → crater layout → kagura wgpu → BMP
///
/// Demonstrates the full pipeline:
/// 1. Parse HTML with <script> tags
/// 2. Execute JavaScript via V8 (modifies DOM)
/// 3. Layout via crater
/// 4. Render via kagura headless wgpu
/// 5. Save to BMP

///|
let screen_w : Int = 320

///|
let screen_h : Int = 240

///|
let html_source : String =
  #|<div style="background: #1e1e2e; padding: 16px; color: #cdd6f4; display: flex; flex-direction: column; gap: 12px;">
  #|  <div style="color: #89b4fa; background: #313244; padding: 8px;">Browser Headless Demo</div>
  #|  <div id="output" style="background: #313244; padding: 8px; color: #a6e3a1;">Loading...</div>
  #|  <script>
  #|    document.getElementById('output').textContent = 'Rendered by V8 + crater + kagura!';
  #|  </script>
  #|  <div style="display: flex; gap: 8px;">
  #|    <div style="background: #a6e3a1; padding: 4px 8px; color: #1e1e2e;">OK</div>
  #|    <div style="background: #89b4fa; padding: 4px 8px; color: #1e1e2e;">v0.1</div>
  #|  </div>
  #|</div>

///|
fn draw_frame(
  engine_ctx : @engine.EngineContext,
  html : String,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let sw = engine_ctx.screen_w.to_double()
  let sh = engine_ctx.screen_h.to_double()
  let scissor = @draw2d_ui.ScissorStack::new(
    engine_ctx.screen_w,
    engine_ctx.screen_h,
  )
  let render_ctx : @renderer.RenderContext = {
    viewport_width: sw,
    viewport_height: sh,
    root_font_size: 16.0,
    color_scheme: Dark,
  }
  let node = @renderer.render_to_node(html, render_ctx)
  let layout = @renderer.render(html, render_ctx)
  let paint_root = @paint.from_node_and_layout(node, layout)
  // Background
  let (bg_v, bg_i) = @draw2d_ui.filled_rect_vertices(0.0, 0.0, sw, sh, sw, sh)
  cmds.push(make_cmd(engine_ctx, scissor, bg_v, bg_i, 0x1e1e2e))
  // Render paint tree
  render_paint_node(cmds, engine_ctx, scissor, paint_root, 0.0, 0.0)
  cmds
}

///|
fn render_paint_node(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  scissor : @draw2d_ui.ScissorStack,
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
  // Background
  if w > 0.0 && h > 0.0 {
    let bg = paint.background_color
    if bg.a > 0.0 {
      let sw = ctx.screen_w.to_double()
      let sh = ctx.screen_h.to_double()
      let (v, i) = @draw2d_ui.filled_rect_vertices(x, y, w, h, sw, sh)
      cmds.push(make_cmd(ctx, scissor, v, i, crater_color_to_hex(bg)))
    }
  }
  // Text (dot-matrix fallback for native headless)
  match node.text {
    Some(text) =>
      if text.length() > 0 {
        let text_color = crater_color_to_hex(paint.color)
        push_dot_text(cmds, ctx, text, 10.0, x + 2.0, y + 2.0, text_color)
      }
    None => ()
  }
  // Clipping
  let clips = w > 0.0 &&
    h > 0.0 &&
    (
      node.overflow_x != @crater_types.Visible ||
      node.overflow_y != @crater_types.Visible
    )
  if clips {
    let clipped = scissor.push(
      @draw2d_ui.ScissorRect::new(
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
  // Children
  for child in node.children {
    render_paint_node(cmds, ctx, scissor, child, x, y)
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
fn push_dot_text(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  text : String,
  _size_px : Double,
  x : Double,
  y : Double,
  color_hex : Int,
) -> Unit {
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

///|
fn make_cmd(
  ctx : @engine.EngineContext,
  scissor : @draw2d_ui.ScissorStack,
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
    @gfx.blend_mode_from_int(1),
    vertices,
    indices,
    [],
    @renderer2d.color_to_uniform_dwords(
      @renderer2d.color_from_hex_alpha(color_hex, 1.0),
    ),
  )
}

///|
fn main {
  println("=== Headless Browser Demo ===")
  // Step 1: Parse HTML + execute JS via V8
  let browser = @shell.Browser::new(screen_w, screen_h)
  let v8 = @js_v8.V8JsRuntime::new_with_mock_dom(@js_v8.full_mock_dom_js())
  browser.set_js_runtime(v8.as_js_runtime())
  browser.set_html_content(html_source)
  let executed = browser.execute_scripts()
  println("Scripts executed: " + executed.to_string())
  // Step 2: Get the final HTML after JS execution
  // For now, use the original HTML (JS modified DOM but we render from HTML)
  // TODO: serialize DomTree back to HTML for re-rendering
  let render_html = html_source
  // Step 3: Initialize headless wgpu
  if !@native_hooks.initialize_headless_context(screen_w, screen_h) {
    println("FAIL: headless context init failed")
    return
  }
  // Step 4: Render
  let engine_ctx = @native_hooks.get_engine_context(screen_w, screen_h)
  let cmds = draw_frame(engine_ctx, render_html)
  let _ = @native_hooks.render_frame_from_commands(cmds, 0.0, 0.0, 0.0, 1.0)
  // Step 5: Save screenshot
  if @wgpu_native.save_screenshot("browser_output.bmp") {
    println(
      "Saved browser_output.bmp (" +
      screen_w.to_string() +
      "x" +
      screen_h.to_string() +
      ")",
    )
  } else {
    println("FAIL: could not save screenshot")
  }
  @native_hooks.shutdown_context()
  println("=== Done ===")
}
