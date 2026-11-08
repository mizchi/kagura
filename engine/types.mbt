///|
pub(all) struct EngineContext {
  mut dst : @gfx.ImageHandle
  shader : @gfx.ShaderHandle
  mut screen_w : Int32
  mut screen_h : Int32
}
