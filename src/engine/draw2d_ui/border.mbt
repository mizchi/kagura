///|
/// Border widths for 4 sides independently.
pub(all) struct BorderWidths {
  top : Double
  right : Double
  bottom : Double
  left : Double
}

///|
pub fn BorderWidths::uniform(w : Double) -> BorderWidths {
  { top: w, right: w, bottom: w, left: w }
}

///|
pub fn BorderWidths::zero() -> BorderWidths {
  { top: 0.0, right: 0.0, bottom: 0.0, left: 0.0 }
}

///|
pub fn BorderWidths::has_any(self : BorderWidths) -> Bool {
  self.top > 0.0 || self.right > 0.0 || self.bottom > 0.0 || self.left > 0.0
}

///|
/// Generate vertices and indices for a 4-side independent border.
/// Pixel coords in, NDC vertices out (for builtin shader).
pub fn border_vertices(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  border : BorderWidths,
  screen_w : Double,
  screen_h : Double,
) -> (Array[Double], Array[Int]) {
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  let mut base = 0
  let ox0 = x
  let oy0 = y
  let ox1 = x + w
  let oy1 = y + h
  let ix0 = x + border.left
  let iy0 = y + border.top
  let ix1 = x + w - border.right
  let iy1 = y + h - border.bottom
  if border.top > 0.0 {
    push_ndc_quad(
      vertices, indices, base, ox0, oy0, ox1, oy0, ix1, iy0, ix0, iy0, screen_w,
      screen_h,
    )
    base = base + 4
  }
  if border.right > 0.0 {
    push_ndc_quad(
      vertices, indices, base, ox1, oy0, ox1, oy1, ix1, iy1, ix1, iy0, screen_w,
      screen_h,
    )
    base = base + 4
  }
  if border.bottom > 0.0 {
    push_ndc_quad(
      vertices, indices, base, ix0, iy1, ix1, iy1, ox1, oy1, ox0, oy1, screen_w,
      screen_h,
    )
    base = base + 4
  }
  if border.left > 0.0 {
    push_ndc_quad(
      vertices, indices, base, ox0, oy1, ox0, oy0, ix0, iy0, ix0, iy1, screen_w,
      screen_h,
    )
    base = base + 4
  }
  ignore(base)
  (vertices, indices)
}

///|
/// Generate NDC vertices for a filled rectangle from pixel coords.
pub fn filled_rect_vertices(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  screen_w : Double,
  screen_h : Double,
) -> (Array[Double], Array[Int]) {
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  push_ndc_quad(
    vertices,
    indices,
    0,
    x,
    y,
    x + w,
    y,
    x + w,
    y + h,
    x,
    y + h,
    screen_w,
    screen_h,
  )
  (vertices, indices)
}

///|
fn px_to_ndc_x(px : Double, screen_w : Double) -> Double {
  px / screen_w * 2.0 - 1.0
}

///|
fn px_to_ndc_y(py : Double, screen_h : Double) -> Double {
  -(py / screen_h * 2.0 - 1.0)
}

///|
fn push_ndc_quad(
  vertices : Array[Double],
  indices : Array[Int],
  base : Int,
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
  screen_w : Double,
  screen_h : Double,
) -> Unit {
  vertices.push(px_to_ndc_x(x0, screen_w))
  vertices.push(px_to_ndc_y(y0, screen_h))
  vertices.push(0.0)
  vertices.push(0.0)
  vertices.push(px_to_ndc_x(x1, screen_w))
  vertices.push(px_to_ndc_y(y1, screen_h))
  vertices.push(1.0)
  vertices.push(0.0)
  vertices.push(px_to_ndc_x(x2, screen_w))
  vertices.push(px_to_ndc_y(y2, screen_h))
  vertices.push(1.0)
  vertices.push(1.0)
  vertices.push(px_to_ndc_x(x3, screen_w))
  vertices.push(px_to_ndc_y(y3, screen_h))
  vertices.push(0.0)
  vertices.push(1.0)
  indices.push(base)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base)
}
