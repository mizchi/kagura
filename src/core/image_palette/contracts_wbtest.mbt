///|
test "new_rgba clamps channels" {
  let c = new_rgba(-1, 10, 512, 300)
  assert_eq(c.r, 0)
  assert_eq(c.g, 10)
  assert_eq(c.b, 255)
  assert_eq(c.a, 255)
}

///|
test "checker_palette_from_seed is deterministic" {
  let p = checker_palette_from_seed(7)
  let expected_seed0 = (7 * 53 + 17) & 255
  let expected_seed1 = (7 * 97 + 73) & 255
  let expected_seed2 = (7 * 193 + 151) & 255
  assert_eq(palette_channel(p, 0, 0), expected_seed0)
  assert_eq(palette_channel(p, 0, 1), expected_seed1)
  assert_eq(palette_channel(p, 0, 2), expected_seed2)
  assert_eq(palette_channel(p, 0, 3), 255)
}

///|
test "palette_channel returns -1 for out of range" {
  let p = new_solid_palette(new_rgba(1, 2, 3, 4))
  // pixel_index out of range
  assert_eq(palette_channel(p, -1, 0), -1)
  assert_eq(palette_channel(p, 4, 0), -1)
  // channel_index out of range
  assert_eq(palette_channel(p, 0, -1), -1)
  assert_eq(palette_channel(p, 0, 4), -1)
}

///|
test "checker_palette_from_seed negative seed" {
  let p = checker_palette_from_seed(-5)
  // Negative seed → normalized to 0
  let expected_r = (0 * 53 + 17) & 255
  assert_eq(palette_channel(p, 0, 0), expected_r)
}

///|
test "new_image_palette_2x2 preserves four texels" {
  let p00 = new_rgba(10, 20, 30, 40)
  let p10 = new_rgba(50, 60, 70, 80)
  let p01 = new_rgba(90, 100, 110, 120)
  let p11 = new_rgba(130, 140, 150, 160)
  let palette = new_image_palette_2x2(p00, p10, p01, p11)
  assert_eq(palette_channel(palette, 0, 0), 10)
  assert_eq(palette_channel(palette, 1, 0), 50)
  assert_eq(palette_channel(palette, 2, 0), 90)
  assert_eq(palette_channel(palette, 3, 0), 130)
}

///|
test "clamp_channel boundary values" {
  assert_eq(clamp_channel(0), 0)
  assert_eq(clamp_channel(255), 255)
  assert_eq(clamp_channel(256), 255)
  assert_eq(clamp_channel(-1), 0)
  assert_eq(clamp_channel(128), 128)
  assert_eq(clamp_channel(-1000), 0)
  assert_eq(clamp_channel(10000), 255)
}

///|
test "new_rgba all zeros" {
  let c = new_rgba(0, 0, 0, 0)
  assert_eq(c.r, 0)
  assert_eq(c.g, 0)
  assert_eq(c.b, 0)
  assert_eq(c.a, 0)
}

///|
test "new_rgba all max" {
  let c = new_rgba(255, 255, 255, 255)
  assert_eq(c.r, 255)
  assert_eq(c.g, 255)
  assert_eq(c.b, 255)
  assert_eq(c.a, 255)
}

///|
test "checker_palette_from_seed zero" {
  let p = checker_palette_from_seed(0)
  let expected_r = (0 * 53 + 17) & 255
  let expected_g = (0 * 97 + 73) & 255
  let expected_b = (0 * 193 + 151) & 255
  assert_eq(palette_channel(p, 0, 0), expected_r)
  assert_eq(palette_channel(p, 0, 1), expected_g)
  assert_eq(palette_channel(p, 0, 2), expected_b)
  // Inverted texels
  assert_eq(palette_channel(p, 1, 0), 255 - expected_r)
  assert_eq(palette_channel(p, 1, 1), 255 - expected_g)
  assert_eq(palette_channel(p, 1, 2), 255 - expected_b)
}

///|
test "checker_palette_from_seed large seed" {
  let p = checker_palette_from_seed(999999)
  // Should not crash and all channels should be 0-255
  for pixel in 0..<4 {
    for ch in 0..<4 {
      let val = palette_channel(p, pixel, ch)
      assert_true(val >= 0 && val <= 255)
    }
  }
}

///|
test "palette_channel all pixels all channels" {
  let p = new_image_palette_2x2(
    new_rgba(10, 20, 30, 40),
    new_rgba(50, 60, 70, 80),
    new_rgba(90, 100, 110, 120),
    new_rgba(130, 140, 150, 160),
  )
  // p00
  assert_eq(palette_channel(p, 0, 0), 10)
  assert_eq(palette_channel(p, 0, 1), 20)
  assert_eq(palette_channel(p, 0, 2), 30)
  assert_eq(palette_channel(p, 0, 3), 40)
  // p10
  assert_eq(palette_channel(p, 1, 0), 50)
  assert_eq(palette_channel(p, 1, 1), 60)
  assert_eq(palette_channel(p, 1, 2), 70)
  assert_eq(palette_channel(p, 1, 3), 80)
  // p01
  assert_eq(palette_channel(p, 2, 0), 90)
  assert_eq(palette_channel(p, 2, 1), 100)
  assert_eq(palette_channel(p, 2, 2), 110)
  assert_eq(palette_channel(p, 2, 3), 120)
  // p11
  assert_eq(palette_channel(p, 3, 0), 130)
  assert_eq(palette_channel(p, 3, 1), 140)
  assert_eq(palette_channel(p, 3, 2), 150)
  assert_eq(palette_channel(p, 3, 3), 160)
}

///|
test "new_solid_palette fills all texels" {
  let c = new_rgba(9, 8, 7, 6)
  let p = new_solid_palette(c)
  for pixel_index in 0..<4 {
    assert_eq(palette_channel(p, pixel_index, 0), 9)
    assert_eq(palette_channel(p, pixel_index, 1), 8)
    assert_eq(palette_channel(p, pixel_index, 2), 7)
    assert_eq(palette_channel(p, pixel_index, 3), 6)
  }
}
