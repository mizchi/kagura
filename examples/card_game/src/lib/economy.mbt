///|
/// Game Economy Model (Machinations-style formalization)
///
/// This module formalizes the card game economy as a system of
/// interconnected resource flows, inspired by Joris Dormans' Machinations.
///
/// === Resource Pools ===
/// - HP: Finite, drains over the run. THE critical resource.
/// - Energy: Regenerates each turn. Constrains card plays per turn.
/// - Cards (Draw): 5/turn. Information + options.
/// - Block: Temporary, resets each turn. Prevents HP drain.
/// - Deck: Grows over run. Quality vs quantity tension.
///
/// === Key Flows (per turn) ===
/// Energy(3) -> Card plays -> Damage/Block output
/// Enemy Intent -> Incoming Damage -> Block absorbs -> HP drain
///
/// === The Core Loop (Machinations view) ===
///   [Energy Pool: 3] --gate--> [Card Play] --converter--> [Damage Pool]
///                                    |                         |
///                                    v                         v
///                              [Block Pool] <--absorb-- [Enemy Damage]
///                                    |                         |
///                                    v (overflow)              v
///                              [HP Pool: 80] <------------ [HP Drain]
///
/// === What Makes StS Fun (formalized) ===
/// 1. RESOURCE TRADEOFF: HP is the universal currency. Every decision
///    trades future HP for present advantage (or vice versa).
/// 2. SYNERGY EXPLOSION: Build archetypes create multiplicative scaling.
///    Linear cards (Strike) vs multiplicative cards (Inflame + multi-hit).
/// 3. INFORMATION ASYMMETRY: Intent system reveals WHAT but not WHEN.
///    Player must optimize under partial information.
/// 4. POWER CURVE: Starter deck is intentionally weak. Card rewards
///    create a rising power curve that must outpace enemy scaling.
/// 5. DECK QUALITY: Adding cards dilutes deck. Thin deck = consistency.
///    Fat deck = versatility but inconsistency.

///|
/// Economy metrics for a single turn
pub(all) struct TurnEconomy {
  energy_spent : Int
  energy_wasted : Int // energy left at end of turn
  damage_dealt : Int
  block_gained : Int
  block_wasted : Int // block that didn't absorb anything
  hp_lost : Int
  cards_played : Int
  cards_drawn : Int
} derive(Show)

///|
/// Economy metrics aggregated over a full battle
pub(all) struct BattleEconomy {
  turns : Int
  total_damage_dealt : Int
  total_block_gained : Int
  total_hp_lost : Int
  total_energy_spent : Int
  total_energy_wasted : Int
  total_cards_played : Int
  // Derived ratios
  dpe : Double // Damage Per Energy
  bpe : Double // Block Per Energy
  damage_per_turn : Double // Average damage output per turn
  damage_taken_per_turn : Double // Average HP loss per turn
  efficiency : Double // (damage + block) / (energy * baseline_dpe)
} derive(Show)

