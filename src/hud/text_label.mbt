///|
/// TextLabel: simple positioned text with alignment.
pub(all) enum TextAlign {
  Left
  Center
  Right
} derive(Show, Eq)

///|
pub(all) struct TextLabel {
  x : Double
  y : Double
  text : String
  size : Double
  color : Int // hex
  align : TextAlign
}

///|
/// Render the text label.
pub fn TextLabel::render(
  self : TextLabel,
  ctx : HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  match self.align {
    Left =>
      ctx.draw_text(cmds, self.text, self.size, self.x, self.y, self.color)
    Center =>
      ctx.draw_text_centered(
        cmds,
        self.text,
        self.size,
        self.x,
        self.y,
        self.color,
      )
    Right => {
      let (w, _) = ctx.measure_text(self.text, self.size)
      ctx.draw_text(cmds, self.text, self.size, self.x - w, self.y, self.color)
    }
  }
}
