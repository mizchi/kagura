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
  potions : Array[PotionId]
  mut player_hp : Int
  mut player_max_hp : Int
  mut floor : Int
  mut phase : RunPhase
  mut battle : BattleState?
  card_rewards : Array[CardId]
  mut rng_seed : Int
} derive(Show)

///|
let max_floor : Int = 15

///|
/// Floor layout for Act 1 (15 floors, modeled after StS)
/// Floor 1-3: Easy combats (build deck basics)
/// Floor 4: Elite (first test, risky but rewarding)
/// Floor 5: Rest site (recover from elite)
/// Floor 6-8: Normal combats (harder encounters)
/// Floor 9: Rest site
/// Floor 10: Normal combat
/// Floor 11: Elite (mid-Act pressure point)
/// Floor 12: Rest site
/// Floor 13: Normal combat (pre-boss breather)
/// Floor 14: Rest site (prep for boss)
/// Floor 15: BOSS
fn floor_type(floor : Int) -> FloorType {
  match floor {
    1 => Combat(Easy)
    2 => Combat(Easy)
    3 => Combat(Easy)
    4 => Combat(Elite)
    5 => Rest
    6 => Combat(Normal)
    7 => Combat(Normal)
    8 => Combat(Normal)
    9 => Rest
    10 => Combat(Normal)
    11 => Combat(Elite)
    12 => Rest
    13 => Combat(Normal)
    14 => Rest
    15 => Boss
    _ => Combat(Easy)
  }
}

///|
/// Create a new run
pub fn RunState::new(seed? : Int = 42) -> RunState {
  let state : RunState = {
    deck: starter_deck(),
    relics: [BurningBlood],
    relic_state: RelicState::new(),
    potions: [],
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
      let encounter = pick_encounter(state, Boss)
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
      match r % 3 {
        0 => SingleCultist
        1 => FungiPair
        _ => SlaverFight
      }
    Elite =>
      match r % 3 {
        0 => EliteSlaver
        1 => SentryPair
        _ => EliteNob
      }
    Boss =>
      match r % 2 {
        0 => BossGuardian
        _ => BossHexaghost
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
    powers: PowerState::new(),
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
    battle.relic_state,
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
  let turn_logs = relics_on_turn_start(
    battle.relics,
    battle.relic_state,
    battle.player,
    1,
  )
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
      // Update max_hp (Feed may have increased it)
      state.player_max_hp = battle.player.max_hp
      state.rng_seed = battle.rng_seed
      // Award relic after Elite/Boss floors
      let ft = floor_type(state.floor)
      match ft {
        Combat(Elite) | Combat(Boss) | Boss => award_relic(state)
        _ => ()
      }
      // Potion reward (~40% chance, if room)
      if state.potions.length() < max_potions {
        let potion_roll = run_random(state).abs() % 100
        if potion_roll < 40 {
          let potion = random_potion(state.rng_seed)
          // Fruit Juice: auto-use immediately
          if potion == FruitJuice {
            state.player_max_hp += 5
            state.player_hp += 5
          } else {
            state.potions.push(potion)
          }
        }
      }
      // Generate 3 card rewards with rarity distribution
      state.card_rewards.clear()
      let rewards = generate_reward_pool(state)
      for card in rewards {
        state.card_rewards.push(card)
      }
      state.phase = CardReward
    }
    None => ()
  }
}

///|
/// Available relics for rewards (excluding starting relic)
fn relic_reward_pool() -> Array[RelicId] {
  [
    Vajra,
    Anchor,
    Orichalcum,
    BagOfMarbles,
    Lantern,
    PenNib,
    MeatOnTheBone,
    RedSkull,
    Akabeko,
    OrnamentalFan,
    HappyFlower,
  ]
}

///|
/// Award a random relic the player doesn't already have
fn award_relic(state : RunState) -> Unit {
  let pool = relic_reward_pool()
  let available : Array[RelicId] = []
  for r in pool {
    if not(has_relic(state.relics, r)) {
      available.push(r)
    }
  }
  if available.length() > 0 {
    let idx = run_random(state).abs() % available.length()
    state.relics.push(available[idx])
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
/// Generate a card reward pool based on rarity distribution (StS Act 1)
/// Common: 60%, Uncommon: 37%, Rare: 3%
fn generate_reward_pool(state : RunState) -> Array[CardId] {
  let pool : Array[CardId] = []
  let r = run_random(state) % 100
  // Determine rarity for each of the 3 cards
  // StS: each card is rolled independently
  let mut i = 0
  while i < 3 {
    let rarity_roll = run_random(state) % 100
    let cards = if rarity_roll < 60 {
      common_pool()
    } else if rarity_roll < 97 {
      uncommon_pool()
    } else {
      rare_pool()
    }
    let idx = r.abs() % cards.length()
    let card = cards[idx]
    // Avoid duplicates
    let mut dup = false
    for c in pool {
      if c == card {
        dup = true
      }
    }
    if not(dup) {
      pool.push(card)
    }
    i += 1
  }
  // Pad if we got duplicates
  if pool.length() < 3 {
    let all = common_pool()
    for c in all {
      if pool.length() >= 3 {
        break
      }
      let mut dup = false
      for existing in pool {
        if existing == c {
          dup = true
        }
      }
      if not(dup) {
        pool.push(c)
      }
    }
  }
  pool
}

///|
fn common_pool() -> Array[CardId] {
  [
    Cleave,
    Pommel_Strike,
    Twin_Strike,
    Iron_Wave,
    Anger,
    Headbutt,
    Shrug_It_Off,
    Armaments,
    True_Grit,
    Flex,
    Heavy_Blade,
    Pummel,
  ]
}

///|
fn uncommon_pool() -> Array[CardId] {
  [
    Clothesline,
    Uppercut,
    Body_Slam,
    Sword_Boomerang,
    Rampage,
    Bloodletting,
    Offering,
    Seeing_Red,
    Battle_Trance,
    Shockwave,
    Disarm,
    Inflame,
    Metallicize,
    Carnage,
    Entrench,
  ]
}

///|
fn rare_pool() -> Array[CardId] {
  [
    Bludgeon,
    Impervious,
    Demon_Form,
    Barricade,
    Feel_No_Pain,
    Corruption,
    Whirlwind,
    Feed,
    Fiend_Fire,
    Limit_Break,
    Immolate,
    Reaper,
  ]
}
