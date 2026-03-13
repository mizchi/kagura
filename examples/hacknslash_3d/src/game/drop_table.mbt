///|
pub(all) struct DropTableConfig {
  equipment_weight : Int
  health_weight : Int
  score_weight : Int
  weapon_weight : Int
  armor_weight : Int
  accessory_weight : Int
  rarity_bonus_per_floor : Double
  base_item_tier_base : Double
  base_item_tier_per_floor : Double
  prefix_tier_base : Double
  prefix_tier_per_floor : Double
  suffix_tier_base : Double
  suffix_tier_per_floor : Double
  modifier_tier_base : Double
  modifier_tier_per_floor : Double
}

///|
pub fn DropTableConfig::default() -> DropTableConfig {
  {
    equipment_weight: 30,
    health_weight: 30,
    score_weight: 40,
    weapon_weight: 1,
    armor_weight: 1,
    accessory_weight: 1,
    rarity_bonus_per_floor: 0.0,
    base_item_tier_base: 1.0,
    base_item_tier_per_floor: 0.0,
    prefix_tier_base: 0.0,
    prefix_tier_per_floor: 0.0,
    suffix_tier_base: 0.0,
    suffix_tier_per_floor: 0.0,
    modifier_tier_base: 0.0,
    modifier_tier_per_floor: 0.0,
  }
}

///|
fn item_tier_value(base : Double, per_floor : Double, floor : Int) -> Double {
  base + @cmp.maximum(0, floor - 1).to_double() * per_floor
}

///|
fn scaled_base_item_stat(
  base_value : Int,
  tier_value : Double,
  rarity_mult : Int,
  modifier_tier : Double,
) -> Int {
  let multiplier = 1.0 + tier_value * 0.35 + modifier_tier * 0.2
  @cmp.maximum(
    1,
    (base_value.to_double() * rarity_mult.to_double() * multiplier).to_int(),
  )
}

///|
fn scale_affix_with_tier(
  affix : Affix,
  floor : Int,
  tier_value : Double,
  modifier_tier : Double,
) -> Affix {
  let scaled = scale_affix(affix, floor)
  let multiplier = 1.0 + tier_value * 0.3 + modifier_tier * 0.15
  {
    ..scaled,
    atk: @cmp.maximum(0, (scaled.atk.to_double() * multiplier).to_int()),
    def: @cmp.maximum(0, (scaled.def.to_double() * multiplier).to_int()),
    hp: @cmp.maximum(0, (scaled.hp.to_double() * multiplier).to_int()),
  }
}

///|
pub fn item_rarity_rank(rarity : ItemRarity) -> Int {
  match rarity {
    Common => 0
    Uncommon => 1
    Rare => 2
    Epic => 3
  }
}

///|
pub fn roll_item_rarity(
  seed : Int,
  floor : Int,
  config : DropTableConfig,
) -> ItemRarity {
  let base_roll = ((seed / 3) % 100 + 100) % 100
  let bonus = @cmp.maximum(
    0,
    ((floor - 1).to_double() * config.rarity_bonus_per_floor).to_int(),
  )
  let rarity_roll = @cmp.maximum(0, base_roll - bonus)
  if rarity_roll < 50 {
    Common
  } else if rarity_roll < 80 {
    Uncommon
  } else if rarity_roll < 95 {
    Rare
  } else {
    Epic
  }
}

///|
fn weighted_slot_pick(seed : Int, config : DropTableConfig) -> EquipSlot {
  let weapon_weight = @cmp.maximum(0, config.weapon_weight)
  let armor_weight = @cmp.maximum(0, config.armor_weight)
  let accessory_weight = @cmp.maximum(0, config.accessory_weight)
  let total_weight = weapon_weight + armor_weight + accessory_weight
  if total_weight <= 0 {
    return Weapon
  }
  let roll = ((seed % total_weight) + total_weight) % total_weight
  if roll < weapon_weight {
    Weapon
  } else if roll < weapon_weight + armor_weight {
    Armor
  } else {
    Accessory
  }
}

