///|
/// TextLabel: simple positioned text with alignment.
pub(all) enum TextAlign {
  Left
  Center
  Right
} derive(Debug, Eq)

///|
pub impl Show for TextAlign with fn output(self, logger) {
  logger.write_object(Repr(self))
}

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

///|
pub extend TextAlign with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TextAlign with Eq::{not_equal, equal}

///|
pub extend TextAlign with Show::{to_string, output}
