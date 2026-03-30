///|
/// ML-Ready Balance Framework
///
/// This module provides:
/// 1. Feature vector extraction from game state (for ML training data)
/// 2. Archetype detection (what build is the player running?)
/// 3. Gradient-approximation via parameter perturbation
/// 4. Self-play with strategy mixing for robust balance testing
///
/// === Design Philosophy ===
/// Instead of differentiable ECS (which requires a differentiable runtime),
/// we use "finite difference" gradient approximation:
///   grad(f, param) ≈ (f(param + ε) - f(param - ε)) / (2ε)
///
/// This lets us ask: "If we increase Jaw Worm's HP by 5,
/// how does the win rate change?" — without needing autodiff.
///
/// For self-play, we mix strategies with weighted randomization,
/// creating an "ensemble agent" that approximates average human play.

///|
/// Detected player build archetype
pub(all) enum Archetype {
  Strength // STR scaling + multi-hit
  Block // Block stacking + Body Slam
  Exhaust // Thin deck + exhaust synergy
  Balanced // No dominant archetype
} derive(Show, Eq)

///|
/// Detect the archetype of a deck
pub fn detect_archetype(deck : Array[CardId]) -> Archetype {
  let mut str_score = 0
  let mut blk_score = 0
  let mut exh_score = 0
  for card in deck {
    match card {
      // Strength archetype
      Inflame | Demon_Form | Flex => str_score += 3
      Twin_Strike | Sword_Boomerang => str_score += 2
      Headbutt | Rampage => str_score += 1
      // Block archetype
      Barricade | Metallicize => blk_score += 3
      Body_Slam | Impervious => blk_score += 2
      Shrug_It_Off | Iron_Wave | True_Grit | Armaments => blk_score += 1
      // Exhaust archetype
      Feel_No_Pain => exh_score += 3
      Offering | Bloodletting | Seeing_Red => exh_score += 2
      True_Grit => exh_score += 1
      // Neutral
      _ => ()
    }
  }
  let max = if str_score >= blk_score && str_score >= exh_score {
    str_score
  } else if blk_score >= exh_score {
    blk_score
  } else {
    exh_score
  }
  if max < 4 {
    Balanced
  } else if str_score == max {
    Strength
  } else if blk_score == max {
    Block
  } else {
    Exhaust
  }
}

///|
/// Feature vector for ML: captures game state as numeric features
/// Total: 20 features
pub(all) struct GameFeatures {
  // Player state (5)
  player_hp_pct : Double // HP / MaxHP
  player_energy : Double // Current energy
  player_block : Double // Current block
  player_strength : Double // Current strength
  player_hand_size : Double // Cards in hand
  // Deck composition (5)
  deck_size : Double // Total deck size
  attack_ratio : Double // % of deck that is attacks
  avg_card_cost : Double // Average energy cost
  has_scaling : Double // 0 or 1: has STR/Demon Form
  exhaust_count : Double // Number of exhaust cards
  // Enemy state (5)
  total_enemy_hp : Double // Sum of enemy HP
  enemy_count : Double // Number of alive enemies
  max_enemy_damage : Double // Highest incoming damage this turn
  enemy_vulnerable : Double // Sum of vuln turns on enemies
  enemy_strength : Double // Sum of enemy strength
  // Battle state (5)
  turn_number : Double // Current turn
  draw_pile_size : Double // Cards remaining in draw pile
  discard_size : Double // Cards in discard
  powers_active : Double // Number of active power effects
  archetype_score : Double // 0=balanced, 1=str, 2=blk, 3=exh
} derive(Show)

