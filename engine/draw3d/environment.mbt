///|
/// Optional PBR environment. Source image is a six-level equirectangular atlas
/// (roughness 0..1 vertically), RGB encoded as log2(1+radiance)/log2(65).
/// Bind after the base-color texture, if present. All uniform colors are linear.
pub(all) struct PbrEnvironment {
  ground : @math3d.Vec3
  intensity : Double
  fog_color : @math3d.Vec3
  fog_near : Double
  fog_far : Double
}

///|
fn environment_uniforms(e : PbrEnvironment) -> Array[Int] {
  [
    f32(e.ground.x),
    f32(e.ground.y),
    f32(e.ground.z),
    0,
    f32(e.intensity),
    0,
    f32(e.fog_near),
    f32(e.fog_far),
    f32(e.fog_color.x),
    f32(e.fog_color.y),
    f32(e.fog_color.z),
    0,
  ]
}

///|
fn environment_wgsl() -> String {
  let source =
    #|@group(0) @binding(3) var environment_map: texture_2d<f32>;
    #|@group(0) @binding(4) var environment_sampler: sampler;
    #|fn environment_texel(pixel: vec2<i32>) -> vec3<f32> {
    #|  let size = textureDimensions(environment_map);
    #|  let p = vec2<i32>((pixel.x + i32(size.x)) % i32(size.x), clamp(pixel.y, 0, i32(size.y) - 1));
    #|  let uv = (vec2<f32>(p) + 0.5) / vec2<f32>(size);
    #|  let encoded = textureSampleLevel(environment_map, environment_sampler, uv, 0.0).rgb;
    #|  return exp2(encoded * log2(65.0)) - vec3<f32>(1.0);
    #|}
    #|fn environment_level(d: vec3<f32>, level: f32) -> vec3<f32> {
    #|  let dimensions = vec2<f32>(textureDimensions(environment_map));
    #|  let height = max(1.0, dimensions.y / 6.0);
    #|  // Longitude is arbitrary at the poles. Guard the INPUT to atan2:
    #|  // atan2(0, 0) produces NaN on Metal, poisoning HDR alpha blending.
    #|  let horizontal = select(d.xz, vec2<f32>(1.0, 0.0), dot(d.xz, d.xz) < 1e-12);
    #|  let u = fract(atan2(horizontal.y, horizontal.x) / (2.0 * PI) + 0.5);
    #|  let v = acos(clamp(d.y, -1.0, 1.0)) / PI;
    #|  let p = vec2<f32>(u * dimensions.x - 0.5, clamp(v * height - 0.5, 0.0, height - 1.0));
    #|  let lo = vec2<i32>(floor(p));
    #|  let y0 = lo.y + i32(level * height);
    #|  let y1 = min(lo.y + 1, i32(height) - 1) + i32(level * height);
    #|  let top = mix(environment_texel(vec2<i32>(lo.x, y0)), environment_texel(vec2<i32>(lo.x + 1, y0)), fract(p.x));
    #|  let bottom = mix(environment_texel(vec2<i32>(lo.x, y1)), environment_texel(vec2<i32>(lo.x + 1, y1)), fract(p.x));
    #|  return mix(top, bottom, fract(p.y));
    #|}
    #|fn environment_radiance(d: vec3<f32>, roughness: f32) -> vec3<f32> {
    #|  let level = clamp(roughness, 0.0, 1.0) * 5.0;
    #|  return mix(environment_level(d, floor(level)), environment_level(d, min(5.0, floor(level) + 1.0)), fract(level));
    #|}
  source + dfg_wgsl()
}

///|
fn environment_fragment_wgsl() -> String {
  let source =
    #|  let hemisphere = mix(uniforms.environment_ground.rgb, uniforms.ambient_color.rgb, normal.y * 0.5 + 0.5);
    #|  let diffuse_environment = environment_radiance(normal, 1.0) * uniforms.environment_params.x;
    #|  let cosine_irradiance = hemisphere / PI + diffuse_environment;
    #|  let reflected = normalize(mix(reflect(-view_dir, normal), normal, roughness * roughness));
    #|  let reflection = environment_radiance(reflected, roughness) * uniforms.environment_params.x;
    #|  let fab = environment_dfg(roughness, max(dot(normal, view_dir), 0.0));
    #|  let single_dielectric = vec3<f32>(0.04) * fab.x + vec3<f32>(fab.y);
    #|  let single_metallic = albedo * fab.x + vec3<f32>(fab.y);
    #|  let missing_energy = 1.0 - (fab.x + fab.y);
    #|  let average_dielectric = vec3<f32>(0.04 + 0.96 / 21.0);
    #|  let average_metallic = albedo + (vec3<f32>(1.0) - albedo) / 21.0;
    #|  let multi_dielectric = single_dielectric * average_dielectric * missing_energy / (vec3<f32>(1.0) - missing_energy * average_dielectric);
    #|  let multi_metallic = single_metallic * average_metallic * missing_energy / (vec3<f32>(1.0) - missing_energy * average_metallic);
    #|  let single_scattering = mix(single_dielectric, single_metallic, metallic);
    #|  let multi_scattering = mix(multi_dielectric, multi_metallic, metallic);
    #|  let diffuse = albedo * (1.0 - metallic) * (vec3<f32>(1.0) - single_dielectric - multi_dielectric);
    #|  let indirect = reflection * single_scattering + (multi_scattering + diffuse) * cosine_irradiance;
    #|  let lit = lo + indirect + uniforms.emissive.rgb;
    #|  let distance_to_camera = length(uniforms.camera_pos.xyz - in.world_position);
    #|  let fog = smoothstep(uniforms.environment_params.z, uniforms.environment_params.w, distance_to_camera);
    #|  let color = mix(lit, uniforms.fog_color.rgb, fog);
    #|
  source
}

///|
/// Packed RGB depth-to-color shadow map, bound after the environment map.
pub(all) struct PbrShadow {
  light_vp : @math3d.Mat4
  bias : Double
  texel_size : Double
}

///|
fn pbr_shadow_wgsl() -> String {
  "@group(0) @binding(5) var shadow_map: texture_2d<f32>;\n" +
  "@group(0) @binding(6) var shadow_sampler: sampler;\n" +
  @shadow3d.shadow_sampling_wgsl(packed_depth=true)
}
