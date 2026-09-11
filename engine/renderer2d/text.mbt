///|
pub(all) struct DotText2D {
  chars : Array[Int]
  cx : Double
  cy : Double
  color : @gfx.Color
  scale : Double
}

///|
pub fn DotText2D::new(
  chars~ : Array[Int],
  cx~ : Double,
  cy~ : Double,
  color~ : @gfx.Color,
  scale? : Double = 1.0,
) -> DotText2D {
  { chars, cx, cy, color, scale, }
}

///|
/// Rendered size of a dot-text run of `char_count` glyphs: `(width, height)`.
///
/// Exposed because the UI integrity gate compares a label's measured extent
/// against its node rect to catch text that will spill or be clipped; that
/// comparison is only sound if it uses the same arithmetic `append_dot_text`
/// lays the glyphs out with, so both read it from here.
pub fn dot_text_size(
  char_count : Int,
  scale? : Double = 1.0,
) -> (Double, Double) {
  if char_count <= 0 {
    return (0.0, 0.0)
  }
  let px_size = 3.0 * scale
  let char_w = 3.0 * px_size
  let gap = px_size
  let width = char_count.to_double() * char_w +
    (char_count - 1).to_double() * gap
  (width, 5.0 * px_size)
}

///|
pub fn append_dot_text(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : RenderFrame2D,
  text : DotText2D,
) -> Unit {
  let px_size = 3.0 * text.scale
  let char_w = 3.0 * px_size
  let gap = px_size
  let (total_w, char_h) = dot_text_size(text.chars.length(), scale=text.scale)
  let start_x = text.cx - total_w / 2.0
  let start_y = text.cy - char_h / 2.0
  // One command for the whole run, not one per lit dot. Every dot of a run
  // shares dst, shader, pipeline, blend and color -- the color is a uniform, so
  // a run is exactly the granularity that can be merged without touching the
  // vertex layout. The triangles and their order are unchanged, so the
  // rasterizer walks the same list and produces the same pixels; a 3x5 glyph
  // just stops costing ten `DrawTrianglesCommand` allocations.
  // Not pre-sized. Reserving the worst case (15 dots per glyph against the ~10
  // that are typically lit) separated as 1.10x faster only in the one bench
  // that `moon bench -p` misreports, and not at all in the regime the gate
  // runs -- while the vertex array becomes the command's `vertex_data`, so the
  // slack would be held for the whole frame. See
  // `docs/performance/dot-text-batching.md`.
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  let screen_w = frame.screen_w.to_double()
  let screen_h = frame.screen_h.to_double()
  for i in 0..<text.chars.length() {
    let pattern = glyph_pattern(text.chars[i])
    let ox = start_x + i.to_double() * (char_w + gap)
    for row in 0..<5 {
      for col in 0..<3 {
        if pattern[row * 3 + col] == 1 {
          push_rect_fill_geometry(
            vertices,
            indices,
            screen_w,
            screen_h,
            ox + col.to_double() * px_size,
            start_y + row.to_double() * px_size,
            px_size,
            px_size,
          )
        }
      }
    }
  }
  // A run with no lit dots (empty string, or glyphs that are all blank) drew
  // nothing before and must keep drawing nothing -- an empty command would
  // count as a skipped command in the rasterizer.
  if indices.length() > 0 {
    append_primitive_batch(commands, frame, vertices, indices, text.color)
  }
}

///|
pub(all) struct Number2D {
  number : Int
  cx : Double
  cy : Double
  color : @gfx.Color
  scale : Double
}

///|
pub fn Number2D::new(
  number~ : Int,
  cx~ : Double,
  cy~ : Double,
  color~ : @gfx.Color,
  scale? : Double = 1.0,
) -> Number2D {
  { number, cx, cy, color, scale, }
}

///|
fn number_to_char_codes(number : Int) -> Array[Int] {
  let digits : Array[Int] = []
  if number == 0 {
    digits.push(0)
  } else {
    let mut n = if number < 0 { -number } else { number }
    while n > 0 {
      digits.push(n % 10)
      n = n / 10
    }
    if number < 0 {
      digits.push(45)
    }
    let len = digits.length()
    for i in 0..<(len / 2) {
      let tmp = digits[i]
      digits[i] = digits[len - 1 - i]
      digits[len - 1 - i] = tmp
    }
  }
  digits
}

///|
pub fn append_number(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : RenderFrame2D,
  number : Number2D,
) -> Unit {
  append_dot_text(
    commands,
    frame,
    DotText2D::new(
      chars=number_to_char_codes(number.number),
      cx=number.cx,
      cy=number.cy,
      color=number.color,
      scale=number.scale,
    ),
  )
}
