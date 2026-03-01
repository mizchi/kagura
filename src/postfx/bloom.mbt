///|
/// WGSL shader for brightness threshold extraction.
/// Uniform: vec4<f32> where x = threshold.
pub fn bloom_threshold_wgsl() -> String {
  "struct Uniforms {\n" +
  "  params: vec4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var tex_sampler: sampler;\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) uv: vec2<f32>,\n" +
  "};\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let color = textureSample(tex, tex_sampler, in.uv).rgb;\n" +
  "  let brightness = dot(color, vec3<f32>(0.2126, 0.7152, 0.0722));\n" +
  "  let threshold = uniforms.params.x;\n" +
  "  if brightness > threshold {\n" +
  "    return vec4<f32>(color, 1.0);\n" +
  "  }\n" +
  "  return vec4<f32>(0.0, 0.0, 0.0, 1.0);\n" +
  "}\n"
}

///|
/// WGSL shader for 9-tap Gaussian blur (horizontal or vertical).
/// Uniform: vec4<f32> where x = texel_w, y = texel_h.
pub fn bloom_blur_wgsl(horizontal : Bool) -> String {
  let dir = if horizontal {
    "vec2<f32>(texel.x, 0.0)"
  } else {
    "vec2<f32>(0.0, texel.y)"
  }
  "struct Uniforms {\n" +
  "  texel_size: vec4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var tex_sampler: sampler;\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) uv: vec2<f32>,\n" +
  "};\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let texel = uniforms.texel_size.xy;\n" +
  "  let dir = \{dir};\n" +
  "  var result = textureSample(tex, tex_sampler, in.uv).rgb * 0.2270270270;\n" +
  "  result += textureSample(tex, tex_sampler, in.uv + dir * 1.0).rgb * 0.1945945946;\n" +
  "  result += textureSample(tex, tex_sampler, in.uv - dir * 1.0).rgb * 0.1945945946;\n" +
  "  result += textureSample(tex, tex_sampler, in.uv + dir * 2.0).rgb * 0.1216216216;\n" +
  "  result += textureSample(tex, tex_sampler, in.uv - dir * 2.0).rgb * 0.1216216216;\n" +
  "  result += textureSample(tex, tex_sampler, in.uv + dir * 3.0).rgb * 0.0540540541;\n" +
  "  result += textureSample(tex, tex_sampler, in.uv - dir * 3.0).rgb * 0.0540540541;\n" +
  "  result += textureSample(tex, tex_sampler, in.uv + dir * 4.0).rgb * 0.0162162162;\n" +
  "  result += textureSample(tex, tex_sampler, in.uv - dir * 4.0).rgb * 0.0162162162;\n" +
  "  return vec4<f32>(result, 1.0);\n" +
  "}\n"
}

///|
/// WGSL shader for bloom composite (original + bloom additive blend).
/// Uniform: vec4<f32> where x = intensity.
/// Uses two source textures: @binding(1) scene, @binding(3) bloom.
pub fn bloom_composite_wgsl() -> String {
  "struct Uniforms {\n" +
  "  params: vec4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var scene_tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var scene_sampler: sampler;\n" +
  "@group(0) @binding(3) var bloom_tex: texture_2d<f32>;\n" +
  "@group(0) @binding(4) var bloom_sampler: sampler;\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) uv: vec2<f32>,\n" +
  "};\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let scene_color = textureSample(scene_tex, scene_sampler, in.uv).rgb;\n" +
  "  let bloom_color = textureSample(bloom_tex, bloom_sampler, in.uv).rgb;\n" +
  "  let intensity = uniforms.params.x;\n" +
  "  let result = scene_color + bloom_color * intensity;\n" +
  "  return vec4<f32>(result, 1.0);\n" +
  "}\n"
}

///|
/// Build the 4 bloom pass commands.
/// Flow: Scene->[threshold]->A->[hblur]->B->[vblur]->A->[composite(Scene+A)]->dst
pub fn bloom_commands(
  dst : @gfx.ImageHandle,
  scene_image_id : Int,
  bloom_a : @gfx.ImageHandle,
  bloom_b : @gfx.ImageHandle,
  threshold_shader : @gfx.ShaderHandle,
  hblur_shader : @gfx.ShaderHandle,
  vblur_shader : @gfx.ShaderHandle,
  composite_shader : @gfx.ShaderHandle,
  threshold : Double,
  intensity : Double,
  screen_w : Int,
  screen_h : Int,
) -> Array[@gfx.DrawTrianglesCommand] {
  let texel_w = 1.0 / screen_w.to_double()
  let texel_h = 1.0 / screen_h.to_double()
  let texel_dwords = [
    @gfx.double_to_f32_bits(texel_w),
    @gfx.double_to_f32_bits(texel_h),
    0,
    0,
  ]
  // Pass 1: threshold extract Scene -> bloom_a
  let cmd1 = new_fullscreen_quad_command(
    bloom_a,
    threshold_shader,
    [scene_image_id],
    [@gfx.double_to_f32_bits(threshold), 0, 0, 0],
    @gfx.blend_mode_from_int(0),
  )
  // Pass 2: horizontal blur bloom_a -> bloom_b
  let cmd2 = new_fullscreen_quad_command(
    bloom_b,
    hblur_shader,
    [bloom_a.id],
    texel_dwords,
    @gfx.blend_mode_from_int(0),
  )
  // Pass 3: vertical blur bloom_b -> bloom_a
  let cmd3 = new_fullscreen_quad_command(
    bloom_a,
    vblur_shader,
    [bloom_b.id],
    texel_dwords,
    @gfx.blend_mode_from_int(0),
  )
  // Pass 4: composite Scene + bloom_a -> dst
  let cmd4 = new_fullscreen_quad_command(
    dst,
    composite_shader,
    [scene_image_id, bloom_a.id],
    [@gfx.double_to_f32_bits(intensity), 0, 0, 0],
    @gfx.blend_mode_from_int(0),
  )
  [cmd1, cmd2, cmd3, cmd4]
}
