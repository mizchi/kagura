///|
pub let summoned_zombie_limit : Int32 = 2

///|
pub let summoned_zombie_taunt_radius : Double = 112.0

///|
pub let summoned_zombie_cooldown : Int32 = 180

///|
pub let flaming_skull_limit : Int32 = 8

///|
pub let flaming_skull_lifetime : Int32 = 360

///|
pub let flaming_skull_cooldown : Int32 = 18

///|
/// Uses the shared creature locomotion/attack state, but never enters the enemy population.
pub(all) struct SummonedZombie {
  body : Enemy
}

///|
/// Spirits deliberately have no health, collision body or threat entry.
pub(all) struct FlamingSkull {
  mut x : Double
  mut y : Double
  mut angle : Double
  mut age : Int32
  mut attack_cooldown : Int32
  mut target : Enemy?
}

///|
pub(all) struct PlayerSummons {
  zombies : Array[SummonedZombie]
  skulls : Array[FlamingSkull]
  mut zombie_cooldown : Int32
  mut skull_cooldown : Int32
}

///|
pub fn PlayerSummons::new() -> PlayerSummons {
  { zombies: [], skulls: [], zombie_cooldown: 0, skull_cooldown: 0, }
}

///|
pub fn PlayerSummons::clear(self : PlayerSummons) -> Unit {
  self.zombies.clear()
  self.skulls.clear()
  self.zombie_cooldown = 0
  self.skull_cooldown = 0
}