///|
fn equip_slot_icon_base(slot : EquipSlot) -> Int {
  match slot {
    Weapon => 0
    Armor => 1
    Accessory => 2
  }
}

///|
fn rarity_multiplier(rarity : ItemRarity) -> Int {
  match rarity {
    Common => 1
    Uncommon => 2
    Rare => 3
    Epic => 5
  }
}

///|
pub fn generate_item_with_profile_and_drop_config(
  seed : Int,
  floor : Int,
  profile : AffixProfile,
  config : DropTableConfig,
) -> ItemData {
  let rng = seed & 0x7FFFFFFF
  let slot = weighted_slot_pick(rng, config)
  let rarity = roll_item_rarity(rng, floor, config)
  let rarity_mult = rarity_multiplier(rarity)
  let base_tier = item_tier_value(
    config.base_item_tier_base,
    config.base_item_tier_per_floor,
    floor,
  )
  let prefix_tier = item_tier_value(
    config.prefix_tier_base,
    config.prefix_tier_per_floor,
    floor,
  )
  let suffix_tier = item_tier_value(
    config.suffix_tier_base,
    config.suffix_tier_per_floor,
    floor,
  )
  let modifier_tier = item_tier_value(
    config.modifier_tier_base,
    config.modifier_tier_per_floor,
    floor,
  )
  let base = 1 + floor / 3
  let (atk, def, hp) = match slot {
    Weapon =>
      (
        scaled_base_item_stat(base, base_tier, rarity_mult, modifier_tier),
        0,
        0,
      )
    Armor =>
      (
        0,
        scaled_base_item_stat(base, base_tier, rarity_mult, modifier_tier),
        @cmp.maximum(1, (base.to_double() * (1.0 + base_tier * 0.25)).to_int()),
      )
    Accessory =>
      (
        @cmp.maximum(1, (base.to_double() * (1.0 + base_tier * 0.2)).to_int()),
        @cmp.maximum(1, (base.to_double() * (1.0 + base_tier * 0.2)).to_int()),
        scaled_base_item_stat(base, base_tier, rarity_mult, modifier_tier),
      )
  }
  let slot_name = match slot {
    Weapon => "Sword"
    Armor => "Armor"
    Accessory => "Ring"
  }
  let prefixes = prefix_table_for(profile)
  let suffixes = suffix_table_for(profile)
  let prefix_seed = rng / 300 % prefixes.length()
  let suffix_seed = rng / 3000 % suffixes.length()
  let (prefix, suffix) : (Affix?, Affix?) = match rarity {
    Common => (None, None)
    Uncommon =>
      if rng / 30 % 2 == 0 {
        (
          Some(
            scale_affix_with_tier(
              prefixes[prefix_seed],
              floor,
              prefix_tier,
              modifier_tier,
            ),
          ),
          None,
        )
      } else {
        (
          None,
          Some(
            scale_affix_with_tier(
              suffixes[suffix_seed],
              floor,
              suffix_tier,
              modifier_tier,
            ),
          ),
        )
      }
    Rare =>
      (
        Some(
          scale_affix_with_tier(
            prefixes[prefix_seed],
            floor,
            prefix_tier,
            modifier_tier,
          ),
        ),
        Some(
          scale_affix_with_tier(
            suffixes[suffix_seed],
            floor,
            suffix_tier,
            modifier_tier,
          ),
        ),
      )
    Epic =>
      (
        Some(
          scale_affix_with_tier(
            prefixes[prefix_seed],
            floor,
            prefix_tier,
            modifier_tier,
          ),
        ),
        Some(
          scale_affix_with_tier(
            suffixes[suffix_seed],
            floor,
            suffix_tier,
            modifier_tier,
          ),
        ),
      )
  }
  {
    name: slot_name,
    rarity,
    slot,
    atk_bonus: atk,
    def_bonus: def,
    hp_bonus: hp,
    prefix,
    suffix,
    icon_id: equip_slot_icon_base(slot) + (rng / 11 % 3),
  }
}
