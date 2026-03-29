///|
let screen_w : Int = 480

///|
let screen_h : Int = 360

///|
let hand_size : Int = 5

///|
/// Battle phase
pub(all) enum BattlePhase {
  PlayerTurn
  EnemyTurn
  Victory
  Defeat
} derive(Show, Eq)

///|
/// Action result from playing a card
pub(all) enum ActionResult {
  Ok
  NotEnoughEnergy
  InvalidTarget
  InvalidCard
  NotPlayerTurn
} derive(Show, Eq)

///|
/// Core battle state - all game mechanics operate on this
pub(all) struct BattleState {
  player : Fighter
  enemies : Array[Enemy]
  draw_pile : Array[CardId]
  hand : Array[CardId]
  discard_pile : Array[CardId]
  exhaust_pile : Array[CardId]
  mut turn : Int
  mut phase : BattlePhase
  logs : Array[String]
  mut rng_seed : Int
} derive(Show)

///|
/// Simple pseudo-random number generator
fn next_random(state : BattleState) -> Int {
  state.rng_seed = state.rng_seed * 1103515245 + 12345
  (state.rng_seed >> 16) & 0x7FFF
}

///|
/// Fisher-Yates shuffle using the battle state's RNG
fn shuffle(state : BattleState, cards : Array[CardId]) -> Unit {
  let mut i = cards.length() - 1
  while i > 0 {
    let j = next_random(state) % (i + 1)
    let temp = cards[i]
    cards[i] = cards[j]
    cards[j] = temp
    i -= 1
  }
}

///|
/// Create a new battle with given enemies
fn BattleState::new(
  enemy_ids : Array[EnemyId],
  seed? : Int = 42,
) -> BattleState {
  let enemies : Array[Enemy] = []
  for id in enemy_ids {
    enemies.push(spawn_enemy(id))
  }
  let deck = starter_deck()
  let state : BattleState = {
    player: Fighter::new("Ironclad", 80, max_energy=3),
    enemies,
    draw_pile: deck,
    hand: [],
    discard_pile: [],
    exhaust_pile: [],
    turn: 0,
    phase: PlayerTurn,
    logs: [],
    rng_seed: seed,
  }
  // Shuffle and draw initial hand
  shuffle(state, state.draw_pile)
  draw_cards(state, hand_size)
  state.player.energy = state.player.max_energy
  state.turn = 1
  state.logs.push("Battle Start! Turn 1")
  state
}

///|
/// Draw N cards from draw pile to hand
fn draw_cards(state : BattleState, count : Int) -> Unit {
  let mut drawn = 0
  while drawn < count {
    if state.draw_pile.length() == 0 {
      // Reshuffle discard pile into draw pile
      if state.discard_pile.length() == 0 {
        return // No cards left anywhere
      }
      while state.discard_pile.length() > 0 {
        match state.discard_pile.pop() {
          Some(card) => state.draw_pile.push(card)
          None => ()
        }
      }
      shuffle(state, state.draw_pile)
    }
    match state.draw_pile.pop() {
      Some(card) => {
        state.hand.push(card)
        drawn += 1
      }
      None => return
    }
  }
}

///|
/// Play a card from hand
fn play_card(
  state : BattleState,
  hand_index : Int,
  target_index : Int,
) -> ActionResult {
  if state.phase != PlayerTurn {
    return NotPlayerTurn
  }
  if hand_index < 0 || hand_index >= state.hand.length() {
    return InvalidCard
  }
  let card_id = state.hand[hand_index]
  let def = card_def(card_id)
  // Check energy
  if state.player.energy < def.cost {
    return NotEnoughEnergy
  }
  // Validate target for attacks
  if def.card_type == Attack && def.id != Cleave {
    if target_index < 0 || target_index >= state.enemies.length() {
      return InvalidTarget
    }
    if state.enemies[target_index].fighter.is_dead() {
      return InvalidTarget
    }
  }
  // Spend energy
  state.player.energy -= def.cost
  // Remove card from hand
  let removed = remove_at(state.hand, hand_index)
  // Execute card effect
  execute_card(state, removed, target_index)
  // Discard (unless exhausted)
  state.discard_pile.push(removed)
  // Check for victory
  check_battle_end(state)
  Ok
}

///|
fn remove_at(arr : Array[CardId], index : Int) -> CardId {
  let card = arr[index]
  // Shift remaining elements
  let mut i = index
  while i < arr.length() - 1 {
    arr[i] = arr[i + 1]
    i += 1
  }
  match arr.pop() {
    _ => ()
  }
  card
}

