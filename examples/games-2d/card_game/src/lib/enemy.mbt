///|
/// Enemy intent (what the enemy plans to do this turn)
pub(all) enum Intent {
  AttackIntent(Int) // Deal N damage
  DefendIntent(Int) // Gain N block
  BuffIntent // Gain strength
  MultiAttack(Int, Int) // Deal N damage X times
  DebuffIntent // Apply Weak/Vulnerable to player
} derive(Debug, Eq)

///|
pub impl Show for Intent with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Enemy with fighter stats and AI
pub(all) struct Enemy {
  id : EnemyId
  fighter : Fighter
  mut intent : Intent
  mut pattern_index : Int
} derive(Debug)

///|
pub impl Show for Enemy with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Enemy template identifiers
pub(all) enum EnemyId {
  // Easy encounters
  GreenLouse
  RedLouse
  JawWorm
  // Normal encounters
  Cultist
  FungiBeast
  SlaverRed
  // Elite encounters
  Sentry
  GremlinNob // Enrages when player plays Skills
  // Boss encounters
  TheGuardian // 240 HP, Mode Shift mechanic
  Hexaghost // 250 HP, multi-hit + scaling
  // Act 2 Normal
  Chosen // 91 HP, hex debuff + poke attack
  SnakePlant // 75 HP, multi-bite + weaken
  // Act 2 Elite
  BookOfStabbing // 160 HP, escalating multi-stab
  // Act 2 Boss
  BronzeAutomaton // 300 HP, hyper beam + flail
} derive(Debug, Eq)

///|
pub impl Show for EnemyId with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
#warnings("-unused_value")
fn enemy_tier(id : EnemyId) -> EncounterTier {
  match id {
    GreenLouse | RedLouse | JawWorm => Easy
    Cultist | FungiBeast | SlaverRed => Normal
    Chosen | SnakePlant => Normal // Act 2 normal
    Sentry | GremlinNob => Elite
    BookOfStabbing => Elite // Act 2 elite
    TheGuardian | Hexaghost => Boss
    BronzeAutomaton => Boss // Act 2 boss
  }
}

///|
pub fn spawn_enemy(id : EnemyId) -> Enemy {
  match id {
    GreenLouse =>
      {
        id,
        fighter: Fighter::new("Green Louse", 14),
        intent: DefendIntent(4), // Curl Up first (3-7 in StS)
        pattern_index: 0,
      }
    RedLouse =>
      {
        id,
        fighter: Fighter::new("Red Louse", 13),
        intent: AttackIntent(6), // Bite 5-7 in StS
        pattern_index: 0,
      }
    JawWorm =>
      {
        id,
        fighter: Fighter::new("Jaw Worm", 42),
        intent: AttackIntent(11), // Chomp: 11-12 in StS
        pattern_index: 0,
      }
    Cultist =>
      {
        id,
        fighter: Fighter::new("Cultist", 50),
        intent: BuffIntent, // Incantation: +3 Ritual (STR/turn!)
        pattern_index: 0,
      }
    FungiBeast =>
      {
        id,
        fighter: Fighter::new("Fungi Beast", 24),
        intent: AttackIntent(6), // Bite: 6 in StS
        pattern_index: 0,
      }
    SlaverRed =>
      {
        id,
        fighter: Fighter::new("Red Slaver", 50),
        intent: AttackIntent(14), // Stab: 14
        pattern_index: 0,
      }
    Sentry =>
      {
        id,
        fighter: Fighter::new("Sentry", 42),
        intent: AttackIntent(9), // Bolt: 9
        pattern_index: 0,
      }
    GremlinNob =>
      {
        id,
        // Nob: 90 HP, Bellow first turn (+2 STR), enrages on player Skills
        fighter: Fighter::new("Gremlin Nob", 90),
        intent: BuffIntent, // Bellow turn 1
        pattern_index: 0,
      }
    TheGuardian =>
      {
        id,
        // Guardian: 140 HP. Mode Shift at 30 DMG taken → defensive mode
        // Offensive: Twin Slam(2x7), Fierce Bash(22), Whirlwind(4x4)
        // Defensive: Charge Up (+9 block), Roll Attack(9)
        fighter: Fighter::new("The Guardian", 140),
        intent: MultiAttack(7, 2), // Twin Slam first
        pattern_index: 0,
      }
    Hexaghost =>
      {
        id,
        // Hexaghost: 140 HP. Activate first turn, then escalating attacks
        // Divider(5×4), Sear(6), Tackle(5+2), Inflame(+2 STR), Inferno(6×2)
        fighter: Fighter::new("Hexaghost", 140),
        intent: BuffIntent, // Activate: no damage turn 1
        pattern_index: 0,
      }
    Chosen =>
      {
        id,
        // Chosen: 75 HP. Hex (debuff), then Poke(12), then big Drain(18)
        fighter: Fighter::new("Chosen", 75),
        intent: DebuffIntent, // Hex: apply Vulnerable + Weak
        pattern_index: 0,
      }
    SnakePlant =>
      {
        id,
        // SnakePlant: 75 HP. Bite-bite-chomp pattern
        fighter: Fighter::new("Snake Plant", 75),
        intent: AttackIntent(7), // Bite
        pattern_index: 0,
      }
    BookOfStabbing =>
      {
        id,
        // BookOfStabbing: 130 HP. Multi-stab that escalates
        fighter: Fighter::new("Book of Stabbing", 130),
        intent: MultiAttack(6, 2), // starts with 2 stabs
        pattern_index: 0,
      }
    BronzeAutomaton =>
      {
        id,
        // BronzeAutomaton: 200 HP. Flail, then Boost, then Hyper Beam
        fighter: Fighter::new("Bronze Automaton", 200),
        intent: AttackIntent(8), // Flail
        pattern_index: 0,
      }
  }
}

