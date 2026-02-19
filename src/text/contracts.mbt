///|
/// Text contracts.
///
/// Reference:
/// - mizchi/font

///|
pub struct FontKey {
  family : String
  weight : Int
  italic : Bool
} derive(Show)

///|
pub struct TextStyle {
  font : FontKey
  size_px : Double
  line_height : Double
  letter_spacing : Double
} derive(Show)

///|
pub struct TextMetrics {
  width : Double
  height : Double
  baseline : Double
} derive(Show)

///|
pub struct GlyphQuad {
  glyph_id : Int
  atlas_x : Double
  atlas_y : Double
  atlas_w : Double
  atlas_h : Double
  dst_x : Double
  dst_y : Double
  dst_w : Double
  dst_h : Double
} derive(Show)

///|
pub struct TextRun {
  text : String
  style : TextStyle
} derive(Show)

///|
pub trait FontEngine {
  measure(Self, run : TextRun) -> TextMetrics
  shape(Self, run : TextRun) -> Array[GlyphQuad] raise
}

///|
pub trait TextBatchBuilder {
  build_draw_commands(
    Self,
    target : @gfx.ImageHandle,
    glyphs : Array[GlyphQuad],
    shader : @gfx.ShaderHandle,
  ) -> Array[@gfx.DrawTrianglesCommand] raise
}

///|
pub fn default_text_style(family : String, size_px : Double) -> TextStyle {
  {
    font: { family, weight: 400, italic: false },
    size_px,
    line_height: size_px * 1.4,
    letter_spacing: 0.0,
  }
}