///|
/// Extract features from current battle state
fn extract_features(state : BattleState) -> GameFeatures {
  let hp_pct = state.player.hp.to_double() / state.player.max_hp.to_double()
  // Deck composition from all piles
  let all_cards : Array[CardId] = []
  for c in state.draw_pile {
    all_cards.push(c)
  }
  for c in state.hand {
    all_cards.push(c)
  }
  for c in state.discard_pile {
    all_cards.push(c)
  }
  let deck_size = all_cards.length().to_double()
  let mut attacks = 0
  let mut total_cost = 0
  let mut exhaust_cards = 0
  let mut has_scaling = false
  for card in all_cards {
    let def = card_def(card)
    if def.card_type == Attack {
      attacks += 1
    }
    total_cost += def.cost
    if def.exhaust {
      exhaust_cards += 1
    }
    match card {
      Inflame | Demon_Form | Flex => has_scaling = true
      _ => ()
    }
  }
  let mut total_enemy_hp = 0.0
  let mut alive_count = 0.0
  let mut max_dmg = 0.0
  let mut total_vuln = 0.0
  let mut total_str = 0.0
  for enemy in state.enemies {
    if not(enemy.fighter.is_dead()) {
      total_enemy_hp += enemy.fighter.hp.to_double()
      alive_count += 1.0
      let dmg : Double = match enemy.intent {
        AttackIntent(n) => n.to_double()
        MultiAttack(n, t) => (n * t).to_double()
        _ => 0.0
      }
      if dmg > max_dmg {
        max_dmg = dmg
      }
      total_vuln += enemy.fighter.status.vulnerable.to_double()
      total_str += enemy.fighter.status.strength.to_double()
    }
  }
  let powers_active = (if state.powers.metallicize > 0 { 1.0 } else { 0.0 }) +
    (if state.powers.demon_form > 0 { 1.0 } else { 0.0 }) +
    (if state.powers.barricade { 1.0 } else { 0.0 }) +
    (if state.powers.feel_no_pain > 0 { 1.0 } else { 0.0 })
  let arch = detect_archetype(all_cards)
  let arch_score : Double = match arch {
    Balanced => 0.0
    Strength => 1.0
    Block => 2.0
    Exhaust => 3.0
  }
  {
    player_hp_pct: hp_pct,
    player_energy: state.player.energy.to_double(),
    player_block: state.player.block.to_double(),
    player_strength: state.player.status.strength.to_double(),
    player_hand_size: state.hand.length().to_double(),
    deck_size,
    attack_ratio: if deck_size > 0.0 {
      attacks.to_double() / deck_size
    } else {
      0.0
    },
    avg_card_cost: if all_cards.length() > 0 {
      total_cost.to_double() / deck_size
    } else {
      0.0
    },
    has_scaling: if has_scaling {
      1.0
    } else {
      0.0
    },
    exhaust_count: exhaust_cards.to_double(),
    total_enemy_hp,
    enemy_count: alive_count,
    max_enemy_damage: max_dmg,
    enemy_vulnerable: total_vuln,
    enemy_strength: total_str,
    turn_number: state.turn.to_double(),
    draw_pile_size: state.draw_pile.length().to_double(),
    discard_size: state.discard_pile.length().to_double(),
    powers_active,
    archetype_score: arch_score,
  }
}

///|
/// Convert features to a flat array (for ML input)
fn features_to_array(f : GameFeatures) -> Array[Double] {
  [
    f.player_hp_pct,
    f.player_energy,
    f.player_block,
    f.player_strength,
    f.player_hand_size,
    f.deck_size,
    f.attack_ratio,
    f.avg_card_cost,
    f.has_scaling,
    f.exhaust_count,
    f.total_enemy_hp,
    f.enemy_count,
    f.max_enemy_damage,
    f.enemy_vulnerable,
    f.enemy_strength,
    f.turn_number,
    f.draw_pile_size,
    f.discard_size,
    f.powers_active,
    f.archetype_score,
  ]
}

///|
/// === Parameter Perturbation (Finite Difference Gradient) ===
/// Approximate the gradient of win_rate with respect to a game parameter.
///
/// Usage: "If we increase Jaw Worm HP by 5, how does win rate change?"
///   sensitivity = (win_rate(hp+5) - win_rate(hp-5)) / 10
///
/// This is a discrete approximation to ∂(win_rate)/∂(param).

///|
/// Parameter that can be perturbed for sensitivity analysis
pub(all) enum BalanceParam {
  PlayerHP // Player starting HP
  PlayerEnergy // Player starting energy
  EnemyHP(EnemyId) // Specific enemy's HP
  EnemyDamage(EnemyId) // Specific enemy's damage multiplier
  CardDamage(CardId) // Card's base damage
  CardBlock(CardId) // Card's base block
} derive(Show)