///|
/// Decide next intent based on pattern
fn next_intent(enemy : Enemy) -> Intent {
  let idx = enemy.pattern_index
  match enemy.fighter.name {
    "Green Louse" =>
      // Curl Up first, then alternate bite and bite
      match idx % 3 {
        0 => DefendIntent(4) // Curl Up (3-7 block)
        _ => AttackIntent(6) // Bite (5-7)
      }
    "Red Louse" =>
      // Bite, Bite, Grow (+3 STR)
      match idx % 3 {
        0 => AttackIntent(6)
        1 => AttackIntent(6)
        _ => BuffIntent // Grow: +3 STR
      }
    "Jaw Worm" =>
      // Chomp(11), Bellow(block 6 + STR 3), Thrash(7)
      match idx % 3 {
        0 => AttackIntent(11) // Chomp
        1 => DefendIntent(6) // Bellow (also +3 STR)
        _ => AttackIntent(7) // Thrash
      }
    "Cultist" =>
      // Incantation(+3 Ritual/STR), Dark Strike(6), repeat
      // Key: Ritual stacks — each Incantation adds +3 STR permanently
      match idx % 2 {
        0 => BuffIntent // Incantation: +3 Ritual (STR)
        _ => AttackIntent(6) // Dark Strike
      }
    "Fungi Beast" =>
      // Bite(6), Grow(+3 STR), Bite(6), Debuff(vuln 2)
      match idx % 4 {
        0 => AttackIntent(6)
        1 => BuffIntent // Grow: +3 STR
        2 => AttackIntent(6)
        _ => DebuffIntent // Apply Vulnerable 2
      }
    "Red Slaver" =>
      // Stab(14), Stab(14), Scrape(9 + Weak 1), Entangle(debuff)
      match idx % 4 {
        0 => AttackIntent(14)
        1 => AttackIntent(14)
        2 => AttackIntent(9)
        _ => DebuffIntent
      }
    "Sentry" =>
      // Bolt(9), Bolt(9), Beam(attack + Daze status)
      match idx % 3 {
        0 => AttackIntent(9)
        1 => AttackIntent(9)
        _ => MultiAttack(5, 2) // Beam: multiple hits
      }
    "Gremlin Nob" =>
      // Bellow(+2 STR), then Rush(14) / Skull Bash(6 + Vuln 2)
      match idx % 3 {
        0 => BuffIntent // Bellow: +2 STR
        1 => AttackIntent(14) // Rush
        _ => AttackIntent(6) // Skull Bash (+ Vuln 2)
      }
    "The Guardian" =>
      // Offensive mode: Twin Slam, Fierce Bash, Whirlwind, then Charge Up
      match idx % 5 {
        0 => MultiAttack(7, 2) // Twin Slam (2×7)
        1 => AttackIntent(22) // Fierce Bash
        2 => MultiAttack(4, 4) // Whirlwind (4×4)
        3 => DefendIntent(9) // Charge Up (enter defensive)
        _ => AttackIntent(9) // Roll Attack (back to offensive)
      }
    "Hexaghost" =>
      // Activate → Divider(5×4) → Sear(6) → Tackle(5+2) → Inflame → Inferno(6×2)
      match idx % 5 {
        0 => MultiAttack(5, 4) // Divider: 4 hits of 5
        1 => AttackIntent(6) // Sear: 6 damage + burn
        2 => MultiAttack(5, 2) // Tackle: 5×2
        3 => BuffIntent // Inflame: +2 STR
        _ => MultiAttack(6, 2) // Inferno: 6×2 (scales with STR)
      }
    "Chosen" =>
      // Hex (debuff), Poke(12), Drain(18)
      match idx % 3 {
        0 => DebuffIntent // Hex: Vuln 2 + Weak 2
        1 => AttackIntent(12) // Poke
        _ => AttackIntent(18) // Drain: big hit
      }
    "Snake Plant" =>
      // Bite(7), Bite(7), Chomp(18), Weaken
      match idx % 4 {
        0 => AttackIntent(7)
        1 => AttackIntent(7)
        2 => AttackIntent(18) // Chomp: big hit
        _ => DebuffIntent // Weaken: apply Weak 2
      }
    "Book of Stabbing" =>
      // Multi-stab that escalates: 2, 3, 4, 5 stabs of 6 dmg
      match idx % 4 {
        0 => MultiAttack(6, 2)
        1 => MultiAttack(6, 3)
        2 => MultiAttack(6, 4)
        _ => MultiAttack(6, 5) // 30 damage!
      }
    "Bronze Automaton" =>
      // Flail(8), Flail(8), Boost(+3 STR), Hyper Beam(38), Stun(0)
      match idx % 5 {
        0 => AttackIntent(8)
        1 => AttackIntent(8)
        2 => BuffIntent // Boost: +3 STR
        3 => AttackIntent(38) // Hyper Beam
        _ => DefendIntent(0) // Stun: does nothing (recovery)
      }
    _ => AttackIntent(5)
  }
}

