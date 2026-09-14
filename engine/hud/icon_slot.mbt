///|
/// IconSlot: square slot for skill/item icons with cooldown overlay.
pub(all) struct IconSlot {
  x : Double
  y : Double
  size : Double
  bg_color : Int // hex
  border_color : Int // hex
  border_width : Double
  cooldown_ratio : Double // 0.0=ready, 1.0=full cooldown
  cooldown_color : Int // hex
  label : String // hotkey display "1", "Q"
  label_size : Double
  label_color : Int // hex
  selected : Bool
  selected_color : Int // hex
}

///|
/// Render: background -> border -> cooldown overlay -> label
pub fn IconSlot::render(
  self : IconSlot,
  ctx : HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let s = self.size
  // Background
  ctx.draw_rect(cmds, self.x, self.y, s, s, hex_color(self.bg_color, alpha=0.8))
  // Border
  let bc = if self.selected { self.selected_color } else { self.border_color }
  let bw = self.border_width
  let color = hex_color(bc)
  // Top
  ctx.draw_rect(cmds, self.x, self.y, s, bw, color)
  // Bottom
  ctx.draw_rect(cmds, self.x, self.y + s - bw, s, bw, color)
  // Left
  ctx.draw_rect(cmds, self.x, self.y, bw, s, color)
  // Right
  ctx.draw_rect(cmds, self.x + s - bw, self.y, bw, s, color)
  // Cooldown overlay (from bottom to top)
  let cd = self.cooldown_ratio.clamp(min=0.0, max=1.0)
  if cd > 0.0 {
    let cd_h = s * cd
    ctx.draw_rect(
      cmds,
      self.x,
      self.y + s - cd_h,
      s,
      cd_h,
      hex_color(self.cooldown_color, alpha=0.5),
    )
  }
  // Label (bottom-left corner)
  if self.label.length() > 0 {
    ctx.draw_text(
      cmds,
      self.label,
      self.label_size,
      self.x + 2.0,
      self.y + s - self.label_size - 2.0,
      self.label_color,
    )
  }
}
