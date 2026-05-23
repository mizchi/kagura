///|
pub(all) struct RenderFrame2D {
  dst : @gfx.ImageHandle
  shader : @gfx.ShaderHandle
  screen_w : Int
  screen_h : Int
  pipeline_id : Int
  uniform_hash : Int
  blend : @gfx.BlendMode
}

///|
pub fn RenderFrame2D::new(
  dst~ : @gfx.ImageHandle,
  shader~ : @gfx.ShaderHandle,
  screen_w~ : Int,
  screen_h~ : Int,
  pipeline_id? : Int = 0,
  uniform_hash? : Int = 0,
  blend? : @gfx.BlendMode = @gfx.BlendMode::from_int(1),
) -> RenderFrame2D {
  { dst, shader, screen_w, screen_h, pipeline_id, uniform_hash, blend }
}

///|
pub fn RenderFrame2D::dst_region(self : RenderFrame2D) -> @gfx.DstRegion {
  @gfx.new_dst_region(0, 0, self.screen_w, self.screen_h, 6)
}

///|
pub fn color_from_hex(hex : Int) -> @gfx.Color {
  @debugutil.color_from_hex(hex)
}

///|
pub fn color_from_hex_alpha(hex : Int, alpha : Double) -> @gfx.Color {
  @debugutil.color_from_hex_alpha(hex, alpha)
}

///|
pub fn color_white() -> @gfx.Color {
  @debugutil.color_white()
}

///|
pub fn color_to_uniform_dwords(color : @gfx.Color) -> Array[Int] {
  @debugutil.color_to_uniform_dwords(color)
}
