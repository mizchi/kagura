///|
pub(all) struct AtlasQuad2D {
  source : @atlas.AtlasDrawSource
  left : Double
  top : Double
  right : Double
  bottom : Double
  uniform_dwords : Array[Int]
}

///|
pub fn AtlasQuad2D::new(
  source~ : @atlas.AtlasDrawSource,
  left~ : Double,
  top~ : Double,
  right~ : Double,
  bottom~ : Double,
  uniform_dwords? : Array[Int] = [],
) -> AtlasQuad2D {
  { source, left, top, right, bottom, uniform_dwords }
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
