///|
pub(all) enum CleaverComboStep {
  Opening
  Return
  Finisher
} derive(Eq, Debug)
///|
pub extend CleaverComboStep with Eq::{not_equal, equal}
///|
pub extend CleaverComboStep with @moonbitlang/core/debug.Debug::{to_repr}
///|
pub fn CleaverComboStep::index(self : CleaverComboStep) -> Int {
  match self {
    Opening => 0
    Return => 1
    Finisher => 2
  }
}

///|
fn CleaverComboStep::next(self : CleaverComboStep) -> CleaverComboStep {
  match self {
    Opening => Return
    Return => Finisher
    Finisher => Opening
  }
}

///|
pub fn CleaverComboStep::damage_multiplier(self : CleaverComboStep) -> Double {
  match self {
    Opening => 1.0
    Return => 1.4
    Finisher => 2.6
  }
}

///|
pub fn CleaverComboStep::profile(
  self : CleaverComboStep,
) -> PlayerWeaponProfile {
  let base = Cleaver.profile()
  match self {
    Opening => { ..base, action: "一段目・横薙ぎ", }
    Return =>
      { ..base, action: "二段目・返し斬り", windup: 8, recovery: 14, }
    Finisher =>
      { ..base, action: "三段目・叩き斬り", windup: 16, recovery: 32, }
  }
}

///|
pub fn PlayerWeaponAttack::profile(
  self : PlayerWeaponAttack,
) -> PlayerWeaponProfile {
  if self.weapon == Cleaver {
    self.combo.profile()
  } else {
    self.weapon.profile()
  }
}

///|
fn GameWorld::reset_cleaver_combo(self : GameWorld) -> Unit {
  self.cleaver_next = Opening
  self.cleaver_combo_timer = 0
}

///|
// Includes the active strike, then a 0.75 second window to continue the chain.
let cleaver_combo_window : Int = 45
