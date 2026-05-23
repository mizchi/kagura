///|
/// Graphics backend contracts.
/// Ebiten refs:
/// - internal/graphicsdriver/graphics.go
/// - internal/graphicscommand/commandqueue.go
/// - internal/atlas/image.go

///|
pub(all) struct DstRegion {
  x : Int
  y : Int
  width : Int
  height : Int
  index_count : Int
} derive(Debug)

///|
pub impl Show for DstRegion with output(self, logger) {
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
pub(all) struct Color {
  r : Double
  g : Double
  b : Double
  a : Double
} derive(Debug)

///|
pub impl Show for Color with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) struct RenderPassDesc {
  clear_color : Color
  clear_enabled : Bool
  present : Bool
} derive(Debug)

///|
pub impl Show for RenderPassDesc with output(self, logger) {
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
pub(all) struct DrawTrianglesCommand {
  dst : ImageHandle
  shader : ShaderHandle
  dst_regions : Array[DstRegion]
  index_offset : Int
  pipeline_id : Int
  uniform_hash : Int
  blend : BlendMode
  /// Optional explicit payload for backend bridge.
  /// Ebiten refs:
  /// - internal/graphicscommand/command.go (vertex/index payload)
  vertex_data : Array[Double]
  indices : Array[Int]
  src_image_ids : Array[Int]
  uniform_dwords : Array[Int]
  instance_count : Int // 1 = default (non-instanced)
  resource_cache_key : Int // 0 = disabled, non-zero allows backend payload cache reuse
  vertex_stride_hint : Int // 0 = auto-detect from shader, >0 = explicit stride (4=2D, 8=3D, 16=skinned)
}

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
pub impl Show for DrawCommandDispatch with output(self, logger) {
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
pub fn estimated_draw_call_count(command : DrawTrianglesCommand) -> Int {
  let mut draw_calls = 0
  for region in command.dst_regions {
    draw_calls = draw_calls + normalized_region_triangle_count(region)
  }
  draw_calls
}

///|
pub fn estimated_total_index_count(command : DrawTrianglesCommand) -> Int {
  let mut total = 0
  for region in command.dst_regions {
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
    estimated_total_index_count(command)
  }
}

///|
pub fn build_draw_command_dispatch(
  command : DrawTrianglesCommand,
) -> DrawCommandDispatch {
  {
    draw_calls: estimated_draw_call_count(command),
    pipeline_id: command.pipeline_id,
    uniform_hash: command.uniform_hash,
    blend_mode: blend_mode_to_int(command.blend),
    dst_image_id: command.dst.id,
    shader_id: command.shader.id,
    index_offset: command.index_offset,
    region_count: command.dst_regions.length(),
    total_index_count: estimated_total_index_count(command),
    vertex_float_count: command.vertex_data.length(),
    index_count: resolved_index_count(command),
    src_image_count: command.src_image_ids.length(),
    uniform_dword_count: command.uniform_dwords.length(),
  }
}

///|
/// Sum of every Int field of a `DrawCommandDispatch`. Cheap, branch-free
/// fingerprint useful in benches and tests where the caller just needs a
/// `b.keep`-able value derived from the whole dispatch (it is not a
/// cryptographic hash and is not collision-free).
pub fn dispatch_checksum(dispatch : DrawCommandDispatch) -> Int {
  dispatch.draw_calls +
  dispatch.pipeline_id +
  dispatch.uniform_hash +
  dispatch.blend_mode +
  dispatch.dst_image_id +
  dispatch.shader_id +
  dispatch.index_offset +
  dispatch.region_count +
  dispatch.total_index_count +
  dispatch.vertex_float_count +
  dispatch.index_count +
  dispatch.src_image_count +
  dispatch.uniform_dword_count
}

