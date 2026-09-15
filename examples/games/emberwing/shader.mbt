///|
let palette_shader : String =
  #|struct InstanceData { model: mat4x4<f32>, color: vec4<f32> }
  #|struct Uniforms {
  #| vp: mat4x4<f32>, light_dir: vec4<f32>, light_color: vec4<f32>, ambient_color: vec4<f32>,
  #| instance_count: vec4<f32>, instances: array<InstanceData, 256>
  #|}
  #|@group(0) @binding(0) var<uniform> uniforms: Uniforms;
  #|struct Input { @location(0) position: vec3<f32>, @location(1) normal: vec3<f32>, @location(2) uv: vec2<f32> }
  #|struct Output {
  #| @builtin(position) position: vec4<f32>, @location(0) normal: vec3<f32>,
  #| @location(1) color: vec3<f32>, @location(2) depth: f32, @location(3) glow: f32
  #|}
  #|@vertex fn vs_main(input: Input, @builtin(instance_index) index: u32) -> Output {
  #| let instance = uniforms.instances[index];
  #| let world = instance.model * vec4<f32>(input.position, 1.0);
  #| let m = instance.model;
  #| let packed = u32(input.uv.x);
  #| let rgb = vec3<f32>(f32((packed >> 16u) & 255u), f32((packed >> 8u) & 255u), f32(packed & 255u)) / 255.0;
  #| var out: Output;
  #| out.position = uniforms.vp * world;
  #| out.normal = normalize(mat3x3<f32>(m[0].xyz, m[1].xyz, m[2].xyz) * input.normal);
  #| out.color = rgb * instance.color.rgb;
  #| out.depth = out.position.w;
  #| out.glow = input.uv.y;
  #| return out;
  #|}
  #|@fragment fn fs_main(input: Output) -> @location(0) vec4<f32> {
  #| let diffuse = max(dot(normalize(input.normal), -normalize(uniforms.light_dir.xyz)), 0.0);
  #| let lit = input.color * (uniforms.ambient_color.rgb + uniforms.light_color.rgb * diffuse);
  #| let color = mix(lit, input.color, input.glow);
  #| let fog = smoothstep(65.0, 275.0, input.depth) * 0.86;
  #| return vec4<f32>(mix(color, vec3<f32>(0.76, 0.82, 0.77), fog), 1.0);
  #|}
