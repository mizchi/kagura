///|
/// WGSL shader for screen-space ambient occlusion (SSAO).
/// Samples depth buffer neighborhood to estimate occlusion.
/// Uniform: vec4 where x=radius, y=bias, z=intensity, w=unused.
/// Binding 1: scene color texture, Binding 3: depth texture.
pub fn ssao_wgsl() -> String {
  fullscreen_vertex_wgsl() +
  "struct Uniforms {\n" +
  "  params: vec4<f32>,\n" +
  "  screen: vec4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var color_tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var color_sampler: sampler;\n" +
  "@group(0) @binding(3) var depth_tex: texture_2d<f32>;\n" +
  "@group(0) @binding(4) var depth_sampler: sampler;\n\n" +
  // Hash function for pseudo-random sampling
  "fn hash(p: vec2<f32>) -> f32 {\n" +
  "  let h = dot(p, vec2<f32>(127.1, 311.7));\n" +
  "  return fract(sin(h) * 43758.5453);\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let color = textureSampleLevel(color_tex, color_sampler, in.uv, 0.0);\n" +
  "  let depth = textureSampleLevel(depth_tex, depth_sampler, in.uv, 0.0).r;\n" +
  "  let radius = uniforms.params.x;\n" +
  "  let bias = uniforms.params.y;\n" +
  "  let intensity = uniforms.params.z;\n" +
  "  let texel = vec2<f32>(1.0 / uniforms.screen.x, 1.0 / uniforms.screen.y);\n" +
  // 8-tap sample pattern
  "  var occlusion = 0.0;\n" +
  "  let samples = 8;\n" +
  "  let golden_angle = 2.39996;\n" +
  "  for (var i = 0; i < samples; i++) {\n" +
  "    let fi = f32(i);\n" +
  "    let angle = fi * golden_angle + hash(in.uv * 1000.0 + fi);\n" +
  "    let r = radius * (fi + 1.0) / f32(samples);\n" +
  "    let offset = vec2<f32>(cos(angle), sin(angle)) * r * texel;\n" +
  "    let sample_depth = textureSampleLevel(depth_tex, depth_sampler, in.uv + offset, 0.0).r;\n" +
  "    let range_check = smoothstep(0.0, 1.0, radius / (abs(depth - sample_depth) + 0.001));\n" +
  "    occlusion += select(0.0, 1.0, sample_depth < depth - bias) * range_check;\n" +
  "  }\n" +
  "  occlusion = 1.0 - (occlusion / f32(samples)) * intensity;\n" +
  "  return vec4<f32>(color.rgb * occlusion, color.a);\n" +
  "}\n"
}

///|
/// Encode SSAO uniforms: radius, bias, intensity, screen dimensions.
pub fn ssao_uniform_dwords(
  radius : Double,
  bias : Double,
  intensity : Double,
  screen_w : Int,
  screen_h : Int,
) -> Array[Int] {
  [
    @gfx.double_to_f32_bits(radius),
    @gfx.double_to_f32_bits(bias),
    @gfx.double_to_f32_bits(intensity),
    0, // unused
    @gfx.double_to_f32_bits(screen_w.to_double()),
    @gfx.double_to_f32_bits(screen_h.to_double()),
    0,
    0,
  ]
}

///|
/// Build SSAO draw command.
pub fn new_ssao_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  color_src_id : Int,
  depth_src_id : Int,
  radius : Double,
  bias : Double,
  intensity : Double,
  screen_w : Int,
  screen_h : Int,
) -> @gfx.DrawTrianglesCommand {
  new_fullscreen_quad_command(
    dst,
    shader,
    [color_src_id, depth_src_id],
    ssao_uniform_dwords(radius, bias, intensity, screen_w, screen_h),
    @gfx.BlendMode::from_int(0),
  )
}