///|
/// Calculate economy metrics from a simulation
fn analyze_battle_economy(
  encounter : EncounterId,
  strategy : PlayStrategy,
  seed : Int,
  relics? : Array[RelicId] = [],
) -> BattleEconomy {
  let enemy_ids = encounter_enemies(encounter)
  let state = BattleState::new(enemy_ids, seed~, relics~)
  let initial_hp = state.player.hp
  let mut total_damage = 0
  let mut total_block = 0
  let mut total_energy_spent = 0
  let mut total_energy_wasted = 0
  let mut total_cards_played = 0
  let mut safety = 0
  while state.phase == PlayerTurn && safety < 200 {
    safety += 1
    let energy_before = state.player.energy
    let choice = pick_card(state, strategy)
    match choice {
      Some((hand_idx, target)) => {
        let card_id = state.hand[hand_idx]
        let def = card_def(card_id)
        let hp_before_enemies : Array[Int] = []
        for e in state.enemies {
          hp_before_enemies.push(e.fighter.hp)
        }
        let result = play_card(state, hand_idx, target)
        if result == Ok {
          total_cards_played += 1
          total_energy_spent += def.cost
          // Track damage dealt
          let mut i = 0
          while i < state.enemies.length() {
            let before = hp_before_enemies[i]
            let after = state.enemies[i].fighter.hp
            if after < before {
              total_damage += before - after
            }
            i += 1
          }
          // Track block gained from skills
          if def.base_block > 0 {
            total_block += def.base_block
          }
        } else {
          total_energy_wasted += state.player.energy
          end_player_turn(state)
        }
      }
      None => {
        total_energy_wasted += state.player.energy
        end_player_turn(state)
      }
    }
    if state.phase == Victory || state.phase == Defeat {
      break
    }
  }
  let turns = state.turn
  let hp_lost = initial_hp - state.player.hp
  let energy_total = total_energy_spent + total_energy_wasted
  let dpe = if total_energy_spent > 0 {
    total_damage.to_double() / total_energy_spent.to_double()
  } else {
    0.0
  }
  let bpe = if total_energy_spent > 0 {
    total_block.to_double() / total_energy_spent.to_double()
  } else {
    0.0
  }
  let dpt = if turns > 0 {
    total_damage.to_double() / turns.to_double()
  } else {
    0.0
  }
  let dtpt = if turns > 0 {
    hp_lost.to_double() / turns.to_double()
  } else {
    0.0
  }
  // Efficiency: how well are we converting energy into value?
  // Baseline: Strike = 6 DPE, Defend = 5 BPE
  let baseline_value = energy_total.to_double() * 5.5 // avg of 6 and 5
  let actual_value = (total_damage + total_block).to_double()
  let efficiency = if baseline_value > 0.0 {
    actual_value / baseline_value
  } else {
    0.0
  }
  {
    turns,
    total_damage_dealt: total_damage,
    total_block_gained: total_block,
    total_hp_lost: hp_lost,
    total_energy_spent,
    total_energy_wasted,
    total_cards_played,
    dpe,
    bpe,
    damage_per_turn: dpt,
    damage_taken_per_turn: dtpt,
    efficiency,
  }
}

///|
/// Run economy analysis across multiple seeds and aggregate
fn analyze_economy_aggregate(
  encounter : EncounterId,
  strategy : PlayStrategy,
  count : Int,
  relics? : Array[RelicId] = [],
) -> BattleEconomy {
  let mut total_turns = 0
  let mut total_damage = 0
  let mut total_block = 0
  let mut total_hp_lost = 0
  let mut total_energy_spent = 0
  let mut total_energy_wasted = 0
  let mut total_cards = 0
  let mut i = 0
  while i < count {
    let eco = analyze_battle_economy(encounter, strategy, i * 7 + 13, relics~)
    total_turns += eco.turns
    total_damage += eco.total_damage_dealt
    total_block += eco.total_block_gained
    total_hp_lost += eco.total_hp_lost
    total_energy_spent += eco.total_energy_spent
    total_energy_wasted += eco.total_energy_wasted
    total_cards += eco.total_cards_played
    i += 1
  }
  let avg_turns = total_turns / count
  let dpe = if total_energy_spent > 0 {
    total_damage.to_double() / total_energy_spent.to_double()
  } else {
    0.0
  }
  let bpe = if total_energy_spent > 0 {
    total_block.to_double() / total_energy_spent.to_double()
  } else {
    0.0
  }
  let dpt = if total_turns > 0 {
    total_damage.to_double() / total_turns.to_double()
  } else {
    0.0
  }
  let dtpt = if total_turns > 0 {
    total_hp_lost.to_double() / total_turns.to_double()
  } else {
    0.0
  }
  let energy_total = (total_energy_spent + total_energy_wasted).to_double()
  let baseline = energy_total * 5.5
  let actual = (total_damage + total_block).to_double()
  let efficiency = if baseline > 0.0 { actual / baseline } else { 0.0 }
  {
    turns: avg_turns,
    total_damage_dealt: total_damage / count,
    total_block_gained: total_block / count,
    total_hp_lost: total_hp_lost / count,
    total_energy_spent: total_energy_spent / count,
    total_energy_wasted: total_energy_wasted / count,
    total_cards_played: total_cards / count,
    dpe,
    bpe,
    damage_per_turn: dpt,
    damage_taken_per_turn: dtpt,
    efficiency,
  }
}

///|
/// === Synergy Archetype Model ===
/// StS builds are powerful because cards synergize multiplicatively.
/// This models the three Ironclad archetypes and their scaling.
///
/// Archetype 1: STRENGTH (multiplicative damage)
///   Core: Inflame(+2 STR), Spot Weakness(+3), Demon Form(+2/turn)
///   Payoff: Heavy Strike, Sword Boomerang (STR applies per hit)
///   Scaling: Linear with STR, multiplicative with multi-hit
///   Formula: total_damage = hits × (base + STR)
///
/// Archetype 2: BLOCK (defensive scaling)
///   Core: Shrug It Off, Iron Wave, Metallicize
///   Payoff: Body Slam (damage = block), Barricade (block persists)
///   Scaling: Defensive = survive longer = more turns to deal damage
///
/// Archetype 3: EXHAUST (thin deck)
///   Core: Offering, Seeing Red, True Grit
///   Payoff: Feel No Pain(+block on exhaust), Dark Embrace(+draw on exhaust)
///   Scaling: Deck gets thinner → draw key cards more often