///|
/// Result of sensitivity analysis
pub(all) struct SensitivityResult {
  param : String
  base_win_rate : Double
  perturbed_win_rate : Double
  sensitivity : Double // (perturbed - base) / delta
} derive(Show)

///|
/// Run a single battle with parameter perturbation applied post-creation
fn simulate_battle_perturbed(
  encounter : EncounterId,
  strategy : PlayStrategy,
  seed : Int,
  param : BalanceParam,
  delta : Int,
) -> SimResult {
  let enemy_ids = encounter_enemies(encounter)
  let state = BattleState::new(enemy_ids, seed~)
  // Apply perturbation to the created battle state
  match param {
    PlayerHP => {
      state.player.max_hp += delta
      state.player.hp += delta
      if state.player.hp < 1 {
        state.player.hp = 1
      }
    }
    PlayerEnergy => {
      state.player.max_energy += delta
      state.player.energy += delta
      if state.player.energy < 0 {
        state.player.energy = 0
      }
    }
    EnemyHP(eid) =>
      for enemy in state.enemies {
        if enemy.id == eid {
          enemy.fighter.max_hp += delta
          enemy.fighter.hp += delta
          if enemy.fighter.hp < 1 {
            enemy.fighter.hp = 1
          }
        }
      }
    EnemyDamage(eid) =>
      for enemy in state.enemies {
        if enemy.id == eid {
          // Adjust intent damage directly
          enemy.intent = match enemy.intent {
            AttackIntent(n) => AttackIntent(n + delta)
            MultiAttack(n, t) => MultiAttack(n + delta, t)
            other => other
          }
        }
      }
    CardDamage(_) => () // Card perturbation handled at card_def level (future)
    CardBlock(_) => () // Card perturbation handled at card_def level (future)
  }
  // Run the battle
  let mut cards_played = 0
  let mut safety = 0
  while state.phase == PlayerTurn && safety < 200 {
    safety += 1
    let choice = pick_card(state, strategy)
    match choice {
      Some((hand_idx, target)) => {
        let result = play_card(state, hand_idx, target)
        if result == Ok {
          cards_played += 1
        } else {
          end_player_turn(state)
        }
      }
      None => end_player_turn(state)
    }
    if state.phase == Victory || state.phase == Defeat {
      break
    }
  }
  {
    won: state.phase == Victory,
    turns_taken: state.turn,
    hp_remaining: state.player.hp,
    max_hp: state.player.max_hp,
    cards_played,
  }
}

///|
/// Run N perturbed simulations
fn run_perturbed_simulations(
  encounter : EncounterId,
  strategy : PlayStrategy,
  count : Int,
  param : BalanceParam,
  delta : Int,
) -> SimSummary {
  let mut wins = 0
  let mut total_turns = 0
  let mut total_hp = 0
  let mut total_cards = 0
  let mut min_hp = 999
  let mut max_hp = 0
  let mut i = 0
  while i < count {
    let result = simulate_battle_perturbed(
      encounter,
      strategy,
      i * 7 + 13,
      param,
      delta,
    )
    if result.won {
      wins += 1
    }
    total_turns += result.turns_taken
    total_hp += result.hp_remaining
    total_cards += result.cards_played
    if result.hp_remaining < min_hp {
      min_hp = result.hp_remaining
    }
    if result.hp_remaining > max_hp {
      max_hp = result.hp_remaining
    }
    i += 1
  }
  {
    total: count,
    wins,
    losses: count - wins,
    avg_turns: total_turns / count,
    avg_hp_remaining: total_hp / count,
    avg_cards_played: total_cards / count,
    min_hp,
    max_hp,
  }
}

