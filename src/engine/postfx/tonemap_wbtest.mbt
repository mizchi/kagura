///|
test "tonemap_wgsl Reinhard contains tonemap function" {
  let src = tonemap_wgsl(Reinhard)
  assert_true(src.contains("fn tonemap"))
  assert_true(src.contains("exposure"))
  assert_true(src.contains("fs_main"))
}

///|
test "tonemap_wgsl ACES contains ACES coefficients" {
  let src = tonemap_wgsl(ACES)
  assert_true(src.contains("fn tonemap"))
  assert_true(src.contains("2.51"))
  assert_true(src.contains("clamp"))
}

///|
test "tonemap_uniform_dwords has 4 dwords" {
  let dwords = tonemap_uniform_dwords(1.0)
  assert_eq(dwords.length(), 4)
  // First dword should be f32 bits for 1.0
  assert_eq(dwords[0], 0x3F800000)
}
