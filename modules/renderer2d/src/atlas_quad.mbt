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

// Cheap 32-bit hash for a Double. Used only for the (non-functional)
// resource_cache_key metadata, so any deterministic mapping works -
// gfx's queue propagates this value but never compares it. Scaling by 4096
// keeps sub-quarter-pixel resolution which is finer than sprite cache_key
// needs across the typical screen-coordinate range.
fn double_cache_bits(v : Double) -> Int {
  (v * 4096.0).to_int()
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
  hash = mix_cache_key(hash, double_cache_bits(source.u0))
  hash = mix_cache_key(hash, double_cache_bits(source.v0))
  hash = mix_cache_key(hash, double_cache_bits(source.u1))
  hash = mix_cache_key(hash, double_cache_bits(source.v1))
  hash = mix_cache_key(hash, double_cache_bits(left))
  hash = mix_cache_key(hash, double_cache_bits(top))
  hash = mix_cache_key(hash, double_cache_bits(right))
  hash = mix_cache_key(hash, double_cache_bits(bottom))
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

///|
/// Batched atlas quad cache key. Hashes the shared state (dst, shader,
/// blend, source, region) plus a small fingerprint of the rect buffer
/// (count + first/last endpoints) rather than every rect element. The
/// cache key is non-functional metadata (gfx propagates it but never
/// compares it), so a coarse fingerprint is sufficient and avoids
/// O(N) hash work per batch.
fn atlas_quad_batch_resource_cache_key(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  blend : @gfx.BlendMode,
  source : @atlas.AtlasDrawSource,
  rects : Array[Double],
  uniform_dwords : Array[Int],
) -> Int {
  let mut hash = 0x41514254 // "AQBT"
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
  hash = mix_cache_key(hash, double_cache_bits(source.u0))
  hash = mix_cache_key(hash, double_cache_bits(source.v0))
  hash = mix_cache_key(hash, double_cache_bits(source.u1))
  hash = mix_cache_key(hash, double_cache_bits(source.v1))
  hash = mix_cache_key(hash, rects.length())
  hash = mix_cache_key(hash, uniform_dwords.length())
  // Sample endpoints rather than the whole buffer (O(1) instead of O(N)).
  if rects.length() >= 4 {
    hash = mix_cache_key(hash, double_cache_bits(rects[0]))
    hash = mix_cache_key(hash, double_cache_bits(rects[1]))
    hash = mix_cache_key(hash, double_cache_bits(rects[2]))
    hash = mix_cache_key(hash, double_cache_bits(rects[3]))
    let last = rects.length() - 4
    hash = mix_cache_key(hash, double_cache_bits(rects[last]))
    hash = mix_cache_key(hash, double_cache_bits(rects[last + 1]))
    hash = mix_cache_key(hash, double_cache_bits(rects[last + 2]))
    hash = mix_cache_key(hash, double_cache_bits(rects[last + 3]))
  }
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
/// Build a single DrawTrianglesCommand covering N quads that share one
/// atlas source, shader, dst region, pipeline, blend, and uniform state.
/// `rects` is laid out as [l0, t0, r0, b0, l1, t1, r1, b1, ...] so the
/// caller never allocates per-quad arrays. Quad count = rects.length() / 4;
/// trailing partial elements are ignored. dst_region.index_count is
/// overridden to 6*N so the GPU draws all quads in one call.
pub fn new_atlas_quad_batch_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  source : @atlas.AtlasDrawSource,
  rects : Array[Double],
  uniform_dwords : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  let quad_count = rects.length() / 4
  let vertex_data : Array[Double] = Array::make(quad_count * 16, 0.0)
  let indices : Array[Int] = Array::make(quad_count * 6, 0)
  let u0 = source.u0
  let v0 = source.v0
  let u1 = source.u1
  let v1 = source.v1
  for i in 0..<quad_count {
    let left = rects[i * 4]
    let top = rects[i * 4 + 1]
    let right = rects[i * 4 + 2]
    let bottom = rects[i * 4 + 3]
    let vbase = i * 16
    // TL
    vertex_data[vbase] = left
    vertex_data[vbase + 1] = top
    vertex_data[vbase + 2] = u0
    vertex_data[vbase + 3] = v0
    // TR
    vertex_data[vbase + 4] = right
    vertex_data[vbase + 5] = top
    vertex_data[vbase + 6] = u1
    vertex_data[vbase + 7] = v0
    // BR
    vertex_data[vbase + 8] = right
    vertex_data[vbase + 9] = bottom
    vertex_data[vbase + 10] = u1
    vertex_data[vbase + 11] = v1
    // BL
    vertex_data[vbase + 12] = left
    vertex_data[vbase + 13] = bottom
    vertex_data[vbase + 14] = u0
    vertex_data[vbase + 15] = v1
    let ibase = i * 6
    let vstart = i * 4
    indices[ibase] = vstart
    indices[ibase + 1] = vstart + 1
    indices[ibase + 2] = vstart + 2
    indices[ibase + 3] = vstart + 2
    indices[ibase + 4] = vstart + 3
    indices[ibase + 5] = vstart
  }
  let region = @gfx.new_dst_region(
    dst_region.x,
    dst_region.y,
    dst_region.width,
    dst_region.height,
    quad_count * 6,
  )
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [region],
    0,
    pipeline_id,
    uniform_hash,
    blend,
    vertex_data,
    indices,
    [source.page_image_id],
    uniform_dwords,
    resource_cache_key=atlas_quad_batch_resource_cache_key(
      dst, shader, region, blend, source, rects, uniform_dwords,
    ),
  )
}
