///|
/// Tone mapping operators for HDR to LDR conversion.
pub(all) enum ToneMapOperator {
  Reinhard
  ACES
}

///|
/// WGSL shader source for fullscreen tone mapping.
/// Uniform: vec4<f32> where x = exposure.
pub fn tonemap_wgsl(op : ToneMapOperator) -> String {
  let tonemap_fn = match op {
    Reinhard =>
      "fn tonemap(color: vec3<f32>) -> vec3<f32> {\n" +
      "  return color / (color + vec3<f32>(1.0));\n" +
      "}\n\n"
    ACES =>
      "fn tonemap(color: vec3<f32>) -> vec3<f32> {\n" +
      "  let a = 2.51;\n" +
      "  let b = 0.03;\n" +
      "  let c = 2.43;\n" +
      "  let d = 0.59;\n" +
      "  let e = 0.14;\n" +
      "  return clamp((color * (a * color + b)) / (color * (c * color + d) + e), vec3<f32>(0.0), vec3<f32>(1.0));\n" +
      "}\n\n"
  }
  fullscreen_vertex_wgsl() +
  "struct Uniforms {\n" +
  "  exposure: vec4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var tex_sampler: sampler;\n\n" +
  tonemap_fn +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let hdr_color = textureSampleLevel(tex, tex_sampler, in.uv, 0.0).rgb;\n" +
  "  let exposed = hdr_color * uniforms.exposure.x;\n" +
  "  let ldr_color = tonemap(exposed);\n" +
  "  // Vignette: darken edges for atmospheric framing\n" +
  "  let vignette_uv = in.uv * 2.0 - 1.0;\n" +
  "  let vignette_dist = dot(vignette_uv, vignette_uv);\n" +
  "  let vignette = smoothstep(2.0, 0.7, vignette_dist);\n" +
  "  var final_color = ldr_color * vignette;\n" +
  "  // Hit flash: mix red tint based on uniforms.exposure.y\n" +
  "  let flash = uniforms.exposure.y;\n" +
  "  if (flash > 0.0) {\n" +
  "    let edge_boost = smoothstep(0.3, 1.2, vignette_dist);\n" +
  "    let red_tint = vec3<f32>(0.6, 0.05, 0.05);\n" +
  "    final_color = mix(final_color, red_tint, flash * 0.25 * (1.0 + edge_boost));\n" +
  "  }\n" +
  "  return vec4<f32>(final_color, 1.0);\n" +
  "}\n"
}

///|
/// Encode tone map uniform as 4 dwords (vec4 alignment).
pub fn tonemap_uniform_dwords(
  exposure : Double,
  hit_flash? : Double = 0.0,
) -> Array[Int] {
  [@gfx.double_to_f32_bits(exposure), @gfx.double_to_f32_bits(hit_flash), 0, 0]
}

///|
/// Build a tone mapping post-process command.
pub fn new_tonemap_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  src_image_id : Int,
  exposure : Double,
  hit_flash? : Double = 0.0,
) -> @gfx.DrawTrianglesCommand {
  new_fullscreen_quad_command(
    dst,
    shader,
    [src_image_id],
    tonemap_uniform_dwords(exposure, hit_flash~),
    @gfx.blend_mode_from_int(0),
  )
}
