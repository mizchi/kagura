///|
/// CPU rasterizer for `@gfx.DrawTrianglesCommand`, usable as a
/// `@gfx.GraphicsDriver`.
///
/// Why this exists: every other way of getting a kagura frame out needs a
/// GPU and a window. The web canvas capture comes back transparent headless,
/// the Linux Dawn readback never completes, and the native capture needs
/// wgpu-native plus glfw at link time. None of that is available inside a
/// plain `node` process, which is where the verification tooling lives.
///
/// This backend draws the same command stream into an ordinary `Array[Int]`
/// with no host at all, so `moon run --target js` produces a real frame.
///
/// Scope: the 2D command shape kagura's `@renderer2d` emits -- vertices are
/// `[x_ndc, y_ndc, u, v]`, the uniform is an RGBA dword quad, and the shader
/// samples one texture. 3D commands (`vertex_stride_hint` 8 or 16) carry a
/// depth buffer and a projection this backend does not model; they are
/// counted in `skipped_commands` rather than drawn wrong.

///|
/// A source image the rasterizer can sample. Ids match
/// `DrawTrianglesCommand.src_image_ids`; an id with no registered texture
/// samples as 1x1 opaque white, which is what the WebGPU backend binds for an
/// unbound slot (`assets/web/kagura-gfx.js`), so untextured geometry comes out as
/// the flat uniform color on both backends.
pub(all) struct RasterTexture {
  id : Int
  width : Int
  height : Int
  /// RGBA8, `width * height * 4` entries, each 0-255.
  pixels : Array[Int]
}

///|
/// An RGBA8 framebuffer plus the textures bound to it.
pub struct RasterTarget {
  mut width : Int
  mut height : Int
  mut pixels : Array[Int]
  textures : Array[RasterTexture]
  /// Commands the backend refused to draw rather than draw incorrectly.
  mut skipped_commands : Int
  /// Triangles actually rasterized, across every command since the last clear.
  mut drawn_triangles : Int
  mut next_image_id : Int
  mut next_shader_id : Int
}

///|
pub fn RasterTarget::new(width : Int, height : Int) -> RasterTarget {
  let w = if width > 0 { width } else { 1 }
  let h = if height > 0 { height } else { 1 }
  {
    width: w,
    height: h,
    pixels: Array::make(w * h * 4, 0),
    textures: [],
    skipped_commands: 0,
    drawn_triangles: 0,
    next_image_id: 1,
    next_shader_id: 1,
  }
}

///|
/// Fill the whole framebuffer with `color`, and reset the per-frame counters.
pub fn RasterTarget::clear(self : RasterTarget, color : @gfx.Color) -> Unit {
  let r = unit_to_byte(color.r)
  let g = unit_to_byte(color.g)
  let b = unit_to_byte(color.b)
  let a = unit_to_byte(color.a)
  let count = self.width * self.height
  for i in 0..<count {
    let base = i * 4
    self.pixels[base] = r
    self.pixels[base + 1] = g
    self.pixels[base + 2] = b
    self.pixels[base + 3] = a
  }
  self.skipped_commands = 0
  self.drawn_triangles = 0
}

///|
/// Resize the framebuffer. The contents are discarded, so call this outside a
/// render pass.
pub fn RasterTarget::resize_target(
  self : RasterTarget,
  width : Int,
  height : Int,
) -> Unit {
  let w = if width > 0 { width } else { 1 }
  let h = if height > 0 { height } else { 1 }
  if w == self.width && h == self.height {
    return
  }
  self.width = w
  self.height = h
  self.pixels = Array::make(w * h * 4, 0)
}

///|
/// Bind an RGBA8 source image to `id`. A later call with the same id replaces
/// the entry, so an atlas page can be re-uploaded between frames.
pub fn RasterTarget::register_texture(
  self : RasterTarget,
  id : Int,
  width : Int,
  height : Int,
  pixels : Array[Int],
) -> Unit {
  let texture = { id, width, height, pixels, }
  for i in 0..<self.textures.length() {
    if self.textures[i].id == id {
      self.textures[i] = texture
      return
    }
  }
  self.textures.push(texture)
}

///|
fn RasterTarget::find_texture(self : RasterTarget, id : Int) -> RasterTexture? {
  for texture in self.textures {
    if texture.id == id {
      return Some(texture)
    }
  }
  None
}

