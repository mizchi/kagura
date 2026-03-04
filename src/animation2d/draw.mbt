///|
/// Append a draw command for the current frame of a sprite animation player.
/// Returns true if a command was appended, false if the atlas key was not found.
pub fn draw_sprite_animation(
  commands : Array[@gfx.DrawTrianglesCommand],
  atlas : @asset.SimpleAtlasImageRepository,
  player : SpriteAnimationPlayer,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  blend : @gfx.BlendMode,
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
) -> Bool {
  let key = player.current_key()
  @sprite2d.append_atlas_sprite_draw_command(
    commands, atlas, key, dst, shader, dst_region, 0, 0, 0, blend, left, top,
    right, bottom, [],
  )
}
