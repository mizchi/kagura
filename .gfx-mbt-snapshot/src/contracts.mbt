///|
/// Core command-buffer types: `DstRegion`, `Color`, `RenderPassDesc`,
/// `DrawTrianglesCommand`, `DrawCommandDispatch` and the
/// `build_draw_command_dispatch` / `dispatch_checksum` helpers.
///
/// These are deliberately type-erased (vertex payload is
/// `Array[Double]`, indices are `Array[Int]`, uniforms are dwords) so
/// the same command struct flows through any `GraphicsDriver` impl.
///
/// Ebiten refs:
/// - internal/graphicsdriver/graphics.go
/// - internal/graphicscommand/commandqueue.go
/// - internal/atlas/image.go

///|
/// One destination scissor rectangle on the target image, plus the
/// number of indices the caller intends to consume inside it. A
/// command can have several `DstRegion`s when batching independent
/// scissors that share state.
pub(all) struct DstRegion {
  x : Int
  y : Int
  width : Int
  height : Int
  index_count : Int
} derive(Debug)

///|
pub impl Show for DstRegion with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn new_dst_region(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  index_count : Int,
) -> DstRegion {
  { x, y, width, height, index_count }
}

///|
/// RGBA color with channels in `[0.0, 1.0]` (linear, premultiplied is
/// left to the shader). Values outside the range are not clamped here.
pub(all) struct Color {
  r : Double
  g : Double
  b : Double
  a : Double
} derive(Debug)

///|
pub impl Show for Color with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// What `GraphicsDriver.begin` does before any draw calls of a pass.
///
/// `clear_enabled=false` keeps the previous framebuffer contents
/// (useful for additive overlays). `present=true` swaps buffers at
/// `end`; set false for offscreen render-to-texture passes.
pub(all) struct RenderPassDesc {
  clear_color : Color
  clear_enabled : Bool
  present : Bool
} derive(Debug)

///|
pub impl Show for RenderPassDesc with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn new_color(r : Double, g : Double, b : Double, a : Double) -> Color {
  { r, g, b, a }
}

///|
pub fn new_render_pass_desc(
  clear_color : Color,
  clear_enabled : Bool,
  present? : Bool = true,
) -> RenderPassDesc {
  { clear_color, clear_enabled, present }
}

///|
/// One indexed-triangle draw issued against a render target.
///
/// This is the unit of work both the `CommandQueue` and the
/// `GraphicsDriver` traffic in. Two adjacent commands with the same
/// `dst` / `shader` / `pipeline_id` / `uniform_hash` / `blend` /
/// `src_image_ids` / `uniform_dwords` and equal `index_offset` can be
/// merged into one larger draw by the queue.
///
/// Vertex / index data is type-erased into flat arrays so the command
/// stays backend-neutral; the shader interprets `vertex_data` according
/// to its declared input layout. `vertex_stride_hint` is a hint to the
/// backend pipeline picker (0 = auto, 4 = 2D, 8 = 3D, 16 = skinned).
pub(all) struct DrawTrianglesCommand {
  /// The image being drawn onto.
  dst : ImageHandle
  /// The compiled shader to execute.
  shader : ShaderHandle
  /// Destination scissor / region rectangles. Each region accumulates
  /// the triangle count it covers.
  dst_regions : Array[DstRegion]
  /// Offset into the index buffer when the backend caches geometry by
  /// `resource_cache_key`. 0 for explicit payloads.
  index_offset : Int
  /// Backend pipeline identifier (opaque, hashed by the queue).
  pipeline_id : Int
  /// Hash of the canonical uniform payload (`uniform_dwords`).
  uniform_hash : Int
  /// Blend state. `Custom(BlendEquation)` for non-preset modes.
  blend : BlendMode
  /// Optional explicit vertex payload. Empty when the backend reuses
  /// geometry via `resource_cache_key`.
  /// Ebiten ref: internal/graphicscommand/command.go (vertex payload).
  vertex_data : Array[Double]
  /// Optional explicit index payload. Empty when the backend resolves
  /// indices from cached geometry.
  indices : Array[Int]
  /// Bound source-image ids (texture0, texture1, ...).
  src_image_ids : Array[Int]
  /// Canonicalized uniform payload as raw dwords.
  uniform_dwords : Array[Int]
  /// 1 for ordinary draws; > 1 enables instanced rendering and
  /// disables batch-merge.
  instance_count : Int
  /// 0 to force the explicit payload to be uploaded; non-zero lets the
  /// backend reuse a previously uploaded buffer with the same key.
  resource_cache_key : Int
  /// 0 to let the backend pick the stride from the shader; > 0 sets it
  /// explicitly (4 = 2D, 8 = 3D, 16 = skinned).
  vertex_stride_hint : Int
} derive(Debug)

