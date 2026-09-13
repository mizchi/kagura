// Action command IDs are shared by all input adapters. Slots own assignments;
// presets only supply defaults. Legacy save IDs never become live commands.

///|
pub let hunter_slot_actions : Array[Int] = [
  74, 50, 86, 70, 84, 51, 52, 53, 54, 56, 57, 48,
]

///|
pub fn GameWorld::hunter_action_learned(self : GameWorld, key : Int) -> Bool {
  match key {
    74 | 86 | 70 | 84 => true
    50 => self.skills.get_level(Whirlwind) > 0
    51 => self.skills.get_level(SplittingFireball) > 0
    52 => self.skills.get_level(IceNova) > 0
    53 => self.skills.get_level(ChainLightning) > 0
    54 => self.skills.get_level(HomingMissile) > 0
    56 => self.skills.get_level(Counter) > 0
    57 => self.skills.get_level(SummonFlamingSkull) > 0
    48 => self.skills.get_level(RaiseZombie) > 0
    _ => false
  }
}

///|
pub fn GameWorld::assign_hunter_slot(
  self : GameWorld,
  slot : Int,
  key : Int,
) -> Bool {
  if !self.hunting_grounds ||
    slot < 0 ||
    slot >= 4 ||
    !self.hunter_action_learned(key) {
    return false
  }
  let previous = self.hunter_slots[slot]
  for i in 0..<4 {
    if self.hunter_slots[i] == key {
      self.hunter_slots[i] = previous
    }
  }
  self.hunter_slots[slot] = key
  true
}

///|
pub fn GameWorld::restore_hunter_slots(
  self : GameWorld,
  saved : Array[Int],
) -> Unit {
  self.hunter_slots = self.hunter_preset.profile().keys.copy()
  if saved.length() != 4 {
    return
  }
  let slots : Array[Int] = []
  for old in saved {
    let key = match old {
      49 => 74
      67 => 86
      _ => old
    }
    if !hunter_slot_actions.contains(key) || slots.contains(key) {
      return
    }
    slots.push(key)
  }
  self.hunter_slots = slots
}