///|
/// Execute the effect of a card
fn execute_card(
  state : BattleState,
  card_id : CardId,
  target_index : Int,
) -> Unit {
  let def = card_def(card_id)
  match card_id {
    Strike => {
      let damage = calculate_attack_damage(def.base_damage, state.player)
      let actual = apply_damage(state.enemies[target_index].fighter, damage)
      state.logs.push("Play Strike: " + actual.to_string() + " damage!")
    }
    Defend => {
      add_block(state.player, def.base_block)
      state.logs.push(
        "Play Defend: gain " + def.base_block.to_string() + " Block.",
      )
    }
    Bash => {
      let damage = calculate_attack_damage(def.base_damage, state.player)
      let actual = apply_damage(state.enemies[target_index].fighter, damage)
      state.enemies[target_index].fighter.status.vulnerable += 2
      state.logs.push(
        "Play Bash: " +
        actual.to_string() +
        " damage! Target is Vulnerable for 2 turns.",
      )
    }
    Cleave => {
      let damage = calculate_attack_damage(def.base_damage, state.player)
      let mut i = 0
      while i < state.enemies.length() {
        if not(state.enemies[i].fighter.is_dead()) {
          let actual = apply_damage(state.enemies[i].fighter, damage)
          state.logs.push(
            "Cleave hits " +
            state.enemies[i].fighter.name +
            " for " +
            actual.to_string() +
            "!",
          )
        }
        i += 1
      }
    }
    Pommel_Strike => {
      let damage = calculate_attack_damage(def.base_damage, state.player)
      let actual = apply_damage(state.enemies[target_index].fighter, damage)
      state.logs.push("Pommel Strike: " + actual.to_string() + " damage!")
      draw_cards(state, 1)
      state.logs.push("Draw 1 card.")
    }
    Shrug_It_Off => {
      add_block(state.player, def.base_block)
      state.logs.push(
        "Shrug It Off: gain " + def.base_block.to_string() + " Block.",
      )
      draw_cards(state, 1)
      state.logs.push("Draw 1 card.")
    }
    Inflame => {
      state.player.status.strength += 2
      state.logs.push("Inflame: gain 2 Strength!")
    }
  }
}

///|
/// End the player's turn
fn end_player_turn(state : BattleState) -> Unit {
  if state.phase != PlayerTurn {
    return
  }
  // Discard remaining hand
  while state.hand.length() > 0 {
    match state.hand.pop() {
      Some(card) => state.discard_pile.push(card)
      None => ()
    }
  }
  // Tick player status effects
  tick_status_effects(state.player)
  // Enemy turn
  state.phase = EnemyTurn
  execute_enemy_turn(state)
  // Check for defeat
  if state.player.is_dead() {
    state.phase = Defeat
    state.logs.push("You have been defeated...")
    return
  }
  // Start next player turn
  start_player_turn(state)
}

///|
/// Execute all enemy actions
fn execute_enemy_turn(state : BattleState) -> Unit {
  let mut i = 0
  while i < state.enemies.length() {
    let enemy = state.enemies[i]
    if not(enemy.fighter.is_dead()) {
      let enemy_logs = execute_enemy_intent(enemy, state.player)
      for log in enemy_logs {
        state.logs.push(log)
      }
      // Tick enemy status effects
      tick_status_effects(enemy.fighter)
      // Reset enemy block
      reset_block(enemy.fighter)
    }
    i += 1
  }
}

///|
/// Start a new player turn
fn start_player_turn(state : BattleState) -> Unit {
  state.turn += 1
  state.phase = PlayerTurn
  state.player.energy = state.player.max_energy
  reset_block(state.player)
  draw_cards(state, hand_size)
  state.logs.push("Turn " + state.turn.to_string())
}

///|
/// Check if battle is over
fn check_battle_end(state : BattleState) -> Unit {
  let mut all_dead = true
  for enemy in state.enemies {
    if not(enemy.fighter.is_dead()) {
      all_dead = false
    }
  }
  if all_dead {
    state.phase = Victory
    state.logs.push("Victory!")
  }
}

///|
/// Get the first alive enemy index (for default targeting)
fn first_alive_enemy(state : BattleState) -> Int {
  let mut i = 0
  while i < state.enemies.length() {
    if not(state.enemies[i].fighter.is_dead()) {
      return i
    }
    i += 1
  }
  -1
}

///|
/// Count alive enemies
fn alive_enemy_count(state : BattleState) -> Int {
  let mut count = 0
  for enemy in state.enemies {
    if not(enemy.fighter.is_dead()) {
      count += 1
    }
  }
  count
}
