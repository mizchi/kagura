///|
fn pixel_to_ndc_vertices(
  vertices : Array[Double],
  screen_w : Double,
  screen_h : Double,
) -> Array[Double] {
  let out : Array[Double] = []
  let mut i = 0
  while i < vertices.length() {
    let px = vertices[i]
    let py = vertices[i + 1]
    let u = vertices[i + 2]
    let v = vertices[i + 3]
    out.push(px / screen_w * 2.0 - 1.0)
    out.push(1.0 - py / screen_h * 2.0)
    out.push(u)
    out.push(v)
    i = i + 4
  }
  out
}

///|
fn new_primitive_command(
  frame : RenderFrame2D,
  vertex_data : Array[Double],
  indices : Array[Int],
  color : @gfx.Color,
) -> @gfx.DrawTrianglesCommand {
  @gfx.new_draw_triangles_command(
    frame.dst,
    frame.shader,
    [
      @gfx.new_dst_region(
        0,
        0,
        frame.screen_w,
        frame.screen_h,
        indices.length(),
      ),
    ],
    0,
    frame.pipeline_id,
    frame.uniform_hash,
    frame.blend,
    vertex_data,
    indices,
    [],
    color_to_uniform_dwords(color),
  )
}

///|
pub fn append_primitive_batch(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : RenderFrame2D,
  vertex_data : Array[Double],
  indices : Array[Int],
  color : @gfx.Color,
) -> Unit {
  commands.push(new_primitive_command(frame, vertex_data, indices, color))
}

///|
pub(all) struct RectFill2D {
  x : Double
  y : Double
  w : Double
  h : Double
  color : @gfx.Color
}

///|
pub fn RectFill2D::new(
  x~ : Double,
  y~ : Double,
  w~ : Double,
  h~ : Double,
  color~ : @gfx.Color,
) -> RectFill2D {
  { x, y, w, h, color, }
}

///|
/// Push one axis-aligned quad's NDC geometry onto `vertices` / `indices`.
///
/// The only place the pixel-to-NDC arithmetic for a filled rect lives on the
/// appending path, so the single-rect and batched callers cannot drift apart.
/// Takes the screen size and the rect as scalars rather than a `RenderFrame2D`
/// and a `RectFill2D` because a batched run calls it once per quad: the frame
/// conversion hoists out of the loop and no `RectFill2D` is allocated per quad.
fn push_rect_fill_geometry(
  vertices : Array[Double],
  indices : Array[Int],
  screen_w : Double,
  screen_h : Double,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
) -> Unit {
  // Same arithmetic as `ndc_rect_fill_vertices`, written straight into the
  // caller's arrays. Going through that helper allocated a tuple and two
  // arrays per quad and then copied all 22 elements back out, which is most of
  // what a batched text run used to pay per dot.
  let x0 = x / screen_w * 2.0 - 1.0
  let y0 = 1.0 - y / screen_h * 2.0
  let x1 = (x + w) / screen_w * 2.0 - 1.0
  let y1 = 1.0 - (y + h) / screen_h * 2.0
  let base_vertex = vertices.length() / 4
  vertices.push(x0)
  vertices.push(y0)
  vertices.push(0.0)
  vertices.push(0.0)
  vertices.push(x1)
  vertices.push(y0)
  vertices.push(1.0)
  vertices.push(0.0)
  vertices.push(x1)
  vertices.push(y1)
  vertices.push(1.0)
  vertices.push(1.0)
  vertices.push(x0)
  vertices.push(y1)
  vertices.push(0.0)
  vertices.push(1.0)
  indices.push(base_vertex)
  indices.push(base_vertex + 1)
  indices.push(base_vertex + 2)
  indices.push(base_vertex + 2)
  indices.push(base_vertex + 3)
  indices.push(base_vertex)
}

///|
pub fn append_rect_fill_geometry(
  vertices : Array[Double],
  indices : Array[Int],
  frame : RenderFrame2D,
  rect : RectFill2D,
) -> Unit {
  push_rect_fill_geometry(
    vertices,
    indices,
    frame.screen_w.to_double(),
    frame.screen_h.to_double(),
    rect.x,
    rect.y,
    rect.w,
    rect.h,
  )
}

///|
pub fn append_rect_fill(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : RenderFrame2D,
  rect : RectFill2D,
) -> Unit {
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  append_rect_fill_geometry(vertices, indices, frame, rect)
  append_primitive_batch(commands, frame, vertices, indices, rect.color)
}

///|
pub(all) struct Line2D {
  x0 : Double
  y0 : Double
  x1 : Double
  y1 : Double
  width : Double
  color : @gfx.Color
}

///|
pub fn Line2D::new(
  x0~ : Double,
  y0~ : Double,
  x1~ : Double,
  y1~ : Double,
  width? : Double = 1.0,
  color~ : @gfx.Color,
) -> Line2D {
  { x0, y0, x1, y1, width, color, }
}

///|
pub fn append_line(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : RenderFrame2D,
  line : Line2D,
) -> Unit {
  let (vertices, indices) = line_vertices(
    line.x0,
    line.y0,
    line.x1,
    line.y1,
    line.width,
  )
  commands.push(
    new_primitive_command(
      frame,
      pixel_to_ndc_vertices(
        vertices,
        frame.screen_w.to_double(),
        frame.screen_h.to_double(),
      ),
      indices,
      line.color,
    ),
  )
}

///|
pub(all) struct RectOutline2D {
  x : Double
  y : Double
  w : Double
  h : Double
  line_width : Double
  color : @gfx.Color
}

///|
pub fn RectOutline2D::new(
  x~ : Double,
  y~ : Double,
  w~ : Double,
  h~ : Double,
  line_width? : Double = 1.0,
  color~ : @gfx.Color,
) -> RectOutline2D {
  { x, y, w, h, line_width, color, }
}

///|
pub fn append_rect_outline(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : RenderFrame2D,
  rect : RectOutline2D,
) -> Unit {
  let (vertices, indices) = rect_outline_vertices(
    rect.x,
    rect.y,
    rect.w,
    rect.h,
    rect.line_width,
  )
  commands.push(
    new_primitive_command(
      frame,
      pixel_to_ndc_vertices(
        vertices,
        frame.screen_w.to_double(),
        frame.screen_h.to_double(),
      ),
      indices,
      rect.color,
    ),
  )
}
