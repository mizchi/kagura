///|
/// Distance fog post-process: blends scene color toward fog color based on depth.
/// Uniform: fog_color.rgb, fog_start (w), fog_end (x of second vec4), fog_density (y).
pub fn fog_wgsl() -> String {
  fullscreen_vertex_wgsl() +
  "struct Uniforms {\n" +
  "  fog_color_and_start: vec4<f32>,\n" +
  "  fog_params: vec4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var scene_tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var scene_sampler: sampler;\n" +
  "@group(0) @binding(3) var depth_tex: texture_2d<f32>;\n" +
  "@group(0) @binding(4) var depth_sampler: sampler;\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let scene_color = textureSampleLevel(scene_tex, scene_sampler, in.uv, 0.0).rgb;\n" +
  "  let depth_raw = textureSampleLevel(depth_tex, depth_sampler, in.uv, 0.0).r;\n" +
  "  let fog_color = uniforms.fog_color_and_start.rgb;\n" +
  "  let fog_start = uniforms.fog_color_and_start.w;\n" +
  "  let fog_end = uniforms.fog_params.x;\n" +
  "  // depth_raw: 0=near, 1=far. Apply fog between start and end thresholds.\n" +
  "  let fog_factor = smoothstep(fog_start, fog_end, depth_raw);\n" +
  "  let final_color = mix(scene_color, fog_color, fog_factor);\n" +
  "  return vec4<f32>(final_color, 1.0);\n" +
  "}\n"
}

///|
pub fn fog_uniform_dwords(
  fog_r : Double,
  fog_g : Double,
  fog_b : Double,
  fog_start : Double,
  fog_end : Double,
) -> Array[Int] {
  [
    @gfx.double_to_f32_bits(fog_r),
    @gfx.double_to_f32_bits(fog_g),
    @gfx.double_to_f32_bits(fog_b),
    @gfx.double_to_f32_bits(fog_start),
    @gfx.double_to_f32_bits(fog_end),
    0,
    0,
    0,
  ]
}

///|
pub fn new_fog_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  scene_image_id : Int,
  depth_image_id : Int,
  fog_r : Double,
  fog_g : Double,
  fog_b : Double,
  fog_start : Double,
  fog_end : Double,
) -> @gfx.DrawTrianglesCommand {
  new_fullscreen_quad_command(
    dst,
    shader,
    [scene_image_id, depth_image_id],
    fog_uniform_dwords(fog_r, fog_g, fog_b, fog_start, fog_end),
    @gfx.blend_mode_from_int(0),
  )
}