///|
/// Card value model: estimates the "real" value of a card in context
pub(all) struct CardValue {
  raw_damage : Double // Direct damage output
  raw_block : Double // Direct block output
  energy_value : Double // Energy generated/saved
  draw_value : Double // Cards drawn (each worth ~2.0 value)
  debuff_value : Double // Vulnerable/Weak value in future turns
  scaling_value : Double // Strength/permanent buffs
  synergy_multiplier : Double // How much better this gets with archetype
  total : Double
} derive(Show)

///|
/// Evaluate a card's economy value
fn evaluate_card(id : CardId) -> CardValue {
  let def = card_def(id)
  let cost = def.cost.to_double()
  let raw_damage : Double = match id {
    Body_Slam => 10.0 // avg block when played ≈ 10
    Fiend_Fire => 7.0 * 4.0 // ~4 cards exhausted average
    Whirlwind => 5.0 * 3.0 // ~3 energy average
    Heavy_Blade => 14.0 + 6.0 // STR bonus estimate
    _ => def.base_damage.to_double()
  }
  let raw_block = def.base_block.to_double()
  let energy_value : Double = match id {
    Bloodletting => 2.0 * 5.5 - 3.0
    Offering => 2.0 * 5.5 - 6.0 + 3.0 * 2.0
    Seeing_Red => 2.0 * 5.5 - cost * 5.5
    Battle_Trance => 3.0 * 2.0 // 3 draws
    Anger => 3.0 // 0-cost = free + copy in discard
    _ => 0.0
  }
  let draw_value : Double = match id {
    Pommel_Strike | Shrug_It_Off => 2.0
    Headbutt => 1.5 // recurring a key card
    _ => 0.0
  }
  let debuff_value : Double = match id {
    Bash => 15.0
    Uppercut => 7.5 + 3.0
    Clothesline => 6.0
    Shockwave => 30.0 // Vuln 3 + Weak 3 to ALL
    Disarm => 12.0 // -2 STR on enemy for rest of fight
    _ => 0.0
  }
  let scaling_value : Double = match id {
    Inflame => 2.0 * 10.0
    Demon_Form => 2.0 * 30.0 // +2 STR/turn for many turns
    Metallicize => 3.0 * 8.0 // +3 block × remaining turns
    Barricade => 20.0 // enables block stacking
    Feel_No_Pain => 15.0 // synergy with exhaust
    Corruption => 30.0 // free Skills is massive
    Flex => 2.0 * 2.0 // temporary but 0-cost
    Rampage => 5.0 * 3.0 // grows each play
    Limit_Break => 20.0 // double STR is explosive
    Feed => 3.0 * 3.0 // +3 max HP per kill compounds
    _ => 0.0
  }
  let synergy_multiplier : Double = match id {
    Twin_Strike | Sword_Boomerang | Heavy_Blade => 1.3 // STR synergy
    Body_Slam => 1.5 // Block synergy
    Inflame | Demon_Form | Limit_Break => 1.5 // Enables STR archetype
    Offering | True_Grit | Feel_No_Pain | Corruption | Fiend_Fire => 1.4 // Exhaust archetype
    Bash | Shockwave => 1.3 // Vuln synergy
    Barricade | Metallicize => 1.4 // Block archetype
    Impervious => 1.3 // Block archetype
    Whirlwind => 1.3 // AoE + energy dump
    Feed => 1.2 // HP growth
    _ => 1.0
  }
  let adjusted_damage = match id {
    Twin_Strike => raw_damage * 2.0
    _ => raw_damage
  }
  let total = (
      adjusted_damage +
      raw_block +
      energy_value +
      draw_value +
      debuff_value +
      scaling_value
    ) *
    synergy_multiplier /
    (if cost > 0.0 { cost } else { 0.5 }) // 0-cost cards use 0.5 as divisor
  {
    raw_damage: adjusted_damage,
    raw_block,
    energy_value,
    draw_value,
    debuff_value,
    scaling_value,
    synergy_multiplier,
    total,
  }
}