///|
/// Run sensitivity analysis by perturbing a parameter
/// Uses finite-difference: sensitivity ≈ (win_rate(+δ) - win_rate(-δ)) / (2δ)
pub fn analyze_sensitivity(
  encounter : EncounterId,
  param : BalanceParam,
  delta : Int,
  sim_count : Int,
) -> SensitivityResult {
  // Base win rate
  let base = run_simulations(encounter, Smart, sim_count)
  let base_wr = base.wins.to_double() / base.total.to_double()
  // Perturbed win rate (+delta)
  let perturbed = run_perturbed_simulations(
    encounter,
    Smart,
    sim_count,
    param,
    delta,
  )
  let pert_wr = perturbed.wins.to_double() / perturbed.total.to_double()
  // Sensitivity = change in win rate per unit parameter change
  let sensitivity = (pert_wr - base_wr) / delta.to_double()
  let param_name = match param {
    PlayerHP => "PlayerHP"
    PlayerEnergy => "PlayerEnergy"
    EnemyHP(_) => "EnemyHP"
    EnemyDamage(_) => "EnemyDamage"
    CardDamage(_) => "CardDamage"
    CardBlock(_) => "CardBlock"
  }
  {
    param: param_name,
    base_win_rate: base_wr,
    perturbed_win_rate: pert_wr,
    sensitivity,
  }
}

///|
/// === Ensemble Agent (Mixed Strategy) ===
/// Simulates a "realistic" player by mixing strategies:
///   70% Smart, 20% Aggressive, 10% Defensive
/// This better approximates human play than pure optimal.

///|
pub fn simulate_ensemble(
  encounter : EncounterId,
  count : Int,
  relics? : Array[RelicId] = [],
) -> SimSummary {
  let mut wins = 0
  let mut total_turns = 0
  let mut total_hp = 0
  let mut total_cards = 0
  let mut min_hp = 999
  let mut max_hp = 0
  let mut i = 0
  while i < count {
    // Mix strategies: 70% Smart, 20% Aggressive, 10% Defensive
    let strategy_roll = (i * 31 + 17) % 10
    let strategy : PlayStrategy = if strategy_roll < 7 {
      Smart
    } else if strategy_roll < 9 {
      Aggressive
    } else {
      Defensive
    }
    let result = simulate_battle(encounter, strategy, i * 7 + 13, relics~)
    if result.won {
      wins += 1
    }
    total_turns += result.turns_taken
    total_hp += result.hp_remaining
    total_cards += result.cards_played
    if result.hp_remaining < min_hp {
      min_hp = result.hp_remaining
    }
    if result.hp_remaining > max_hp {
      max_hp = result.hp_remaining
    }
    i += 1
  }
  {
    total: count,
    wins,
    losses: count - wins,
    avg_turns: total_turns / count,
    avg_hp_remaining: total_hp / count,
    avg_cards_played: total_cards / count,
    min_hp,
    max_hp,
  }
}

///|
/// === Balance Report ===
/// Generate a comprehensive balance report for all encounters

///|
pub(all) struct BalanceReport {
  encounter : String
  tier : String
  smart_win_pct : Int
  smart_avg_hp : Int
  ensemble_win_pct : Int
  ensemble_avg_hp : Int
  difficulty_score : Double
} derive(Show)

///|
pub fn generate_balance_report(encounter : EncounterId) -> BalanceReport {
  let smart = run_simulations(encounter, Smart, 50)
  let ensemble = simulate_ensemble(encounter, 50)
  let difficulty = encounter_difficulty(encounter)
  let tier_name = match encounter {
    SingleJawWorm | TwoLouses => "Easy"
    SingleCultist | FungiPair | SlaverFight => "Normal"
    EliteSlaver | SentryPair | EliteNob => "Elite"
    BossGuardian | BossHexaghost => "Boss"
  }
  let enc_name = match encounter {
    SingleJawWorm => "JawWorm"
    TwoLouses => "TwoLouses"
    SingleCultist => "Cultist"
    FungiPair => "FungiPair"
    SlaverFight => "Slaver"
    EliteSlaver => "RedSlaver"
    SentryPair => "SentryPair"
    EliteNob => "GremlinNob"
    BossGuardian => "TheGuardian"
    BossHexaghost => "Hexaghost"
  }
  {
    encounter: enc_name,
    tier: tier_name,
    smart_win_pct: smart.wins * 100 / smart.total,
    smart_avg_hp: smart.avg_hp_remaining,
    ensemble_win_pct: ensemble.wins * 100 / ensemble.total,
    ensemble_avg_hp: ensemble.avg_hp_remaining,
    difficulty_score: difficulty,
  }
}
