///|
/// Balance simulation: auto-play battles with simple AI
/// Used to verify game balance through deterministic simulations.

///|
/// Simple AI strategy for auto-play
enum PlayStrategy {
  Aggressive // Play attacks first, then skills
  Defensive // Play skills first, then attacks
  Smart // Prioritize debuffs, then judge by enemy intent
}

///|
/// Result of a simulated battle
pub(all) struct SimResult {
  won : Bool
  turns_taken : Int
  hp_remaining : Int
  max_hp : Int
  cards_played : Int
} derive(Show)

///|
/// Run a single simulated battle
fn simulate_battle(
  encounter : EncounterId,
  strategy : PlayStrategy,
  seed : Int,
  relics? : Array[RelicId] = [],
) -> SimResult {
  let enemy_ids = encounter_enemies(encounter)
  let state = BattleState::new(enemy_ids, seed~, relics~)
  let mut cards_played = 0
  let mut safety = 0
  while state.phase == PlayerTurn && safety < 200 {
    safety += 1
    // AI picks a card to play
    let choice = pick_card(state, strategy)
    match choice {
      Some((hand_idx, target)) => {
        let result = play_card(state, hand_idx, target)
        if result == Ok {
          cards_played += 1
        } else {
          // Can't play, end turn
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
/// AI card selection
fn pick_card(state : BattleState, strategy : PlayStrategy) -> (Int, Int)? {
  let hand = state.hand
  if hand.length() == 0 {
    return None
  }
  let target = first_alive_enemy(state)
  if target < 0 {
    return None
  }
  match strategy {
    Aggressive => pick_aggressive(state, target)
    Defensive => pick_defensive(state, target)
    Smart => pick_smart(state, target)
  }
}

///|
fn pick_aggressive(state : BattleState, target : Int) -> (Int, Int)? {
  // Play highest damage attack first, then skills
  let mut best_idx = -1
  let mut best_value = -1
  let mut i = 0
  while i < state.hand.length() {
    let def = card_def(state.hand[i])
    if state.player.energy >= def.cost {
      let value = match def.card_type {
        Attack => 100 + def.base_damage
        Power => 90
        Skill =>
          if def.id == Bloodletting ||
            def.id == Offering ||
            def.id == Seeing_Red {
            95 // Energy generators are high priority
          } else {
            def.base_block
          }
      }
      if value > best_value {
        best_value = value
        best_idx = i
      }
    }
    i += 1
  }
  if best_idx >= 0 {
    Some((best_idx, target))
  } else {
    None
  }
}

///|
fn pick_defensive(state : BattleState, target : Int) -> (Int, Int)? {
  let mut best_idx = -1
  let mut best_value = -1
  let mut i = 0
  while i < state.hand.length() {
    let def = card_def(state.hand[i])
    if state.player.energy >= def.cost {
      let value = match def.card_type {
        Skill => 100 + def.base_block
        Power => 90
        Attack => def.base_damage
      }
      if value > best_value {
        best_value = value
        best_idx = i
      }
    }
    i += 1
  }
  if best_idx >= 0 {
    Some((best_idx, target))
  } else {
    None
  }
}

///|
fn pick_smart(state : BattleState, target : Int) -> (Int, Int)? {
  // Check enemy intent to decide strategy
  let enemy = state.enemies[target]
  let enemy_attacking = match enemy.intent {
    AttackIntent(_) | MultiAttack(_, _) => true
    _ => false
  }
  // If enemy is attacking heavy and we have low block, defend
  let need_defense = enemy_attacking && state.player.block < 5
  let mut best_idx = -1
  let mut best_value = -1
  let mut i = 0
  while i < state.hand.length() {
    let def = card_def(state.hand[i])
    if state.player.energy >= def.cost {
      let value = card_smart_value(def, need_defense)
      if value > best_value {
        best_value = value
        best_idx = i
      }
    }
    i += 1
  }
  if best_idx >= 0 {
    Some((best_idx, target))
  } else {
    None
  }
}

///|
fn card_smart_value(def : CardDef, need_defense : Bool) -> Int {
  // Energy generators always high priority
  match def.id {
    Offering => return 200
    Bloodletting => return 190
    Seeing_Red => return 180
    _ => ()
  }
  // Powers are second priority
  if def.card_type == Power {
    return 170
  }
  // Bash/Uppercut/Clothesline (debuff attacks) high priority
  match def.id {
    Bash => return 160
    Uppercut => return 155
    Clothesline => return 150
    _ => ()
  }
  if need_defense {
    match def.card_type {
      Skill => 100 + def.base_block * 3
      Attack =>
        // Iron Wave is good when defending too
        if def.id == Iron_Wave {
          120
        } else {
          def.base_damage
        }
      _ => 50
    }
  } else {
    match def.card_type {
      Attack => 100 + effective_damage(def)
      Skill =>
        if def.id == Shrug_It_Off {
          95 // Draw is valuable
        } else {
          def.base_block
        }
      _ => 50
    }
  }
}

///|
fn effective_damage(def : CardDef) -> Int {
  match def.id {
    Twin_Strike => def.base_damage * 2
    Pommel_Strike => def.base_damage + 5 // bonus for draw
    _ => def.base_damage
  }
}

///|
/// Run N simulations and return summary stats
pub(all) struct SimSummary {
  total : Int
  wins : Int
  losses : Int
  avg_turns : Int
  avg_hp_remaining : Int
  avg_cards_played : Int
  min_hp : Int
  max_hp : Int
} derive(Show)

///|
fn run_simulations(
  encounter : EncounterId,
  strategy : PlayStrategy,
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
