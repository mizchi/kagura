/// HudContext: stateless drawing context for HUD widgets.
/// Wraps dst/shader/screen dimensions and provides draw helpers.

pub(all) struct HudContext {
  dst : @gfx.ImageHandle
  shader : @gfx.ShaderHandle
  screen_w : Double
  screen_h : Double
  text_renderer : @text.TextRenderer?
}

/// Convert hex color (0xRRGGBB) to @gfx.Color.
pub fn hex_color(hex : Int, alpha~ : Double = 1.0) -> @gfx.Color {
  let r = ((hex >> 16) & 0xFF).to_double() / 255.0
  let g = ((hex >> 8) & 0xFF).to_double() / 255.0
  let b = (hex & 0xFF).to_double() / 255.0
  @gfx.new_color(r, g, b, alpha)
}

/// Convert hex color to uniform dwords [R, G, B, A].
fn hex_to_uniform(hex : Int, alpha~ : Int = 255) -> Array[Int] {
  [(hex >> 16) & 0xFF, (hex >> 8) & 0xFF, hex & 0xFF, alpha]
}

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
  cmds.push(
    @debugutil.new_ndc_rect_fill_command(
      self.dst, self.shader, x, y, w, h,
      self.screen_w, self.screen_h, color, 0,
    ),
  )
}

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
        text, size, x, y, self.dst, self.shader, blend, hex_to_uniform(color_hex),
      )
      for cmd in text_cmds {
        cmds.push(cmd)
      }
    }
    None => {
      let chars : Array[Int] = []
      for ch in text {
        chars.push(ch.to_int())
      }
      let scale = size / 10.0
      // dot-matrix: centered at (cx, cy), so offset to top-left alignment
      let cx = x + (chars.length().to_double() * 4.0 * scale) / 2.0
      let cy = y + (5.0 * scale) / 2.0
      @debugutil.draw_dot_text(
        cmds, self.dst, self.shader, chars, cx, cy,
        self.screen_w, self.screen_h, hex_color(color_hex), scale,
      )
    }
  }
}

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
        text, size, x, y, self.dst, self.shader, blend, hex_to_uniform(color_hex),
      )
      for cmd in text_cmds {
        cmds.push(cmd)
      }
    }
    None => {
      let chars : Array[Int] = []
      for ch in text {
        chars.push(ch.to_int())
      }
      let scale = size / 10.0
      @debugutil.draw_dot_text(
        cmds, self.dst, self.shader, chars, cx, cy,
        self.screen_w, self.screen_h, hex_color(color_hex), scale,
      )
    }
  }
}

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
      // Dot-matrix estimation: each char is 3 wide + 1 spacing, 5 tall
      let scale = size / 10.0
      let char_count = text.iter().count()
      let w = char_count.to_double() * 4.0 * scale
      let h = 5.0 * scale
      (w, h)
    }
  }
}