///|
pub fn new_draw_triangles_command(
  dst : ImageHandle,
  shader : ShaderHandle,
  dst_regions : Array[DstRegion],
  index_offset : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : BlendMode,
  vertex_data : Array[Double],
  indices : Array[Int],
  src_image_ids : Array[Int],
  uniform_dwords : Array[Int],
  instance_count? : Int = 1,
  resource_cache_key? : Int = 0,
  vertex_stride_hint? : Int = 0,
) -> DrawTrianglesCommand {
  {
    dst,
    shader,
    dst_regions,
    index_offset,
    pipeline_id,
    uniform_hash,
    blend,
    vertex_data,
    indices,
    src_image_ids,
    uniform_dwords,
    instance_count,
    resource_cache_key,
    vertex_stride_hint,
  }
}

///|
fn mix_resource_cache_key(seed : Int, value : Int) -> Int {
  seed * 16777619 + value + 31
}

///|
pub fn build_resource_cache_key(seed : Int, values : Array[Int]) -> Int {
  let mut hash = if seed == 0 { 146959810 } else { seed }
  for value in values {
    hash = mix_resource_cache_key(hash, value)
  }
  if hash == 0 {
    1
  } else {
    hash
  }
}

///|
pub(all) struct DrawCommandDispatch {
  draw_calls : Int
  pipeline_id : Int
  uniform_hash : Int
  blend_mode : Int
  dst_image_id : Int
  shader_id : Int
  index_offset : Int
  region_count : Int
  total_index_count : Int
  vertex_float_count : Int
  index_count : Int
  src_image_count : Int
  uniform_dword_count : Int
} derive(Debug)

///|
pub impl Show for DrawCommandDispatch with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
fn normalized_region_triangle_count(region : DstRegion) -> Int {
  if region.index_count <= 0 {
    1
  } else {
    let triangles = region.index_count / 3
    if triangles <= 0 {
      1
    } else {
      triangles
    }
  }
}

///|
fn normalized_region_index_count(region : DstRegion) -> Int {
  if region.index_count <= 0 {
    3
  } else {
    region.index_count
  }
}

///|
pub fn DrawTrianglesCommand::estimated_draw_call_count(
  self : DrawTrianglesCommand,
) -> Int {
  let mut draw_calls = 0
  for region in self.dst_regions {
    draw_calls = draw_calls + normalized_region_triangle_count(region)
  }
  draw_calls
}

///|
pub fn DrawTrianglesCommand::estimated_total_index_count(
  self : DrawTrianglesCommand,
) -> Int {
  let mut total = 0
  for region in self.dst_regions {
    total = total + normalized_region_index_count(region)
  }
  total
}

///|
fn resolved_index_count(command : DrawTrianglesCommand) -> Int {
  let explicit = command.indices.length()
  if explicit > 0 {
    explicit
  } else {
    command.estimated_total_index_count()
  }
}

///|
/// Build the `DrawCommandDispatch` summary the backend / queue use for
/// fingerprinting and merge decisions.
pub fn DrawTrianglesCommand::build_dispatch(
  self : DrawTrianglesCommand,
) -> DrawCommandDispatch {
  {
    draw_calls: self.estimated_draw_call_count(),
    pipeline_id: self.pipeline_id,
    uniform_hash: self.uniform_hash,
    blend_mode: self.blend.to_int(),
    dst_image_id: self.dst.id,
    shader_id: self.shader.id,
    index_offset: self.index_offset,
    region_count: self.dst_regions.length(),
    total_index_count: self.estimated_total_index_count(),
    vertex_float_count: self.vertex_data.length(),
    index_count: resolved_index_count(self),
    src_image_count: self.src_image_ids.length(),
    uniform_dword_count: self.uniform_dwords.length(),
  }
}

///|
/// Sum of every Int field of a `DrawCommandDispatch`. Cheap, branch-free
/// fingerprint useful in benches and tests where the caller just needs a
/// `b.keep`-able value derived from the whole dispatch (it is not a
/// cryptographic hash and is not collision-free).
pub fn DrawCommandDispatch::checksum(self : DrawCommandDispatch) -> Int {
  self.draw_calls +
  self.pipeline_id +
  self.uniform_hash +
  self.blend_mode +
  self.dst_image_id +
  self.shader_id +
  self.index_offset +
  self.region_count +
  self.total_index_count +
  self.vertex_float_count +
  self.index_count +
  self.src_image_count +
  self.uniform_dword_count
}
