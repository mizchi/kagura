///|
/// 2D draw-command builders.
///
/// Ebiten refs:
/// - internal/atlas/image.go (atlas page + region UV)
/// - internal/graphicscommand/command.go (DrawTriangles payload)

///|
pub fn atlas_quad_indices() -> Array[Int] {
  [0, 1, 2, 2, 3, 0]
}

///|
pub fn atlas_quad_vertex_data(
  source : @asset.AtlasDrawSource,
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

///|
pub fn new_atlas_quad_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  index_offset : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  source : @asset.AtlasDrawSource,
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
  )
}
