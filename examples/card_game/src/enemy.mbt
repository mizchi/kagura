///|
/// Enemy intent (what the enemy plans to do this turn)
pub(all) enum Intent {
  AttackIntent(Int) // Deal N damage
  DefendIntent(Int) // Gain N block
  BuffIntent // Gain strength
  MultiAttack(Int, Int) // Deal N damage X times
} derive(Show, Eq)

///|
/// Enemy with fighter stats and AI
pub(all) struct Enemy {
  fighter : Fighter
  mut intent : Intent
  mut pattern_index : Int // Track AI pattern
} derive(Show)

///|
/// Enemy template identifiers
pub(all) enum EnemyId {
  JawWorm
  Cultist
  SlaverRed
} derive(Show, Eq)

///|
fn spawn_enemy(id : EnemyId) -> Enemy {
  match id {
    JawWorm =>
      {
        fighter: Fighter::new("Jaw Worm", 42),
        intent: AttackIntent(11),
        pattern_index: 0,
      }
    Cultist =>
      {
        fighter: Fighter::new("Cultist", 50),
        intent: BuffIntent,
        pattern_index: 0,
      }
    SlaverRed =>
      {
        fighter: Fighter::new("Red Slaver", 46),
        intent: AttackIntent(13),
        pattern_index: 0,
      }
  }
}

///|
/// Decide next intent based on pattern
fn next_intent(enemy : Enemy) -> Intent {
  let idx = enemy.pattern_index
  // Simple pattern-based AI
  match enemy.fighter.name {
    "Jaw Worm" =>
      // Pattern: Attack 11, Chomp 7+5block, Attack 11, ...
      match idx % 3 {
        0 => AttackIntent(11)
        1 => DefendIntent(5)
        _ => AttackIntent(11)
      }
    "Cultist" =>
      // Pattern: Buff, Attack 6, Attack 6, Buff, ...
      match idx % 3 {
        0 => BuffIntent
        _ => AttackIntent(6)
      }
    "Red Slaver" =>
      // Pattern: Attack 13, Attack 13, MultiAttack 7x2, ...
      match idx % 3 {
        0 => AttackIntent(13)
        1 => AttackIntent(13)
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
    }
    BuffIntent => {
      enemy.fighter.status.strength += 2
      logs.push(enemy.fighter.name + " gains 2 Strength!")
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
          " damage! (" +
          (i + 1).to_string() +
          "/" +
          times.to_string() +
          ")",
        )
        i += 1
      }
    }
  }
  // Advance pattern and set next intent
  enemy.pattern_index += 1
  enemy.intent = next_intent(enemy)
  logs
}
