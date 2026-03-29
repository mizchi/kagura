// === Combat System Tests ===

///|
test "apply_damage goes through block first" {
  let fighter = Fighter::new("Test", 50)
  fighter.block = 10
  let actual = apply_damage(fighter, 15)
  assert_eq(actual, 5)
  assert_eq(fighter.hp, 45)
  assert_eq(fighter.block, 0)
}

///|
test "apply_damage fully absorbed by block" {
  let fighter = Fighter::new("Test", 50)
  fighter.block = 20
  let actual = apply_damage(fighter, 10)
  assert_eq(actual, 0)
  assert_eq(fighter.hp, 50)
  assert_eq(fighter.block, 10)
}

///|
test "apply_damage with no block" {
  let fighter = Fighter::new("Test", 50)
  let actual = apply_damage(fighter, 12)
  assert_eq(actual, 12)
  assert_eq(fighter.hp, 38)
}

///|
test "vulnerable increases damage by 50 percent" {
  let fighter = Fighter::new("Test", 100)
  fighter.status.vulnerable = 2
  let actual = apply_damage(fighter, 10)
  // 10 * 1.5 = 15
  assert_eq(actual, 15)
  assert_eq(fighter.hp, 85)
}

///|
test "weak reduces outgoing damage by 25 percent" {
  let attacker = Fighter::new("Attacker", 50)
  attacker.status.weak = 2
  let damage = calculate_attack_damage(10, attacker)
  // 10 * 0.75 = 7
  assert_eq(damage, 7)
}

///|
test "strength adds to attack damage" {
  let attacker = Fighter::new("Attacker", 50)
  attacker.status.strength = 3
  let damage = calculate_attack_damage(6, attacker)
  assert_eq(damage, 9)
}

///|
test "weak and strength combine correctly" {
  let attacker = Fighter::new("Attacker", 50)
  attacker.status.strength = 4
  attacker.status.weak = 1
  // (6 + 4) * 0.75 = 7
  let damage = calculate_attack_damage(6, attacker)
  assert_eq(damage, 7)
}

///|
test "tick_status_effects decrements durations" {
  let fighter = Fighter::new("Test", 50)
  fighter.status.vulnerable = 2
  fighter.status.weak = 1
  fighter.status.strength = 3
  tick_status_effects(fighter)
  assert_eq(fighter.status.vulnerable, 1)
  assert_eq(fighter.status.weak, 0)
  assert_eq(fighter.status.strength, 3) // Strength is permanent
}

///|
test "hp cannot go below zero" {
  let fighter = Fighter::new("Test", 10)
  let _ = apply_damage(fighter, 100)
  assert_eq(fighter.hp, 0)
  assert_true(fighter.is_dead())
}

// === Deck Management Tests ===

///|
test "starter deck has correct size" {
  let deck = starter_deck()
  assert_eq(deck.length(), 10)
}

///|
test "battle state initializes correctly" {
  let state = BattleState::new([JawWorm])
  assert_eq(state.player.hp, 80)
  assert_eq(state.player.max_hp, 80)
  assert_eq(state.player.energy, 3)
  assert_eq(state.hand.length(), 5)
  assert_eq(state.draw_pile.length(), 5) // 10 - 5 drawn
  assert_eq(state.discard_pile.length(), 0)
  assert_eq(state.enemies.length(), 1)
  assert_eq(state.turn, 1)
  assert_true(state.phase == PlayerTurn)
}

///|
test "play strike deals damage to enemy" {
  let state = BattleState::new([JawWorm], seed=1)
  let enemy_hp_before = state.enemies[0].fighter.hp
  // Find a Strike in hand
  let mut strike_idx = -1
  let mut i = 0
  while i < state.hand.length() {
    if state.hand[i] == Strike {
      strike_idx = i
      break
    }
    i += 1
  }
  if strike_idx >= 0 {
    let result = play_card(state, strike_idx, 0)
    assert_true(result == Ok)
    assert_true(state.enemies[0].fighter.hp < enemy_hp_before)
    assert_eq(state.player.energy, 2) // Cost 1 energy
    assert_eq(state.hand.length(), 4) // One card removed
  }
}

///|
test "play defend adds block" {
  let state = BattleState::new([JawWorm], seed=2)
  // Find a Defend in hand
  let mut defend_idx = -1
  let mut i = 0
  while i < state.hand.length() {
    if state.hand[i] == Defend {
      defend_idx = i
      break
    }
    i += 1
  }
  if defend_idx >= 0 {
    let result = play_card(state, defend_idx, 0)
    assert_true(result == Ok)
    assert_eq(state.player.block, 5)
    assert_eq(state.player.energy, 2)
  }
}

///|
test "cannot play card without enough energy" {
  let state = BattleState::new([JawWorm])
  state.player.energy = 0
  // Find any card
  if state.hand.length() > 0 {
    let result = play_card(state, 0, 0)
    assert_true(result == NotEnoughEnergy)
  }
}

