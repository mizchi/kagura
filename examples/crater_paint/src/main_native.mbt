///|
/// Headless crater paint renderer.
///
/// Reads HTML from an input file, renders via crater layout + kagura wgpu,
/// and writes BMP output.
///
/// Input/output paths and viewport are configured via fixed paths:
///   Input:  /tmp/crater_paint_input.html
///   Output: /tmp/crater_paint_output.bmp
///   Config: /tmp/crater_paint_config.txt (optional: "width height", default "800 600")

///|
extern "C" fn clock() -> Int64 = "clock"

///|
fn clock_ms() -> Double {
  // CLOCKS_PER_SEC is 1000000 on macOS
  clock().to_double() / 1000.0
}

///|
let default_w : Int = 800

///|
let default_h : Int = 600

///|
let input_path : String = "/tmp/crater_paint_input.html"

///|
let output_path : String = "/tmp/crater_paint_output.bmp"

///|
let config_path : String = "/tmp/crater_paint_config.txt"

///|
struct RenderState {
  text_renderer : @text.TextRenderer?
  bold_text_renderer : @text.TextRenderer?
  font_map : Map[String, @text.TextRenderer] // family name → renderer
  bold_font_map : Map[String, @text.TextRenderer]
}

///|
fn main {
  // Read viewport config
  let (screen_w, screen_h) = read_config()

  // Read HTML input
  let html = match read_file_as_string(input_path) {
    Some(s) => s
    None => {
      println("Error: cannot read " + input_path)
      return
    }
  }

  if html.length() == 0 {
    println("Error: empty input HTML")
    return
  }

  // Initialize headless GPU
  if !@native_hooks.initialize_headless_context(screen_w, screen_h) {
    println("Error: failed to initialize headless GPU context")
    return
  }

  // Load fonts (regular + bold, with family mapping)
  let text_renderer = load_font(regular_font_candidates)
  let bold_text_renderer = load_font(bold_font_candidates)
  let font_map : Map[String, @text.TextRenderer] = {}
  let bold_font_map : Map[String, @text.TextRenderer] = {}
  // Load additional fonts for family matching
  load_font_family(
    font_map,
    bold_font_map,
    "verdana",
    ["/System/Library/Fonts/Supplemental/Verdana.ttf"],
    ["/System/Library/Fonts/Supplemental/Verdana Bold.ttf"],
  )
  load_font_family(
    font_map,
    bold_font_map,
    "georgia",
    ["/System/Library/Fonts/Supplemental/Georgia.ttf"],
    ["/System/Library/Fonts/Supplemental/Georgia Bold.ttf"],
  )
  load_font_family(
    font_map,
    bold_font_map,
    "times new roman",
    ["/System/Library/Fonts/Supplemental/Times New Roman.ttf"],
    ["/System/Library/Fonts/Supplemental/Times New Roman Bold.ttf"],
  )
  let state = RenderState::{
    text_renderer,
    bold_text_renderer,
    font_map,
    bold_font_map,
  }

  // Load glyph cache from disk
  load_glyph_cache(state.text_renderer, "/tmp/crater_glyph_cache_regular.bin")
  load_glyph_cache(state.bold_text_renderer, "/tmp/crater_glyph_cache_bold.bin")

  // Install font metrics for layout (bold-aware)
  match text_renderer {
    Some(tr) =>
      match bold_text_renderer {
        Some(bold_tr) =>
          install_font_metrics_provider_with_bold(
            tr.inner.font,
            bold_tr.inner.font,
          )
        None => install_font_metrics_provider(tr.inner.font)
      }
    None => println("[warn] No font loaded, using monospace fallback")
  }

  // Render HTML → layout → paint tree
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let render_ctx : @renderer.RenderContext = {
    viewport_width: sw,
    viewport_height: sh,
    root_font_size: 16.0,
    color_scheme: Light,
  }
  // Phase 1: HTML parse
  let t0 = clock_ms()
  let doc = @html.parse_document(html)
  let t1 = clock_ms()
  // Phase 2: CSS parse + style resolution
  let prepared = @renderer.prepare_render_document(doc, render_ctx, [])
  let t2 = clock_ms()
  // Phase 3: build render node tree
  let node = @renderer.build_render_root_node(doc, render_ctx, prepared)
  let t3 = clock_ms()
  // Phase 4: layout
  let layout = @renderer.compute_layout_from_render_root(
    node, prepared, render_ctx,
  )
  let t4 = clock_ms()
  // Phase 5: paint tree
  let paint_root = match
    @paint.from_node_and_layout_with_viewport(node, layout, 0.0, sh, 0.0) {
    Some(root) => root
    None => {
      println("Error: failed to build paint tree")
      @native_hooks.shutdown_context()
      return
    }
  }
  let t5 = clock_ms()
  println(
    "[perf] html_parse=" +
    (t1 - t0).to_int().to_string() +
    "ms css+style=" +
    (t2 - t1).to_int().to_string() +
    "ms build_node=" +
    (t3 - t2).to_int().to_string() +
    "ms layout=" +
    (t4 - t3).to_int().to_string() +
    "ms paint_tree=" +
    (t5 - t4).to_int().to_string() +
    "ms total=" +
    (t5 - t0).to_int().to_string() +
    "ms",
  )
  // DOM stats
  fn count_elements(e : @html.Element) -> (Int, Int) {
    let mut total = 1
    let mut max_depth = 0
    for child in e.children {
      match child {
        @html.Node::Element(ce) => {
          let (c, d) = count_elements(ce)
          total += c
          if d + 1 > max_depth {
            max_depth = d + 1
          }
        }
        _ => ()
      }
    }
    (total, max_depth)
  }
  let (elem_count, max_depth) = count_elements(doc.root)
  println(
    "[perf] dom_elements=" +
    elem_count.to_string() +
    " max_depth=" +
    max_depth.to_string(),
  )
  println(
    "[perf] selector_build=" +
    (@renderer.perf_selector_build_us.val / 1000L).to_string() +
    "ms pre_checks=" +
    (@renderer.perf_pre_checks_us.val / 1000L).to_string() +
    "ms pseudo=" +
    (@renderer.perf_pseudo_us.val / 1000L).to_string() +
    "ms child_loop=" +
    (@renderer.perf_child_loop_us.val / 1000L).to_string() +
    "ms",
  )

  // Build draw commands
  let engine_ctx = @native_hooks.get_engine_context(screen_w, screen_h)
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let scissor = @draw2d_ui.ScissorStack::new(screen_w, screen_h)

  // Canvas background: CSS spec propagates body background to viewport
  // when html has no explicit background.
  let canvas_bg = paint_root.paint.background_color
  let canvas_hex = if canvas_bg.a > 0.0 {
    crater_color_to_hex(canvas_bg)
  } else {
    0xFFFFFF
  }
  let (bg_v, bg_i) = @draw2d_ui.filled_rect_vertices(0.0, 0.0, sw, sh, sw, sh)
  cmds.push(make_draw_cmd(engine_ctx, scissor, bg_v, bg_i, canvas_hex))

  // Render paint tree
  render_paint_node(cmds, engine_ctx, state, scissor, paint_root, 0.0, 0.0)

  // Upload glyph atlas textures to GPU before rendering
  fn upload_atlas(renderer : @text.TextRenderer?) -> Unit {
    match renderer {
      Some(tr) => {
        let dirty_pages = tr.flush_dirty_pages()
        for info in dirty_pages {
          let page_idx = info.page_id - tr.inner.base_page_id
          if page_idx >= 0 && page_idx < tr.inner.pages.length() {
            let page = tr.inner.pages[page_idx]
            @wgpu_native.begin_planned_source_image_upload(
              info.page_id,
              info.width,
              info.height,
            )
            for y = 0; y < info.height; y = y + 1 {
              for x = 0; x < info.width; x = x + 1 {
                let idx = (y * info.width + x) * 4
                @wgpu_native.set_planned_source_image_pixel(
                  info.page_id,
                  x,
                  y,
                  page.pixels[idx],
                  page.pixels[idx + 1],
                  page.pixels[idx + 2],
                  page.pixels[idx + 3],
                )
              }
            }
            @wgpu_native.end_planned_source_image_upload(info.page_id)
          }
        }
      }
      None => ()
    }
  }
  upload_atlas(state.text_renderer)
  upload_atlas(state.bold_text_renderer)
  state.font_map.each(fn(_family, tr) { upload_atlas(Some(tr)) })
  state.bold_font_map.each(fn(_family, tr) { upload_atlas(Some(tr)) })

  // Render frame
  let _ = @native_hooks.render_frame_from_commands(cmds, 1.0, 1.0, 1.0, 1.0)

  // Save glyph cache to disk for next run
  save_glyph_cache(state.text_renderer, "/tmp/crater_glyph_cache_regular.bin")
  save_glyph_cache(state.bold_text_renderer, "/tmp/crater_glyph_cache_bold.bin")

  // Save output
  if @wgpu_native.save_screenshot(output_path) {
    println("OK " + screen_w.to_string() + "x" + screen_h.to_string())
  } else {
    println("Error: screenshot save failed")
  }

  @native_hooks.shutdown_context()
}

