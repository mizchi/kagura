///|
test "camera occlusion appends three aligned vec4s without disturbing existing uniforms" {
  let mask : CameraOcclusion = {
    eye: @math3d.Vec3::new(1.0, 2.0, 3.0),
    target: @math3d.Vec3::new(4.0, 5.0, 6.0),
    enabled: true,
    eye_radius: 1.25,
    target_radius: 0.85,
    softness: 0.55,
    end_fraction: 0.97,
  }
  let words = [11, 22, 33, 44]
  mask.append_uniform_dwords(words)
  assert_eq(words.length(), 16)
  assert_eq(words[0:4].to_array(), [11, 22, 33, 44])
  let expected = [
    1.0, 2.0, 3.0, 1.0, 4.0, 5.0, 6.0, 0.85, 1.25, 0.55, 0.97, 0.0,
  ]
  for i, value in expected {
    assert_true(
      (@gfx.f32_bits_to_double(words[4 + i]) - value).abs() < 0.000001,
    )
  }
  let disabled : CameraOcclusion = { ..mask, enabled: false, }
  let disabled_words : Array[Int] = []
  disabled.append_uniform_dwords(disabled_words)
  assert_eq(disabled_words[3], 0)
}
