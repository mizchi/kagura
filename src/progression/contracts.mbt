///|
pub(all) struct LevelUpConfig {
  xp_base : Int
  xp_growth : Int
}

///|
pub fn LevelUpConfig::default() -> LevelUpConfig {
  { xp_base: 10, xp_growth: 6 }
}

///|
pub(all) struct LevelProgression {
  mut level : Int
  mut xp : Int
  mut next_level_xp : Int
  mut pending_choices : Int
}

///|
pub fn LevelProgression::new(
  config? : LevelUpConfig = LevelUpConfig::default(),
) -> LevelProgression {
  {
    level: 1,
    xp: 0,
    next_level_xp: next_level_xp_for(1, config),
    pending_choices: 0,
  }
}

///|
pub fn next_level_xp_for(level : Int, config : LevelUpConfig) -> Int {
  @cmp.maximum(1, config.xp_base + (level - 1) * config.xp_growth)
}

///|
pub fn LevelProgression::gain_xp(
  self : LevelProgression,
  gained_xp : Int,
  config : LevelUpConfig,
) -> Bool {
  if gained_xp <= 0 {
    return false
  }
  self.xp = self.xp + gained_xp
  let mut leveled = false
  while self.xp >= self.next_level_xp {
    self.xp = self.xp - self.next_level_xp
    self.level = self.level + 1
    self.next_level_xp = next_level_xp_for(self.level, config)
    self.pending_choices = self.pending_choices + 1
    leveled = true
  }
  leveled
}

///|
pub fn LevelProgression::consume_choice(self : LevelProgression) -> Bool {
  if self.pending_choices <= 0 {
    return false
  }
  self.pending_choices = self.pending_choices - 1
  true
}

// ============================================================
// Loot: rarity rolls, tier curves, weighted selection
// ============================================================

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