///|
fn read_config() -> (Int, Int) {
  match read_file_as_string(config_path) {
    Some(s) => {
      let parts = s.trim().split(" ").collect()
      if parts.length() >= 2 {
        let w = @string.parse_int(parts[0]) catch {
          _ => return (default_w, default_h)
        }
        let h = @string.parse_int(parts[1]) catch {
          _ => return (default_w, default_h)
        }
        (w, h)
      } else {
        (default_w, default_h)
      }
    }
    None => (default_w, default_h)
  }
}

///|
/// Save glyph atlas (entries + pixels) to cache file.
fn save_glyph_cache(renderer : @text.TextRenderer?, path : String) -> Unit {
  match renderer {
    Some(tr) =>
      if tr.glyph_count() > 0 {
        let ints = tr.inner.pages[0].serialize()
        let bytes = ints_to_bytes(ints)
        if @wgpu_native.write_file_bytes(path, bytes) {
          println(
            "[cache] Saved " +
            tr.glyph_count().to_string() +
            " glyphs (" +
            bytes.length().to_string() +
            " bytes) to " +
            path,
          )
        }
      }
    None => ()
  }
}

///|
/// Load glyph atlas from cache file (entries + pixels).
fn load_glyph_cache(renderer : @text.TextRenderer?, path : String) -> Unit {
  match renderer {
    Some(tr) =>
      match @wgpu_native.read_file_bytes(path) {
        Some(bytes) => {
          let ints = bytes_to_ints(bytes)
          if tr.load_atlas_cache(ints) {
            println(
              "[cache] Loaded " +
              tr.glyph_count().to_string() +
              " glyphs from " +
              path,
            )
          }
        }
        None => ()
      }
    None => ()
  }
}