///|
/// Copy back a sub-rectangle as flat RGBA8. Out-of-bounds pixels read as
/// transparent black rather than raising, so a caller asking for a region
/// larger than the target still gets a correctly sized buffer.
pub fn RasterTarget::read_rect(
  self : RasterTarget,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Array[Int] {
  let out = Array::make(width * height * 4, 0)
  for row in 0..<height {
    let sy = y + row
    for col in 0..<width {
      let sx = x + col
      let dst_base = (row * width + col) * 4
      if sx < 0 || sy < 0 || sx >= self.width || sy >= self.height {
        continue
      }
      let src_base = (sy * self.width + sx) * 4
      out[dst_base] = self.pixels[src_base]
      out[dst_base + 1] = self.pixels[src_base + 1]
      out[dst_base + 2] = self.pixels[src_base + 2]
      out[dst_base + 3] = self.pixels[src_base + 3]
    }
  }
  out
}

// ============================================================
// Command rasterization
// ============================================================

///|
/// Scissor rectangle in pixels, already clipped to the framebuffer.
priv struct Scissor {
  x0 : Int
  y0 : Int
  x1 : Int
  y1 : Int
}

///|
fn RasterTarget::clip_scissor(
  self : RasterTarget,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Scissor {
  let x0 = max_int(0, x)
  let y0 = max_int(0, y)
  let x1 = min_int(self.width, x + width)
  let y1 = min_int(self.height, y + height)
  { x0, y0, x1, y1, }
}

///|
/// Rasterize one command. Returns the number of triangles drawn.
///
/// `dst_regions` are walked in order, each consuming its own `index_count`
/// indices starting at `index_offset` -- that is the contract in
/// `@gfx.DstRegion`, where one command can batch several scissors that share
/// pipeline state. An empty region list means "the whole target", which is
/// what a backend does with a command that never declared one.
pub fn RasterTarget::draw_command(
  self : RasterTarget,
  cmd : @gfx.DrawTrianglesCommand,
) -> Int {
  let stride = resolve_vertex_stride(cmd)
  if stride != 4 {
    self.skipped_commands = self.skipped_commands + 1
    return 0
  }
  if cmd.vertex_data.length() < 12 || cmd.indices.length() < 3 {
    self.skipped_commands = self.skipped_commands + 1
    return 0
  }
  let color = decode_uniform_color(cmd.uniform_dwords)
  let texture = if cmd.src_image_ids.length() > 0 {
    self.find_texture(cmd.src_image_ids[0])
  } else {
    None
  }
  let equation = cmd.blend.to_equation()
  let mut drawn = 0
  if cmd.dst_regions.length() == 0 {
    let scissor = self.clip_scissor(0, 0, self.width, self.height)
    drawn = drawn +
      self.draw_index_range(
        cmd,
        cmd.index_offset,
        cmd.indices.length() - cmd.index_offset,
        scissor,
        color,
        texture,
        equation,
      )
  } else {
    let mut cursor = cmd.index_offset
    for region in cmd.dst_regions {
      let scissor = self.clip_scissor(
        region.x,
        region.y,
        region.width,
        region.height,
      )
      drawn = drawn +
        self.draw_index_range(
          cmd,
          cursor,
          region.index_count,
          scissor,
          color,
          texture,
          equation,
        )
      cursor = cursor + region.index_count
    }
  }
  self.drawn_triangles = self.drawn_triangles + drawn
  drawn
}

///|
fn RasterTarget::draw_index_range(
  self : RasterTarget,
  cmd : @gfx.DrawTrianglesCommand,
  start : Int,
  count : Int,
  scissor : Scissor,
  color : @gfx.Color,
  texture : RasterTexture?,
  equation : @gfx.BlendEquation,
) -> Int {
  if count <= 0 || scissor.x0 >= scissor.x1 || scissor.y0 >= scissor.y1 {
    return 0
  }
  let vertex_count = cmd.vertex_data.length() / 4
  let index_end = min_int(cmd.indices.length(), start + count)
  let mut drawn = 0
  let mut i = max_int(0, start)
  while i + 2 < index_end {
    let i0 = cmd.indices[i]
    let i1 = cmd.indices[i + 1]
    let i2 = cmd.indices[i + 2]
    i = i + 3
    if i0 < 0 ||
      i1 < 0 ||
      i2 < 0 ||
      i0 >= vertex_count ||
      i1 >= vertex_count ||
      i2 >= vertex_count {
      continue
    }
    if self.draw_triangle(
        cmd.vertex_data,
        i0,
        i1,
        i2,
        scissor,
        color,
        texture,
        equation,
      ) {
      drawn = drawn + 1
    }
  }
  drawn
}

///|
/// One triangle. Vertices arrive in normalized device coordinates, the space
/// the builtin 2D shader passes straight through
/// (`out.position = vec4f(pos, 0.0, 1.0)` in `assets/web/kagura-gfx.js`), so the
/// only transform here is the viewport mapping.
fn RasterTarget::draw_triangle(
  self : RasterTarget,
  vertex_data : Array[Double],
  i0 : Int,
  i1 : Int,
  i2 : Int,
  scissor : Scissor,
  color : @gfx.Color,
  texture : RasterTexture?,
  equation : @gfx.BlendEquation,
) -> Bool {
  let w = self.width.to_double()
  let h = self.height.to_double()
  let ax = ndc_to_pixel_x(vertex_data[i0 * 4], w)
  let ay = ndc_to_pixel_y(vertex_data[i0 * 4 + 1], h)
  let mut bx = ndc_to_pixel_x(vertex_data[i1 * 4], w)
  let mut by = ndc_to_pixel_y(vertex_data[i1 * 4 + 1], h)
  let mut cx = ndc_to_pixel_x(vertex_data[i2 * 4], w)
  let mut cy = ndc_to_pixel_y(vertex_data[i2 * 4 + 1], h)
  let au = vertex_data[i0 * 4 + 2]
  let av = vertex_data[i0 * 4 + 3]
  let mut bu = vertex_data[i1 * 4 + 2]
  let mut bv = vertex_data[i1 * 4 + 3]
  let mut cu = vertex_data[i2 * 4 + 2]
  let mut cv = vertex_data[i2 * 4 + 3]
  let mut area = edge_function(ax, ay, bx, by, cx, cy)
  if area == 0.0 {
    return false
  }
  // Both windings reach here: a quad emitted counter-clockwise in NDC turns
  // clockwise once y is flipped for the viewport, and callers are not required
  // to agree on a winding. Normalizing to a positive area lets one top-left
  // rule cover both, which is what stops the shared diagonal of a two-triangle
  // rect from being blended over twice.
  if area < 0.0 {
    let tx = bx
    let ty = by
    let tu = bu
    let tv = bv
    bx = cx
    by = cy
    bu = cu
    bv = cv
    cx = tx
    cy = ty
    cu = tu
    cv = tv
    area = -area
  }
  let min_x = max_int(scissor.x0, floor_to_int(min3(ax, bx, cx)))
  let max_x = min_int(scissor.x1 - 1, ceil_to_int(max3(ax, bx, cx)))
  let min_y = max_int(scissor.y0, floor_to_int(min3(ay, by, cy)))
  let max_y = min_int(scissor.y1 - 1, ceil_to_int(max3(ay, by, cy)))
  if min_x > max_x || min_y > max_y {
    return false
  }
  let bias0 = if is_top_left(bx, by, cx, cy) { 0.0 } else { -epsilon }
  let bias1 = if is_top_left(cx, cy, ax, ay) { 0.0 } else { -epsilon }
  let bias2 = if is_top_left(ax, ay, bx, by) { 0.0 } else { -epsilon }
  let mut covered = false
  for py in min_y..<=max_y {
    let sample_y = py.to_double() + 0.5
    for px in min_x..<=max_x {
      let sample_x = px.to_double() + 0.5
      let w0 = edge_function(bx, by, cx, cy, sample_x, sample_y) + bias0
      let w1 = edge_function(cx, cy, ax, ay, sample_x, sample_y) + bias1
      let w2 = edge_function(ax, ay, bx, by, sample_x, sample_y) + bias2
      if w0 < 0.0 || w1 < 0.0 || w2 < 0.0 {
        continue
      }
      covered = true
      let l0 = w0 / area
      let l1 = w1 / area
      let l2 = w2 / area
      let u = l0 * au + l1 * bu + l2 * cu
      let v = l0 * av + l1 * bv + l2 * cv
      let (tr, tg, tb, ta) = sample_texture(texture, u, v)
      let sr = tr * color.r
      let sg = tg * color.g
      let sb = tb * color.b
      let sa = ta * color.a
      self.blend_pixel(px, py, sr, sg, sb, sa, equation)
    }
  }
  covered
}

///|
fn RasterTarget::blend_pixel(
  self : RasterTarget,
  x : Int,
  y : Int,
  sr : Double,
  sg : Double,
  sb : Double,
  sa : Double,
  equation : @gfx.BlendEquation,
) -> Unit {
  let base = (y * self.width + x) * 4
  let dr = self.pixels[base].to_double() / 255.0
  let dg = self.pixels[base + 1].to_double() / 255.0
  let db = self.pixels[base + 2].to_double() / 255.0
  let da = self.pixels[base + 3].to_double() / 255.0
  let out_r = blend_channel(
    equation.op_rgb,
    sr * blend_factor(equation.src_factor_rgb, sr, sa, dr, da),
    dr * blend_factor(equation.dst_factor_rgb, sr, sa, dr, da),
  )
  let out_g = blend_channel(
    equation.op_rgb,
    sg * blend_factor(equation.src_factor_rgb, sg, sa, dg, da),
    dg * blend_factor(equation.dst_factor_rgb, sg, sa, dg, da),
  )
  let out_b = blend_channel(
    equation.op_rgb,
    sb * blend_factor(equation.src_factor_rgb, sb, sa, db, da),
    db * blend_factor(equation.dst_factor_rgb, sb, sa, db, da),
  )
  let out_a = blend_channel(
    equation.op_alpha,
    sa * blend_factor(equation.src_factor_alpha, sa, sa, da, da),
    da * blend_factor(equation.dst_factor_alpha, sa, sa, da, da),
  )
  self.pixels[base] = unit_to_byte(out_r)
  self.pixels[base + 1] = unit_to_byte(out_g)
  self.pixels[base + 2] = unit_to_byte(out_b)
  self.pixels[base + 3] = unit_to_byte(out_a)
}

// ============================================================
// GraphicsDriver
// ============================================================

///|
pub impl @gfx.GraphicsDriver for RasterTarget with fn initialize(_self) {

}

///|
pub impl @gfx.GraphicsDriver for RasterTarget with fn begin(self, pass) {
  if pass.clear_enabled {
    self.clear(pass.clear_color)
  }
}

///|
pub impl @gfx.GraphicsDriver for RasterTarget with fn end(_self, _present) {

}

///|
pub impl @gfx.GraphicsDriver for RasterTarget with fn resize(
  self,
  width,
  height,
) {
  self.resize_target(width, height)
}

///|
pub impl @gfx.GraphicsDriver for RasterTarget with fn new_image(
  self,
  width,
  height,
) {
  let id = self.next_image_id
  self.next_image_id = id + 1
  @gfx.new_image_handle(id, width, height)
}

///|
pub impl @gfx.GraphicsDriver for RasterTarget with fn new_shader(self, source) {
  let id = self.next_shader_id
  self.next_shader_id = id + 1
  @gfx.new_shader_handle(id, source)
}

///|
pub impl @gfx.GraphicsDriver for RasterTarget with fn draw_triangles(
  self,
  command,
) {
  let _ = self.draw_command(command)
}

///|
pub impl @gfx.GraphicsDriver for RasterTarget with fn read_pixels(
  self,
  x,
  y,
  width,
  height,
) {
  Some(self.read_rect(x, y, width, height))
}

// ============================================================
// Helpers
// ============================================================

///|
/// Slack for the top-left rule. The edge functions are evaluated in doubles
/// over pixel-scale coordinates, so an exactly-on-edge sample lands within a
/// few ulps of zero rather than on it; anything smaller than this would let
/// the shared edge of two triangles double-blend.
let epsilon : Double = 1.0e-9

///|
fn resolve_vertex_stride(cmd : @gfx.DrawTrianglesCommand) -> Int {
  if cmd.vertex_stride_hint > 0 {
    cmd.vertex_stride_hint
  } else {
    4
  }
}

///|
/// The uniform is the canonical RGBA dword quad `@renderer2d` builds with
/// `color_to_uniform_dwords`. Anything else -- a different uniform layout, a
/// short array -- falls back to opaque white, matching
/// `@renderer2d.decode_triangle_payload`.
fn decode_uniform_color(uniform_dwords : Array[Int]) -> @gfx.Color {
  @gfx.new_color(
    uniform_channel(uniform_dwords, 0),
    uniform_channel(uniform_dwords, 1),
    uniform_channel(uniform_dwords, 2),
    uniform_channel(uniform_dwords, 3),
  )
}

///|
fn uniform_channel(uniform_dwords : Array[Int], index : Int) -> Double {
  if index < uniform_dwords.length() {
    let value = uniform_dwords[index]
    if value >= 0 && value <= 255 {
      return value.to_double() / 255.0
    }
  }
  1.0
}

///|
/// Nearest-neighbour sample with edge clamping. The builtin shader's default
/// address mode is `Unsafe` (no wrap, no clamp) because a GPU is free to
/// return anything outside [0,1]; clamping keeps this backend in bounds
/// without inventing colors.
fn sample_texture(
  texture : RasterTexture?,
  u : Double,
  v : Double,
) -> (Double, Double, Double, Double) {
  match texture {
    None => (1.0, 1.0, 1.0, 1.0)
    Some(tex) => {
      if tex.width <= 0 || tex.height <= 0 {
        return (1.0, 1.0, 1.0, 1.0)
      }
      let tx = clamp_int(
        floor_to_int(u * tex.width.to_double()),
        0,
        tex.width - 1,
      )
      let ty = clamp_int(
        floor_to_int(v * tex.height.to_double()),
        0,
        tex.height - 1,
      )
      let base = (ty * tex.width + tx) * 4
      if base + 3 >= tex.pixels.length() {
        return (1.0, 1.0, 1.0, 1.0)
      }
      (
        tex.pixels[base].to_double() / 255.0,
        tex.pixels[base + 1].to_double() / 255.0,
        tex.pixels[base + 2].to_double() / 255.0,
        tex.pixels[base + 3].to_double() / 255.0,
      )
    }
  }
}

///|
fn blend_factor(
  factor : @gfx.BlendFactor,
  src_channel : Double,
  src_alpha : Double,
  dst_channel : Double,
  dst_alpha : Double,
) -> Double {
  match factor {
    @gfx.BlendFactor::Zero => 0.0
    @gfx.BlendFactor::One => 1.0
    @gfx.BlendFactor::SrcAlpha => src_alpha
    @gfx.BlendFactor::OneMinusSrcAlpha => 1.0 - src_alpha
    @gfx.BlendFactor::DstAlpha => dst_alpha
    @gfx.BlendFactor::OneMinusDstAlpha => 1.0 - dst_alpha
    @gfx.BlendFactor::SrcColor => src_channel
    @gfx.BlendFactor::OneMinusSrcColor => 1.0 - src_channel
    @gfx.BlendFactor::DstColor => dst_channel
    @gfx.BlendFactor::OneMinusDstColor => 1.0 - dst_channel
  }
}

///|
fn blend_channel(
  op : @gfx.BlendOperation,
  src : Double,
  dst : Double,
) -> Double {
  match op {
    @gfx.BlendOperation::Add => src + dst
    @gfx.BlendOperation::Subtract => src - dst
    @gfx.BlendOperation::ReverseSubtract => dst - src
    @gfx.BlendOperation::Min => if src < dst { src } else { dst }
    @gfx.BlendOperation::Max => if src > dst { src } else { dst }
  }
}

///|
fn edge_function(
  ax : Double,
  ay : Double,
  bx : Double,
  by : Double,
  px : Double,
  py : Double,
) -> Double {
  (bx - ax) * (py - ay) - (by - ay) * (px - ax)
}

///|
/// Top-left rule for a positive-area triangle in a y-down viewport: a
/// horizontal edge running leftwards is a top edge, and an edge running
/// downwards is a left edge. Samples exactly on those edges belong to this
/// triangle; samples on the others belong to the neighbour.
fn is_top_left(ax : Double, ay : Double, bx : Double, by : Double) -> Bool {
  (ay == by && bx < ax) || by > ay
}

///|
fn ndc_to_pixel_x(x : Double, width : Double) -> Double {
  (x + 1.0) * 0.5 * width
}

///|
fn ndc_to_pixel_y(y : Double, height : Double) -> Double {
  (1.0 - y) * 0.5 * height
}

///|
fn unit_to_byte(value : Double) -> Int {
  let scaled = value * 255.0 + 0.5
  if scaled <= 0.0 {
    0
  } else if scaled >= 255.0 {
    255
  } else {
    scaled.to_int()
  }
}

///|
fn floor_to_int(value : Double) -> Int {
  let truncated = value.to_int()
  if value < 0.0 && truncated.to_double() != value {
    truncated - 1
  } else {
    truncated
  }
}

///|
fn ceil_to_int(value : Double) -> Int {
  let truncated = value.to_int()
  if value > 0.0 && truncated.to_double() != value {
    truncated + 1
  } else {
    truncated
  }
}

///|
fn clamp_int(value : Int, low : Int, high : Int) -> Int {
  if value < low {
    low
  } else if value > high {
    high
  } else {
    value
  }
}

///|
fn min_int(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn min3(a : Double, b : Double, c : Double) -> Double {
  let m = if a < b { a } else { b }
  if m < c {
    m
  } else {
    c
  }
}

///|
fn max3(a : Double, b : Double, c : Double) -> Double {
  let m = if a > b { a } else { b }
  if m > c {
    m
  } else {
    c
  }
}
