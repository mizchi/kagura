///|
/// Sprite-level draw-command builders based on atlas repositories.
///
/// Ebiten refs:
/// - internal/atlas/image.go
/// - internal/graphicscommand/command.go

///|
pub fn new_atlas_sprite_draw_command(
  atlas_repository : @asset.SimpleAtlasImageRepository,
  atlas_key : @asset.AssetKey,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  index_offset : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
  uniform_dwords : Array[Int],
) -> @gfx.DrawTrianglesCommand? {
  match @asset.get_atlas_draw_source(atlas_repository, atlas_key) {
    Some(source) =>
      Some(
        @draw2d.new_atlas_quad_draw_command(
          dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend,
          source, left, top, right, bottom, uniform_dwords,
        ),
      )
    None => None
  }
}

///|
pub fn append_atlas_sprite_draw_command(
  commands : Array[@gfx.DrawTrianglesCommand],
  atlas_repository : @asset.SimpleAtlasImageRepository,
  atlas_key : @asset.AssetKey,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  index_offset : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
  uniform_dwords : Array[Int],
) -> Bool {
  match
    new_atlas_sprite_draw_command(
      atlas_repository, atlas_key, dst, shader, dst_region, index_offset, pipeline_id,
      uniform_hash, blend, left, top, right, bottom, uniform_dwords,
    ) {
    Some(command) => {
      commands.push(command)
      true
    }
    None => false
  }
}
