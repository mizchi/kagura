///|
/// Fullscreen quad vertex data in NDC [-1, 1].
/// Stride 4: x, y, u, v per vertex. 4 vertices = 16 floats.
pub fn fullscreen_quad_vertex_data() -> Array[Double] {
  [
    // bottom-left
    -1.0, -1.0, 0.0, 1.0,
    // bottom-right
    1.0, -1.0, 1.0, 1.0,
    // top-right
    1.0, 1.0, 1.0, 0.0,
    // top-left
    -1.0, 1.0, 0.0, 0.0,
  ]
}

///|
/// Fullscreen quad indices: two triangles covering the screen.
pub fn fullscreen_quad_indices() -> Array[Int] {
  [0, 1, 2, 2, 3, 0]
}

///|
/// Build a DrawTrianglesCommand for a fullscreen post-processing pass.
pub fn new_fullscreen_quad_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  src_image_ids : Array[Int],
  uniform_dwords : Array[Int],
  blend : @gfx.BlendMode,
) -> @gfx.DrawTrianglesCommand {
  let dst_region = @gfx.new_dst_region(0, 0, dst.width, dst.height, 6)
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    0,
    0,
    0,
    blend,
    fullscreen_quad_vertex_data(),
    fullscreen_quad_indices(),
    src_image_ids,
    uniform_dwords,
  )
}
