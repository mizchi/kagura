///|
/// Starting builds are equipment and skill presets, not permanent class locks.
pub fn CharacterArchetype::build_name(self : CharacterArchetype) -> String {
  match self {
    Melee => "狩人"
    Mage => "魔法使い"
    Ranger => "弓使い"
    Summoner => "召喚師"
  }
}

///|
pub fn CharacterArchetype::build_description(
  self : CharacterArchetype,
) -> String {
  match self {
    Melee =>
      "鉈の連撃と回転攻撃で切り込み、盾で正面の攻撃を防ぐ。筋力重視。"
    Mage =>
      "連鎖する雷と位置指定の爆発で、離れた敵の群れを制圧する。知力重視。"
    Ranger =>
      "長弓で遠くの敵を狙い、追尾弾と突進で距離を調整する。器用さ重視。"
    Summoner =>
      "ゾンビに敵を引きつけさせ、短命な炎の頭蓋を次々に召喚する。知力重視。"
  }
}

///|
pub fn CharacterArchetype::build_glyph(self : CharacterArchetype) -> String {
  match self {
    Melee => "blade"
    Mage => "lightning"
    Ranger => "bow"
    Summoner => "skull"
  }
}

///|
pub fn CharacterArchetype::starting_equipment(
  self : CharacterArchetype,
) -> Array[ItemData] {
  let names = match self {
    Melee =>
      [
        "狩人の外套", "狩人の三角帽", "狩人の手甲", "狩人の長靴",
      ]
    Mage =>
      [
        "見習いのローブ", "見習いの尖り帽", "見習いの手袋", "見習いの靴",
      ]
    Ranger =>
      [
        "射手の革鎧", "射手の革帽", "射手の手甲", "射手の革靴",
      ]
    Summoner =>
      [
        "喚霊のローブ", "喚霊の尖り帽", "喚霊の手袋", "喚霊の靴",
      ]
  }
  let style = match self {
    Melee => WornGear
    Ranger => LeatherGear
    Mage | Summoner => OccultGear
  }
  let items = [
    {
      ..hunter_equipment_item(
        Weapon,
        weapon=default_hunter_preset(self).profile().weapon,
      ),
      atk_bonus: 0,
    },
  ]
  let slots = [Armor, Helmet, Gloves, Boots]
  for i in 0..<slots.length() {
    items.push({
      ..hunter_equipment_item(slots[i]),
      name: names[i],
      def_bonus: 0,
      // Persist visual identity with the item without granting rare-item stats.
      icon_id: 60 + style.index() * 8 + slots[i].index(),
    })
  }
  items
}

///|
/// Called only after confirming a new character, never when restoring a save.
pub fn GameWorld::begin_starting_build(
  self : GameWorld,
  archetype : CharacterArchetype,
) -> Unit {
  if self.hunting_grounds {
    self.equipment.clear()
    for item in archetype.starting_equipment() {
      ignore(self.equipment.equip(item))
    }
    self.inventory.clear()
    for item in new_hunter_inventory(archetype~).items {
      if item is Some(item) {
        ignore(self.inventory.add(item))
      }
    }
  }
  self.apply_archetype(archetype)
}
