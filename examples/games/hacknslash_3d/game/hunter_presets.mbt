///|
pub(all) enum HunterPreset {
  BladePreset
  StormPreset
  MarksmanPreset
} derive(Eq, Debug)

///|
pub(all) struct HunterPresetProfile {
  id : String
  name : String
  weapon : PlayerWeaponKind
  // Existing action command IDs, shared by keyboard, touch and pad adapters.
  keys : Array[Int]
}

///|
pub let hunter_presets : Array[HunterPresetProfile] = [
  { id: "blade", name: "近接", weapon: Cleaver, keys: [74, 50, 86, 70], },
  { id: "storm", name: "魔法", weapon: Focus, keys: [53, 84, 51, 52], },
  { id: "marksman", name: "遠距離", weapon: Bow, keys: [54, 84, 51, 52], },
]

///|
pub fn HunterPreset::index(self : HunterPreset) -> Int {
  match self {
    BladePreset => 0
    StormPreset => 1
    MarksmanPreset => 2
  }
}

///|
pub fn HunterPreset::profile(self : HunterPreset) -> HunterPresetProfile {
  hunter_presets[self.index()]
}

///|
pub fn hunter_preset_from_id(id : String) -> HunterPreset? {
  match id {
    "blade" => Some(BladePreset)
    "storm" => Some(StormPreset)
    "marksman" => Some(MarksmanPreset)
    _ => None
  }
}

///|
pub fn default_hunter_preset(archetype : CharacterArchetype) -> HunterPreset {
  match archetype {
    Melee => BladePreset
    Mage => StormPreset
    _ => MarksmanPreset
  }
}

///|
pub fn GameWorld::apply_hunter_preset(
  self : GameWorld,
  preset : HunterPreset,
) -> Bool {
  if !self.hunting_grounds || !self.equip_player_weapon(preset.profile().weapon) {
    return false
  }
  self.hunter_preset = preset
  self.hunter_slots = preset.profile().keys.copy()
  true
}
