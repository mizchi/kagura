///|
/// WGSL shader source for FXAA (Fast Approximate Anti-Aliasing).
/// Uniform: vec4<f32> where x = texel_w (1/screen_w), y = texel_h (1/screen_h).
pub fn fxaa_wgsl() -> String {
  "struct Uniforms {\n" +
  "  texel_size: vec4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var tex_sampler: sampler;\n\n" +
  "fn luminance(color: vec3<f32>) -> f32 {\n" +
  "  return dot(color, vec3<f32>(0.299, 0.587, 0.114));\n" +
  "}\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) uv: vec2<f32>,\n" +
  "};\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let texel = uniforms.texel_size.xy;\n" +
  "  let color_m = textureSample(tex, tex_sampler, in.uv).rgb;\n" +
  "  let color_n = textureSample(tex, tex_sampler, in.uv + vec2<f32>(0.0, -texel.y)).rgb;\n" +
  "  let color_s = textureSample(tex, tex_sampler, in.uv + vec2<f32>(0.0, texel.y)).rgb;\n" +
  "  let color_e = textureSample(tex, tex_sampler, in.uv + vec2<f32>(texel.x, 0.0)).rgb;\n" +
  "  let color_w = textureSample(tex, tex_sampler, in.uv + vec2<f32>(-texel.x, 0.0)).rgb;\n" +
  "  let luma_m = luminance(color_m);\n" +
  "  let luma_n = luminance(color_n);\n" +
  "  let luma_s = luminance(color_s);\n" +
  "  let luma_e = luminance(color_e);\n" +
  "  let luma_w = luminance(color_w);\n" +
  "  let luma_min = min(luma_m, min(min(luma_n, luma_s), min(luma_e, luma_w)));\n" +
  "  let luma_max = max(luma_m, max(max(luma_n, luma_s), max(luma_e, luma_w)));\n" +
  "  let luma_range = luma_max - luma_min;\n" +
  "  if luma_range < max(0.0312, luma_max * 0.125) {\n" +
  "    return vec4<f32>(color_m, 1.0);\n" +
  "  }\n" +
  "  let dir_x = -((luma_n + luma_s) - (luma_e + luma_w));\n" +
  "  let dir_y = (luma_n + luma_e) - (luma_s + luma_w);\n" +
  "  let dir_reduce = max((luma_n + luma_s + luma_e + luma_w) * 0.25 * 0.25, 1.0 / 128.0);\n" +
  "  let rcp_dir_min = 1.0 / (min(abs(dir_x), abs(dir_y)) + dir_reduce);\n" +
  "  let dir = clamp(vec2<f32>(dir_x, dir_y) * rcp_dir_min, vec2<f32>(-8.0), vec2<f32>(8.0)) * texel;\n" +
  "  let result_a = 0.5 * (\n" +
  "    textureSample(tex, tex_sampler, in.uv + dir * (1.0 / 3.0 - 0.5)).rgb +\n" +
  "    textureSample(tex, tex_sampler, in.uv + dir * (2.0 / 3.0 - 0.5)).rgb\n" +
  "  );\n" +
  "  let result_b = result_a * 0.5 + 0.25 * (\n" +
  "    textureSample(tex, tex_sampler, in.uv + dir * -0.5).rgb +\n" +
  "    textureSample(tex, tex_sampler, in.uv + dir * 0.5).rgb\n" +
  "  );\n" +
  "  let luma_b = luminance(result_b);\n" +
  "  if luma_b < luma_min || luma_b > luma_max {\n" +
  "    return vec4<f32>(result_a, 1.0);\n" +
  "  }\n" +
  "  return vec4<f32>(result_b, 1.0);\n" +
  "}\n"
}

///|
/// Encode FXAA uniform as 4 dwords (vec4 alignment).
pub fn fxaa_uniform_dwords(
  texel_w : Double,
  texel_h : Double,
) -> Array[Int] {
  [
    @gfx.double_to_f32_bits(texel_w),
    @gfx.double_to_f32_bits(texel_h),
    0,
    0,
  ]
}

///|
/// Build an FXAA post-process command.
pub fn new_fxaa_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  src_image_id : Int,
  screen_w : Int,
  screen_h : Int,
) -> @gfx.DrawTrianglesCommand {
  let texel_w = 1.0 / screen_w.to_double()
  let texel_h = 1.0 / screen_h.to_double()
  new_fullscreen_quad_command(
    dst,
    shader,
    [src_image_id],
    fxaa_uniform_dwords(texel_w, texel_h),
    @gfx.blend_mode_from_int(0),
  )
}
