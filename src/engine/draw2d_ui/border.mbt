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
/// Generate NDC vertices for a filled rounded rectangle.
/// Each corner is approximated with `segments` triangle-fan triangles.
pub fn filled_rounded_rect_vertices(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  tl : Double,
  tr : Double,
  br : Double,
  bl : Double,
  screen_w : Double,
  screen_h : Double,
) -> (Array[Double], Array[Int]) {
  let segments = 6 // segments per corner arc
  // If all radii are zero, fall back to simple rect
  if tl <= 0.0 && tr <= 0.0 && br <= 0.0 && bl <= 0.0 {
    return filled_rect_vertices(x, y, w, h, screen_w, screen_h)
  }
  // Clamp radii to half dimensions
  let max_r = @cmp.minimum(w / 2.0, h / 2.0)
  let tl = @cmp.minimum(tl, max_r)
  let tr = @cmp.minimum(tr, max_r)
  let br = @cmp.minimum(br, max_r)
  let bl = @cmp.minimum(bl, max_r)
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  // Center vertex (index 0)
  let cx = x + w / 2.0
  let cy = y + h / 2.0
  vertices.push(px_to_ndc_x(cx, screen_w))
  vertices.push(px_to_ndc_y(cy, screen_h))
  vertices.push(0.5)
  vertices.push(0.5)
  let mut idx = 1
  // Helper: push a vertex and return its index
  fn push_v(px : Double, py : Double) -> Int {
    vertices.push(px_to_ndc_x(px, screen_w))
    vertices.push(px_to_ndc_y(py, screen_h))
    vertices.push(0.0)
    vertices.push(0.0)
    let i = idx
    idx = idx + 1
    i
  }
  // Build perimeter vertices: top-left corner → top-right → bottom-right → bottom-left
  let perimeter : Array[Int] = []
  // Top-left corner arc (center at x+tl, y+tl, from PI to PI*1.5)
  if tl > 0.0 {
    for i = 0; i <= segments; i = i + 1 {
      let angle = 3.14159265 +
        i.to_double() / segments.to_double() * 3.14159265 / 2.0
      let px = x + tl + tl * @math.cos(angle)
      let py = y + tl + tl * @math.sin(angle)
      perimeter.push(push_v(px, py))
    }
  } else {
    perimeter.push(push_v(x, y))
  }
  // Top-right corner arc (center at x+w-tr, y+tr, from PI*1.5 to PI*2)
  if tr > 0.0 {
    for i = 0; i <= segments; i = i + 1 {
      let angle = 3.14159265 * 1.5 +
        i.to_double() / segments.to_double() * 3.14159265 / 2.0
      let px = x + w - tr + tr * @math.cos(angle)
      let py = y + tr + tr * @math.sin(angle)
      perimeter.push(push_v(px, py))
    }
  } else {
    perimeter.push(push_v(x + w, y))
  }
  // Bottom-right corner arc (center at x+w-br, y+h-br, from 0 to PI*0.5)
  if br > 0.0 {
    for i = 0; i <= segments; i = i + 1 {
      let angle = i.to_double() / segments.to_double() * 3.14159265 / 2.0
      let px = x + w - br + br * @math.cos(angle)
      let py = y + h - br + br * @math.sin(angle)
      perimeter.push(push_v(px, py))
    }
  } else {
    perimeter.push(push_v(x + w, y + h))
  }
  // Bottom-left corner arc (center at x+bl, y+h-bl, from PI*0.5 to PI)
  if bl > 0.0 {
    for i = 0; i <= segments; i = i + 1 {
      let angle = 3.14159265 / 2.0 +
        i.to_double() / segments.to_double() * 3.14159265 / 2.0
      let px = x + bl + bl * @math.cos(angle)
      let py = y + h - bl + bl * @math.sin(angle)
      perimeter.push(push_v(px, py))
    }
  } else {
    perimeter.push(push_v(x, y + h))
  }
  // Build triangle fan from center (index 0) to perimeter
  for i = 0; i < perimeter.length() - 1; i = i + 1 {
    indices.push(0)
    indices.push(perimeter[i])
    indices.push(perimeter[i + 1])
  }
  // Close the fan
  indices.push(0)
  indices.push(perimeter[perimeter.length() - 1])
  indices.push(perimeter[0])
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
