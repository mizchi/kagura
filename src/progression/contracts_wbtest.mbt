///|
test "LevelProgression gains xp and increments pending choices" {
  let progression = LevelProgression::new()
  let leveled = progression.add_xp(10, LevelUpConfig::default())
  assert_true(leveled)
  assert_eq(progression.level, 2)
  assert_eq(progression.pending_choices, 1)
}

///|
test "LevelProgression can consume a pending choice" {
  let progression = LevelProgression::{
    level: 2,
    xp: 0,
    next_level_xp: 16,
    pending_choices: 2,
  }
  assert_true(progression.consume_pending_choice())
  assert_eq(progression.pending_choices, 1)
}

///|
test "xp_required_for_level uses base and growth" {
  let config = LevelUpConfig::{ xp_base: 10, xp_growth: 6 }
  assert_eq(xp_required_for_level(1, config), 10)
  assert_eq(xp_required_for_level(4, config), 28)
}

///|
test "evaluate_tier_curve applies per-floor growth after floor 1" {
  let curve = TierCurve::{ base: 1.0, per_floor: 0.25 }
  assert_eq(evaluate_tier_curve(curve, 1), 1.0)
  assert_eq(evaluate_tier_curve(curve, 5), 2.0)
}

///|
test "sample_loot_rarity becomes stronger with floor bias" {
  let config = {
    ..LootRarityRollConfig::default(),
    rarity_bonus_per_floor: 2.0,
  }
  let low = sample_loot_rarity(123, 1, config~)
  let high = sample_loot_rarity(123, 12, config~)
  assert_true(loot_rarity_rank(high) >= loot_rarity_rank(low))
}

///|
test "pick_weighted_index respects weights and fallback" {
  assert_eq(pick_weighted_index(7, [10, 0, 0]), 0)
  assert_eq(pick_weighted_index(7, [0, 5, 0]), 1)
  assert_eq(pick_weighted_index(7, [0, 0, 0]), 0)
}

///|
test "scale_loot_stat keeps at least one" {
  let scaled = scale_loot_stat(0, 1.0, loot_rarity_multiplier(LootEpic), 1.0)
  assert_eq(scaled, 1)
}
