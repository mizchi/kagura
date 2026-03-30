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
  id : EnemyId
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
  SlaverRed
  // Elite encounters
  Sentry
  GremlinNob // Enrages when player plays Skills
  // Boss encounters
  TheGuardian // 240 HP, Mode Shift mechanic
  Hexaghost // 250 HP, multi-hit + scaling
} derive(Show, Eq)

///|
fn enemy_tier(id : EnemyId) -> EncounterTier {
  match id {
    GreenLouse | RedLouse | JawWorm => Easy
    Cultist | FungiBeast | SlaverRed => Normal
    Sentry | GremlinNob => Elite
    TheGuardian | Hexaghost => Boss
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
        // Guardian: 180 HP. Mode Shift at 30 DMG taken → defensive mode
        // Offensive: Twin Slam(2x8), Fierce Bash(28), Whirlwind(5x4)
        // Defensive: Charge Up (+9 block), Roll Attack(9)
        fighter: Fighter::new("The Guardian", 180),
        intent: AttackIntent(8), // Twin Slam first
        pattern_index: 0,
      }
    Hexaghost =>
      {
        id,
        // Hexaghost: 190 HP. Activate first turn, then escalating attacks
        // Inferno(6×2 scaling), Sear(6), Tackle(5+5), Inflame(+2 STR)
        fighter: Fighter::new("Hexaghost", 190),
        intent: BuffIntent, // Activate: no damage turn 1
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
        0 => MultiAttack(8, 2) // Twin Slam (2×8)
        1 => AttackIntent(28) // Fierce Bash
        2 => MultiAttack(5, 4) // Whirlwind (4×5)
        3 => DefendIntent(9) // Charge Up (enter defensive)
        _ => AttackIntent(9) // Roll Attack (back to offensive)
      }
    "Hexaghost" =>
      // Activate → Divider(6×6) → Sear(6) → Tackle(5+5) → Inflame → Inferno(6×2)
      match idx % 5 {
        0 => MultiAttack(6, 6) // Divider: 6 hits of (player HP/12+1)
        1 => AttackIntent(6) // Sear: 6 damage + burn
        2 => MultiAttack(5, 2) // Tackle: 5×2
        3 => BuffIntent // Inflame: +2 STR
        _ => MultiAttack(6, 2) // Inferno: 6×2 (scales with STR)
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
  SlaverFight // Normal: Red Slaver
  EliteSlaver // Elite: heavy hitter (same as SlaverFight but elite tier)
  SentryPair // Elite: two sentries
  EliteNob // Elite: punishes Skills
  BossGuardian // Boss: The Guardian (240 HP)
  BossHexaghost // Boss: Hexaghost (250 HP)
} derive(Show, Eq)

///|
pub fn encounter_enemies(id : EncounterId) -> Array[EnemyId] {
  match id {
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
  }
}

///|
pub(all) enum EncounterTier {
  Easy
  Normal
  Elite
  Boss
} derive(Show, Eq)

///|
fn encounter_tier(id : EncounterId) -> EncounterTier {
  match id {
    SingleJawWorm | TwoLouses => Easy
    SingleCultist | FungiPair | SlaverFight => Normal
    EliteSlaver | SentryPair | EliteNob => Elite
    BossGuardian | BossHexaghost => Boss
  }
}
