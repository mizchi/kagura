// Direct port of Three.js cube_uv_reflection_fragment.glsl.js (MIT).
// Native PMREM CubeUV atlas in RGBA16F: no equirectangular resampling/quantization.
@group(0) @binding(3) var environment_map: texture_2d<f32>;
@group(0) @binding(4) var environment_sampler: sampler;
fn cube_face(d: vec3<f32>) -> i32 {
  let a = abs(d);
  if (a.x > a.z) {
    if (a.x > a.y) { return select(3, 0, d.x > 0); }
    return select(4, 1, d.y > 0);
  }
  if (a.z > a.y) { return select(5, 2, d.z > 0); }
  return select(4, 1, d.y > 0);
}
fn cube_uv(d: vec3<f32>, face: i32) -> vec2<f32> {
  var uv: vec2<f32>;
  switch face {
    case 0: { uv = vec2(d.z, d.y) / abs(d.x); }
    case 1: { uv = vec2(-d.x, -d.z) / abs(d.y); }
    case 2: { uv = vec2(-d.x, d.y) / abs(d.z); }
    case 3: { uv = vec2(-d.z, d.y) / abs(d.x); }
    case 4: { uv = vec2(-d.x, d.z) / abs(d.y); }
    default: { uv = vec2(d.x, d.y) / abs(d.z); }
  }
  return (uv + 1) * 0.5;
}
fn cube_level(direction: vec3<f32>, mip: f32) -> vec3<f32> {
  // Avoid division by zero for a degenerate reflected direction.
  let d = select(direction, vec3(0, 1, 0), dot(direction, direction) < 1e-12);
  var face = cube_face(d);
  let filter_index = max(4 - mip, 0);
  let face_size = exp2(max(mip, 4));
  var uv = cube_uv(d, face) * (face_size - 2) + 1;
  if (face > 2) { uv.y += face_size; face -= 3; }
  let size = vec2<f32>(textureDimensions(environment_map));
  uv.x += f32(face) * face_size + filter_index * 48;
  uv.y += 4 * (size.y * 0.25 - face_size);
  return textureSampleLevel(environment_map, environment_sampler, uv / size, 0).rgb;
}
fn roughness_to_mip(r: f32) -> f32 {
  if (r >= 0.8) { return (1 - r) * 5 - 2; }
  if (r >= 0.4) { return (0.8 - r) * 7.5 - 1; }
  if (r >= 0.305) { return (0.4 - r) / 0.095 + 2; }
  if (r >= 0.21) { return (0.305 - r) / 0.095 + 3; }
  return -2 * log2(1.16 * max(r, 0.000001));
}
fn environment_radiance(direction: vec3<f32>, roughness: f32) -> vec3<f32> {
  let max_mip = log2(f32(textureDimensions(environment_map).y)) - 2;
  let mip = clamp(roughness_to_mip(roughness), -2, max_mip);
  return mix(cube_level(direction, floor(mip)), cube_level(direction, ceil(mip)), fract(mip));
}
