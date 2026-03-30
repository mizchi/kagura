///|
pub let screen_w : Int = 480

///|
pub let screen_h : Int = 360

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

///|
/// Persistent power effects (from Power cards)
pub(all) struct PowerState {
  mut metallicize : Int // Block gained at end of turn
  mut demon_form : Int // Strength gained at start of turn
  mut barricade : Bool // Block persists between turns
  mut feel_no_pain : Int // Block gained on exhaust
  mut flex_loss : Int // Strength to lose at end of turn
  mut rampage_bonus : Int // Accumulated Rampage damage bonus
} derive(Show)

///|
fn PowerState::new() -> PowerState {
  {
    metallicize: 0,
    demon_form: 0,
    barricade: false,
    feel_no_pain: 0,
    flex_loss: 0,
    rampage_bonus: 0,
  }
}

///|
pub(all) struct BattleState {
  player : Fighter
  enemies : Array[Enemy]
  relics : Array[RelicId]
  relic_state : RelicState
  powers : PowerState
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
pub fn BattleState::new(
  enemy_ids : Array[EnemyId],
  seed? : Int = 42,
  relics? : Array[RelicId] = [],
) -> BattleState {
  let enemies : Array[Enemy] = []
  for id in enemy_ids {
    enemies.push(spawn_enemy(id))
  }
  BattleState::init(enemies, seed, relics)
}

///|
/// Create battle from encounter preset
pub fn BattleState::from_encounter(
  encounter : EncounterId,
  seed? : Int = 42,
  relics? : Array[RelicId] = [],
) -> BattleState {
  BattleState::new(encounter_enemies(encounter), seed~, relics~)
}

///|
fn BattleState::init(
  enemies : Array[Enemy],
  seed : Int,
  relics : Array[RelicId],
) -> BattleState {
  let deck = starter_deck()
  let state : BattleState = {
    player: Fighter::new("Ironclad", 80, max_energy=3),
    enemies,
    relics,
    relic_state: RelicState::new(),
    powers: PowerState::new(),
    draw_pile: deck,
    hand: [],
    discard_pile: [],
    exhaust_pile: [],
    turn: 0,
    phase: PlayerTurn,
    logs: [],
    rng_seed: seed,
  }
  // Apply relic battle start effects
  let relic_logs = relics_on_battle_start(
    state.relics,
    state.player,
    state.enemies,
  )
  for log in relic_logs {
    state.logs.push(log)
  }
  // Shuffle and draw initial hand
  shuffle(state, state.draw_pile)
  draw_cards(state, hand_size)
  state.player.energy = state.player.max_energy
  state.turn = 1
  state.logs.push("Battle Start! Turn 1")
  // Apply turn 1 relic effects
  let turn_logs = relics_on_turn_start(state.relics, state.player, 1)
  for log in turn_logs {
    state.logs.push(log)
  }
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
pub fn play_card(
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
  // Validate target for cards that need a target
  if card_needs_target(card_id) {
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
  // Nob's Enrage: gains +2 STR whenever player plays a Skill
  if def.card_type == Skill || def.card_type == Power {
    trigger_nob_enrage(state)
  }
  // Exhaust or discard
  if def.exhaust {
    state.exhaust_pile.push(removed)
    trigger_exhaust(state)
  } else {
    state.discard_pile.push(removed)
  }
  // Check for victory
  check_battle_end(state)
  Ok
}

///|
/// Check if a card hits all enemies
fn is_aoe_card(id : CardId) -> Bool {
  match id {
    Cleave | Shockwave => true
    _ => false
  }
}

///|
/// Cards that don't need an enemy target at all (self-targeting skills/powers)
fn is_self_card(id : CardId) -> Bool {
  let def = card_def(id)
  match id {
    // Skills that only affect player
    Defend
    | Shrug_It_Off
    | Armaments
    | True_Grit
    | Flex
    | Bloodletting
    | Offering
    | Seeing_Red
    | Battle_Trance
    | Impervious => true
    // Powers
    Inflame | Metallicize | Demon_Form | Barricade | Feel_No_Pain => true
    // AoE
    Cleave | Shockwave => true
    // Disarm targets enemy but isn't an attack
    _ => def.card_type == Skill && def.base_damage == 0 && def.base_block > 0
  }
}

///|
/// Check if a card needs a target
fn card_needs_target(id : CardId) -> Bool {
  match id {
    Disarm => true // Targets specific enemy
    _ => {
      let def = card_def(id)
      def.card_type == Attack && not(is_aoe_card(id))
    }
  }
}

///|
fn remove_at(arr : Array[CardId], index : Int) -> CardId {
  let card = arr[index]
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
/// Apply attack damage with relic modifiers
fn apply_attack_with_relics(
  state : BattleState,
  base_damage : Int,
  target : Fighter,
) -> Int {
  let damage = calculate_attack_damage(base_damage, state.player)
  let (modified, relic_logs) = relics_on_attack(
    state.relics,
    state.relic_state,
    damage,
  )
  for log in relic_logs {
    state.logs.push(log)
  }
  apply_damage(target, modified)
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
    // === Starter ===
    Strike => {
      let actual = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.logs.push("Strike: " + actual.to_string() + " damage!")
    }
    Defend => {
      add_block(state.player, def.base_block)
      state.logs.push("Defend: gain " + def.base_block.to_string() + " Block.")
    }
    Bash => {
      let actual = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.enemies[target_index].fighter.status.vulnerable += 2
      state.logs.push("Bash: " + actual.to_string() + " damage! Vulnerable 2.")
    }
    // === Common Attacks ===
    Cleave => {
      let damage = calculate_attack_damage(def.base_damage, state.player)
      let (modified, relic_logs) = relics_on_attack(
        state.relics,
        state.relic_state,
        damage,
      )
      for log in relic_logs {
        state.logs.push(log)
      }
      let mut i = 0
      while i < state.enemies.length() {
        if not(state.enemies[i].fighter.is_dead()) {
          let actual = apply_damage(state.enemies[i].fighter, modified)
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
      let actual = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.logs.push("Pommel Strike: " + actual.to_string() + " damage!")
      draw_cards(state, 1)
    }
    Twin_Strike => {
      let actual1 = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      let actual2 = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.logs.push(
        "Twin Strike: " +
        actual1.to_string() +
        " + " +
        actual2.to_string() +
        " damage!",
      )
    }
    Iron_Wave => {
      add_block(state.player, def.base_block)
      let actual = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.logs.push(
        "Iron Wave: gain 5 Block, " + actual.to_string() + " damage!",
      )
    }
    Anger => {
      let actual = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.logs.push("Anger: " + actual.to_string() + " damage!")
      // Add a copy to discard pile
      state.discard_pile.push(Anger)
    }
    Headbutt => {
      let actual = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.logs.push("Headbutt: " + actual.to_string() + " damage!")
      // Put a card from discard on top of draw pile (pick last discarded)
      if state.discard_pile.length() > 0 {
        match state.discard_pile.pop() {
          Some(card) => state.draw_pile.push(card)
          None => ()
        }
      }
    }
    // === Common Skills ===
    Shrug_It_Off => {
      add_block(state.player, def.base_block)
      state.logs.push("Shrug It Off: gain 8 Block.")
      draw_cards(state, 1)
    }
    Armaments => {
      add_block(state.player, def.base_block)
      state.logs.push("Armaments: gain 5 Block.")
    }
    True_Grit => {
      add_block(state.player, def.base_block)
      // Exhaust a random card from hand
      if state.hand.length() > 0 {
        let idx = next_random(state) % state.hand.length()
        let exhausted = remove_at(state.hand, idx)
        state.exhaust_pile.push(exhausted)
        trigger_exhaust(state)
        state.logs.push("True Grit: gain 7 Block, exhaust a card.")
      } else {
        state.logs.push("True Grit: gain 7 Block.")
      }
    }
    Flex => {
      state.player.status.strength += 2
      state.powers.flex_loss += 2
      state.logs.push("Flex: gain 2 temporary Strength!")
    }
    // === Uncommon Attacks ===
    Clothesline => {
      let actual = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.enemies[target_index].fighter.status.weak += 2
      state.logs.push("Clothesline: " + actual.to_string() + " damage! Weak 2.")
    }
    Uppercut => {
      let actual = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.enemies[target_index].fighter.status.weak += 1
      state.enemies[target_index].fighter.status.vulnerable += 1
      state.logs.push(
        "Uppercut: " + actual.to_string() + " damage! Weak 1, Vulnerable 1.",
      )
    }
    Body_Slam => {
      let base = state.player.block
      let actual = apply_attack_with_relics(
        state,
        base,
        state.enemies[target_index].fighter,
      )
      state.logs.push("Body Slam: " + actual.to_string() + " damage!")
    }
    Sword_Boomerang => {
      // Deal 3 damage to random enemy 3 times
      let mut total = 0
      let mut i = 0
      while i < 3 {
        let alive = first_alive_enemy(state)
        if alive >= 0 {
          let actual = apply_attack_with_relics(
            state,
            def.base_damage,
            state.enemies[alive].fighter,
          )
          total += actual
        }
        i += 1
      }
      state.logs.push(
        "Sword Boomerang: " + total.to_string() + " total damage!",
      )
    }
    Rampage => {
      let damage = def.base_damage + state.powers.rampage_bonus
      let actual = apply_attack_with_relics(
        state,
        damage,
        state.enemies[target_index].fighter,
      )
      state.powers.rampage_bonus += 5
      state.logs.push("Rampage: " + actual.to_string() + " damage!")
    }
    // === Uncommon Skills ===
    Bloodletting => {
      state.player.hp -= 3
      if state.player.hp < 0 {
        state.player.hp = 0
      }
      state.player.energy += 2
      state.logs.push("Bloodletting: lose 3 HP, gain 2 Energy!")
    }
    Offering => {
      state.player.hp -= 6
      if state.player.hp < 0 {
        state.player.hp = 0
      }
      state.player.energy += 2
      draw_cards(state, 3)
      state.logs.push("Offering: lose 6 HP, gain 2 Energy, draw 3!")
    }
    Seeing_Red => {
      state.player.energy += 2
      state.logs.push("Seeing Red: gain 2 Energy!")
    }
    Battle_Trance => {
      draw_cards(state, 3)
      state.logs.push("Battle Trance: draw 3 cards!")
    }
    Shockwave => {
      for enemy in state.enemies {
        if not(enemy.fighter.is_dead()) {
          enemy.fighter.status.weak += 3
          enemy.fighter.status.vulnerable += 3
        }
      }
      state.logs.push("Shockwave: Weak 3 + Vulnerable 3 to ALL!")
    }
    Disarm =>
      if target_index >= 0 && target_index < state.enemies.length() {
        state.enemies[target_index].fighter.status.strength -= 2
        state.logs.push("Disarm: enemy loses 2 Strength!")
      }
    // === Uncommon Powers ===
    Inflame => {
      state.player.status.strength += 2
      state.logs.push("Inflame: gain 2 Strength!")
    }
    Metallicize => {
      state.powers.metallicize += 3
      state.logs.push("Metallicize: gain 3 Block at end of turn!")
    }
    // === Rare ===
    Bludgeon => {
      let actual = apply_attack_with_relics(
        state,
        def.base_damage,
        state.enemies[target_index].fighter,
      )
      state.logs.push("Bludgeon: " + actual.to_string() + " damage!")
    }
    Impervious => {
      add_block(state.player, def.base_block)
      state.logs.push("Impervious: gain 30 Block!")
    }
    Demon_Form => {
      state.powers.demon_form += 2
      state.logs.push("Demon Form: gain 2 Strength each turn!")
    }
    Barricade => {
      state.powers.barricade = true
      state.logs.push("Barricade: Block no longer decays!")
    }
    Feel_No_Pain => {
      state.powers.feel_no_pain += 3
      state.logs.push("Feel No Pain: gain 3 Block on Exhaust!")
    }
  }
}

///|
/// Trigger Nob's Enrage: +2 STR when player plays a Skill
fn trigger_nob_enrage(state : BattleState) -> Unit {
  for enemy in state.enemies {
    if enemy.fighter.name == "Gremlin Nob" && not(enemy.fighter.is_dead()) {
      enemy.fighter.status.strength += 2
      state.logs.push("Nob Enrages! +2 Strength!")
    }
  }
}

///|
/// Trigger Feel No Pain when a card is exhausted
fn trigger_exhaust(state : BattleState) -> Unit {
  if state.powers.feel_no_pain > 0 {
    add_block(state.player, state.powers.feel_no_pain)
    state.logs.push(
      "Feel No Pain: +" + state.powers.feel_no_pain.to_string() + " Block!",
    )
  }
}

///|
/// End the player's turn
pub fn end_player_turn(state : BattleState) -> Unit {
  if state.phase != PlayerTurn {
    return
  }
  // Metallicize: gain block at end of turn
  if state.powers.metallicize > 0 {
    add_block(state.player, state.powers.metallicize)
  }
  // Flex: lose temporary strength
  if state.powers.flex_loss > 0 {
    state.player.status.strength -= state.powers.flex_loss
    state.powers.flex_loss = 0
  }
  // Relic end-of-turn effects (before discarding)
  let relic_logs = relics_on_turn_end(state.relics, state.player)
  for log in relic_logs {
    state.logs.push(log)
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
  // Barricade: block persists
  if not(state.powers.barricade) {
    reset_block(state.player)
  }
  // Demon Form: gain strength each turn
  if state.powers.demon_form > 0 {
    state.player.status.strength += state.powers.demon_form
    state.logs.push(
      "Demon Form: +" + state.powers.demon_form.to_string() + " Strength!",
    )
  }
  draw_cards(state, hand_size)
  state.logs.push("Turn " + state.turn.to_string())
  // Relic turn-start effects
  let relic_logs = relics_on_turn_start(state.relics, state.player, state.turn)
  for log in relic_logs {
    state.logs.push(log)
  }
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
    // Apply victory relic effects
    let relic_logs = relics_on_victory(state.relics, state.player)
    for log in relic_logs {
      state.logs.push(log)
    }
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
