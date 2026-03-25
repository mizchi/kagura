///|
/// Headless crater paint renderer.
///
/// Renders a fixed example-com HTML to PNG using crater layout + kagura wgpu.
/// Output: crater_paint_output.png
///
/// This is a proof-of-concept for the native paint pipeline.
/// TODO: Read HTML from file, parameterize width/height/font.

///|
let screen_w : Int = 800

///|
let screen_h : Int = 600

///|
let example_html : String =
  #|<html><head><style>body{background:#eee;width:60vw;margin:15vh auto;font-family:system-ui,sans-serif}h1{font-size:1.5em}div{opacity:0.8}a:link,a:visited{color:#348}</style></head><body><div><h1>Example Domain</h1><p>This domain is for use in documentation examples without needing permission. Avoid use in operations.</p><p><a href="https://iana.org/domains/example">Learn more</a></p></div></body></html>

///|
struct RenderState {
  text_renderer : @text.TextRenderer?
}

///|
fn main {
  if not(@native_hooks.initialize_headless_context(screen_w, screen_h)) {
    println("Error: failed to initialize headless GPU context")
    return
  }

  // Try to load a system font
  let text_renderer = load_font()
  let state = RenderState::{ text_renderer, }

  // Set up font-based text metrics for crater layout
  match text_renderer {
    Some(tr) => install_font_metrics_provider(tr.font)
    None => println("[warn] No font loaded, using monospace fallback")
  }

  // Render HTML to paint tree
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let render_ctx : @renderer.RenderContext = {
    viewport_width: sw,
    viewport_height: sh,
    root_font_size: 16.0,
    color_scheme: Light,
  }
  let node = @renderer.render_to_node(example_html, render_ctx)
  let layout = @renderer.render(example_html, render_ctx)
  let paint_root = match @paint.from_node_and_layout_with_viewport(
    node, layout, 0.0, sh, 0.0,
  ) {
    Some(root) => root
    None => {
      println("Error: failed to build paint tree")
      @native_hooks.shutdown_context()
      return
    }
  }

  // Build draw commands
  let engine_ctx = @native_hooks.get_engine_context(screen_w, screen_h)
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let scissor = @draw2d_ui.ScissorStack::new(screen_w, screen_h)

  // White background
  let (bg_v, bg_i) = @draw2d_ui.filled_rect_vertices(
    0.0, 0.0, sw, sh, sw, sh,
  )
  cmds.push(make_draw_cmd(engine_ctx, scissor, bg_v, bg_i, 0xFFFFFF))

  // Render paint tree
  render_paint_node(cmds, engine_ctx, state, scissor, paint_root, 0.0, 0.0)

  println("Draw commands: " + cmds.length().to_string())

  // GPU render (render twice for double-buffered swap chain)
  let _ = @native_hooks.render_frame_from_commands(cmds, 1.0, 1.0, 1.0, 1.0)
  let _ = @native_hooks.render_frame_from_commands(cmds, 1.0, 1.0, 1.0, 1.0)

  // Read pixels and save
  if @wgpu_native.save_screenshot("crater_paint_output.bmp") {
    println("Saved crater_paint_output.bmp (" + screen_w.to_string() + "x" + screen_h.to_string() + ")")
  } else {
    println("Error: screenshot save failed")
  }

  @native_hooks.shutdown_context()
}

///|
fn install_font_metrics_provider(font : @font.TTFont) -> Unit {
  let provider = @renderer.TextMetricsProvider::new(
    fn(text, font_size, line_height, _white_space, _writing_mode) {
      let measured_width = font.measure_text(text, font_size)
      let effective_height = if line_height > 0.0 {
        line_height
      } else {
        font_size
      }
      {
        func: fn(_available_width, _available_height) {
          {
            min_width: measured_width,
            max_width: measured_width,
            min_height: effective_height,
            max_height: effective_height,
          }
        },
      }
    },
  )
  @renderer.set_text_metrics_provider(provider)
}

