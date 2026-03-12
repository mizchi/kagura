///|
pub(all) struct DropTableConfig {
  equipment_weight : Int
  health_weight : Int
  score_weight : Int
  weapon_weight : Int
  armor_weight : Int
  accessory_weight : Int
  rarity_bonus_per_floor : Double
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
  let base = 1 + floor / 3
  let (atk, def, hp) = match slot {
    Weapon => (base * rarity_mult, 0, 0)
    Armor => (0, base * rarity_mult, base)
    Accessory => (base, base, base * rarity_mult)
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
        (Some(scale_affix(prefixes[prefix_seed], floor)), None)
      } else {
        (None, Some(scale_affix(suffixes[suffix_seed], floor)))
      }
    Rare =>
      (
        Some(scale_affix(prefixes[prefix_seed], floor)),
        Some(scale_affix(suffixes[suffix_seed], floor)),
      )
    Epic =>
      (
        Some(scale_affix(prefixes[prefix_seed], floor)),
        Some(scale_affix(suffixes[suffix_seed], floor)),
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
