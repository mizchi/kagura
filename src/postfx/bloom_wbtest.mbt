///|
test "bloom_threshold_wgsl contains brightness and threshold" {
  let src = bloom_threshold_wgsl()
  assert_true(src.contains("brightness"))
  assert_true(src.contains("threshold"))
  assert_true(src.contains("fs_main"))
}

///|
test "bloom_blur_wgsl horizontal contains gaussian weights" {
  let src = bloom_blur_wgsl(true)
  assert_true(src.contains("0.2270270270"))
  assert_true(src.contains("texel"))
  assert_true(src.contains("fs_main"))
}

///|
test "bloom_blur_wgsl vertical uses y direction" {
  let src_h = bloom_blur_wgsl(true)
  let src_v = bloom_blur_wgsl(false)
  // Both should have gaussian weights
  assert_true(src_h.contains("0.2270270270"))
  assert_true(src_v.contains("0.2270270270"))
  // They should differ in direction
  assert_true(src_h != src_v)
}

///|
test "bloom_composite_wgsl contains scene and bloom textures" {
  let src = bloom_composite_wgsl()
  assert_true(src.contains("scene_tex"))
  assert_true(src.contains("bloom_tex"))
  assert_true(src.contains("intensity"))
  assert_true(src.contains("@binding(3)"))
}

///|
test "bloom_commands returns 4 commands" {
  let dst = @gfx.new_image_handle(1, 800, 600)
  let bloom_a = @gfx.new_image_handle(2, 400, 300)
  let bloom_b = @gfx.new_image_handle(3, 400, 300)
  let threshold_shader = @gfx.new_shader_handle(1, "threshold")
  let hblur_shader = @gfx.new_shader_handle(2, "hblur")
  let vblur_shader = @gfx.new_shader_handle(3, "vblur")
  let composite_shader = @gfx.new_shader_handle(4, "composite")
  let cmds = bloom_commands(
    dst, 10, bloom_a, bloom_b,
    threshold_shader, hblur_shader, vblur_shader, composite_shader,
    0.8, 1.0, 800, 600,
  )
  assert_eq(cmds.length(), 4)
  // Each command should have vertex data and indices
  for i = 0; i < 4; i = i + 1 {
    assert_eq(cmds[i].vertex_data.length(), 16)
    assert_eq(cmds[i].indices.length(), 6)
    assert_eq(cmds[i].uniform_dwords.length(), 4)
  }
}
