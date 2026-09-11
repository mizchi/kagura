///|
/// StatusBar: horizontal progress bar for HP, MP, stamina, cooldowns, etc.
pub(all) struct StatusBar {
  x : Double
  y : Double
  width : Double
  height : Double
  ratio : Double // 0.0 .. 1.0
  fill_color : Int // hex
  bg_color : Int // hex
  border_color : Int? // None = no border
  border_width : Double
  label : String // "" = no label
  label_size : Double
  label_color : Int // hex
}

///|
/// Default status bar preset.
pub fn default_status_bar() -> StatusBar {
  {
    x: 0.0,
    y: 0.0,
    width: 120.0,
    height: 16.0,
    ratio: 1.0,
    fill_color: 0x00CC00,
    bg_color: 0x440000,
    border_color: None,
    border_width: 1.0,
    label: "",
    label_size: 12.0,
    label_color: 0xFFFFFF,
  }
}

///|
/// Render: background -> fill -> border (4 rects) -> label (centered)
pub fn StatusBar::render(
  self : StatusBar,
  ctx : HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  // Background
  ctx.draw_rect(
    cmds,
    self.x,
    self.y,
    self.width,
    self.height,
    hex_color(self.bg_color, alpha=0.8),
  )
  // Fill
  let fill_w = self.width * self.ratio.clamp(min=0.0, max=1.0)
  if fill_w > 0.0 {
    ctx.draw_rect(
      cmds,
      self.x,
      self.y,
      fill_w,
      self.height,
      hex_color(self.fill_color),
    )
  }
  // Border (4 rects: top, bottom, left, right)
  match self.border_color {
    Some(bc) => {
      let bw = self.border_width
      let color = hex_color(bc)
      // Top
      ctx.draw_rect(cmds, self.x, self.y, self.width, bw, color)
      // Bottom
      ctx.draw_rect(
        cmds,
        self.x,
        self.y + self.height - bw,
        self.width,
        bw,
        color,
      )
      // Left
      ctx.draw_rect(cmds, self.x, self.y, bw, self.height, color)
      // Right
      ctx.draw_rect(
        cmds,
        self.x + self.width - bw,
        self.y,
        bw,
        self.height,
        color,
      )
    }
    None => ()
  }
  // Label (centered in the bar)
  if self.label.length() > 0 {
    let cx = self.x + self.width / 2.0
    let cy = self.y + self.height / 2.0
    ctx.draw_text_centered(
      cmds,
      self.label,
      self.label_size,
      cx,
      cy,
      self.label_color,
    )
  }
}