///|
fn ints_to_bytes(ints : Array[Int]) -> Bytes {
  let arr : Array[Byte] = []
  for v in ints {
    arr.push((v & 0xFF).to_byte())
    arr.push(((v >> 8) & 0xFF).to_byte())
    arr.push(((v >> 16) & 0xFF).to_byte())
    arr.push(((v >> 24) & 0xFF).to_byte())
  }
  Bytes::from_array(arr)
}

///|
fn bytes_to_ints(bytes : Bytes) -> Array[Int] {
  let ints : Array[Int] = []
  let count = bytes.length() / 4
  for i = 0; i < count; i = i + 1 {
    let o = i * 4
    ints.push(
      bytes[o].to_int() |
      (bytes[o + 1].to_int() << 8) |
      (bytes[o + 2].to_int() << 16) |
      (bytes[o + 3].to_int() << 24),
    )
  }
  ints
}

///|
fn read_file_as_string(path : String) -> String? {
  match @wgpu_native.read_file_bytes(path) {
    Some(bytes) => {
      let buf = StringBuilder::new()
      for i = 0; i < bytes.length(); i = i + 1 {
        buf.write_char(bytes[i].to_int().unsafe_to_char())
      }
      Some(buf.to_string())
    }
    None => None
  }
}

///|
fn install_font_metrics_provider(font : @font.TTFont) -> Unit {
  let metrics_cache : Map[String, @crater_types.MeasureFunc] = {}
  let provider = @renderer.TextMetricsProvider::new(fn(
    text,
    font_size,
    line_height,
    white_space,
    _writing_mode,
    _font_weight,
    _font_family,
  ) {
    let cache_key = text +
      "|" +
      font_size.to_string() +
      "|" +
      white_space.to_string() +
      "|" +
      line_height.to_string()
    match metrics_cache.get(cache_key) {
      Some(cached) => return cached
      None => ()
    }
    let effective_line_height = if line_height > 0.0 {
      line_height
    } else {
      font_size
    }
    let max_width = font.measure_text(text, font_size)
    // Compute min_width (widest single word)
    let words = split_words(text)
    let word_widths : Array[Double] = []
    let mut min_word_width = 0.0
    for word in words {
      if word == "\n" {
        word_widths.push(0.0)
        continue
      }
      let w = font.measure_text(word, font_size)
      word_widths.push(w)
      if w > min_word_width {
        min_word_width = w
      }
    }
    let space_w = font.measure_text(" ", font_size)
    let ws_str = white_space.to_string()
    let no_wrap = ws_str == "nowrap" || ws_str == "pre"
    let result : @crater_types.MeasureFunc = {
      func: fn(available_width, _available_height) {
        if no_wrap || available_width <= 0.0 {
          {
            min_width: min_word_width,
            max_width,
            min_height: effective_line_height,
            max_height: effective_line_height,
          }
        } else {
          // Word-wrap calculation
          let mut wrapped_lines = 0
          let mut cur_width = 0.0
          for i, word in words {
            if word == "\n" {
              wrapped_lines += 1
              cur_width = 0.0
              continue
            }
            let word_w = word_widths[i]
            if cur_width == 0.0 {
              cur_width = word_w
            } else if cur_width + space_w + word_w <= available_width + 0.01 {
              cur_width = cur_width + space_w + word_w
            } else {
              wrapped_lines += 1
              cur_width = word_w
            }
          }
          wrapped_lines += 1
          let max_h = wrapped_lines.to_double() * effective_line_height
          {
            min_width: min_word_width,
            max_width,
            min_height: effective_line_height,
            max_height: max_h,
          }
        }
      },
    }
    metrics_cache[cache_key] = result
    result
  })
  @renderer.set_text_metrics_provider(provider)
}

