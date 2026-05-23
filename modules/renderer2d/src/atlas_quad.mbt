///|
/// 2D draw-command builders.
///
/// Ebiten refs:
/// - internal/atlas/image.go (atlas page + region UV)
/// - internal/graphicscommand/command.go (DrawTriangles payload)

// Shared, read-only quad-index pattern. The downstream gfx queue / merger
// only reads `.length()` on indices, so reusing one Array per call saves an
// allocation on every sprite draw. Do not mutate.
let atlas_quad_indices_shared : Array[Int] = [0, 1, 2, 2, 3, 0]

///|
pub fn atlas_quad_indices() -> Array[Int] {
  atlas_quad_indices_shared
}

///|
pub fn atlas_quad_vertex_data(
  source : @atlas.AtlasDrawSource,
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
) -> Array[Double] {
  [
    left,
    top,
    source.u0,
    source.v0,
    right,
    top,
    source.u1,
    source.v0,
    right,
    bottom,
    source.u1,
    source.v1,
    left,
    bottom,
    source.u0,
    source.v1,
  ]
}

// Must mirror `mix_resource_cache_key` in mizchi/gfx/src/contracts.mbt.
// Kept local so we can hash inline without allocating a values array.
fn mix_cache_key(seed : Int, value : Int) -> Int {
  seed * 16777619 + value + 31
}

///|
fn atlas_quad_resource_cache_key(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  blend : @gfx.BlendMode,
  source : @atlas.AtlasDrawSource,
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
  uniform_dwords : Array[Int],
) -> Int {
  let mut hash = 0x41544C53
  hash = mix_cache_key(hash, dst.id)
  hash = mix_cache_key(hash, dst.width)
  hash = mix_cache_key(hash, dst.height)
  hash = mix_cache_key(hash, shader.id)
  hash = mix_cache_key(hash, dst_region.x)
  hash = mix_cache_key(hash, dst_region.y)
  hash = mix_cache_key(hash, dst_region.width)
  hash = mix_cache_key(hash, dst_region.height)
  hash = mix_cache_key(hash, dst_region.index_count)
  hash = mix_cache_key(hash, @gfx.BlendMode::to_int(blend))
  hash = mix_cache_key(hash, source.page_image_id)
  hash = mix_cache_key(hash, @gfx.double_to_f32_bits(source.u0))
  hash = mix_cache_key(hash, @gfx.double_to_f32_bits(source.v0))
  hash = mix_cache_key(hash, @gfx.double_to_f32_bits(source.u1))
  hash = mix_cache_key(hash, @gfx.double_to_f32_bits(source.v1))
  hash = mix_cache_key(hash, @gfx.double_to_f32_bits(left))
  hash = mix_cache_key(hash, @gfx.double_to_f32_bits(top))
  hash = mix_cache_key(hash, @gfx.double_to_f32_bits(right))
  hash = mix_cache_key(hash, @gfx.double_to_f32_bits(bottom))
  hash = mix_cache_key(hash, uniform_dwords.length())
  for dword in uniform_dwords {
    hash = mix_cache_key(hash, dword)
  }
  if hash == 0 {
    1
  } else {
    hash
  }
}

///|
pub fn new_atlas_quad_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  index_offset : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  source : @atlas.AtlasDrawSource,
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
  uniform_dwords : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    index_offset,
    pipeline_id,
    uniform_hash,
    blend,
    atlas_quad_vertex_data(source, left, top, right, bottom),
    atlas_quad_indices(),
    [source.page_image_id],
    uniform_dwords,
    resource_cache_key=atlas_quad_resource_cache_key(
      dst, shader, dst_region, blend, source, left, top, right, bottom, uniform_dwords,
    ),
  )
}
