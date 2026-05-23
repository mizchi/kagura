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
  { chars, cx, cy, color, scale }
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
  let total_w = text.chars.length().to_double() * char_w +
    (text.chars.length() - 1).to_double() * gap
  let char_h = 5.0 * px_size
  let start_x = text.cx - total_w / 2.0
  let start_y = text.cy - char_h / 2.0
  for i in 0..<text.chars.length() {
    let pattern = glyph_pattern(text.chars[i])
    let ox = start_x + i.to_double() * (char_w + gap)
    for row in 0..<5 {
      for col in 0..<3 {
        if pattern[row * 3 + col] == 1 {
          append_rect_fill(
            commands,
            frame,
            RectFill2D::new(
              x=ox + col.to_double() * px_size,
              y=start_y + row.to_double() * px_size,
              w=px_size,
              h=px_size,
              color=text.color,
            ),
          )
        }
      }
    }
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
  { number, cx, cy, color, scale }
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
