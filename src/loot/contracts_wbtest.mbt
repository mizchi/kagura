///|
test "tier_curve_value applies per-floor growth after floor 1" {
  let curve = TierCurve::{ base: 1.0, per_floor: 0.25 }
  assert_eq(tier_curve_value(curve, 1), 1.0)
  assert_eq(tier_curve_value(curve, 5), 2.0)
}

///|
test "roll_loot_rarity becomes stronger with floor bias" {
  let config = {
    ..LootRarityRollConfig::default(),
    rarity_bonus_per_floor: 2.0,
  }
  let low = roll_loot_rarity(123, 1, config~)
  let high = roll_loot_rarity(123, 12, config~)
  assert_true(loot_rarity_rank(high) >= loot_rarity_rank(low))
}

///|
test "weighted_pick_index respects weights and fallback" {
  assert_eq(weighted_pick_index(7, [10, 0, 0]), 0)
  assert_eq(weighted_pick_index(7, [0, 5, 0]), 1)
  assert_eq(weighted_pick_index(7, [0, 0, 0]), 0)
}

///|
test "scale_base_stat keeps at least one" {
  let scaled = scale_base_stat(0, 1.0, loot_rarity_multiplier(LootEpic), 1.0)
  assert_eq(scaled, 1)
}
