///|
test "new application travels through title character stage and boss scenes" {
  let game = Game::new_app()
  assert_eq(game.snapshot_state(), "title")
  game.update(key_input([13]))
  assert_eq(game.snapshot_state(), "transition")
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "character_select")
  game.update(key_input([13]))
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "stage_select")
  game.scene_focus = 2
  game.update(key_input([13]))
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "boss")
  assert_eq(game.run.get().floor, 15)
  assert_eq(game.run.get().battle.unwrap().enemies[0].id, TheGuardian)
}

///|
test "character choice changes persistent deck health relic and fighter" {
  let run = RunState::start(Warden, Ascent)
  assert_eq(run.player_max_hp, 96)
  assert_true(run.deck.contains(Body_Slam))
  assert_true(run.relics.contains(Anchor))
  assert_eq(run.battle.unwrap().player.name, "Warden")
  assert_eq(run.battle.unwrap().player.block, 10)
  run.floor = 1
  advance_floor(run)
  assert_eq(run.battle.unwrap().player.name, "Warden")
}

///|
test "settings return to the previous scene and apply explicit motion choice" {
  let game = Game::new_app()
  game.open_settings()
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "settings")
  game.update(key_input([13]))
  assert_true(game.motion_mode is Reduced)
  assert_true(game.reduced_motion)
  game.update(key_input([27]))
  settle_presentation(game)
  assert_eq(game.snapshot_state(), "title")
}

///|
test "modal blocks battle actions and returns focus to the pile trigger" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  game.open_pile(Draw)
  assert_eq(game.snapshot_state(), "draw_pile")
  assert_true(
    drop_snapshot(game).nodes.any(n => {
      n.id == "pile_close" && n.path.has_prefix("pile_modal>")
    }),
  )
  let count = b.hand.length()
  game.update(key_input([69, 49]))
  assert_eq(b.phase, PlayerTurn)
  assert_eq(b.hand.length(), count)
  assert_eq(b.player.energy, 3)
  game.update(key_input([27]))
  assert_eq(game.snapshot_state(), "battle")
  assert_true(game.combat_focus is Some(DrawPile))
  assert_eq(game.selected_card.get(), -1)
}

///|
test "pile popup renders the actual draw and discard contents including emptiness" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.draw_pile.clear()
  b.draw_pile.push(Impervious)
  game.open_pile(Draw)
  assert_true(
    drop_snapshot(game).nodes.any(n => {
      n.text is Some(text) && text.contains("IMPERVIOUS")
    }),
  )
  game.close_pile(@ui.UIModalCloseReason::Explicit)
  game.open_pile(Discard)
  assert_eq(drop_text(game, "pile_empty"), Some("NO CARDS IN THIS PILE"))
}

///|
fn controller_input(
  buttons : Array[Int],
  axes? : Array[Double] = [],
) -> @core.InputSnapshot {
  @core.new_input_snapshot_full(-1.0, -1.0, 0.0, 0.0, [], [], [], [
    @core.new_gamepad_snapshot(0, axes, buttons),
  ])
}

///|
fn controller_press(game : Game, buttons : Array[Int]) -> Unit {
  game.update(controller_input([]))
  game.update(controller_input(buttons))
}

///|
test "controller chooses a card then switches live targets before confirming" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  let hp = b.enemies[1].fighter.hp
  controller_press(game, [15])
  assert_true(game.combat_focus is Some(Hand(0)))
  controller_press(game, [0])
  assert_eq(game.selected_card.get(), 0)
  assert_eq(b.player.energy, 3)
  controller_press(game, [15])
  assert_eq(game.target_enemy.get(), 1)
  controller_press(game, [0])
  assert_eq(b.enemies[1].fighter.hp, hp - 6)
  assert_eq(b.player.energy, 2)
  game.update(controller_input([0]), elapsed_ms=1000.0)
  settle_presentation(game)
  assert_eq(b.player.energy, 2)
}

///|
test "controller cancellation returns to hand and bumper popup traps inputs" {
  let game = interaction_game()
  controller_press(game, [15])
  controller_press(game, [0])
  controller_press(game, [1])
  assert_true(game.combat_focus is Some(Hand(0)))
  assert_eq(game.selected_card.get(), -1)
  controller_press(game, [5])
  assert_eq(game.snapshot_state(), "discard_pile")
  controller_press(game, [3])
  assert_eq(game.run.get().battle.unwrap().turn, 1)
  controller_press(game, [1])
  assert_eq(game.snapshot_state(), "battle")
}

