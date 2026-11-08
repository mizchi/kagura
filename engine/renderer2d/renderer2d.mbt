///|
pub(all) struct RenderFrame2D {
  dst : @gfx.ImageHandle
  shader : @gfx.ShaderHandle
  screen_w : Int32
  screen_h : Int32
  pipeline_id : Int32
  uniform_hash : Int32
  blend : @gfx.BlendMode
}

///|
pub fn RenderFrame2D::new(
  dst~ : @gfx.ImageHandle,
  shader~ : @gfx.ShaderHandle,
  screen_w~ : Int32,
  screen_h~ : Int32,
  pipeline_id~ : Int32 = 0,
  uniform_hash~ : Int32 = 0,
  blend~ : @gfx.BlendMode = @gfx.BlendMode::from_int(1),
) -> RenderFrame2D {
  { dst, shader, screen_w, screen_h, pipeline_id, uniform_hash, blend, }
}

///|
pub fn RenderFrame2D::dst_region(self : RenderFrame2D) -> @gfx.DstRegion {
  @gfx.new_dst_region(0, 0, self.screen_w, self.screen_h, 6)
}
