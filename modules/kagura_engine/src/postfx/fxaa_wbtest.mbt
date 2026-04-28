///|
test "fxaa_wgsl contains luminance and edge detection" {
  let src = fxaa_wgsl()
  assert_true(src.contains("fn luminance"))
  assert_true(src.contains("luma_range"))
  assert_true(src.contains("fs_main"))
}

///|
test "fxaa_wgsl contains direction computation" {
  let src = fxaa_wgsl()
  assert_true(src.contains("dir_x"))
  assert_true(src.contains("dir_y"))
  assert_true(src.contains("texel_size"))
}

///|
test "fxaa_uniform_dwords has 4 dwords" {
  let dwords = fxaa_uniform_dwords(1.0 / 800.0, 1.0 / 600.0)
  assert_eq(dwords.length(), 4)
  // First two should be non-zero f32 bits
  assert_true(dwords[0] != 0)
  assert_true(dwords[1] != 0)
  // Padding should be zero
  assert_eq(dwords[2], 0)
  assert_eq(dwords[3], 0)
}
