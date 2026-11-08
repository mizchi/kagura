///|
pub(all) struct LevelUpConfig {
  xp_base : Int32
  xp_growth : Int32
}

///|
pub fn LevelUpConfig::default() -> LevelUpConfig {
  { xp_base: 10, xp_growth: 6, }
}

///|
pub(all) struct LevelProgression {
  mut level : Int32
  mut xp : Int32
  mut next_level_xp : Int32
  mut pending_choices : Int32
}

///|
pub fn LevelProgression::new(
  config~ : LevelUpConfig = LevelUpConfig::default(),
) -> LevelProgression {
  {
    level: 1,
    xp: 0,
    next_level_xp: xp_required_for_level(1, config),
    pending_choices: 0,
  }
}

///|
pub fn xp_required_for_level(level : Int32, config : LevelUpConfig) -> Int32 {
  @cmp.maximum(1, config.xp_base + (level - 1) * config.xp_growth)
}

///|
pub fn LevelProgression::add_xp(
  self : LevelProgression,
  gained_xp : Int32,
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
    self.next_level_xp = xp_required_for_level(self.level, config)
    self.pending_choices = self.pending_choices + 1
    leveled = true
  }
  leveled
}

///|
pub fn LevelProgression::consume_pending_choice(
  self : LevelProgression,
) -> Bool {
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
  { base, per_floor, }
}

///|
pub fn evaluate_tier_curve(curve : TierCurve, floor : Int32) -> Double {
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
  common_max : Int32
  uncommon_max : Int32
  rare_max : Int32
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
pub fn loot_rarity_rank(rarity : LootRarity) -> Int32 {
  match rarity {
    LootCommon => 0
    LootUncommon => 1
    LootRare => 2
    LootEpic => 3
  }
}

///|
pub fn loot_rarity_multiplier(rarity : LootRarity) -> Int32 {
  match rarity {
    LootCommon => 1
    LootUncommon => 2
    LootRare => 3
    LootEpic => 5
  }
}

///|
pub fn sample_loot_rarity(
  seed : Int32,
  floor : Int32,
  config~ : LootRarityRollConfig = LootRarityRollConfig::default(),
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
pub fn pick_weighted_index(seed : Int32, weights : Array[Int32]) -> Int32 {
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
pub fn scale_loot_stat(
  base_value : Int32,
  tier_value : Double,
  rarity_multiplier : Int32,
  modifier_tier : Double,
) -> Int32 {
  let multiplier = 1.0 + tier_value * 0.35 + modifier_tier * 0.2
  @cmp.maximum(
    1,
    (base_value.to_double() * rarity_multiplier.to_double() * multiplier).to_int(),
  )
}