///|
fn load_font() -> @text.TextRenderer? {
  let candidates = [
    "/System/Library/Fonts/Supplemental/Arial.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/usr/share/fonts/liberation-sans/LiberationSans-Regular.ttf",
  ]
  for path in candidates {
    match @wgpu_native.read_file_bytes(path) {
      Some(data) =>
        match @text.parse_font_bytes(data) {
          Some(font) => {
            println("[font] Loaded: " + path)
            return Some(@text.TextRenderer::new(font, 1024, 0, 0))
          }
          None => continue
        }
      None => continue
    }
  }
  None
}

///|
fn render_paint_node(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  state : RenderState,
  scissor : @draw2d_ui.ScissorStack,
  node : @paint.PaintNode,
  parent_x : Double,
  parent_y : Double,
) -> Unit {
  if not(scissor.is_visible()) {
    return
  }
  let paint = node.paint
  if not(paint.should_render()) {
    return
  }
  let x = parent_x + node.x
  let y = parent_y + node.y
  let w = node.width
  let h = node.height
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()

  // Background fill
  if w > 0.0 && h > 0.0 {
    let bg = paint.background_color
    if bg.a > 0.0 {
      let (v, i) = @draw2d_ui.filled_rect_vertices(x, y, w, h, sw, sh)
      cmds.push(
        make_draw_cmd_alpha(
          ctx, scissor, v, i, crater_color_to_hex(bg), paint.opacity * bg.a,
        ),
      )
    }
  }

  // Text rendering
  match node.text {
    Some(text) =>
      if text.length() > 0 {
        let size_px = paint.font_size
        let text_color = crater_color_to_hex(paint.color)
        push_text(cmds, ctx, state, text, size_px, x, y, text_color)
      }
    None => ()
  }

  // Clipping
  let clips = w > 0.0 &&
    h > 0.0 &&
    (node.overflow_x != @crater_types.Visible ||
    node.overflow_y != @crater_types.Visible)
  if clips {
    let clipped = scissor.push(
      @draw2d_ui.ScissorRect::new(
        x.to_int(), y.to_int(), w.to_int(), h.to_int(),
      ),
    )
    if not(clipped) {
      scissor.pop()
      return
    }
  }
  for child in node.children {
    render_paint_node(cmds, ctx, state, scissor, child, x, y)
  }
  if clips {
    scissor.pop()
  }
}

///|
fn push_text(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  state : RenderState,
  text : String,
  size_px : Double,
  x : Double,
  y : Double,
  color_hex : Int,
) -> Unit {
  match state.text_renderer {
    Some(tr) => {
      let sw = ctx.screen_w.to_double()
      let sh = ctx.screen_h.to_double()
      let text_cmds = @draw2d_ui.render_text(
        tr, text, size_px, x, y, ctx.dst, ctx.shader, color_hex, sw, sh,
      )
      for cmd in text_cmds {
        cmds.push(cmd)
      }
    }
    None => {
      let chars : Array[Int] = []
      for ch in text {
        let code = ch.to_int()
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
      let sw = ctx.screen_w.to_double()
      let sh = ctx.screen_h.to_double()
      @debugutil.draw_dot_text(
        cmds, ctx.dst, ctx.shader, chars, cx, cy, sw, sh,
        @debugutil.color_from_hex(color_hex), scale,
      )
    }
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
fn make_draw_cmd(
  ctx : @engine.EngineContext,
  scissor : @draw2d_ui.ScissorStack,
  vertices : Array[Double],
  indices : Array[Int],
  color_hex : Int,
) -> @gfx.DrawTrianglesCommand {
  make_draw_cmd_alpha(ctx, scissor, vertices, indices, color_hex, 1.0)
}

///|
fn make_draw_cmd_alpha(
  ctx : @engine.EngineContext,
  scissor : @draw2d_ui.ScissorStack,
  vertices : Array[Double],
  indices : Array[Int],
  color_hex : Int,
  alpha : Double,
) -> @gfx.DrawTrianglesCommand {
  let sc = scissor.current()
  @gfx.new_draw_triangles_command(
    ctx.dst,
    ctx.shader,
    [sc.to_dst_region(indices.length())],
    0, 0, 0,
    @gfx.blend_mode_from_int(1),
    vertices,
    indices,
    [],
    @debugutil.color_to_uniform_dwords(
      @debugutil.color_from_hex_alpha(color_hex, alpha),
    ),
  )
}
