///|
/// Relic identifiers
pub(all) enum RelicId {
  BurningBlood // Heal 6 HP at end of combat
  Vajra // Start combat with +1 Strength
  Anchor // Start combat with 10 Block
  Orichalcum // End turn without Block -> gain 6 Block
  BagOfMarbles // Apply 1 Vulnerable to all enemies at start
  Lantern // +1 Energy on turn 1
  PenNib // Every 10th attack deals double damage
  MeatOnTheBone // If HP <= 50% at end of combat, heal 12
  RedSkull // +3 Strength while HP <= 50%
  Akabeko // First attack each combat deals +8 damage
  OrnamentalFan // Every 3rd attack played, gain 4 Block
  HappyFlower // Every 3 turns, gain 1 Energy
} derive(Debug, Eq)

///|
pub impl Show for RelicId with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Relic definition (static data)
pub(all) struct RelicDef {
  id : RelicId
  name : String
  description : String
} derive(Debug)

///|
pub impl Show for RelicDef with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
fn relic_def(id : RelicId) -> RelicDef {
  match id {
    BurningBlood =>
      {
        id: BurningBlood,
        name: "Burning Blood",
        description: "At end of combat, heal 6 HP.",
      }
    Vajra =>
      {
        id: Vajra,
        name: "Vajra",
        description: "At the start of combat, gain 1 Strength.",
      }
    Anchor =>
      {
        id: Anchor,
        name: "Anchor",
        description: "At the start of combat, gain 10 Block.",
      }
    Orichalcum =>
      {
        id: Orichalcum,
        name: "Orichalcum",
        description: "If you end turn with 0 Block, gain 6 Block.",
      }
    BagOfMarbles =>
      {
        id: BagOfMarbles,
        name: "Bag of Marbles",
        description: "At start of combat, apply 1 Vulnerable to ALL enemies.",
      }
    Lantern =>
      {
        id: Lantern,
        name: "Lantern",
        description: "Gain 1 Energy on the first turn.",
      }
    PenNib =>
      {
        id: PenNib,
        name: "Pen Nib",
        description: "Every 10th attack deals double damage.",
      }
    MeatOnTheBone =>
      {
        id: MeatOnTheBone,
        name: "Meat on the Bone",
        description: "If HP <= 50% at end of combat, heal 12 HP.",
      }
    RedSkull =>
      {
        id: RedSkull,
        name: "Red Skull",
        description: "While HP <= 50%, gain 3 Strength.",
      }
    Akabeko =>
      {
        id: Akabeko,
        name: "Akabeko",
        description: "Your first Attack each combat deals 8 additional damage.",
      }
    OrnamentalFan =>
      {
        id: OrnamentalFan,
        name: "Ornamental Fan",
        description: "Every 3rd Attack played, gain 4 Block.",
      }
    HappyFlower =>
      {
        id: HappyFlower,
        name: "Happy Flower",
        description: "Every 3 turns, gain 1 Energy.",
      }
  }
}

///|
/// Mutable relic runtime state
pub(all) struct RelicState {
  mut pen_nib_counter : Int // Tracks attacks played for PenNib
  mut akabeko_active : Bool // First attack this combat gets +8
  mut fan_counter : Int // Counts attacks for OrnamentalFan
  mut flower_counter : Int // Counts turns for HappyFlower
} derive(Debug)

///|
pub impl Show for RelicState with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
fn RelicState::new() -> RelicState {
  {
    pen_nib_counter: 0,
    akabeko_active: true,
    fan_counter: 0,
    flower_counter: 0,
  }
}

///|
/// Check if player has a specific relic
fn has_relic(relics : Array[RelicId], id : RelicId) -> Bool {
  for r in relics {
    if r == id {
      return true
    }
  }
  false
}

