///|
fn settle_presentation(game : Game) -> Unit {
  for _ in 0..<240 {
    game.update(@core.empty_input_snapshot())
  }
}

///|
test "a played card has a readable effect and ignores repeated input" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  press_card(game, 0)
  let r = game.layout.enemy_rect(1, 2)
  drag_to(game, r.cx(), r.cy())
  assert_eq(game.snapshot_state(), "card_play")
  game.update(key_input([49]))
  game.update(key_input([13, 69]))
  assert_eq(b.player.energy, 2)
  assert_eq(b.turn, 1)
  assert_eq(b.discard_pile.length(), 1)
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "battle")
}

///|
test "enemy actions are shown in order before drawing the next hand" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  let hp = b.player.hp
  game.update(key_input([69]))
  assert_eq(b.phase, EnemyTurn)
  assert_eq(b.turn, 1)
  assert_eq(b.player.hp, hp)
  assert_eq(b.enemies[0].pattern_index, 0)
  assert_eq(b.hand.length(), 0)
  // The first enemy defends; the second has not attacked yet.
  for _ in 0..<38 {
    game.update(@core.empty_input_snapshot())
  }
  assert_eq(b.enemies[0].pattern_index, 1)
  assert_eq(b.enemies[1].pattern_index, 0)
  assert_eq(b.player.hp, hp)
  settle_presentation(game)
  assert_eq(b.turn, 2)
  assert_eq(b.player.hp, hp - 6)
  assert_eq(b.hand.length(), 5)
  assert_eq(game.snapshot_state(), "battle")
}

///|
test "a killing card keeps the battlefield visible before the result" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.enemies[0].fighter.hp = 0
  b.enemies[1].fighter.hp = 1
  game.commit_card(b, 0, 1)
  assert_eq(b.phase, Victory)
  assert_eq(game.snapshot_state(), "card_play")
  for _ in 0..<24 {
    game.update(@core.empty_input_snapshot())
  }
  assert_eq(game.snapshot_state(), "battle_outcome")
  game.update(key_input([13]))
  assert_eq(game.run.get().phase, Battle)
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "battle_victory")
}

///|
test "defeat stops remaining enemy actions and delays the result" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.player.hp = 1
  b.enemies[0].intent = AttackIntent(6)
  game.update(key_input([69]))
  for _ in 0..<60 {
    game.update(@core.empty_input_snapshot())
  }
  assert_eq(b.phase, Defeat)
  assert_eq(b.enemies[1].pattern_index, 0)
  assert_eq(game.snapshot_state(), "battle_outcome")
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "battle_defeat")
}

///|
test "reward transition applies once and does not accept a second choice" {
  let game = interaction_game()
  let run = game.run.get()
  run.phase = CardReward
  run.card_rewards.clear()
  run.card_rewards.push(Inflame)
  let n = run.deck.length()
  game.update(key_input([49]))
  assert_eq(game.snapshot_state(), "transition")
  assert_eq(run.floor, 1)
  game.update(key_input([]))
  game.update(key_input([49, 13]))
  settle_presentation(game)
  assert_eq(run.floor, 2)
  assert_eq(run.deck.length(), n + 1)
  assert_eq(game.snapshot_state(), "battle")
}

///|
test "presentation timing depends on elapsed time rather than frame count" {
  let fast = interaction_game()
  let slow = interaction_game()
  fast.commit_card(fast.run.get().battle.unwrap(), 1, 0)
  slow.commit_card(slow.run.get().battle.unwrap(), 1, 0)
  for _ in 0..<40 {
    fast.update(@core.empty_input_snapshot(), elapsed_ms=5.0)
  }
  for _ in 0..<8 {
    slow.update(@core.empty_input_snapshot(), elapsed_ms=25.0)
  }
  assert_eq(fast.snapshot_state(), "card_play")
  assert_eq(slow.snapshot_state(), "card_play")
  assert_eq(
    fast.presentation.unwrap().elapsed_ms,
    slow.presentation.unwrap().elapsed_ms,
  )
  for _ in 0..<32 {
    fast.update(@core.empty_input_snapshot(), elapsed_ms=5.0)
  }
  for _ in 0..<8 {
    slow.update(@core.empty_input_snapshot(), elapsed_ms=20.0)
  }
  assert_eq(fast.snapshot_state(), "battle")
  assert_eq(slow.snapshot_state(), "battle")
}

///|
test "a background-tab delay does not skip all enemy actions" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  game.update(key_input([69]))
  game.update(@core.empty_input_snapshot(), elapsed_ms=10000.0)
  assert_eq(b.turn, 1)
  assert_eq(b.enemies[0].pattern_index, 0)
  assert_eq(b.enemies[1].pattern_index, 0)
}

///|
test "reduced motion retains readable pauses and suppresses actor movement" {
  let game = interaction_game()
  game.set_reduced_motion(true)
  let b = game.run.get().battle.unwrap()
  game.commit_card(b, 0, 1)
  game.update(@core.empty_input_snapshot(), elapsed_ms=50.0)
  let hero = game.actor_pose(b.player, -1)
  assert_eq(hero.x, 0.0)
  assert_eq(hero.y, 0.0)
  assert_eq(game.shown_hp(b.enemies[1].fighter, 1), b.enemies[1].fighter.hp)
  assert_eq(game.snapshot_state(), "card_play")
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "battle")
}

///|
test "staged enemy actions preserve the synchronous rules outcome" {
  let direct = BattleState::new([JawWorm, RedLouse])
  let staged = BattleState::new([JawWorm, RedLouse])
  for b in [direct, staged] {
    b.player.block = 8
    b.player.status.weak = 2
    b.powers.metallicize = 3
    b.powers.demon_form = 2
    b.powers.regen = 2
    b.player.hp = 50
    b.hand.push(Carnage)
  }
  end_player_turn(direct)
  begin_enemy_turn(staged)
  assert_eq(staged.phase, EnemyTurn)
  execute_enemy_action(staged, 0)
  execute_enemy_action(staged, 1)
  finish_enemy_turn(staged)
  assert_eq(staged.to_string(), direct.to_string())
  finish_enemy_turn(staged)
  assert_eq(staged.turn, 2)
}

///|
test "held confirmation is consumed during the effect rather than queued" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  game.update(key_input([49]))
  game.update(key_input([13]))
  for _ in 0..<40 {
    game.update(key_input([13, 69]))
  }
  assert_eq(b.turn, 1)
  assert_eq(b.player.energy, 2)
  assert_eq(game.selected_card.get(), -1)
}

///|
test "already defeated enemies do not reappear in the victory effect" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.enemies[0].fighter.hp = 0
  b.enemies[1].fighter.hp = 1
  game.commit_card(b, 0, 1)
  for _ in 0..<24 {
    game.update(@core.empty_input_snapshot())
  }
  assert_false(game.show_enemy(b.enemies[0].fighter, 0))
  assert_true(game.show_enemy(b.enemies[1].fighter, 1))
}

///|
test "continuing from a result preserves the outgoing screen while fading" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.phase = Victory
  game.update(key_input([13]))
  // Result headings remain on screen until the transition midpoint.
  let ui = @scene.ui_snapshot_from_scene(
    game.view(),
    screen_width=640.0,
    screen_height=480.0,
  )
  assert_true(ui.nodes.any(n => n.text == Some("BATTLE WON")))
  assert_eq(game.run.get().phase, Battle)
  for _ in 0..<4 {
    game.update(@core.empty_input_snapshot(), elapsed_ms=50.0)
  }
  assert_eq(game.run.get().phase, CardReward)
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "card_reward")
}
