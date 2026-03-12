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

///|
test "hacknslash effect presets expose readable names and patterns" {
  let chain = chain_lightning_effect_document()
  let fireball = splitting_fireball_effect_document()
  let fireball_cast = splitting_fireball_cast_effect_document()
  let nova = ice_nova_effect_document()
  let telegraph_ring = ground_telegraph_ring_effect_document()
  let telegraph_line = ground_telegraph_line_effect_document()

  assert_eq(chain.name, "chain_lightning")
  assert_eq(fireball.name, "splitting_fireball")
  assert_eq(fireball_cast.name, "splitting_fireball_cast")
  assert_eq(nova.name, "ice_nova")
  assert_eq(telegraph_ring.name, "ground_telegraph_ring")
  assert_eq(telegraph_line.name, "ground_telegraph_line")

  assert_eq(effect_spawn_pattern_name(chain.tracks[0].pattern), "line")
  assert_eq(effect_spawn_pattern_name(fireball.tracks[0].pattern), "point")
  assert_eq(effect_spawn_pattern_name(nova.tracks[0].pattern), "ring")
  assert_eq(effect_spawn_pattern_name(telegraph_ring.tracks[0].pattern), "ring")
  assert_eq(effect_spawn_pattern_name(telegraph_line.tracks[0].pattern), "line")
  assert_true(chain.tracks.length() >= 4)
  assert_true(fireball.tracks.length() >= 4)
  assert_true(fireball_cast.tracks.length() >= 3)
  assert_true(telegraph_ring.tracks.length() >= 2)
  assert_true(telegraph_line.tracks.length() >= 2)
}
