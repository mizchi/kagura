struct Uniforms { uv_scale: vec2<f32>, };
@group(0) @binding(0) var<uniform> uniforms: Uniforms;
// The source scene already contains display sRGB. Copy resolved MSAA with no second filter.
@group(0) @binding(1) var scene: texture_2d<f32>;
@group(0) @binding(2) var scene_sampler: sampler;
struct Input { @location(0) position: vec2<f32>, @location(1) uv: vec2<f32>, };
struct Output { @builtin(position) position: vec4<f32>, @location(0) uv: vec2<f32>, };
@vertex fn vs_main(input: Input) -> Output {
  var out: Output; out.position = vec4(input.position, 0, 1); out.uv = input.uv; return out;
}
@fragment fn fs_main(in: Output) -> @location(0) vec4<f32> {
  return textureSampleLevel(scene, scene_sampler, in.uv * uniforms.uv_scale, 0);
}