///|
test "cannot play card with invalid index" {
  let state = BattleState::new([JawWorm])
  let result = play_card(state, 99, 0)
  assert_true(result == InvalidCard)
}

///|
test "bash applies vulnerable" {
  let state = BattleState::new([JawWorm], seed=3)
  // Find Bash in hand
  let mut bash_idx = -1
  let mut i = 0
  while i < state.hand.length() {
    if state.hand[i] == Bash {
      bash_idx = i
      break
    }
    i += 1
  }
  if bash_idx >= 0 {
    let _ = play_card(state, bash_idx, 0)
    assert_eq(state.enemies[0].fighter.status.vulnerable, 2)
  }
}

///|
test "end turn discards hand and draws new cards" {
  let state = BattleState::new([JawWorm])
  let hand_before = state.hand.length()
  end_player_turn(state)
  // Hand should have been discarded and new hand drawn
  assert_eq(
    state.discard_pile.length() +
    state.hand.length() +
    state.draw_pile.length() +
    state.exhaust_pile.length(),
    10,
  )
  assert_true(state.turn == 2)
  assert_true(state.phase == PlayerTurn)
  assert_eq(state.player.energy, 3) // Energy reset
  let _ = hand_before
}

///|
test "end turn resets player block" {
  let state = BattleState::new([JawWorm])
  state.player.block = 15
  end_player_turn(state)
  // Block resets at start of next turn
  assert_eq(state.player.block, 0)
}

///|
test "enemy deals damage on their turn" {
  let state = BattleState::new([JawWorm])
  let hp_before = state.player.hp
  // Jaw Worm's first intent is AttackIntent(11)
  end_player_turn(state)
  assert_true(state.player.hp < hp_before)
}

///|
test "victory when all enemies are dead" {
  let state = BattleState::new([JawWorm])
  // Kill the enemy directly
  state.enemies[0].fighter.hp = 1
  // Find a Strike
  let mut strike_idx = -1
  let mut i = 0
  while i < state.hand.length() {
    if state.hand[i] == Strike {
      strike_idx = i
      break
    }
    i += 1
  }
  if strike_idx >= 0 {
    let _ = play_card(state, strike_idx, 0)
    assert_true(state.phase == Victory)
  }
}

///|
test "defeat when player hp reaches zero" {
  let state = BattleState::new([JawWorm])
  state.player.hp = 1
  state.player.block = 0
  end_player_turn(state)
  assert_true(state.phase == Defeat)
}

// === Enemy AI Tests ===

///|
test "jaw worm follows attack pattern" {
  let enemy = spawn_enemy(JawWorm)
  // First intent: Attack 11
  assert_true(enemy.intent == AttackIntent(11))
  // Execute and check next intent
  let player = Fighter::new("Test", 100)
  let _ = execute_enemy_intent(enemy, player)
  // Second intent: Defend 5
  assert_true(enemy.intent == DefendIntent(5))
}

///|
test "cultist starts with buff" {
  let enemy = spawn_enemy(Cultist)
  assert_true(enemy.intent == BuffIntent)
  let player = Fighter::new("Test", 100)
  let _ = execute_enemy_intent(enemy, player)
  // After buff, should have 2 strength
  assert_eq(enemy.fighter.status.strength, 2)
}

///|
test "multiple enemies battle" {
  let state = BattleState::new([JawWorm, Cultist])
  assert_eq(state.enemies.length(), 2)
  assert_eq(alive_enemy_count(state), 2)
}

// === Card Effect Tests ===

///|
test "inflame gives player strength" {
  let state = BattleState::new([JawWorm])
  // Manually add Inflame to hand for testing
  state.hand.push(Inflame)
  let idx = state.hand.length() - 1
  let _ = play_card(state, idx, 0)
  assert_eq(state.player.status.strength, 2)
}

///|
test "strength increases strike damage" {
  let state = BattleState::new([JawWorm], seed=10)
  state.player.status.strength = 3
  let hp_before = state.enemies[0].fighter.hp
  // Find Strike
  let mut idx = -1
  let mut i = 0
  while i < state.hand.length() {
    if state.hand[i] == Strike {
      idx = i
      break
    }
    i += 1
  }
  if idx >= 0 {
    let _ = play_card(state, idx, 0)
    // Strike base 6 + 3 strength = 9 damage
    assert_eq(state.enemies[0].fighter.hp, hp_before - 9)
  }
}

///|
test "draw pile reshuffles from discard when empty" {
  let state = BattleState::new([JawWorm])
  // Move all draw pile to discard
  while state.draw_pile.length() > 0 {
    match state.draw_pile.pop() {
      Some(c) => state.discard_pile.push(c)
      None => ()
    }
  }
  let discard_count = state.discard_pile.length()
  assert_true(discard_count > 0)
  assert_eq(state.draw_pile.length(), 0)
  // Drawing should reshuffle
  draw_cards(state, 1)
  assert_eq(state.draw_pile.length(), discard_count - 1)
  assert_eq(state.discard_pile.length(), 0)
}
