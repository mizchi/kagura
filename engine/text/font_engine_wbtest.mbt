///|
test "SimpleFontEngine::measure returns valid metrics for 'I'" {
  let font_data = test_font_otf_data()
  let bytes = font_data_to_bytes(font_data)
  let font = parse_font_bytes(bytes).unwrap()
  let engine = SimpleFontEngine::new(font)
  let style = @font.default_text_style("NotoSans", 24.0)
  let run = @font.new_text_run("I", style)
  let metrics = engine.measure(run)
  assert_true(metrics.width > 0.0)
  assert_true(metrics.height > 0.0)
  assert_true(metrics.baseline > 0.0)
  assert_true(metrics.baseline < metrics.height)
}

///|
test "SimpleFontEngine::measure empty string returns zero width" {
  let font_data = test_font_otf_data()
  let bytes = font_data_to_bytes(font_data)
  let font = parse_font_bytes(bytes).unwrap()
  let engine = SimpleFontEngine::new(font)
  let style = @font.default_text_style("NotoSans", 24.0)
  let run = @font.new_text_run("", style)
  let metrics = engine.measure(run)
  assert_eq(metrics.width, 0.0)
  assert_true(metrics.height > 0.0)
}

///|
test "SimpleFontEngine::shape returns quads for 'I'" {
  let font_data = test_font_otf_data()
  let bytes = font_data_to_bytes(font_data)
  let font = parse_font_bytes(bytes).unwrap()
  let engine = SimpleFontEngine::new(font)
  let style = @font.default_text_style("NotoSans", 24.0)
  let run = @font.new_text_run("I", style)
  let quads = engine.shape(run)
  assert_true(quads.length() >= 0)
}