///|
/// Apply relic effects at combat start
fn relics_on_battle_start(
  relics : Array[RelicId],
  relic_state : RelicState,
  player : Fighter,
  enemies : Array[Enemy],
) -> Array[String] {
  let logs : Array[String] = []
  // Reset per-combat relic state
  relic_state.akabeko_active = true
  relic_state.fan_counter = 0
  relic_state.flower_counter = 0
  for r in relics {
    match r {
      Vajra => {
        player.status.strength += 1
        logs.push("[Vajra] +1 Strength")
      }
      Anchor => {
        add_block(player, 10)
        logs.push("[Anchor] +10 Block")
      }
      BagOfMarbles => {
        for enemy in enemies {
          if !enemy.fighter.is_dead() {
            enemy.fighter.status.vulnerable += 1
          }
        }
        logs.push("[Bag of Marbles] All enemies Vulnerable 1")
      }
      RedSkull =>
        if player.hp * 2 <= player.max_hp {
          player.status.strength += 3
          logs.push("[Red Skull] +3 Strength (HP <= 50%)")
        }
      _ => ()
    }
  }
  logs
}

///|
/// Apply relic effects at turn start
fn relics_on_turn_start(
  relics : Array[RelicId],
  relic_state : RelicState,
  player : Fighter,
  turn : Int,
) -> Array[String] {
  let logs : Array[String] = []
  for r in relics {
    match r {
      Lantern =>
        if turn == 1 {
          player.energy += 1
          logs.push("[Lantern] +1 Energy")
        }
      HappyFlower => {
        relic_state.flower_counter += 1
        if relic_state.flower_counter >= 3 {
          relic_state.flower_counter = 0
          player.energy += 1
          logs.push("[Happy Flower] +1 Energy")
        }
      }
      _ => ()
    }
  }
  logs
}

///|
/// Apply relic effects at end of player turn (before enemy turn)
fn relics_on_turn_end(
  relics : Array[RelicId],
  player : Fighter,
) -> Array[String] {
  let logs : Array[String] = []
  for r in relics {
    match r {
      Orichalcum =>
        if player.block == 0 {
          add_block(player, 6)
          logs.push("[Orichalcum] +6 Block")
        }
      _ => ()
    }
  }
  logs
}

///|
/// Apply relic effects on attack (modifies damage)
fn relics_on_attack(
  relics : Array[RelicId],
  relic_state : RelicState,
  player : Fighter,
  damage : Int,
) -> (Int, Array[String]) {
  let logs : Array[String] = []
  let mut result = damage
  // Akabeko: first attack +8
  if has_relic(relics, Akabeko) && relic_state.akabeko_active {
    relic_state.akabeko_active = false
    result += 8
    logs.push("[Akabeko] +8 damage!")
  }
  // Pen Nib: every 10th attack double damage
  if has_relic(relics, PenNib) {
    relic_state.pen_nib_counter += 1
    if relic_state.pen_nib_counter >= 10 {
      relic_state.pen_nib_counter = 0
      result = result * 2
      logs.push("[Pen Nib] Double damage!")
    }
  }
  // Ornamental Fan: every 3rd attack +4 block
  if has_relic(relics, OrnamentalFan) {
    relic_state.fan_counter += 1
    if relic_state.fan_counter >= 3 {
      relic_state.fan_counter = 0
      add_block(player, 4)
      logs.push("[Ornamental Fan] +4 Block!")
    }
  }
  (result, logs)
}

///|
/// Apply relic effects on victory
fn relics_on_victory(
  relics : Array[RelicId],
  player : Fighter,
) -> Array[String] {
  let logs : Array[String] = []
  for r in relics {
    match r {
      BurningBlood => {
        let heal = 6
        player.hp = if player.hp + heal > player.max_hp {
          player.max_hp
        } else {
          player.hp + heal
        }
        logs.push("[Burning Blood] Heal 6 HP")
      }
      MeatOnTheBone =>
        if player.hp * 2 <= player.max_hp {
          let heal = 12
          player.hp = if player.hp + heal > player.max_hp {
            player.max_hp
          } else {
            player.hp + heal
          }
          logs.push("[Meat on the Bone] Heal 12 HP")
        }
      _ => ()
    }
  }
  logs
}

///|
pub extend RelicId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RelicId with Eq::{not_equal, equal}

///|
pub extend RelicId with Show::{to_string, output}

///|
pub extend RelicDef with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RelicDef with Show::{to_string, output}

///|
pub extend RelicState with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RelicState with Show::{to_string, output}