///|
test "directional zero cost selection owns focus even when energy is empty" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.player.energy = 0
  b.hand[0] = Offering
  controller_press(game, [15])
  assert_false(game.end_turn_focused())
  assert_eq(drop_snapshot(game).nodes.filter(n => n.focused).map(n => n.id), [
    "card_frame_0",
  ])
  controller_press(game, [0])
  assert_eq(drop_snapshot(game).nodes.filter(n => n.focused).map(n => n.id), [
    "player",
  ])
  controller_press(game, [0])
  settle_presentation(game)
  assert_eq(b.player.energy, 2)
  assert_eq(b.turn, 1)
}

///|
test "modal returns focus but numeric shortcut still selects a card" {
  let game = interaction_game()
  game.open_pile(Draw)
  game.close_pile(@ui.UIModalCloseReason::Explicit)
  game.update(key_input([49]))
  game.update(key_input([13]))
  assert_eq(game.run.get().battle.unwrap().player.energy, 2)
}

///|
test "controller navigates rewards and boss victory ends the trial" {
  let game = interaction_game()
  let run = game.run.get()
  run.phase = CardReward
  run.card_rewards.push(Impervious)
  run.card_rewards.push(Inflame)
  controller_press(game, [15])
  controller_press(game, [0])
  settle_presentation(game)
  assert_true(run.deck.contains(Inflame))
  let boss = RunState::start(Ironclad, GuardianTrial)
  boss.battle.unwrap().phase = Victory
  on_battle_victory(boss)
  assert_eq(boss.phase, RunVictory)
}

///|
fn paint_keys(node : @scene.SceneNode, keys : Array[String]) -> Unit {
  match node {
    Element(el) => {
      for pair in el.attrs {
        if pair.0 == "key" && pair.1 is VStatic(@scene.SceneText(key)) {
          keys.push(key)
        }
      }
      for child in el.children {
        paint_keys(child, keys)
      }
    }
    Fragment(children) =>
      for child in children {
        paint_keys(child, keys)
      }
    _ => ()
  }
}

///|
test "target tether is painted after the enemy and before command controls" {
  let game = interaction_game()
  press_card(game, 0)
  let enemy = game.layout.enemy_rect(1, 2)
  game.update(pointer_input(enemy.cx(), enemy.cy(), true))
  let keys : Array[String] = []
  paint_keys(game.view(), keys)
  let mut enemy_index = -1
  let mut tether_index = -1
  let mut hud_index = -1
  for i, key in keys {
    match key {
      "enemy_body_1" => enemy_index = i
      "target_tether" => tether_index = i
      "energy_panel" => hud_index = i
      _ => ()
    }
  }
  assert_true(
    enemy_index >= 0 && tether_index > enemy_index && hud_index > tether_index,
  )
}

///|
test "controller target selection restores actors after inspecting a crowded hand" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  for _ in 0..<9 {
    b.hand.push(Strike)
  }
  let card = game.layout.card_rect(0, b.hand.length())
  game.cursor_x = card.x + 2.0
  game.cursor_y = card.y + 30.0
  controller_press(game, [15])
  controller_press(game, [0])
  assert_true(drop_snapshot(game).nodes.any(n => n.id == "enemy_body_0"))
  assert_true(drop_snapshot(game).nodes.any(n => n.id == "player"))
}

///|
test "controller confirm cannot spend a card during an owned pointer drag" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  press_card(game, 0)
  let enemy = game.layout.enemy_rect(1, 2)
  game.update(pointer_input(enemy.cx(), enemy.cy(), true))
  let frame = @core.new_input_snapshot_full(
    enemy.cx(),
    enemy.cy(),
    0.0,
    0.0,
    [],
    [0],
    [],
    [@core.new_gamepad_snapshot(0, [], [0])],
  )
  game.update(frame)
  assert_eq(b.player.energy, 3)
  game.update(pointer_input(enemy.cx(), enemy.cy(), false))
  assert_eq(b.player.energy, 2)
}
