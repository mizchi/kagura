/// Panel: bordered container with optional title bar.

pub(all) struct Panel {
  x : Double
  y : Double
  width : Double
  height : Double
  bg_color : Int       // hex
  border_color : Int   // hex
  border_width : Double
  title : String       // "" = no title bar
  title_size : Double
  title_color : Int    // hex
  title_bg_color : Int // hex
}

/// Render the panel and return the content area (cx, cy, cw, ch).
pub fn Panel::render(
  self : Panel,
  ctx : HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> (Double, Double, Double, Double) {
  let bw = self.border_width
  // Background
  ctx.draw_rect(cmds, self.x, self.y, self.width, self.height, hex_color(self.bg_color, alpha=0.8))
  // Border (4 rects)
  let bc = hex_color(self.border_color)
  // Top
  ctx.draw_rect(cmds, self.x, self.y, self.width, bw, bc)
  // Bottom
  ctx.draw_rect(cmds, self.x, self.y + self.height - bw, self.width, bw, bc)
  // Left
  ctx.draw_rect(cmds, self.x, self.y, bw, self.height, bc)
  // Right
  ctx.draw_rect(cmds, self.x + self.width - bw, self.y, bw, self.height, bc)
  // Title bar
  let title_h = if self.title.length() > 0 {
    let th = self.title_size + 4.0
    ctx.draw_rect(cmds, self.x + bw, self.y + bw, self.width - bw * 2.0, th, hex_color(self.title_bg_color))
    ctx.draw_text(
      cmds, self.title, self.title_size,
      self.x + bw + 4.0, self.y + bw + 2.0,
      self.title_color,
    )
    th
  } else {
    0.0
  }
  // Content area
  let cx = self.x + bw
  let cy = self.y + bw + title_h
  let cw = self.width - bw * 2.0
  let ch = self.height - bw * 2.0 - title_h
  (cx, cy, cw, ch)
}