///|
let regular_font_candidates : Array[String] = [
  "/System/Library/Fonts/Supplemental/Arial.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
  "/usr/share/fonts/liberation-sans/LiberationSans-Regular.ttf",
]

///|
let bold_font_candidates : Array[String] = [
  "/System/Library/Fonts/Supplemental/Arial Bold.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
  "/usr/share/fonts/liberation-sans/LiberationSans-Bold.ttf",
]

///|
/// next_page_id tracks atlas page IDs to avoid texture_seed=0 collision
let next_page_id : Ref[Int] = { val: 1 }

///|
fn load_font(candidates : Array[String]) -> @text.TextRenderer? {
  for path in candidates {
    match @wgpu_native.read_file_bytes(path) {
      Some(data) =>
        match @text.parse_font_bytes(data) {
          Some(font) => {
            println("[font] Loaded: " + path)
            let page_id = next_page_id.val
            next_page_id.val = page_id + 10 // reserve range for atlas pages
            return Some(@text.TextRenderer::new(font, 1024, page_id, 0))
          }
          None => continue
        }
      None => continue
    }
  }
  None
}

///|
fn install_font_metrics_provider_with_bold(
  regular : @font.TTFont,
  bold : @font.TTFont,
) -> Unit {
  let metrics_cache : Map[String, @crater_types.MeasureFunc] = {}
  let provider = @renderer.TextMetricsProvider::new(fn(
    text,
    font_size,
    line_height,
    white_space,
    _writing_mode,
    font_weight,
    _font_family,
  ) {
    let cache_key = text +
      "|" +
      font_size.to_string() +
      "|" +
      font_weight.to_string() +
      "|" +
      white_space.to_string() +
      "|" +
      line_height.to_string()
    match metrics_cache.get(cache_key) {
      Some(cached) => return cached
      None => ()
    }
    let font = if font_weight >= 700.0 { bold } else { regular }
    let effective_line_height = if line_height > 0.0 {
      line_height
    } else {
      font_size
    }
    let max_width = font.measure_text(text, font_size)
    let words = split_words(text)
    let word_widths : Array[Double] = []
    let mut min_word_width = 0.0
    for word in words {
      if word == "\n" {
        word_widths.push(0.0)
        continue
      }
      let w = font.measure_text(word, font_size)
      word_widths.push(w)
      if w > min_word_width {
        min_word_width = w
      }
    }
    let space_w = font.measure_text(" ", font_size)
    let ws_str = white_space.to_string()
    let no_wrap = ws_str == "nowrap" || ws_str == "pre"
    let result : @crater_types.MeasureFunc = {
      func: fn(available_width, _available_height) {
        if no_wrap || available_width <= 0.0 {
          {
            min_width: min_word_width,
            max_width,
            min_height: effective_line_height,
            max_height: effective_line_height,
          }
        } else {
          let mut wrapped_lines = 0
          let mut cur_width = 0.0
          for i, word in words {
            if word == "\n" {
              wrapped_lines += 1
              cur_width = 0.0
              continue
            }
            let word_w = word_widths[i]
            if cur_width == 0.0 {
              cur_width = word_w
            } else if cur_width + space_w + word_w <= available_width + 0.01 {
              cur_width = cur_width + space_w + word_w
            } else {
              wrapped_lines += 1
              cur_width = word_w
            }
          }
          wrapped_lines += 1
          let max_h = wrapped_lines.to_double() * effective_line_height
          {
            min_width: min_word_width,
            max_width,
            min_height: effective_line_height,
            max_height: max_h,
          }
        }
      },
    }
    metrics_cache[cache_key] = result
    result
  })
  @renderer.set_text_metrics_provider(provider)
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
  if !scissor.is_visible() {
    return
  }
  let paint = node.paint
  if !paint.should_render() {
    return
  }
  // Early viewport culling: skip nodes entirely below or above viewport
  let abs_y = parent_y + node.y
  let abs_x = parent_x + node.x
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()
  if abs_y > sh ||
    abs_y + node.height < 0.0 ||
    abs_x > sw ||
    abs_x + node.width < 0.0 {
    return
  }
  let x = parent_x + node.x
  let y = parent_y + node.y
  let w = node.width
  let h = node.height
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()

  // Background fill (with border-radius support)
  if w > 0.0 && h > 0.0 {
    let bg = paint.background_color
    if bg.a > 0.0 {
      let tl = paint.border_top_left_radius
      let tr = paint.border_top_right_radius
      let br = paint.border_bottom_right_radius
      let bl = paint.border_bottom_left_radius
      let (v, i) = if tl > 0.0 || tr > 0.0 || br > 0.0 || bl > 0.0 {
        @draw2d_ui.filled_rounded_rect_vertices(
          x, y, w, h, tl, tr, br, bl, sw, sh,
        )
      } else {
        @draw2d_ui.filled_rect_vertices(x, y, w, h, sw, sh)
      }
      cmds.push(
        make_draw_cmd_alpha(
          ctx,
          scissor,
          v,
          i,
          crater_color_to_hex(bg),
          paint.opacity * bg.a,
        ),
      )
    }
  }

  // Text rendering with word wrap
  match node.text {
    Some(text) =>
      if text.length() > 0 {
        let size_px = paint.font_size
        let is_bold = paint.is_bold
        let font_family = paint.font_family
        let text_color = crater_color_to_hex(paint.color)
        // Select renderer based on font-family and weight
        let active_renderer = select_renderer(state, font_family, is_bold)
        let ascent_offset = match active_renderer {
          Some(tr) => {
            let ascent = tr.inner.font.ascent.to_double()
            let upm = tr.inner.font.units_per_em.to_double()
            ascent / upm * size_px
          }
          None => size_px * 0.8
        }
        let line_height = if paint.font_size > 0.0 {
          paint.font_size
        } else {
          16.0
        }
        // Word wrap using regular font metrics (matching layout engine)
        let max_width = w
        let words = split_words(text)
        let mut cur_x = x
        let mut cur_y = y
        // Layout wrap uses regular font (matching layout engine)
        let layout_space_w = match state.text_renderer {
          Some(tr) => tr.inner.font.measure_text(" ", size_px)
          None => size_px * 0.5
        }
        // Render advance uses actual font (bold or regular)
        let render_font = match active_renderer {
          Some(tr) => Some(tr.inner.font)
          None => None
        }
        let render_space_w = match render_font {
          Some(f) => f.measure_text(" ", size_px)
          None => size_px * 0.5
        }
        for i, word in words {
          if word == "\n" {
            cur_x = x
            cur_y = cur_y + line_height
            continue
          }
          // Layout width for wrap decision (regular font)
          let layout_word_w = match state.text_renderer {
            Some(tr) => tr.inner.font.measure_text(word, size_px)
            None => word.length().to_double() * size_px * 0.5
          }
          // Render width for cursor advance (actual font)
          let render_word_w = match render_font {
            Some(f) => f.measure_text(word, size_px)
            None => layout_word_w
          }
          // Wrap check uses layout font
          if max_width > 0.0 &&
            cur_x + layout_word_w > x + max_width &&
            cur_x > x + 0.01 {
            cur_x = x
            cur_y = cur_y + line_height
          }
          // Space before word
          if i > 0 && word != "\n" && cur_x > x + 0.01 {
            cur_x = cur_x + render_space_w
          }
          // Render word
          push_text_with_renderer(
            cmds,
            ctx,
            active_renderer,
            word,
            size_px,
            cur_x,
            cur_y + ascent_offset,
            text_color,
          )
          cur_x = cur_x + render_word_w
        }
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
  for child in node.children {
    render_paint_node(cmds, ctx, state, scissor, child, x, y)
  }
  if clips {
    scissor.pop()
  }
}

///|
fn push_text_with_renderer(
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  renderer : @text.TextRenderer?,
  text : String,
  size_px : Double,
  x : Double,
  y : Double,
  color_hex : Int,
) -> Unit {
  match renderer {
    Some(tr) => {
      let sw = ctx.screen_w.to_double()
      let sh = ctx.screen_h.to_double()
      let text_cmds = @draw2d_ui.render_text(
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
        // Swap V between top and bottom vertices of each glyph quad
        // to correct Y-mirror (font Y-up stored in Y-down atlas).
        // Each quad = 4 vertices, stride=4 (x,y,u,v):
        //   [0]=top-left, [1]=top-right, [2]=bottom-right, [3]=bottom-left
        let vdata = cmd.vertex_data
        let quad_stride = 4 * 4 // 4 vertices × 4 floats
        for q = 0; q < vdata.length(); q = q + quad_stride {
          // Swap V of vertex 0 (top-left) with vertex 3 (bottom-left)
          let v0_idx = q + 3 // v of vertex 0
          let v3_idx = q + 3 * 4 + 3 // v of vertex 3
          if v3_idx < vdata.length() {
            let tmp = vdata[v0_idx]
            vdata[v0_idx] = vdata[v3_idx]
            vdata[v3_idx] = tmp
          }
          // Swap V of vertex 1 (top-right) with vertex 2 (bottom-right)
          let v1_idx = q + 1 * 4 + 3
          let v2_idx = q + 2 * 4 + 3
          if v2_idx < vdata.length() {
            let tmp = vdata[v1_idx]
            vdata[v1_idx] = vdata[v2_idx]
            vdata[v2_idx] = tmp
          }
        }
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
fn split_words(text : String) -> Array[String] {
  let words : Array[String] = []
  let buf = StringBuilder::new()
  for c in text {
    if c == '\n' {
      if buf.to_string().length() > 0 {
        words.push(buf.to_string())
        buf.reset()
      }
      words.push("\n")
    } else if c == ' ' || c == '\t' || c == '\r' {
      if buf.to_string().length() > 0 {
        words.push(buf.to_string())
        buf.reset()
      }
    } else {
      buf.write_char(c)
    }
  }
  if buf.to_string().length() > 0 {
    words.push(buf.to_string())
  }
  words
}

///|
fn load_font_family(
  font_map : Map[String, @text.TextRenderer],
  bold_font_map : Map[String, @text.TextRenderer],
  family : String,
  regular_paths : Array[String],
  bold_paths : Array[String],
) -> Unit {
  match load_font(regular_paths) {
    Some(tr) => {
      font_map.set(family, tr)
      println("[font] Family '" + family + "' loaded")
    }
    None => ()
  }
  match load_font(bold_paths) {
    Some(tr) => bold_font_map.set(family, tr)
    None => ()
  }
}

///|
/// Select renderer based on font_family and is_bold from paint properties.
fn select_renderer(
  state : RenderState,
  font_family : String,
  is_bold : Bool,
) -> @text.TextRenderer? {
  // Try exact family match first
  if font_family.length() > 0 {
    if is_bold {
      match state.bold_font_map.get(font_family) {
        Some(tr) => return Some(tr)
        None => ()
      }
    }
    match state.font_map.get(font_family) {
      Some(tr) => return Some(tr)
      None => ()
    }
  }
  // Fallback to default
  if is_bold {
    match state.bold_text_renderer {
      Some(_) => state.bold_text_renderer
      None => state.text_renderer
    }
  } else {
    state.text_renderer
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
    0,
    0,
    0,
    @gfx.blend_mode_from_int(1),
    vertices,
    indices,
    [],
    @renderer2d.color_to_uniform_dwords(
      @renderer2d.color_from_hex_alpha(color_hex, alpha),
    ),
  )
}
