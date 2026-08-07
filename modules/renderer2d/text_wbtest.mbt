///|
/// `dot_text_size` has to agree with the layout `append_dot_text` performs, so
/// these pin the arithmetic: a glyph cell is 3x5 at `px_size = 3 * scale`, with
/// one `px_size` gap between glyphs and no trailing gap.
test "dot_text_size measures a single glyph cell" {
  let (w, h) = dot_text_size(1)
  assert_eq(w, 9.0)
  assert_eq(h, 15.0)
}

///|
test "dot_text_size adds one gap between glyphs and none after the last" {
  let (w2, _) = dot_text_size(2)
  let (w3, _) = dot_text_size(3)
  assert_eq(w2, 21.0)
  assert_eq(w3, 33.0)
}

///|
test "dot_text_size scales linearly" {
  let (w1, h1) = dot_text_size(5)
  let (w2, h2) = dot_text_size(5, scale=2.0)
  assert_eq(w2, w1 * 2.0)
  assert_eq(h2, h1 * 2.0)
  assert_eq(h2, 30.0)
}

///|
/// An empty run draws nothing; the naive formula would yield a negative width
/// from the missing-gap term, which would read as "fits" in the integrity gate.
test "dot_text_size is zero for an empty run" {
  let (w, h) = dot_text_size(0)
  assert_eq(w, 0.0)
  assert_eq(h, 0.0)
  let (wn, hn) = dot_text_size(-3)
  assert_eq(wn, 0.0)
  assert_eq(hn, 0.0)
}
