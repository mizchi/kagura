///|
test "new run starts at floor 1 with battle" {
  let run = RunState::new()
  assert_eq(run.floor, 1)
  assert_eq(run.phase, Battle)
  assert_true(run.battle is Some(_))
  assert_eq(run.deck.length(), 10) // starter deck
  assert_eq(run.player_hp, 80)
  assert_eq(run.relics.length(), 1) // BurningBlood
}

///|
test "battle victory triggers card reward" {
  let run = RunState::new()
  match run.battle {
    Some(battle) => {
      // Kill all enemies instantly
      for enemy in battle.enemies {
        enemy.fighter.hp = 0
      }
      battle.phase = Victory
      on_battle_victory(run)
      assert_eq(run.phase, CardReward)
      assert_eq(run.card_rewards.length(), 3)
    }
    None => assert_true(false)
  }
}

///|
test "pick card reward adds to deck and advances floor" {
  let run = RunState::new()
  match run.battle {
    Some(battle) => {
      for enemy in battle.enemies {
        enemy.fighter.hp = 0
      }
      battle.phase = Victory
      on_battle_victory(run)
      let reward_card = run.card_rewards[0]
      pick_card_reward(run, 0)
      // Card should be in deck
      let mut found = false
      for card in run.deck {
        if card == reward_card {
          found = true
        }
      }
      assert_true(found)
      assert_eq(run.floor, 2) // advanced to floor 2
      assert_eq(run.phase, Battle)
    }
    None => assert_true(false)
  }
}

///|
test "skip card reward doesn't add card" {
  let run = RunState::new()
  match run.battle {
    Some(battle) => {
      for enemy in battle.enemies {
        enemy.fighter.hp = 0
      }
      battle.phase = Victory
      on_battle_victory(run)
      let deck_size = run.deck.length()
      pick_card_reward(run, -1) // skip
      assert_eq(run.deck.length(), deck_size) // unchanged
      assert_eq(run.floor, 2)
    }
    None => assert_true(false)
  }
}

///|
test "rest site heals 30 percent" {
  let run = RunState::new()
  run.player_hp = 50
  run.player_max_hp = 80
  run.floor = 3 // floor 4 is rest
  run.phase = RestSite
  rest_heal(run)
  assert_eq(run.player_hp, 74) // 50 + 24 (30% of 80)
  assert_eq(run.floor, 4) // rest is floor 4, advance to 5
}

///|
test "rest site caps at max hp" {
  let run = RunState::new()
  run.player_hp = 75
  run.player_max_hp = 80
  run.floor = 3
  run.phase = RestSite
  rest_heal(run)
  assert_eq(run.player_hp, 80) // capped
}

///|
test "battle defeat ends run" {
  let run = RunState::new()
  match run.battle {
    Some(battle) => {
      battle.player.hp = 0
      battle.phase = Defeat
      on_battle_defeat(run)
      assert_eq(run.phase, RunDefeat)
      assert_eq(run.player_hp, 0)
    }
    None => assert_true(false)
  }
}

///|
test "hp persists across battles" {
  let run = RunState::new()
  match run.battle {
    Some(battle) => {
      // Simulate taking damage
      battle.player.hp = 60
      for enemy in battle.enemies {
        enemy.fighter.hp = 0
      }
      battle.phase = Victory
      on_battle_victory(run)
      assert_eq(run.player_hp, 60)
      pick_card_reward(run, -1) // skip
      // New battle should start with 60 HP
      match run.battle {
        Some(battle2) => assert_eq(battle2.player.hp, 60)
        None => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "floor progression through full run" {
  // Floor 1: Easy, 2: Easy, 3: Normal, 4: Rest, 5: Normal, 6: Elite, 7: Elite
  assert_eq(floor_type(1), Combat(Easy))
  assert_eq(floor_type(2), Combat(Easy))
  assert_eq(floor_type(3), Combat(Normal))
  assert_eq(floor_type(4), Rest)
  assert_eq(floor_type(5), Combat(Normal))
  assert_eq(floor_type(6), Combat(Elite))
  assert_eq(floor_type(7), Combat(Elite))
}

///|
test "completing all floors wins the run" {
  let run = RunState::new()
  run.floor = max_floor
  run.phase = Battle
  // Simulate advancing past last floor
  advance_floor(run)
  assert_eq(run.phase, RunVictory)
}
