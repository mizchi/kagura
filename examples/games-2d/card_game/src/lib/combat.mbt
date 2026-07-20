///|
/// Status effects with duration (turns remaining)
pub(all) struct StatusEffects {
  mut vulnerable : Int // Take 50% more damage
  mut weak : Int // Deal 25% less damage
  mut strength : Int // +damage per attack (permanent)
} derive(Debug)

///|
pub impl Show for StatusEffects with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
fn StatusEffects::new() -> StatusEffects {
  { vulnerable: 0, weak: 0, strength: 0 }
}

///|
/// A combatant (player or enemy)
pub(all) struct Fighter {
  name : String
  mut hp : Int
  mut max_hp : Int
  mut block : Int
  mut energy : Int
  mut max_energy : Int
  status : StatusEffects
} derive(Debug)

///|
pub impl Show for Fighter with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
fn Fighter::new(name : String, max_hp : Int, max_energy? : Int = 0) -> Fighter {
  {
    name,
    hp: max_hp,
    max_hp,
    block: 0,
    energy: max_energy,
    max_energy,
    status: StatusEffects::new(),
  }
}

///|
fn Fighter::is_dead(self : Fighter) -> Bool {
  self.hp <= 0
}

///|
/// Calculate outgoing damage with attacker's status effects
fn calculate_attack_damage(base : Int, attacker : Fighter) -> Int {
  let mut damage = base + attacker.status.strength
  if attacker.status.weak > 0 {
    // Weak: deal 25% less damage
    damage = (damage.to_double() * 0.75).to_int()
  }
  if damage < 0 {
    0
  } else {
    damage
  }
}

///|
/// Calculate incoming damage with defender's status effects
fn calculate_received_damage(damage : Int, defender : Fighter) -> Int {
  let mut result = damage
  if defender.status.vulnerable > 0 {
    // Vulnerable: take 50% more damage
    result = (result.to_double() * 1.5).to_int()
  }
  if result < 0 {
    0
  } else {
    result
  }
}

///|
/// Apply damage to a fighter (goes through block first)
fn apply_damage(fighter : Fighter, raw_damage : Int) -> Int {
  let damage = calculate_received_damage(raw_damage, fighter)
  if fighter.block >= damage {
    fighter.block -= damage
    0
  } else {
    let remaining = damage - fighter.block
    fighter.block = 0
    fighter.hp -= remaining
    if fighter.hp < 0 {
      fighter.hp = 0
    }
    remaining
  }
}

///|
/// Add block to a fighter
fn add_block(fighter : Fighter, amount : Int) -> Unit {
  fighter.block += amount
}

///|
/// Tick down status effects at end of turn
fn tick_status_effects(fighter : Fighter) -> Unit {
  if fighter.status.vulnerable > 0 {
    fighter.status.vulnerable -= 1
  }
  if fighter.status.weak > 0 {
    fighter.status.weak -= 1
  }
}

///|
/// Reset block at start of turn
fn reset_block(fighter : Fighter) -> Unit {
  fighter.block = 0
}

///|
pub extend StatusEffects with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StatusEffects with Show::{to_string, output}

///|
pub extend Fighter with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Fighter with Show::{to_string, output}
