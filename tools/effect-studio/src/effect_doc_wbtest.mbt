///|
test "default_effect_document has three readable tracks" {
  let doc = default_effect_document()
  assert_eq(doc.name, "forge_burst")
  assert_eq(doc.tracks.length(), 3)
  assert_true(doc.duration >= effect_track_end_time(doc.tracks[2]))
  assert_eq(effect_spawn_pattern_name(doc.tracks[0].pattern), "point")
  assert_eq(effect_spawn_pattern_name(doc.tracks[1].pattern), "ring")
  assert_eq(effect_spawn_pattern_name(doc.tracks[2].pattern), "column")
}

///|
test "effect_document_time loops when looping is enabled" {
  let doc = default_effect_document()
  let time = effect_document_time(doc, 2.05)
  assert_true((time - 0.25).abs() < 0.000001)
}
