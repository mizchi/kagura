///|
/// Balance simulation: auto-play battles with simple AI
/// Used to verify game balance through deterministic simulations.

///|
/// Simple AI strategy for auto-play
pub(all) enum PlayStrategy {
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
} derive(Debug)

///|
pub impl Show for SimResult with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Run a single simulated battle
pub fn simulate_battle(
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
    let cost = if state.powers.corruption && def.card_type == Skill {
      0
    } else {
      def.cost
    }
    if state.player.energy >= cost {
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
    let cost = if state.powers.corruption && def.card_type == Skill {
      0
    } else {
      def.cost
    }
    if state.player.energy >= cost {
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
/// Calculate total incoming damage from all enemy intents
fn calc_incoming_damage(state : BattleState) -> Int {
  let mut total = 0
  for enemy in state.enemies {
    if !enemy.fighter.is_dead() {
      match enemy.intent {
        AttackIntent(base) => {
          let dmg = calculate_attack_damage(base, enemy.fighter)
          total += dmg
        }
        MultiAttack(base, times) => {
          let dmg = calculate_attack_damage(base, enemy.fighter)
          total += dmg * times
        }
        _ => ()
      }
    }
  }
  total
}

///|
/// Check if any alive enemy is Gremlin Nob
fn has_nob(state : BattleState) -> Bool {
  for enemy in state.enemies {
    if enemy.id == GremlinNob && !enemy.fighter.is_dead() {
      return true
    }
  }
  false
}

///|
/// Find the best target (lowest HP alive enemy for faster kills)
fn best_target(state : BattleState) -> Int {
  let mut best = -1
  let mut lowest_hp = 9999
  let mut i = 0
  while i < state.enemies.length() {
    if !state.enemies[i].fighter.is_dead() {
      if state.enemies[i].fighter.hp < lowest_hp {
        lowest_hp = state.enemies[i].fighter.hp
        best = i
      }
    }
    i += 1
  }
  best
}

///|
fn pick_smart(state : BattleState, _default_target : Int) -> (Int, Int)? {
  let target = best_target(state)
  if target < 0 {
    return None
  }
  let incoming = calc_incoming_damage(state)
  let unblocked = incoming - state.player.block
  // Need defense if incoming damage exceeds current block significantly
  let need_defense = unblocked > 5
  // Against Nob: avoid Skills and Powers (they trigger Enrage +2 STR)
  let nob_present = has_nob(state)
  let mut best_idx = -1
  let mut best_value = -1
  let mut i = 0
  while i < state.hand.length() {
    let def = card_def(state.hand[i])
    let cost = if state.powers.corruption && def.card_type == Skill {
      0
    } else if state.hand[i] == Whirlwind {
      0
    } else {
      def.cost
    }
    if state.player.energy >= cost {
      let value = card_smart_value(
        def, need_defense, nob_present, unblocked, state,
      )
      if value > best_value {
        best_value = value
        best_idx = i
      }
    }
    i += 1
  }
  if best_idx >= 0 {
    // For targeted cards, pick the best target
    let card_id = state.hand[best_idx]
    let actual_target = if card_needs_target(card_id) { target } else { 0 }
    Some((best_idx, actual_target))
  } else {
    None
  }
}

///|
fn card_smart_value(
  def : CardDef,
  need_defense : Bool,
  nob_present : Bool,
  unblocked_damage : Int,
  state : BattleState,
) -> Int {
  // Against Nob: heavily penalize Skills and Powers (they trigger Enrage)
  if nob_present && (def.card_type == Skill || def.card_type == Power) {
    // Only play Skills if we're about to die and need block
    if need_defense && unblocked_damage > 15 && def.base_block > 0 {
      return def.base_block // Low value, but better than dying
    }
    return -100 // Don't play Skills/Powers against Nob
  }
  // Energy generators: high priority but not against Nob (they're Skills/Powers)
  match def.id {
    Offering => return 200
    Bloodletting => return 190
    Battle_Trance => return 185
    Seeing_Red => return 180
    _ => ()
  }
  // Powers: invest in scaling (very high priority in long fights)
  match def.id {
    Demon_Form => return 175
    Inflame => return 170
    Corruption => return 170 // Extremely powerful: free Skills
    Metallicize => return 168
    Barricade => return 165
    Feel_No_Pain => return 163
    _ => ()
  }
  // Limit Break: double strength — amazing when STR > 0
  if def.id == Limit_Break {
    if state.player.status.strength >= 3 {
      return 200 // Double 3+ STR is game-changing
    }
    if state.player.status.strength >= 1 {
      return 160
    }
    return 10 // Not useful with 0 STR
  }
  // AoE debuffs
  match def.id {
    Shockwave => return 160
    _ => ()
  }
  // Debuff attacks: apply vulnerability/weakness early
  match def.id {
    Bash =>
      // Higher value if enemy isn't already vulnerable
      return 155
    Uppercut => return 153
    Clothesline => return 150
    Disarm => return 148
    _ => ()
  }
  // Entrench: double Block — great when already blocking
  if def.id == Entrench {
    if state.player.block >= 10 {
      return 180 // Double 10+ block is huge
    }
    return 30 // Not useful without existing block
  }
  // Impervious: amazing when facing big damage
  if def.id == Impervious {
    if unblocked_damage > 15 {
      return 250
    }
    if need_defense {
      return 200
    }
    return 50 // Don't waste it when not needed
  }
  if need_defense {
    // Prioritize blocking proportional to unblocked damage
    match def.card_type {
      Skill => {
        let block_value = def.base_block
        if block_value > 0 {
          // Value block cards more when incoming damage is high
          let urgency = if unblocked_damage > 20 { 4 } else { 3 }
          100 + block_value * urgency
        } else {
          20
        }
      }
      Attack =>
        if def.id == Iron_Wave {
          120 // Both block and damage
        } else {
          // Still play attacks, but lower priority than blocking
          50 + effective_damage(def)
        }
      _ => 50
    }
  } else {
    // Offensive mode: prioritize damage
    match def.card_type {
      Attack => {
        let eff = effective_damage(def)
        // Bonus for vulnerability exploiters (multi-hit)
        let vuln_bonus = if state.enemies.length() > 0 {
          let t = best_target(state)
          if t >= 0 && state.enemies[t].fighter.status.vulnerable > 0 {
            eff / 3 // 33% bonus damage from vuln is valuable
          } else {
            0
          }
        } else {
          0
        }
        100 + eff + vuln_bonus
      }
      Skill =>
        if def.id == Shrug_It_Off {
          95 // Draw + block is always good
        } else if def.id == True_Grit {
          90
        } else if def.id == Flex {
          88
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
    Sword_Boomerang => def.base_damage * 3
    Bludgeon => def.base_damage // 32 is already high
    Anger => def.base_damage + 3 // free + copy value
    Rampage => def.base_damage + 10 // scaling value
    Heavy_Blade => def.base_damage + 10 // STR scaling value
    Whirlwind => def.base_damage * 3 // ~3 energy worth of AoE
    Feed => def.base_damage + 5 // kill bonus value
    Fiend_Fire => def.base_damage * 4 // ~4 cards in hand average
    Pummel => def.base_damage * 4 // 4 hits
    Carnage => def.base_damage // 20 is already high
    Immolate => def.base_damage + 10 // AoE value
    Reaper => def.base_damage * 3 + 5 // AoE + heal value
    _ => def.base_damage
  }
}

///|
/// AI potion usage: returns (potion_index, target) or None
fn pick_potion(state : BattleState, potions : Array[PotionId]) -> (Int, Int)? {
  if potions.length() == 0 {
    return None
  }
  let incoming = calc_incoming_damage(state)
  let unblocked = incoming - state.player.block
  let target = best_target(state)
  if target < 0 {
    return None
  }
  let target_hp = state.enemies[target].fighter.hp
  // Count alive enemies
  let mut alive = 0
  for e in state.enemies {
    if !e.fighter.is_dead() {
      alive += 1
    }
  }
  // Priority 1: StrengthPotion early in battle (turn 1-2)
  if state.turn <= 2 {
    let mut i = 0
    while i < potions.length() {
      if potions[i] == StrengthPotion {
        return Some((i, 0))
      }
      i += 1
    }
  }
  // Priority 2: FirePotion to finish off an enemy
  let mut i = 0
  while i < potions.length() {
    if potions[i] == FirePotion && target_hp <= 20 {
      return Some((i, target))
    }
    i += 1
  }
  // Priority 3: BlockPotion when taking big unblocked damage
  if unblocked > 15 {
    let mut i = 0
    while i < potions.length() {
      if potions[i] == BlockPotion {
        return Some((i, 0))
      }
      i += 1
    }
  }
  // Priority 4: ExplosivePotion against multiple enemies
  if alive >= 2 {
    let mut i = 0
    while i < potions.length() {
      if potions[i] == ExplosivePotion {
        return Some((i, 0))
      }
      i += 1
    }
  }
  // Priority 5: WeakPotion against strong attackers
  if unblocked > 10 {
    let mut i = 0
    while i < potions.length() {
      if potions[i] == WeakPotion {
        return Some((i, target))
      }
      i += 1
    }
  }
  // Priority 6: RegenPotion when HP is low
  if state.player.hp < state.player.max_hp / 2 {
    let mut i = 0
    while i < potions.length() {
      if potions[i] == RegenPotion {
        return Some((i, 0))
      }
      i += 1
    }
  }
  None
}

///|
/// Use potions at start of player turn during simulation
fn try_use_potions(state : BattleState, potions : Array[PotionId]) -> Int {
  let mut used = 0
  let mut safety = 0
  while safety < 3 {
    safety += 1
    match pick_potion(state, potions) {
      Some((idx, target)) => {
        let potion = potions[idx]
        if use_potion_in_combat(state, potion, target) {
          potions.remove(idx) |> ignore
          used += 1
        } else {
          break
        }
      }
      None => break
    }
    if state.phase == Victory || state.phase == Defeat {
      break
    }
  }
  used
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
} derive(Debug)

///|
pub impl Show for SimSummary with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn run_simulations(
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

///|
pub extend SimResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SimResult with Show::{to_string, output}

///|
pub extend SimSummary with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SimSummary with Show::{to_string, output}
