///|
test "is_stride32 detects basic 3d shader" {
  let src = "struct VertexInput { @location(0) position: vec3<f32>, @location(1) normal: vec3<f32>, @location(2) uv: vec2<f32>, }"
  assert_true(is_stride32(src))
}

///|
test "is_stride64 detects skinned shader" {
  let src = "struct VertexInput { @location(0) position: vec3<f32>, @location(1) normal: vec3<f32>, @location(2) uv: vec2<f32>, @location(3) joints: vec4<f32>, @location(4) weights: vec4<f32>, }"
  assert_true(is_stride64(src))
}

///|
test "is_3d_shader is true for stride64 and false for 2d" {
  let skinned = "struct VertexInput { @location(0) position: vec3<f32>, @location(1) normal: vec3<f32>, @location(2) uv: vec2<f32>, @location(3) joints: vec4<f32>, @location(4) weights: vec4<f32>, }"
  let sprite = "@vertex fn vs_main(@location(0) pos: vec2f, @location(1) uv: vec2f) -> vec4f { return vec4f(pos, 0.0, 1.0); }"
  assert_true(is_3d_shader(skinned))
  assert_false(is_3d_shader(sprite))
}