///|
/// Execute enemy's intended action against the player
fn execute_enemy_intent(enemy : Enemy, player : Fighter) -> Array[String] {
  let logs : Array[String] = []
  match enemy.intent {
    AttackIntent(base_damage) => {
      let damage = calculate_attack_damage(base_damage, enemy.fighter)
      let actual = apply_damage(player, damage)
      logs.push(
        enemy.fighter.name + " attacks for " + actual.to_string() + " damage!",
      )
      // Nob's Skull Bash (6 dmg base) applies Vulnerable 2
      if enemy.fighter.name == "Gremlin Nob" && base_damage == 6 {
        player.status.vulnerable += 2
        logs.push("Skull Bash! Vulnerable 2!")
      }
    }
    DefendIntent(amount) => {
      add_block(enemy.fighter, amount)
      logs.push(enemy.fighter.name + " gains " + amount.to_string() + " Block.")
      // Jaw Worm Bellow also buffs strength (+3 in StS)
      if enemy.fighter.name == "Jaw Worm" {
        enemy.fighter.status.strength += 3
        logs.push(enemy.fighter.name + " gains 3 Strength!")
      }
    }
    BuffIntent => {
      let str_amount = match enemy.fighter.name {
        "Cultist" => 3 // Ritual: +3 STR (stacks each cycle!)
        "Red Louse" => 3 // Grow: +3 STR
        "Fungi Beast" => 3 // Grow: +3 STR
        "Gremlin Nob" => 2 // Bellow: +2 STR
        "Bronze Automaton" => 3 // Boost: +3 STR
        _ => 2
      }
      enemy.fighter.status.strength += str_amount
      logs.push(
        enemy.fighter.name + " gains " + str_amount.to_string() + " Strength!",
      )
    }
    MultiAttack(base_damage, times) => {
      let damage = calculate_attack_damage(base_damage, enemy.fighter)
      let mut i = 0
      while i < times {
        let actual = apply_damage(player, damage)
        logs.push(
          enemy.fighter.name +
          " hits for " +
          actual.to_string() +
          " (" +
          (i + 1).to_string() +
          "/" +
          times.to_string() +
          ")",
        )
        i += 1
      }
    }
    DebuffIntent =>
      match enemy.fighter.name {
        "Fungi Beast" => {
          player.status.vulnerable += 2
          logs.push(enemy.fighter.name + " applies Vulnerable 2!")
        }
        "Red Slaver" => {
          player.status.weak += 1
          player.status.vulnerable += 1
          logs.push(enemy.fighter.name + " entangles! Weak 1, Vulnerable 1.")
        }
        "Chosen" => {
          // Hex: apply Vulnerable 2 + Weak 2
          player.status.vulnerable += 2
          player.status.weak += 2
          logs.push("Hex! Vulnerable 2, Weak 2!")
        }
        "Snake Plant" => {
          // Weaken: apply Weak 2
          player.status.weak += 2
          logs.push(enemy.fighter.name + " weakens you! Weak 2!")
        }
        _ => {
          player.status.weak += 1
          logs.push(enemy.fighter.name + " weakens you!")
        }
      }
  }
  // Advance pattern and set next intent
  enemy.pattern_index += 1
  enemy.intent = next_intent(enemy)
  logs
}

