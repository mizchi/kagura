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
  blend? : @gfx.BlendMode = @gfx.blend_mode_from_int(1),
) -> RenderFrame2D {
  { dst, shader, screen_w, screen_h, pipeline_id, uniform_hash, blend }
}

///|
pub(all) struct AtlasQuad2D {
  source : @asset.AtlasDrawSource
  left : Double
  top : Double
  right : Double
  bottom : Double
  uniform_dwords : Array[Int]
}

///|
pub fn AtlasQuad2D::new(
  source~ : @asset.AtlasDrawSource,
  left~ : Double,
  top~ : Double,
  right~ : Double,
  bottom~ : Double,
  uniform_dwords? : Array[Int] = [],
) -> AtlasQuad2D {
  { source, left, top, right, bottom, uniform_dwords }
}

///|
pub fn RenderFrame2D::dst_region(self : RenderFrame2D) -> @gfx.DstRegion {
  @gfx.new_dst_region(0, 0, self.screen_w, self.screen_h, 6)
}

///|
pub fn append_atlas_quad(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : RenderFrame2D,
  quad : AtlasQuad2D,
) -> Unit {
  commands.push(
    @draw2d.new_atlas_quad_draw_command(
      frame.dst,
      frame.shader,
      frame.dst_region(),
      0,
      frame.pipeline_id,
      frame.uniform_hash,
      frame.blend,
      quad.source,
      quad.left,
      quad.top,
      quad.right,
      quad.bottom,
      quad.uniform_dwords,
    ),
  )
}

///|
pub fn render_atlas_quads(
  frame : RenderFrame2D,
  quads : Array[AtlasQuad2D],
) -> Array[@gfx.DrawTrianglesCommand] {
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  for quad in quads {
    append_atlas_quad(commands, frame, quad)
  }
  commands
}
