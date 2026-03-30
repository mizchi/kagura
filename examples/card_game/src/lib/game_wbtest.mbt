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
  assert_eq(actual, 15)
  assert_eq(fighter.hp, 85)
}

///|
test "weak reduces outgoing damage by 25 percent" {
  let attacker = Fighter::new("Attacker", 50)
  attacker.status.weak = 2
  let damage = calculate_attack_damage(10, attacker)
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
  assert_eq(fighter.status.strength, 3)
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
  assert_eq(state.draw_pile.length(), 5)
  assert_eq(state.discard_pile.length(), 0)
  assert_eq(state.enemies.length(), 1)
  assert_eq(state.turn, 1)
  assert_true(state.phase == PlayerTurn)
}

///|
test "play strike deals damage to enemy" {
  let state = BattleState::new([JawWorm], seed=1)
  let enemy_hp_before = state.enemies[0].fighter.hp
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
    assert_eq(state.player.energy, 2)
    assert_eq(state.hand.length(), 4)
  }
}

///|
test "play defend adds block" {
  let state = BattleState::new([JawWorm], seed=2)
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
    assert_eq(state.player.block, 6)
    assert_eq(state.player.energy, 2)
  }
}

///|
test "cannot play card without enough energy" {
  let state = BattleState::new([JawWorm])
  state.player.energy = 0
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
  end_player_turn(state)
  assert_eq(
    state.discard_pile.length() +
    state.hand.length() +
    state.draw_pile.length() +
    state.exhaust_pile.length(),
    10,
  )
  assert_true(state.turn == 2)
  assert_true(state.phase == PlayerTurn)
  assert_eq(state.player.energy, 3)
}

///|
test "end turn resets player block" {
  let state = BattleState::new([JawWorm])
  state.player.block = 15
  end_player_turn(state)
  assert_eq(state.player.block, 0)
}

///|
test "enemy deals damage on their turn" {
  let state = BattleState::new([JawWorm])
  let hp_before = state.player.hp
  end_player_turn(state)
  assert_true(state.player.hp < hp_before)
}

///|
test "victory when all enemies are dead" {
  let state = BattleState::new([JawWorm])
  state.enemies[0].fighter.hp = 1
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
  assert_true(enemy.intent == AttackIntent(11))
  let player = Fighter::new("Test", 100)
  let _ = execute_enemy_intent(enemy, player)
  // Bellow: DefendIntent(6) + gains 3 STR
  assert_true(enemy.intent == DefendIntent(6))
}

///|
test "cultist starts with buff" {
  let enemy = spawn_enemy(Cultist)
  assert_true(enemy.intent == BuffIntent)
  let player = Fighter::new("Test", 100)
  let _ = execute_enemy_intent(enemy, player)
  // Cultist incantation gives +3 Strength (Ritual)
  assert_eq(enemy.fighter.status.strength, 3)
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
    assert_eq(state.enemies[0].fighter.hp, hp_before - 9)
  }
}

///|
test "draw pile reshuffles from discard when empty" {
  let state = BattleState::new([JawWorm])
  while state.draw_pile.length() > 0 {
    match state.draw_pile.pop() {
      Some(c) => state.discard_pile.push(c)
      None => ()
    }
  }
  let discard_count = state.discard_pile.length()
  assert_true(discard_count > 0)
  assert_eq(state.draw_pile.length(), 0)
  draw_cards(state, 1)
  assert_eq(state.draw_pile.length(), discard_count - 1)
  assert_eq(state.discard_pile.length(), 0)
}

// === New Card Tests ===

///|
test "body slam deals damage equal to block" {
  let state = BattleState::new([JawWorm])
  state.player.block = 15
  state.hand.push(Body_Slam)
  let idx = state.hand.length() - 1
  let hp_before = state.enemies[0].fighter.hp
  let _ = play_card(state, idx, 0)
  assert_eq(state.enemies[0].fighter.hp, hp_before - 15)
}

///|
test "twin strike hits twice" {
  let state = BattleState::new([JawWorm])
  state.hand.push(Twin_Strike)
  let idx = state.hand.length() - 1
  let hp_before = state.enemies[0].fighter.hp
  let _ = play_card(state, idx, 0)
  // 5 + 5 = 10 total damage
  assert_eq(state.enemies[0].fighter.hp, hp_before - 10)
}

///|
test "clothesline applies weak" {
  let state = BattleState::new([JawWorm])
  state.hand.push(Clothesline)
  state.player.energy = 3
  let idx = state.hand.length() - 1
  let _ = play_card(state, idx, 0)
  assert_eq(state.enemies[0].fighter.status.weak, 2)
}

///|
test "iron wave gives block and deals damage" {
  let state = BattleState::new([JawWorm])
  state.hand.push(Iron_Wave)
  let idx = state.hand.length() - 1
  let hp_before = state.enemies[0].fighter.hp
  let _ = play_card(state, idx, 0)
  assert_eq(state.player.block, 6)
  assert_eq(state.enemies[0].fighter.hp, hp_before - 5)
}

///|
test "bloodletting costs HP and gives energy" {
  let state = BattleState::new([JawWorm])
  state.hand.push(Bloodletting)
  let idx = state.hand.length() - 1
  let hp_before = state.player.hp
  let energy_before = state.player.energy
  let _ = play_card(state, idx, 0)
  assert_eq(state.player.hp, hp_before - 3)
  assert_eq(state.player.energy, energy_before + 2)
  // Should be exhausted, not discarded
  assert_eq(state.exhaust_pile.length(), 1)
}

