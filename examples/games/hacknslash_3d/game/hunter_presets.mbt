///|
pub(all) enum HunterPreset {
  BladePreset
  StormPreset
  MarksmanPreset
  SummonerPreset
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
  {
    id: "blade",
    name: Melee.build_name(),
    weapon: Cleaver,
    keys: [74, 50, 86, 70],
  },
  {
    id: "storm",
    name: Mage.build_name(),
    weapon: Focus,
    keys: [53, 84, 51, 52],
  },
  {
    id: "marksman",
    name: Ranger.build_name(),
    weapon: Bow,
    keys: [74, 54, 86, 70],
  },
  {
    id: "summoner",
    name: CharacterArchetype::Summoner.build_name(),
    weapon: Focus,
    keys: [57, 48, 52, 86],
  },
]

///|
pub fn HunterPreset::index(self : HunterPreset) -> Int {
  match self {
    BladePreset => 0
    StormPreset => 1
    MarksmanPreset => 2
    SummonerPreset => 3
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
    "summoner" => Some(SummonerPreset)
    _ => None
  }
}

///|
pub fn default_hunter_preset(archetype : CharacterArchetype) -> HunterPreset {
  match archetype {
    Melee => BladePreset
    Mage => StormPreset
    Summoner => SummonerPreset
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
