///|
test "mage starts with chain lightning and the ground explosion in its primary slots" {
  let w = GameWorld::new(seed=42, archetype=Mage, hunting_grounds=true)
  assert_true(w.hunter_preset == StormPreset)
  assert_eq(w.hunter_preset.profile().keys, [53, 84, 51, 52])
  assert_true(w.player_weapon == Focus)
  assert_true(w.skills.get_level(ChainLightning) >= 1)
  w.mode = Playing
  assert_true(w.request_hunter_spell(LightningArt))
}

///|
test "preset changes equip their weapon without resetting learned skills or points" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  w.skills.skill_points = 7
  assert_true(w.apply_hunter_preset(StormPreset))
  assert_eq(w.skills.skill_points, 7)
  assert_true(w.player_weapon == Focus)
  assert_eq(w.skills.get_level(ChainLightning), 0)
  assert_true(w.apply_hunter_preset(BladePreset))
  assert_true(w.player_weapon == Cleaver)
  assert_eq(w.hunter_preset.profile().keys, [49, 50, 51, 52])
  assert_eq(w.skills.skill_points, 7)
  assert_true(w.request_charge(0.0))
  assert_false(w.apply_hunter_preset(StormPreset))
}
