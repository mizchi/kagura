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
} derive(Show, Eq)

///|
/// Relic definition (static data)
pub(all) struct RelicDef {
  id : RelicId
  name : String
  description : String
} derive(Show)

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
  }
}

///|
/// Mutable relic runtime state
pub(all) struct RelicState {
  mut pen_nib_counter : Int // Tracks attacks played for PenNib
} derive(Show)

///|
fn RelicState::new() -> RelicState {
  { pen_nib_counter: 0 }
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
  player : Fighter,
  enemies : Array[Enemy],
) -> Array[String] {
  let logs : Array[String] = []
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
          if not(enemy.fighter.is_dead()) {
            enemy.fighter.status.vulnerable += 1
          }
        }
        logs.push("[Bag of Marbles] All enemies Vulnerable 1")
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
  damage : Int,
) -> (Int, Array[String]) {
  let logs : Array[String] = []
  let mut result = damage
  if has_relic(relics, PenNib) {
    relic_state.pen_nib_counter += 1
    if relic_state.pen_nib_counter >= 10 {
      relic_state.pen_nib_counter = 0
      result = result * 2
      logs.push("[Pen Nib] Double damage!")
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
