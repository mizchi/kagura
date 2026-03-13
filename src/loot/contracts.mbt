///|
pub(all) struct TierCurve {
  base : Double
  per_floor : Double
}

///|
pub fn TierCurve::new(base : Double, per_floor : Double) -> TierCurve {
  { base, per_floor }
}

///|
pub fn tier_curve_value(curve : TierCurve, floor : Int) -> Double {
  curve.base + @cmp.maximum(0, floor - 1).to_double() * curve.per_floor
}

///|
pub(all) enum LootRarity {
  LootCommon
  LootUncommon
  LootRare
  LootEpic
}

///|
pub(all) struct LootRarityRollConfig {
  rarity_bonus_per_floor : Double
  common_max : Int
  uncommon_max : Int
  rare_max : Int
}

///|
pub fn LootRarityRollConfig::default() -> LootRarityRollConfig {
  {
    rarity_bonus_per_floor: 0.0,
    common_max: 50,
    uncommon_max: 80,
    rare_max: 95,
  }
}

///|
pub fn loot_rarity_rank(rarity : LootRarity) -> Int {
  match rarity {
    LootCommon => 0
    LootUncommon => 1
    LootRare => 2
    LootEpic => 3
  }
}

///|
pub fn loot_rarity_multiplier(rarity : LootRarity) -> Int {
  match rarity {
    LootCommon => 1
    LootUncommon => 2
    LootRare => 3
    LootEpic => 5
  }
}

///|
pub fn roll_loot_rarity(
  seed : Int,
  floor : Int,
  config? : LootRarityRollConfig = LootRarityRollConfig::default(),
) -> LootRarity {
  let base_roll = (seed / 3 % 100 + 100) % 100
  let bonus = @cmp.maximum(
    0,
    ((floor - 1).to_double() * config.rarity_bonus_per_floor).to_int(),
  )
  let rarity_roll = @cmp.maximum(0, base_roll - bonus)
  if rarity_roll < config.common_max {
    LootCommon
  } else if rarity_roll < config.uncommon_max {
    LootUncommon
  } else if rarity_roll < config.rare_max {
    LootRare
  } else {
    LootEpic
  }
}

///|
pub fn weighted_pick_index(seed : Int, weights : Array[Int]) -> Int {
  let mut total_weight = 0
  for weight in weights {
    total_weight = total_weight + @cmp.maximum(0, weight)
  }
  if total_weight <= 0 {
    return 0
  }
  let roll = (seed % total_weight + total_weight) % total_weight
  let mut cursor = 0
  for index = 0; index < weights.length(); index = index + 1 {
    let weight = @cmp.maximum(0, weights[index])
    cursor = cursor + weight
    if roll < cursor {
      return index
    }
  }
  0
}

///|
pub fn scale_base_stat(
  base_value : Int,
  tier_value : Double,
  rarity_multiplier : Int,
  modifier_tier : Double,
) -> Int {
  let multiplier = 1.0 + tier_value * 0.35 + modifier_tier * 0.2
  @cmp.maximum(
    1,
    (base_value.to_double() * rarity_multiplier.to_double() * multiplier).to_int(),
  )
}
