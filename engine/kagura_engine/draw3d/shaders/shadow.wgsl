// Three r185 PCF: five Vogel disk samples, each with bilinear depth comparison.
// Packed depths are decoded and compared BEFORE interpolation (hardware PCF semantics).
@group(0) @binding(5) var shadow_map: texture_2d<f32>;
@group(0) @binding(6) var shadow_sampler: sampler;
fn shadow_compare_texel(p: vec2<i32>, depth: f32) -> f32 {
  let size = vec2<i32>(textureDimensions(shadow_map));
  let uv = (vec2<f32>(clamp(p, vec2(0), size - 1)) + 0.5) / vec2<f32>(size);
  let packed = textureSampleLevel(shadow_map, shadow_sampler, uv, 0).rgb;
  let stored = dot(packed, vec3(65536, 256, 1)) * (255.0 / 16777215.0);
  return select(0.0, 1.0, depth <= stored);
}
fn shadow_compare_linear(uv: vec2<f32>, depth: f32) -> f32 {
  let texel = uv * vec2<f32>(textureDimensions(shadow_map)) - 0.5;
  let p = vec2<i32>(floor(texel));
  let f = fract(texel);
  return mix(mix(shadow_compare_texel(p, depth), shadow_compare_texel(p + vec2(1, 0), depth), f.x),
    mix(shadow_compare_texel(p + vec2(0, 1), depth), shadow_compare_texel(p + vec2(1, 1), depth), f.x), f.y);
}
fn standard_shadow(clip: vec4<f32>, screen: vec2<f32>) -> f32 {
  let ndc = clip.xyz / clip.w;
  let uv = vec2(ndc.x * 0.5 + 0.5, 0.5 - ndc.y * 0.5);
  let depth = ndc.z + uniforms.shadow_params.x;
  if (any(uv < vec2(0)) || any(uv > vec2(1)) || depth > 1 || uniforms.shadow_params.w > 0) { return 1; }
  // WebGL gl_FragCoord has a bottom-left origin, WebGPU a top-left origin.
  let gl_pixel = vec2(screen.x, uniforms.shadow_params.z - screen.y);
  let noise = fract(52.9829189 * fract(dot(gl_pixel, vec2(0.06711056, 0.00583715))));
  let phi = noise * 6.283185307179586;
  var visibility = 0.0;
  for (var i = 0; i < 5; i++) {
    let radius = sqrt((f32(i) + 0.5) / 5.0) * uniforms.shadow_params.y;
    let theta = f32(i) * 2.399963229728653 + phi;
    visibility += shadow_compare_linear(uv + vec2(cos(theta), -sin(theta)) * radius, depth);
  }
  return visibility * 0.2;
}