///|
test "offering costs HP gives energy and draws" {
  let state = BattleState::new([JawWorm])
  state.hand.push(Offering)
  let idx = state.hand.length() - 1
  let hp_before = state.player.hp
  let hand_before = state.hand.length()
  let _ = play_card(state, idx, 0)
  assert_eq(state.player.hp, hp_before - 6)
  // Hand should grow by 2 (played 1, drew 3)
  assert_eq(state.hand.length(), hand_before - 1 + 3)
  assert_eq(state.exhaust_pile.length(), 1)
}

///|
test "uppercut applies weak and vulnerable" {
  let state = BattleState::new([JawWorm])
  state.hand.push(Uppercut)
  state.player.energy = 3
  let idx = state.hand.length() - 1
  let _ = play_card(state, idx, 0)
  assert_eq(state.enemies[0].fighter.status.weak, 1)
  assert_eq(state.enemies[0].fighter.status.vulnerable, 1)
}

///|
test "seeing red gives energy and exhausts" {
  let state = BattleState::new([JawWorm])
  state.hand.push(Seeing_Red)
  let idx = state.hand.length() - 1
  let energy_before = state.player.energy
  let _ = play_card(state, idx, 0)
  assert_eq(state.player.energy, energy_before - 1 + 2)
  assert_eq(state.exhaust_pile.length(), 1)
}

///|
test "exhaust cards go to exhaust pile not discard" {
  let state = BattleState::new([JawWorm])
  state.hand.push(Bloodletting)
  let idx = state.hand.length() - 1
  let discard_before = state.discard_pile.length()
  let _ = play_card(state, idx, 0)
  assert_eq(state.discard_pile.length(), discard_before)
  assert_eq(state.exhaust_pile.length(), 1)
}

// === Relic Tests ===

///|
test "vajra gives strength at combat start" {
  let state = BattleState::new([JawWorm], relics=[Vajra])
  assert_eq(state.player.status.strength, 1)
}

///|
test "anchor gives block at combat start" {
  let state = BattleState::new([JawWorm], relics=[Anchor])
  assert_eq(state.player.block, 10)
}

///|
test "bag of marbles applies vulnerable to enemies" {
  let state = BattleState::new([JawWorm, Cultist], relics=[BagOfMarbles])
  assert_eq(state.enemies[0].fighter.status.vulnerable, 1)
  assert_eq(state.enemies[1].fighter.status.vulnerable, 1)
}

///|
test "lantern gives extra energy on turn 1" {
  let state = BattleState::new([JawWorm], relics=[Lantern])
  assert_eq(state.player.energy, 4) // 3 base + 1 from Lantern
}

///|
test "orichalcum gives block when ending turn with 0 block" {
  let state = BattleState::new([JawWorm], relics=[Orichalcum])
  state.player.block = 0
  // End turn should trigger Orichalcum before enemy acts
  end_player_turn(state)
  // After enemy turn and new turn start, block resets
  // But Orichalcum fires before enemy turn
  // We need to check the logs
  let mut found = false
  for log in state.logs {
    if log == "[Orichalcum] +6 Block" {
      found = true
    }
  }
  assert_true(found)
}

///|
test "orichalcum does not trigger with existing block" {
  let state = BattleState::new([JawWorm], relics=[Orichalcum])
  state.player.block = 5
  end_player_turn(state)
  let mut found = false
  for log in state.logs {
    if log == "[Orichalcum] +6 Block" {
      found = true
    }
  }
  assert_false(found)
}

///|
test "burning blood heals on victory" {
  let state = BattleState::new([JawWorm], relics=[BurningBlood])
  state.player.hp = 50
  state.enemies[0].fighter.hp = 1
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
    assert_eq(state.player.hp, 56) // 50 + 6
  }
}

///|
test "meat on the bone heals on victory when low hp" {
  let state = BattleState::new([JawWorm], relics=[MeatOnTheBone])
  state.player.hp = 30 // <= 50% of 80
  state.enemies[0].fighter.hp = 1
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
    assert_eq(state.player.hp, 42) // 30 + 12
  }
}

///|
test "meat on the bone does not heal when high hp" {
  let state = BattleState::new([JawWorm], relics=[MeatOnTheBone])
  state.player.hp = 60 // > 50% of 80
  state.enemies[0].fighter.hp = 1
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
    assert_eq(state.player.hp, 60) // unchanged
  }
}

///|
test "pen nib doubles every 10th attack" {
  let state = BattleState::new([JawWorm], relics=[PenNib])
  // Give enemy lots of HP so it doesn't die
  state.enemies[0].fighter.hp = 999
  // Play 9 attacks (pen nib counter goes to 9)
  let mut attacks = 0
  while attacks < 9 {
    state.hand.push(Strike)
    let idx = state.hand.length() - 1
    state.player.energy = 10
    let _ = play_card(state, idx, 0)
    attacks += 1
  }
  assert_eq(state.relic_state.pen_nib_counter, 9)
  // 10th attack should double
  state.enemies[0].fighter.hp = 100
  state.hand.push(Strike)
  let idx = state.hand.length() - 1
  state.player.energy = 10
  let _ = play_card(state, idx, 0)
  // Strike does 6, doubled = 12
  assert_eq(state.enemies[0].fighter.hp, 88)
  assert_eq(state.relic_state.pen_nib_counter, 0)
}

///|
test "multiple relics combine" {
  let state = BattleState::new([JawWorm], relics=[Vajra, Anchor, Lantern])
  assert_eq(state.player.status.strength, 1) // Vajra
  assert_eq(state.player.block, 10) // Anchor
  assert_eq(state.player.energy, 4) // 3 + Lantern
}