///|
/// === Run-Level Power Curve ===
/// Models how player power should scale across floors.
///
/// The key insight: enemy difficulty scales roughly linearly,
/// but player power should scale sub-linearly on average,
/// with occasional super-linear spikes when synergies click.
///
///   Power
///     |          /--- synergy spike
///     |        /
///     |      /  --- enemy scaling
///     |    /  /
///     |  / /  --- avg player scaling
///     | //
///     |/
///     +---------> Floor
///
/// This tension (player slightly behind enemy curve most of the time,
/// occasionally ahead when build comes together) is what creates
/// the "one more run" feeling.

///|
/// Estimate deck power level (simple heuristic)
fn deck_power(deck : Array[CardId]) -> Double {
  let mut total = 0.0
  for card in deck {
    total += evaluate_card(card).total
  }
  // Deck consistency penalty: larger decks are less consistent
  // Optimal deck size ≈ 12-15 cards for Ironclad
  let size = deck.length().to_double()
  let consistency = if size <= 12.0 {
    1.0
  } else {
    12.0 / size // diminishing returns
  }
  total * consistency
}

///|
/// Estimate enemy encounter difficulty
fn encounter_difficulty(id : EncounterId) -> Double {
  let enemies = encounter_enemies(id)
  let mut total_hp = 0.0
  let mut total_dpt = 0.0 // damage per turn from enemies
  for eid in enemies {
    let e = spawn_enemy(eid)
    total_hp += e.fighter.hp.to_double()
    // Estimate average damage per turn from intent pattern
    let avg_dmg = match eid {
      JawWorm => (11.0 + 0.0 + 7.0) / 3.0 // chomp, bellow, thrash
      GreenLouse => (0.0 + 6.0 + 6.0) / 3.0
      RedLouse => (6.0 + 6.0 + 0.0) / 3.0
      Cultist => (0.0 + 6.0) / 2.0 // + scaling STR makes this much worse
      FungiBeast => (6.0 + 0.0 + 6.0 + 0.0) / 4.0
      SlaverRed => (13.0 + 13.0 + 8.0 + 0.0) / 4.0
      Sentry => (9.0 + 9.0 + 10.0) / 3.0
      GremlinNob => (0.0 + 14.0 + 6.0) / 3.0 // + enrage scaling
      TheGuardian => (16.0 + 32.0 + 20.0 + 0.0 + 9.0) / 5.0
      Hexaghost => (36.0 + 6.0 + 10.0 + 0.0 + 12.0) / 5.0
    }
    total_dpt += avg_dmg
  }
  // Difficulty = how many turns to kill × damage per turn
  // Higher = harder
  let turns_to_kill = total_hp / 15.0 // ~15 damage per turn from starter deck
  turns_to_kill * total_dpt
}

///|
/// === Balance Targets (StS Act 1 reference) ===
///
/// Starter deck (10 cards, no relics):
///   DPE: 6.0 (Strike baseline)
///   BPE: 5.0 (Defend baseline)
///   Avg damage/turn: ~13-15 (2 Strikes + 1 Defend or similar)
///
/// Target HP loss per encounter (starter deck):
///   Easy:    5-15 HP  (player has clear advantage)
///   Normal: 15-30 HP  (player needs to play well)
///   Elite:  30-50 HP  (significant cost, may need potions)
///
/// Target win rate (optimal play):
///   Easy:   95-100%
///   Normal: 80-95%
///   Elite:  50-75%
///
/// Card reward value progression:
///   Common: 1.0-1.3× Strike value
///   Uncommon: 1.5-2.0× Strike value
///   Rare: 2.5-4.0× Strike value (but situational)

///|
/// Run simulation with full economy tracking
pub(all) struct RunSimResult {
  won : Bool
  floors_reached : Int
  hp_at_each_floor : Array[Int]
  deck_size_at_each_floor : Array[Int]
  cards_added : Array[CardId]
} derive(Show)

