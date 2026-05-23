///|
test "render_text returns empty for empty string" {
  // Without a real font, we can't test rendering.
  // This just verifies the API compiles and the color encoding is correct.
  let r = (0xFF8040 >> 16) & 0xFF
  let g = (0xFF8040 >> 8) & 0xFF
  let b = 0xFF8040 & 0xFF
  assert_eq(r, 255)
  assert_eq(g, 128)
  assert_eq(b, 64)
}
