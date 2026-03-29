///|
/// Enemy intent (what the enemy plans to do this turn)
pub(all) enum Intent {
  AttackIntent(Int) // Deal N damage
  DefendIntent(Int) // Gain N block
  BuffIntent // Gain strength
  MultiAttack(Int, Int) // Deal N damage X times
  DebuffIntent // Apply Weak/Vulnerable to player
} derive(Show, Eq)

///|
/// Enemy with fighter stats and AI
pub(all) struct Enemy {
  fighter : Fighter
  mut intent : Intent
  mut pattern_index : Int
} derive(Show)

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
  // Elite encounters
  SlaverRed
  Sentry
} derive(Show, Eq)

///|
/// Encounter difficulty tier
pub(all) enum EncounterTier {
  Easy
  Normal
  Elite
} derive(Show, Eq)

///|
fn enemy_tier(id : EnemyId) -> EncounterTier {
  match id {
    GreenLouse | RedLouse | JawWorm => Easy
    Cultist | FungiBeast => Normal
    SlaverRed | Sentry => Elite
  }
}

///|
fn spawn_enemy(id : EnemyId) -> Enemy {
  match id {
    GreenLouse =>
      {
        fighter: Fighter::new("Green Louse", 18),
        intent: DefendIntent(5), // Curl Up first
        pattern_index: 0,
      }
    RedLouse =>
      {
        fighter: Fighter::new("Red Louse", 20),
        intent: AttackIntent(10),
        pattern_index: 0,
      }
    JawWorm =>
      {
        fighter: Fighter::new("Jaw Worm", 48),
        intent: AttackIntent(14),
        pattern_index: 0,
      }
    Cultist =>
      {
        fighter: Fighter::new("Cultist", 85),
        intent: BuffIntent,
        pattern_index: 0,
      }
    FungiBeast =>
      {
        fighter: Fighter::new("Fungi Beast", 46),
        intent: AttackIntent(10),
        pattern_index: 0,
      }
    SlaverRed =>
      {
        fighter: Fighter::new("Red Slaver", 96),
        intent: AttackIntent(20),
        pattern_index: 0,
      }
    Sentry =>
      {
        fighter: Fighter::new("Sentry", 40),
        intent: AttackIntent(11),
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
      // Curl Up, then bite repeatedly
      match idx % 3 {
        0 => DefendIntent(5)
        _ => AttackIntent(8)
      }
    "Red Louse" =>
      // Attack, attack, grow (buff)
      match idx % 3 {
        0 => AttackIntent(10)
        1 => AttackIntent(10)
        _ => BuffIntent
      }
    "Jaw Worm" =>
      // Chomp(14), Bellow(block 7 + STR), Thrash(10)
      match idx % 3 {
        0 => AttackIntent(14)
        1 => DefendIntent(7)
        _ => AttackIntent(10)
      }
    "Cultist" =>
      // Incantation(buff), Dark Strike x2, repeat
      match idx % 3 {
        0 => BuffIntent
        _ => AttackIntent(9)
      }
    "Fungi Beast" =>
      // Bite(10), Grow(buff), Bite(10), Debuff(vuln)
      match idx % 4 {
        0 => AttackIntent(10)
        1 => BuffIntent
        2 => AttackIntent(10)
        _ => DebuffIntent
      }
    "Red Slaver" =>
      // Stab(20), Stab(20), Scrape(14+weak), Entangle(debuff)
      match idx % 4 {
        0 => AttackIntent(20)
        1 => AttackIntent(20)
        2 => AttackIntent(14)
        _ => DebuffIntent
      }
    "Sentry" =>
      // Beam(11), Beam(11), Bolt(7x2)
      match idx % 3 {
        0 => AttackIntent(11)
        1 => AttackIntent(11)
        _ => MultiAttack(7, 2)
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
    }
    DefendIntent(amount) => {
      add_block(enemy.fighter, amount)
      logs.push(enemy.fighter.name + " gains " + amount.to_string() + " Block.")
      // Jaw Worm Bellow also buffs strength
      if enemy.fighter.name == "Jaw Worm" {
        enemy.fighter.status.strength += 2
        logs.push(enemy.fighter.name + " gains 2 Strength!")
      }
    }
    BuffIntent => {
      let str_amount = match enemy.fighter.name {
        "Cultist" => 5
        _ => 3
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
          player.status.weak += 2
          player.status.vulnerable += 1
          logs.push(enemy.fighter.name + " entangles! Weak 2, Vulnerable 1.")
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
  SingleJawWorm // Easy: single enemy
  TwoLouses // Easy: two small enemies
  SingleCultist // Normal: scaling threat
  FungiPair // Normal: two fungi beasts
  EliteSlaver // Elite: heavy hitter
  SentryPair // Elite: two sentries
} derive(Show, Eq)

///|
fn encounter_enemies(id : EncounterId) -> Array[EnemyId] {
  match id {
    SingleJawWorm => [JawWorm]
    TwoLouses => [GreenLouse, RedLouse]
    SingleCultist => [Cultist]
    FungiPair => [FungiBeast, FungiBeast]
    EliteSlaver => [SlaverRed]
    SentryPair => [Sentry, Sentry]
  }
}

///|
fn encounter_tier(id : EncounterId) -> EncounterTier {
  match id {
    SingleJawWorm | TwoLouses => Easy
    SingleCultist | FungiPair => Normal
    EliteSlaver | SentryPair => Elite
  }
}
