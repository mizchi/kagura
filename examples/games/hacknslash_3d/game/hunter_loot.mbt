///|
pub fn hunter_equipment_item(
  slot : EquipSlot,
  weapon? : PlayerWeaponKind = Cleaver,
  rarity? : ItemRarity = Common,
) -> ItemData {
  {
    name: match slot {
      Weapon => weapon.profile().name
      Armor => "夜狩りの外套"
      Helmet => "擦り切れた狩人帽"
      Gloves => "革の手甲"
      Boots => "古街道の長靴"
      Offhand => "鉄のバックラー"
      Accessory => "煤銀の指輪"
      Amulet => "月石の首飾り"
    },
    rarity,
    slot,
    atk_bonus: if slot == Weapon {
      1
    } else {
      0
    },
    def_bonus: if slot == Armor || slot == Offhand {
      1
    } else {
      0
    },
    hp_bonus: if slot == Accessory || slot == Amulet {
      1
    } else {
      0
    },
    str_bonus: 0,
    int_bonus: 0,
    dex_bonus: 0,
    str_scaling: 0.0,
    int_scaling: 0.0,
    dex_scaling: 0.0,
    prefix: None,
    suffix: None,
    icon_id: if slot == Weapon {
      40 + weapon.index()
    } else {
      50 + slot.index()
    },
  }
}

///|
pub fn new_hunter_inventory() -> Inventory {
  let inventory = Inventory::new_grid(8, 6)
  for
    item in [
      hunter_equipment_item(Weapon, weapon=Spear),
      hunter_equipment_item(Weapon),
      hunter_equipment_item(Armor),
      hunter_equipment_item(Helmet),
      hunter_equipment_item(Gloves),
      hunter_equipment_item(Accessory),
    ] {
    ignore(inventory.add(item))
  }
  inventory
}

///|
fn hunter_drop_variant(base : ItemData, seed : Int) -> ItemData {
  let value = seed & 0x7FFFFFFF
  let slot = match base.slot {
    Armor => [Armor, Helmet, Gloves, Boots, Offhand][value / 7 % 5]
    Accessory => if value / 7 % 2 == 0 { Accessory } else { Amulet }
    _ => base.slot
  }
  let kind = player_weapon_from_index(value / 11 % 5).or(Cleaver)
  let template = hunter_equipment_item(slot, weapon=kind)
  { ..base, slot, name: template.name, icon_id: template.icon_id, }
}
