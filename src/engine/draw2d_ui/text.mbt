///|
/// Render text at pixel coordinates using a TextRenderer.
/// Converts pixel-space vertices to NDC for the builtin shader.
pub fn render_text(
  text_renderer : @text.TextRenderer,
  text : String,
  size_px : Double,
  x : Double,
  y : Double,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  color_hex : Int,
  screen_w : Double,
  screen_h : Double,
) -> Array[@gfx.DrawTrianglesCommand] {
  let blend = @gfx.blend_mode_from_int(1)
  let r = (color_hex >> 16) & 0xFF
  let g = (color_hex >> 8) & 0xFF
  let b = color_hex & 0xFF
  let uniform = [r, g, b, 255]
  let cmds = text_renderer.render_text(
    text, size_px, x, y, dst, shader, blend, uniform,
  )
  // Convert pixel-space vertices to NDC (stride 4: x, y, u, v)
  let result : Array[@gfx.DrawTrianglesCommand] = []
  for cmd in cmds {
    let vdata = cmd.vertex_data
    let ndc_vdata : Array[Double] = Array::make(vdata.length(), 0.0)
    for i = 0; i < vdata.length(); i = i + 4 {
      ndc_vdata[i] = vdata[i] / screen_w * 2.0 - 1.0 // x → NDC
      ndc_vdata[i + 1] = -(vdata[i + 1] / screen_h * 2.0 - 1.0) // y → NDC (flip)
      ndc_vdata[i + 2] = vdata[i + 2] // u
      ndc_vdata[i + 3] = vdata[i + 3] // v
    }
    result.push(
      @gfx.new_draw_triangles_command(
        cmd.dst,
        cmd.shader,
        cmd.dst_regions,
        cmd.index_offset,
        cmd.pipeline_id,
        cmd.uniform_hash,
        blend,
        ndc_vdata,
        cmd.indices,
        cmd.src_image_ids,
        cmd.uniform_dwords,
      ),
    )
  }
  result
}

///|
/// Measure text dimensions without rendering.
pub fn measure_text(
  text_renderer : @text.TextRenderer,
  text : String,
  size_px : Double,
) -> @text.TextMetrics {
  text_renderer.measure(text, size_px)
}
