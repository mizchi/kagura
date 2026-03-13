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
  @loot.tier_curve_value(@loot.TierCurve::new(base, per_floor), floor)
}

///|
fn scaled_base_item_stat(
  base_value : Int,
  tier_value : Double,
  rarity_mult : Int,
  modifier_tier : Double,
) -> Int {
  @loot.scale_base_stat(base_value, tier_value, rarity_mult, modifier_tier)
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
    str_bonus: @cmp.maximum(
      0,
      (scaled.str_bonus.to_double() * multiplier).to_int(),
    ),
    int_bonus: @cmp.maximum(
      0,
      (scaled.int_bonus.to_double() * multiplier).to_int(),
    ),
    dex_bonus: @cmp.maximum(
      0,
      (scaled.dex_bonus.to_double() * multiplier).to_int(),
    ),
  }
}

///|
pub fn item_rarity_rank(rarity : ItemRarity) -> Int {
  @loot.loot_rarity_rank(item_rarity_to_loot_rarity(rarity))
}

///|
pub fn roll_item_rarity(
  seed : Int,
  floor : Int,
  config : DropTableConfig,
) -> ItemRarity {
  loot_rarity_to_item_rarity(
    @loot.roll_loot_rarity(seed, floor, config={
      rarity_bonus_per_floor: config.rarity_bonus_per_floor,
      common_max: 50,
      uncommon_max: 80,
      rare_max: 95,
    }),
  )
}

///|
fn weighted_slot_pick(seed : Int, config : DropTableConfig) -> EquipSlot {
  let index = @loot.weighted_pick_index(seed, [
    @cmp.maximum(0, config.weapon_weight),
    @cmp.maximum(0, config.armor_weight),
    @cmp.maximum(0, config.accessory_weight),
  ])
  if index == 0 {
    Weapon
  } else if index == 1 {
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
  @loot.loot_rarity_multiplier(item_rarity_to_loot_rarity(rarity))
}

///|
fn item_rarity_to_loot_rarity(rarity : ItemRarity) -> @loot.LootRarity {
  match rarity {
    Common => @loot.LootCommon
    Uncommon => @loot.LootUncommon
    Rare => @loot.LootRare
    Epic => @loot.LootEpic
  }
}

///|
fn loot_rarity_to_item_rarity(rarity : @loot.LootRarity) -> ItemRarity {
  match rarity {
    LootCommon => Common
    LootUncommon => Uncommon
    LootRare => Rare
    LootEpic => Epic
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
  let primary_stat_index = rng / 17 % 3
  let base = 1 + floor / 3
  let primary_bonus = @cmp.maximum(
    1,
    (base.to_double() * (1.0 + base_tier * 0.35 + modifier_tier * 0.2)).to_int(),
  )
  let secondary_bonus = @cmp.maximum(
    0,
    (base.to_double() * (0.4 + base_tier * 0.15)).to_int(),
  )
  let primary_scaling = 0.25 + base_tier * 0.08 + modifier_tier * 0.05
  let secondary_scaling = 0.05 + base_tier * 0.03
  let (
    atk,
    def,
    hp,
    str_bonus,
    int_bonus,
    dex_bonus,
    str_scaling,
    int_scaling,
    dex_scaling,
  ) = match slot {
    Weapon => {
      let atk = scaled_base_item_stat(
        base, base_tier, rarity_mult, modifier_tier,
      )
      match primary_stat_index {
        0 =>
          (
            atk, 0, 0, primary_bonus, 0, secondary_bonus, primary_scaling, 0.0, secondary_scaling,
          )
        1 =>
          (
            atk, 0, 0, secondary_bonus, primary_bonus, 0, secondary_scaling, primary_scaling,
            0.0,
          )
        _ =>
          (
            atk, 0, 0, 0, secondary_bonus, primary_bonus, 0.0, secondary_scaling,
            primary_scaling,
          )
      }
    }
    Armor => {
      let def = scaled_base_item_stat(
        base, base_tier, rarity_mult, modifier_tier,
      )
      let hp = @cmp.maximum(
        1,
        (base.to_double() * (1.0 + base_tier * 0.25)).to_int(),
      )
      match primary_stat_index {
        0 => (0, def, hp, primary_bonus, 0, 0, secondary_scaling, 0.0, 0.0)
        1 => (0, def, hp, 0, primary_bonus, 0, 0.0, secondary_scaling, 0.0)
        _ => (0, def, hp, 0, 0, primary_bonus, 0.0, 0.0, secondary_scaling)
      }
    }
    Accessory => {
      let atk = @cmp.maximum(
        1,
        (base.to_double() * (1.0 + base_tier * 0.2)).to_int(),
      )
      let def = @cmp.maximum(
        1,
        (base.to_double() * (1.0 + base_tier * 0.2)).to_int(),
      )
      let hp = scaled_base_item_stat(
        base, base_tier, rarity_mult, modifier_tier,
      )
      match primary_stat_index {
        0 =>
          (
            atk, def, hp, primary_bonus, secondary_bonus, secondary_bonus, secondary_scaling,
            secondary_scaling, secondary_scaling,
          )
        1 =>
          (
            atk, def, hp, secondary_bonus, primary_bonus, secondary_bonus, secondary_scaling,
            secondary_scaling, secondary_scaling,
          )
        _ =>
          (
            atk, def, hp, secondary_bonus, secondary_bonus, primary_bonus, secondary_scaling,
            secondary_scaling, secondary_scaling,
          )
      }
    }
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
    str_bonus,
    int_bonus,
    dex_bonus,
    str_scaling,
    int_scaling,
    dex_scaling,
    prefix,
    suffix,
    icon_id: equip_slot_icon_base(slot) + rng / 11 % 3,
  }
}