///|
pub fn simulate_run(seed : Int, strategy : PlayStrategy) -> RunSimResult {
  let run = RunState::new(seed~)
  let hp_history : Array[Int] = [run.player_hp]
  let deck_history : Array[Int] = [run.deck.length()]
  let cards_added : Array[CardId] = []
  let mut safety = 0
  while safety < 100 {
    safety += 1
    match run.phase {
      Battle =>
        match run.battle {
          Some(state) => {
            // Auto-play the battle
            let mut battle_safety = 0
            while state.phase == PlayerTurn && battle_safety < 300 {
              battle_safety += 1
              let choice = pick_card(state, strategy)
              match choice {
                Some((hand_idx, target)) => {
                  let result = play_card(state, hand_idx, target)
                  if result != Ok {
                    end_player_turn(state)
                  }
                }
                None => end_player_turn(state)
              }
              if state.phase == Victory || state.phase == Defeat {
                break
              }
            }
            if state.phase == Victory {
              on_battle_victory(run)
            } else {
              on_battle_defeat(run)
            }
          }
          None => break
        }
      CardReward => {
        // Smart card pick: consider deck synergy and size
        if run.card_rewards.length() > 0 {
          let archetype = detect_archetype(run.deck)
          let mut best_idx = 0
          let mut best_val = 0.0
          let mut i = 0
          while i < run.card_rewards.length() {
            let card = run.card_rewards[i]
            let base_val = evaluate_card(card).total
            // Synergy bonus: cards that match current archetype
            let synergy = match (archetype, card) {
              // Strength archetype: bonus for multi-hit and STR cards
              (Strength, Twin_Strike) => 5.0
              (Strength, Sword_Boomerang) => 5.0
              (Strength, Heavy_Blade) => 8.0
              (Strength, Inflame) => 8.0
              (Strength, Demon_Form) => 10.0
              (Strength, Limit_Break) => 12.0
              (Strength, Flex) => 3.0
              // Block archetype: bonus for block-related cards
              (Block, Barricade) => 10.0
              (Block, Metallicize) => 8.0
              (Block, Body_Slam) => 7.0
              (Block, Impervious) => 6.0
              (Block, Shrug_It_Off) => 3.0
              // Exhaust archetype
              (Exhaust, Feel_No_Pain) => 10.0
              (Exhaust, Corruption) => 12.0
              (Exhaust, Fiend_Fire) => 8.0
              (Exhaust, True_Grit) => 5.0
              (Exhaust, Offering) => 5.0
              // Universal good cards
              (_, Shockwave) => 4.0
              (_, Bash) => 2.0
              (_, Battle_Trance) => 3.0
              (_, Feed) => 3.0
              (_, Whirlwind) => 4.0
              _ => 0.0
            }
            let val = base_val + synergy
            if val > best_val {
              best_val = val
              best_idx = i
            }
            i += 1
          }
          // Skip thresholds based on deck size
          let skip_threshold = if run.deck.length() > 18 {
            20.0 // Very selective when deck is large
          } else if run.deck.length() > 14 {
            12.0
          } else {
            5.0 // Take almost anything early
          }
          if best_val < skip_threshold {
            pick_card_reward(run, -1) // skip
          } else {
            cards_added.push(run.card_rewards[best_idx])
            pick_card_reward(run, best_idx)
          }
        } else {
          pick_card_reward(run, -1)
        }
        hp_history.push(run.player_hp)
        deck_history.push(run.deck.length())
      }
      RestSite => {
        rest_heal(run)
        hp_history.push(run.player_hp)
        deck_history.push(run.deck.length())
      }
      RunVictory | RunDefeat => break
    }
  }
  {
    won: run.phase == RunVictory,
    floors_reached: run.floor,
    hp_at_each_floor: hp_history,
    deck_size_at_each_floor: deck_history,
    cards_added,
  }
}

///|
/// Run multiple full-run simulations
pub(all) struct RunSimSummary {
  total : Int
  wins : Int
  avg_floors : Int
  avg_final_hp : Int
  avg_deck_size : Int
  win_rate_pct : Int
} derive(Show)

///|
pub fn simulate_runs(count : Int, strategy : PlayStrategy) -> RunSimSummary {
  let mut wins = 0
  let mut total_floors = 0
  let mut total_hp = 0
  let mut total_deck = 0
  let mut i = 0
  while i < count {
    let result = simulate_run(i * 13 + 7, strategy)
    if result.won {
      wins += 1
    }
    total_floors += result.floors_reached
    // Final HP
    let final_hp = if result.hp_at_each_floor.length() > 0 {
      result.hp_at_each_floor[result.hp_at_each_floor.length() - 1]
    } else {
      0
    }
    total_hp += final_hp
    let final_deck = if result.deck_size_at_each_floor.length() > 0 {
      result.deck_size_at_each_floor[result.deck_size_at_each_floor.length() - 1]
    } else {
      10
    }
    total_deck += final_deck
    i += 1
  }
  {
    total: count,
    wins,
    avg_floors: total_floors / count,
    avg_final_hp: total_hp / count,
    avg_deck_size: total_deck / count,
    win_rate_pct: wins * 100 / count,
  }
}
