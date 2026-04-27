///|
/// HudContext: stateless drawing context for HUD widgets.
/// Wraps dst/shader/screen dimensions and provides draw helpers.
pub(all) struct HudContext {
  dst : @gfx.ImageHandle
  shader : @gfx.ShaderHandle
  screen_w : Double
  screen_h : Double
  text_renderer : @text.TextRenderer?
}

///|
/// Convert hex color (0xRRGGBB) to @gfx.Color.
pub fn hex_color(hex : Int, alpha? : Double = 1.0) -> @gfx.Color {
  @renderer2d.color_from_hex_alpha(hex, alpha)
}

///|
/// Convert hex color to uniform dwords [R, G, B, A].
fn hex_to_uniform(hex : Int, alpha? : Int = 255) -> Array[Int] {
  [(hex >> 16) & 0xFF, (hex >> 8) & 0xFF, hex & 0xFF, alpha]
}

///|
fn HudContext::render_frame(self : HudContext) -> @renderer2d.RenderFrame2D {
  @renderer2d.RenderFrame2D::new(
    dst=self.dst,
    shader=self.shader,
    screen_w=self.screen_w.to_int(),
    screen_h=self.screen_h.to_int(),
  )
}

///|
/// Append rectangle geometry into a shared HUD batch.
pub fn HudContext::append_rect_batch_geometry(
  self : HudContext,
  vertices : Array[Double],
  indices : Array[Int],
  x : Double,
  y : Double,
  w : Double,
  h : Double,
) -> Unit {
  @renderer2d.append_rect_fill_geometry(
    vertices,
    indices,
    self.render_frame(),
    @renderer2d.RectFill2D::new(x~, y~, w~, h~, color=@renderer2d.color_white()),
  )
}

///|
/// Flush shared rectangle geometry as a single HUD draw command.
pub fn HudContext::push_rect_batch_command(
  self : HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
  vertices : Array[Double],
  indices : Array[Int],
  color : @gfx.Color,
) -> Unit {
  if indices.is_empty() {
    return
  }
  @renderer2d.append_primitive_batch(
    cmds,
    self.render_frame(),
    vertices,
    indices,
    color,
  )
}

///|
/// Draw a filled rectangle in pixel coordinates.
pub fn HudContext::draw_rect(
  self : HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  color : @gfx.Color,
) -> Unit {
  @renderer2d.append_rect_fill(
    cmds,
    self.render_frame(),
    @renderer2d.RectFill2D::new(x~, y~, w~, h~, color~),
  )
}

///|
/// Draw text at pixel coordinates.
/// Falls back to dot-matrix when TextRenderer is unavailable.
pub fn HudContext::draw_text(
  self : HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
  text : String,
  size : Double,
  x : Double,
  y : Double,
  color_hex : Int,
) -> Unit {
  match self.text_renderer {
    Some(tr) => {
      let blend = @gfx.blend_mode_from_int(1)
      let text_cmds = tr.render_text(
        text,
        size,
        x,
        y,
        self.dst,
        self.shader,
        blend,
        hex_to_uniform(color_hex),
      )
      for cmd in text_cmds {
        cmds.push(cmd)
      }
    }
    None => {
      let chars : Array[Int] = []
      for ch in text {
        let c = ch.to_int()
        // Auto-uppercase: a-z (97-122) → A-Z (65-90)
        let c = if c >= 97 && c <= 122 { c - 32 } else { c }
        chars.push(c)
      }
      if chars.length() == 0 {
        return
      }
      let scale = size / 10.0
      // dot-matrix: px_size=3*scale, char_w=9*scale, gap=3*scale
      // total_w = n*9*scale + (n-1)*3*scale = (12n-3)*scale
      // char_h = 5*3*scale = 15*scale
      let n = chars.length().to_double()
      let total_w = (12.0 * n - 3.0) * scale
      let total_h = 15.0 * scale
      let cx = x + total_w / 2.0
      let cy = y + total_h / 2.0
      @renderer2d.append_dot_text(
        cmds,
        self.render_frame(),
        @renderer2d.DotText2D::new(
          chars~,
          cx~,
          cy~,
          color=hex_color(color_hex),
          scale~,
        ),
      )
    }
  }
}

///|
/// Draw text centered at (cx, cy).
pub fn HudContext::draw_text_centered(
  self : HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
  text : String,
  size : Double,
  cx : Double,
  cy : Double,
  color_hex : Int,
) -> Unit {
  match self.text_renderer {
    Some(tr) => {
      let metrics = tr.measure(text, size)
      let x = cx - metrics.width / 2.0
      let y = cy - metrics.height / 2.0
      let blend = @gfx.blend_mode_from_int(1)
      let text_cmds = tr.render_text(
        text,
        size,
        x,
        y,
        self.dst,
        self.shader,
        blend,
        hex_to_uniform(color_hex),
      )
      for cmd in text_cmds {
        cmds.push(cmd)
      }
    }
    None => {
      let chars : Array[Int] = []
      for ch in text {
        let c = ch.to_int()
        let c = if c >= 97 && c <= 122 { c - 32 } else { c }
        chars.push(c)
      }
      let scale = size / 10.0
      @renderer2d.append_dot_text(
        cmds,
        self.render_frame(),
        @renderer2d.DotText2D::new(
          chars~,
          cx~,
          cy~,
          color=hex_color(color_hex),
          scale~,
        ),
      )
    }
  }
}

///|
/// Measure text dimensions. Returns (width, height).
pub fn HudContext::measure_text(
  self : HudContext,
  text : String,
  size : Double,
) -> (Double, Double) {
  match self.text_renderer {
    Some(tr) => {
      let metrics = tr.measure(text, size)
      (metrics.width, metrics.height)
    }
    None => {
      // Dot-matrix: px_size=3*scale, char_w=9*scale, gap=3*scale
      let scale = size / 10.0
      let n = text.iter().count().to_double()
      if n <= 0.0 {
        return (0.0, 0.0)
      }
      let w = (12.0 * n - 3.0) * scale
      let h = 15.0 * scale
      (w, h)
    }
  }
}
