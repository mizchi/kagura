///|
/// Run progression: multi-encounter roguelike loop

///|
/// Phase of the overall run
pub(all) enum RunPhase {
  Battle
  CardReward
  RestSite
  RunVictory
  RunDefeat
} derive(Show, Eq)

///|
/// Floor type determines what happens on each floor
enum FloorType {
  Combat(EncounterTier)
  Rest
  Boss
} derive(Show, Eq)

///|
/// The full run state persisting across battles
pub(all) struct RunState {
  deck : Array[CardId]
  relics : Array[RelicId]
  relic_state : RelicState
  mut player_hp : Int
  mut player_max_hp : Int
  mut floor : Int
  mut phase : RunPhase
  mut battle : BattleState?
  card_rewards : Array[CardId]
  mut rng_seed : Int
} derive(Show)

///|
let max_floor : Int = 7

///|
/// Floor layout for Act 1
fn floor_type(floor : Int) -> FloorType {
  match floor {
    1 => Combat(Easy)
    2 => Combat(Easy)
    3 => Combat(Normal)
    4 => Rest
    5 => Combat(Normal)
    6 => Combat(Elite)
    7 => Combat(Elite)
    _ => Combat(Easy)
  }
}

///|
/// Create a new run
fn RunState::new(seed? : Int = 42) -> RunState {
  let state : RunState = {
    deck: starter_deck(),
    relics: [BurningBlood],
    relic_state: RelicState::new(),
    player_hp: 80,
    player_max_hp: 80,
    floor: 0,
    phase: Battle,
    battle: None,
    card_rewards: [],
    rng_seed: seed,
  }
  advance_floor(state)
  state
}

///|
/// Simple RNG for run-level decisions
fn run_random(state : RunState) -> Int {
  state.rng_seed = state.rng_seed * 1103515245 + 12345
  (state.rng_seed >> 16) & 0x7FFF
}

///|
/// Advance to the next floor
fn advance_floor(state : RunState) -> Unit {
  state.floor += 1
  if state.floor > max_floor {
    state.phase = RunVictory
    return
  }
  match floor_type(state.floor) {
    Combat(tier) => {
      let encounter = pick_encounter(state, tier)
      let battle = start_run_battle(state, encounter)
      state.battle = Some(battle)
      state.phase = Battle
    }
    Rest => state.phase = RestSite
    Boss => {
      // Use elite for now as "boss"
      let encounter = pick_encounter(state, Elite)
      let battle = start_run_battle(state, encounter)
      state.battle = Some(battle)
      state.phase = Battle
    }
  }
}

///|
/// Pick a random encounter for a given tier
fn pick_encounter(state : RunState, tier : EncounterTier) -> EncounterId {
  let r = run_random(state)
  match tier {
    Easy =>
      match r % 2 {
        0 => SingleJawWorm
        _ => TwoLouses
      }
    Normal =>
      match r % 2 {
        0 => SingleCultist
        _ => FungiPair
      }
    Elite =>
      match r % 2 {
        0 => EliteSlaver
        _ => SentryPair
      }
  }
}

///|
/// Start a battle using the run's persistent state
fn start_run_battle(state : RunState, encounter : EncounterId) -> BattleState {
  let enemy_ids = encounter_enemies(encounter)
  let enemies : Array[Enemy] = []
  for id in enemy_ids {
    enemies.push(spawn_enemy(id))
  }
  // Build deck copy
  let deck : Array[CardId] = []
  for card in state.deck {
    deck.push(card)
  }
  let battle : BattleState = {
    player: Fighter::new("Ironclad", state.player_max_hp, max_energy=3),
    enemies,
    relics: state.relics,
    relic_state: state.relic_state,
    draw_pile: deck,
    hand: [],
    discard_pile: [],
    exhaust_pile: [],
    turn: 0,
    phase: PlayerTurn,
    logs: [],
    rng_seed: state.rng_seed,
  }
  battle.player.hp = state.player_hp
  // Apply relic battle start effects
  let relic_logs = relics_on_battle_start(
    battle.relics,
    battle.player,
    battle.enemies,
  )
  for log in relic_logs {
    battle.logs.push(log)
  }
  shuffle(battle, battle.draw_pile)
  draw_cards(battle, hand_size)
  battle.player.energy = battle.player.max_energy
  battle.turn = 1
  battle.logs.push(
    "Floor " + state.floor.to_string() + " - Battle Start! Turn 1",
  )
  let turn_logs = relics_on_turn_start(battle.relics, battle.player, 1)
  for log in turn_logs {
    battle.logs.push(log)
  }
  battle
}

///|
/// Handle battle victory: sync HP back to run, offer card rewards
fn on_battle_victory(state : RunState) -> Unit {
  match state.battle {
    Some(battle) => {
      state.player_hp = battle.player.hp
      state.rng_seed = battle.rng_seed
      // Generate 3 card rewards
      state.card_rewards.clear()
      let pool = reward_card_pool()
      let mut i = 0
      while i < 3 && pool.length() > 0 {
        let idx = run_random(state) % pool.length()
        let card = pool[idx]
        // Avoid duplicates in rewards
        let mut dup = false
        for c in state.card_rewards {
          if c == card {
            dup = true
          }
        }
        if not(dup) {
          state.card_rewards.push(card)
          i += 1
        }
        // Remove from pool to avoid infinite loop
        let _ = pool.remove(idx)
      }
      state.phase = CardReward
    }
    None => ()
  }
}

///|
/// Handle battle defeat
fn on_battle_defeat(state : RunState) -> Unit {
  match state.battle {
    Some(battle) => {
      state.player_hp = battle.player.hp
      state.phase = RunDefeat
    }
    None => ()
  }
}

///|
/// Add a card reward to deck and advance
fn pick_card_reward(state : RunState, index : Int) -> Unit {
  if index >= 0 && index < state.card_rewards.length() {
    state.deck.push(state.card_rewards[index])
  }
  // index == -1 means skip
  state.card_rewards.clear()
  state.battle = None
  advance_floor(state)
}

///|
/// Rest at a rest site: heal 30% max HP
fn rest_heal(state : RunState) -> Unit {
  let heal = state.player_max_hp * 3 / 10
  state.player_hp = state.player_hp + heal
  if state.player_hp > state.player_max_hp {
    state.player_hp = state.player_max_hp
  }
  advance_floor(state)
}

///|
/// Pool of non-starter cards available as rewards
fn reward_card_pool() -> Array[CardId] {
  [
    Cleave,
    Pommel_Strike,
    Shrug_It_Off,
    Inflame,
    Body_Slam,
    Twin_Strike,
    Clothesline,
    Iron_Wave,
    Bloodletting,
    Offering,
    Uppercut,
    Seeing_Red,
    Armaments,
  ]
}
