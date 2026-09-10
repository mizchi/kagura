@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
  let sampled = textureSample(tex, tex_sampler, in.uv);
  let albedo = select(standard_linear(sampled.rgb), sampled.rgb, STANDARD_TEXTURE_SRGB) * uniforms.base_color.rgb;
  var color = standard_srgb(albedo);
  if (STANDARD_TONEMAPPED) { color = standard_srgb(aces_filmic(albedo)); }
  if (STANDARD_FOG) {
    let fog = smoothstep(uniforms.environment_params.z, uniforms.environment_params.w, in.view_depth);
    color = mix(color, standard_srgb(uniforms.fog_color.rgb), fog);
  }
  return vec4(color, sampled.a * uniforms.base_color.a);
}
