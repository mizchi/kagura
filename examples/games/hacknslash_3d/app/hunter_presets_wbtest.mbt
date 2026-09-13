///|
test "mage primary slots expose lightning and targeted blast without duplicate learned buttons" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.apply_archetype(@game.Mage)
  s.world.mode = @game.Playing
  let skills = s.hunter_preset_skills()
  assert_eq(skills[0].key, 53)
  assert_eq(skills[0].level, 1)
  assert_eq(skills[1].key, 84)
  assert_eq(skills[1].hold, "")
  assert_false(s.hunter_extra_skills().any(skill => skill.key == 53))
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [50]))
  assert_true(s.ground_targeting)
  assert_false(s.world.arts.whirlwind.active)
}

///|
test "save round trip retains a custom preset and legacy saves use their oath preset" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.apply_archetype(@game.Mage)
  s.world.mode = @game.Playing
  s.world.skills.skill_points = 9
  assert_true(s.world.apply_hunter_preset(@game.BladePreset))
  let restored = GameState::new_with_params(
    seed=9,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  let data = s.serialize_save()
  assert_true(restored.restore_save(data))
  assert_true(restored.world.archetype is @game.Mage)
  assert_true(restored.world.hunter_preset is @game.BladePreset)
  assert_eq(restored.world.skills.skill_points, 9)
  let legacy = data.split("|").to_array()[:21].join("|")
  assert_true(restored.restore_save(legacy))
  assert_true(restored.world.hunter_preset is @game.StormPreset)
}

///|
test "custom slots persist and reject malformed saves while old execution and charge IDs migrate" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.mode = @game.Playing
  assert_true(s.world.assign_hunter_slot(0, 50))
  assert_true(s.world.assign_hunter_slot(1, 84))
  let data = s.serialize_save()
  let restored = GameState::new_with_params(
    seed=9,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  assert_true(restored.restore_save(data))
  assert_eq(restored.world.hunter_slots, [50, 84, 86, 70])
  let legacy = data.split("|").to_array()[:22].join("|")
  assert_true(restored.restore_save(legacy))
  assert_eq(restored.world.hunter_slots, [74, 50, 86, 70])
  assert_true(restored.restore_save(legacy + "|49,50,67,70"))
  assert_eq(restored.world.hunter_slots, [74, 50, 86, 70])
  assert_true(restored.restore_save(legacy + "|84,84,999,70"))
  assert_eq(restored.world.hunter_slots, [74, 50, 86, 70])
}

///|
test "native mouse buttons resolve to the same slots as digits and never cast in menus" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.apply_archetype(@game.Mage)
  s.world.mode = @game.Playing
  let input = @core.new_input_snapshot_full(
    100.0,
    100.0,
    0.0,
    0.0,
    [],
    [0, 2],
    [],
    [],
  )
  assert_eq(s.resolve_hunter_hotbar(input).pressed_keys, [53, 84])
  s.paused = true
  assert_eq(s.resolve_hunter_hotbar(input).pressed_keys, [])
  s.paused = false
  s.ground_targeting = true
  assert_eq(s.resolve_hunter_hotbar(input).pressed_keys, [])
}

///|
test "native digit slot still cancels ground targeting while mouse only confirms" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.apply_archetype(@game.Mage)
  s.world.mode = @game.Playing
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [50]))
  assert_true(s.ground_targeting)
  s.update(@core.empty_input_snapshot())
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [50]))
  assert_false(s.ground_targeting)
  assert_eq(s.world.arts.ground_cooldown, 0)
}
