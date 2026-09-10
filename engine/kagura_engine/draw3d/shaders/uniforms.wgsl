// Same 104-dword contract as pbr_uniform_dwords(environment=Some, shadow=Some).
struct Uniforms {
  mvp: mat4x4<f32>, model: mat4x4<f32>,
  normal_col0: vec4<f32>, normal_col1: vec4<f32>, normal_col2: vec4<f32>,
  light_dir: vec4<f32>, light_color: vec4<f32>, ambient_color: vec4<f32>,
  base_color: vec4<f32>, pbr_params: vec4<f32>, emissive: vec4<f32>, camera_pos: vec4<f32>,
  environment_ground: vec4<f32>, environment_params: vec4<f32>, fog_color: vec4<f32>,
  light_vp: mat4x4<f32>, shadow_params: vec4<f32>,
};
@group(0) @binding(0) var<uniform> uniforms: Uniforms;
@group(0) @binding(1) var tex: texture_2d<f32>;
@group(0) @binding(2) var tex_sampler: sampler;
struct VertexInput {
  @location(0) position: vec3<f32>, @location(1) normal: vec3<f32>, @location(2) uv: vec2<f32>,
};
struct VertexOutput {
  @builtin(position) clip_position: vec4<f32>,
  @location(0) world_normal: vec3<f32>, @location(1) world_position: vec3<f32>,
  @location(2) uv: vec2<f32>, @location(3) view_depth: f32,
  @location(4) shadow_position: vec4<f32>,
};
@vertex fn vs_main(input: VertexInput) -> VertexOutput {
  var out: VertexOutput;
  out.clip_position = uniforms.mvp * vec4(input.position, 1);
  out.view_depth = out.clip_position.w;
  let normal_matrix = mat3x3<f32>(uniforms.normal_col0.xyz, uniforms.normal_col1.xyz, uniforms.normal_col2.xyz);
  out.world_normal = normalize(normal_matrix * input.normal);
  out.world_position = (uniforms.model * vec4(input.position, 1)).xyz;
  out.shadow_position = uniforms.light_vp * vec4(out.world_position + out.world_normal * 0.04, 1);
  out.uv = input.uv;
  return out;
}
