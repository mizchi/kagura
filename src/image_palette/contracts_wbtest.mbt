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
