// MeshStandardMaterial lighting from Three.js 0.185.1 (MIT).
const PI: f32 = 3.141592653589793;
fn standard_lighting(albedo: vec3<f32>, normal: vec3<f32>, view: vec3<f32>, shadow: f32, roughness: f32) -> vec3<f32> {
  let metallic = uniforms.pbr_params.x;
  let f0 = mix(vec3(0.04), albedo, metallic);
  let light = normalize(-uniforms.light_dir.xyz);
  let sum = view + light;
  let half_dir = sum * inverseSqrt(max(dot(sum, sum), 1e-12));
  let nl = clamp(dot(normal, light), 0, 1);
  let nv = clamp(dot(normal, view), 0, 1);
  let nh = clamp(dot(normal, half_dir), 0, 1);
  let vh = clamp(dot(view, half_dir), 0, 1);
  let a2 = pow(roughness, 4);
  let distribution = a2 / (PI * pow(nh * nh * (a2 - 1) + 1, 2));
  let gv = nl * sqrt(a2 + (1 - a2) * nv * nv);
  let gl = nv * sqrt(a2 + (1 - a2) * nl * nl);
  let visibility = 0.5 / max(gv + gl, 1e-6);
  let fresnel_weight = exp2((-5.55473 * vh - 6.98316) * vh);
  let fresnel = f0 * (1 - fresnel_weight) + fresnel_weight;
  let fab = environment_dfg(roughness, nv);
  let fab_l = environment_dfg(roughness, nl);
  let missing = 1 - fab.x - fab.y;
  let missing_l = 1 - fab_l.x - fab_l.y;
  let average = f0 + (1 - f0) * 0.047619;
  let direct_multi = (f0 * fab.x + fab.y) * (f0 * fab_l.x + fab_l.y) * average
    / (1 - missing * missing_l * average + 1e-6) * missing * missing_l;
  let diffuse_base = albedo * (1 - metallic);
  let direct = (diffuse_base / PI + fresnel * visibility * distribution + direct_multi)
    * uniforms.light_color.rgb * nl * shadow;
  // Hemisphere light is ordinary indirect diffuse, separate from IBL energy conservation.
  let hemisphere = mix(uniforms.environment_ground.rgb, uniforms.ambient_color.rgb, normal.y * 0.5 + 0.5);
  let ambient = hemisphere * diffuse_base / PI;
  let diffuse_environment = environment_radiance(normal, 1) * uniforms.environment_params.x;
  let reflection_direction = mix(reflect(-view, normal), normal, pow(roughness, 4));
  let reflection = environment_radiance(reflection_direction, roughness) * uniforms.environment_params.x;
  let single_dielectric = vec3(0.04) * fab.x + fab.y;
  let single_metallic = albedo * fab.x + fab.y;
  let average_dielectric = vec3(0.04 + 0.96 * 0.047619);
  let average_metallic = albedo + (1 - albedo) * 0.047619;
  let multi_dielectric = single_dielectric * average_dielectric * missing / (1 - missing * average_dielectric);
  let multi_metallic = single_metallic * average_metallic * missing / (1 - missing * average_metallic);
  let single = mix(single_dielectric, single_metallic, metallic);
  let multi = mix(multi_dielectric, multi_metallic, metallic);
  let diffuse = diffuse_base * (1 - single_dielectric - multi_dielectric);
  return direct + ambient + reflection * single + (multi + diffuse) * diffuse_environment + uniforms.emissive.rgb;
}
@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
  let sampled = textureSample(tex, tex_sampler, in.uv);
  let albedo = select(standard_linear(sampled.rgb), sampled.rgb, STANDARD_TEXTURE_SRGB) * uniforms.base_color.rgb;
  let normal = normalize(in.world_normal);
  let view = normalize(uniforms.camera_pos.xyz - in.world_position);
  let dxy = max(abs(dpdx(normal)), abs(dpdy(normal)));
  let roughness = min(max(uniforms.pbr_params.y, 0.0525) + max(dxy.x, max(dxy.y, dxy.z)), 1);
  let lit = standard_lighting(albedo, normal, view, standard_shadow(in.shadow_position, in.clip_position.xy), roughness);
  let color = select(standard_display(lit, in.view_depth), lit, STANDARD_LINEAR_OUTPUT);
  return vec4(color, sampled.a * uniforms.base_color.a);
}
