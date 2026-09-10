// Three.js 0.185.1 ACESFilmicToneMapping, MIT; see ../THIRD_PARTY.md.
fn aces_filmic(color: vec3<f32>) -> vec3<f32> {
  let input_matrix = mat3x3<f32>(
    vec3(0.59719, 0.07600, 0.02840),
    vec3(0.35458, 0.90834, 0.13383),
    vec3(0.04823, 0.01566, 0.83777));
  let output_matrix = mat3x3<f32>(
    vec3(1.60475, -0.10208, -0.00327),
    vec3(-0.53108, 1.10813, -0.07276),
    vec3(-0.07367, -0.00605, 1.07602));
  let v = input_matrix * (color / 0.6);
  let a = v * (v + 0.0245786) - 0.000090537;
  let b = v * (0.983729 * v + 0.4329510) + 0.238081;
  return clamp(output_matrix * (a / b), vec3(0), vec3(1));
}
fn standard_srgb(color: vec3<f32>) -> vec3<f32> {
  return select(1.055 * pow(max(color, vec3(0)), vec3(1.0 / 2.4)) - 0.055,
    color * 12.92, color <= vec3(0.0031308));
}
fn standard_linear(color: vec3<f32>) -> vec3<f32> {
  return select(pow((color + 0.055) / 1.055, vec3(2.4)), color / 12.92, color <= vec3(0.04045));
}
// Three's screen path applies tone mapping -> sRGB -> fog, then blending.
fn standard_display(color: vec3<f32>, depth: f32) -> vec3<f32> {
  let display = standard_srgb(aces_filmic(color));
  let fog = smoothstep(uniforms.environment_params.z, uniforms.environment_params.w, depth);
  return mix(display, standard_srgb(uniforms.fog_color.rgb), fog);
}