///|
/// Predefined encounter configurations
pub(all) enum EncounterId {
  // Act 1
  SingleJawWorm // Easy: single enemy
  TwoLouses // Easy: two small enemies
  SingleCultist // Normal: scaling threat
  FungiPair // Normal: two fungi beasts
  SlaverFight // Normal: Red Slaver
  EliteSlaver // Elite: heavy hitter (same as SlaverFight but elite tier)
  SentryPair // Elite: two sentries
  EliteNob // Elite: punishes Skills
  BossGuardian // Boss: The Guardian
  BossHexaghost // Boss: Hexaghost
  // Act 2
  SingleChosen // Normal: hex debuff + poke
  SnakePlantFight // Normal: multi-bite + weaken
  ChosenSlaver // Normal: mixed debuff pair
  Act2EliteBook // Elite: escalating multi-stab
  Act2EliteSentryTrio // Elite: three sentries
  BossAutomaton // Boss: Bronze Automaton
} derive(Debug, Eq)

///|
pub impl Show for EncounterId with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn encounter_enemies(id : EncounterId) -> Array[EnemyId] {
  match id {
    // Act 1
    SingleJawWorm => [JawWorm]
    TwoLouses => [GreenLouse, RedLouse]
    SingleCultist => [Cultist]
    FungiPair => [FungiBeast, FungiBeast]
    SlaverFight => [SlaverRed]
    EliteSlaver => [SlaverRed]
    SentryPair => [Sentry, Sentry]
    EliteNob => [GremlinNob]
    BossGuardian => [TheGuardian]
    BossHexaghost => [Hexaghost]
    // Act 2
    SingleChosen => [Chosen]
    SnakePlantFight => [SnakePlant]
    ChosenSlaver => [Chosen, GreenLouse]
    Act2EliteBook => [BookOfStabbing]
    Act2EliteSentryTrio => [Sentry, Sentry]
    BossAutomaton => [BronzeAutomaton]
  }
}

///|
pub(all) enum EncounterTier {
  Easy
  Normal
  Elite
  Boss
} derive(Debug, Eq)

///|
pub impl Show for EncounterTier with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
#warnings("-unused_value")
fn encounter_tier(id : EncounterId) -> EncounterTier {
  match id {
    SingleJawWorm | TwoLouses => Easy
    SingleCultist | FungiPair | SlaverFight => Normal
    SingleChosen | SnakePlantFight | ChosenSlaver => Normal
    EliteSlaver | SentryPair | EliteNob => Elite
    Act2EliteBook | Act2EliteSentryTrio => Elite
    BossGuardian | BossHexaghost => Boss
    BossAutomaton => Boss
  }
}

///|
pub extend Intent with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Intent with Eq::{not_equal, equal}

///|
pub extend Intent with Show::{to_string, output}

///|
pub extend Enemy with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Enemy with Show::{to_string, output}

///|
pub extend EnemyId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EnemyId with Eq::{not_equal, equal}

///|
pub extend EnemyId with Show::{to_string, output}

///|
pub extend EncounterId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EncounterId with Eq::{not_equal, equal}

///|
pub extend EncounterId with Show::{to_string, output}

///|
pub extend EncounterTier with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EncounterTier with Eq::{not_equal, equal}

///|
pub extend EncounterTier with Show::{to_string, output}
