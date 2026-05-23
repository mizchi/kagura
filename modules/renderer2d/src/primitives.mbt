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
    @debugutil.color_to_uniform_dwords(color),
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
  { x, y, w, h, color }
}

///|
pub fn append_rect_fill_geometry(
  vertices : Array[Double],
  indices : Array[Int],
  frame : RenderFrame2D,
  rect : RectFill2D,
) -> Unit {
  let (rect_vertices, rect_indices) = @debugutil.ndc_rect_fill_vertices(
    rect.x,
    rect.y,
    rect.w,
    rect.h,
    frame.screen_w.to_double(),
    frame.screen_h.to_double(),
  )
  let base_vertex = vertices.length() / 4
  for value in rect_vertices {
    vertices.push(value)
  }
  for idx in rect_indices {
    indices.push(base_vertex + idx)
  }
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
  { x0, y0, x1, y1, width, color }
}

///|
pub fn append_line(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : RenderFrame2D,
  line : Line2D,
) -> Unit {
  let (vertices, indices) = @debugutil.line_vertices(
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
  { x, y, w, h, line_width, color }
}

///|
pub fn append_rect_outline(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : RenderFrame2D,
  rect : RectOutline2D,
) -> Unit {
  let (vertices, indices) = @debugutil.rect_outline_vertices(
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
