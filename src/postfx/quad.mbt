///|
/// Common fullscreen quad vertex shader for postfx passes.
/// Stride 16: vec2 position + vec2 uv.
pub fn fullscreen_vertex_wgsl() -> String {
  "struct VertexInput {\n" +
  "  @location(0) position: vec2<f32>,\n" +
  "  @location(1) uv: vec2<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) uv: vec2<f32>,\n" +
  "};\n\n" +
  "@vertex fn vs_main(in: VertexInput) -> VertexOutput {\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = vec4<f32>(in.position, 0.0, 1.0);\n" +
  "  out.uv = in.uv;\n" +
  "  return out;\n" +
  "}\n\n"
}

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
fn fullscreen_quad_resource_cache_key(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  src_image_ids : Array[Int],
  uniform_dwords : Array[Int],
  blend : @gfx.BlendMode,
) -> Int {
  let values : Array[Int] = [
    dst.id,
    dst.width,
    dst.height,
    shader.id,
    @gfx.blend_mode_to_int(blend),
    src_image_ids.length(),
    uniform_dwords.length(),
  ]
  for image_id in src_image_ids {
    values.push(image_id)
  }
  for dword in uniform_dwords {
    values.push(dword)
  }
  @gfx.build_resource_cache_key(0x504F5354, values)
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
    resource_cache_key=fullscreen_quad_resource_cache_key(
      dst, shader, src_image_ids, uniform_dwords, blend,
    ),
  )
}
