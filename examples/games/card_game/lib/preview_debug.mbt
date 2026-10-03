///|
/// Fresh deterministic fixtures for visual review, excluded from release builds.
pub fn Game::preview(name : String, width : Int, height : Int) -> Game {
  let game = Game::new()
  game.set_viewport(width, height)
  let run = game.run.get()
  match name {
    "map"
    | "map_unique"
    | "map_event"
    | "event"
    | "event_complete"
    | "shop"
    | "shop_sold"
    | "card_removal"
    | "treasure"
    | "unique_battle"
    | "unique_reward" => {
      let adventure = RunState::adventure(Ironclad, Ascent, seed=42)
      game.run.set(adventure)
      if name == "map_unique" {
        adventure.floor = 6
        adventure.route.unwrap().current = Some(16)
        adventure.route.unwrap().visited.append([1, 4, 7, 10, 13, 16])
        let choices = run_choices(adventure)
        for index, choice in choices {
          if choice.action is PickNode(id) &&
            adventure.route.unwrap().nodes.any(n => {
              n.id == id && n.kind == RoomUnique
            }) {
            game.scene_focus = index
          }
        }
      } else if name == "map_event" ||
        name == "event" ||
        name == "event_complete" {
        apply_run_choice(adventure, "node:1") |> ignore
        adventure.battle.unwrap().phase = Victory
        on_battle_victory(adventure)
        pick_card_reward(adventure, -1)
        if name != "map_event" {
          for node in available_rooms(adventure) {
            if node.kind == RoomEvent {
              apply_run_choice(adventure, "node:\{node.id}") |> ignore
              break
            }
          }
          adventure.event = Some(HealingSpring)
          adventure.player_hp = 40
          adventure.gold = 20
        }
        if name == "event_complete" {
          apply_run_choice(adventure, "event:0") |> ignore
        }
      } else if name == "shop" || name == "shop_sold" || name == "card_removal" {
        adventure.phase = ShopRoom
        adventure.gold = 240
        adventure.shop = Some(ShopState::new(adventure))
        if name == "shop_sold" {
          apply_run_choice(adventure, "buy:0") |> ignore
        }
        if name == "card_removal" {
          apply_run_choice(adventure, "remove_card") |> ignore
        }
      } else if name == "treasure" {
        open_treasure(adventure)
      } else if name == "unique_battle" || name == "unique_reward" {
        adventure.current_room = Some(RoomUnique)
        adventure.floor = 7
        adventure.phase = Battle
        adventure.battle = Some(start_run_battle(adventure, UniqueSentinel))
        adventure.unique_enemies_seen.push(GildedSentinel)
        adventure.route.unwrap().current = Some(18)
        adventure.route.unwrap().visited.append([1, 4, 7, 10, 13, 16, 18])
        if name == "unique_reward" {
          adventure.battle.unwrap().enemies[0].fighter.hp = 1
          adventure.battle.unwrap().hand[0] = Strike
        }
      }
    }
    "card_reward" | "complex_reward" => {
      run.phase = CardReward
      run.card_rewards.clear()
      let cards = if name == "complex_reward" {
        [Corruption, Feed, Reaper]
      } else {
        [Pommel_Strike, Inflame, Shrug_It_Off]
      }
      for card in cards {
        run.card_rewards.push(card)
      }
    }
    "rest" => {
      run.phase = RestSite
      run.floor = 5
      run.player_hp = 46
    }
    "victory" => {
      run.phase = RunVictory
      run.floor = 30
    }
    "defeat" => {
      run.phase = RunDefeat
      run.player_hp = 0
    }
    "battle_victory" => run.battle.unwrap().phase = Victory
    "card_impact" | "block_effect" => {
      let b = run.battle.unwrap()
      b.hand[0] = if name == "block_effect" { Defend } else { Strike }
      game.commit_card(b, 0, 1)
    }
    "enemy_windup" => {
      let b = run.battle.unwrap()
      begin_enemy_turn(b)
      game.present(EnemyWindup(1))
      game.hint = "RED LOUSE ACTS"
    }
    "enemy_impact" => {
      let b = run.battle.unwrap()
      begin_enemy_turn(b)
      let before = CombatFeedback::capture(b)
      execute_enemy_action(b, 1)
      game.present(EnemyImpact(1, before))
      game.hint = "RED LOUSE ACTS"
    }
    "draw_hand" => {
      let b = run.battle.unwrap()
      end_player_turn(b)
      game.present(DrawHand)
      game.hint = "YOUR TURN"
    }
    "battle_outcome" => {
      let b = run.battle.unwrap()
      for enemy in b.enemies {
        enemy.fighter.hp = 0
      }
      b.phase = Victory
      game.present(BattleOutcome([0, 1]))
    }
    "title" => game.scene = Title
    "settings" => game.scene = Settings
    "character_select" => game.scene = CharacterSelect
    "boss" => game.run.set(RunState::start(Ironclad, GuardianTrial))
    "deck" => game.open_pile(Deck)
    "draw_pile" => game.open_pile(Draw)
    "discard_pile" => {
      run.battle.unwrap().discard_pile.push(Strike)
      run.battle.unwrap().discard_pile.push(Defend)
      game.open_pile(Discard)
    }
    "controller_target" => {
      let b = run.battle.unwrap()
      game.select_card(b, 0)
      game.combat_focus = Some(Target(1))
      game.target_enemy.set(1)
      game.hint = "ARROWS: TARGET / A OR ENTER: PLAY / B OR ESC: BACK"
    }
    "large_hand" | "inspect_card" => {
      let b = run.battle.unwrap()
      b.hand.clear()
      for
        card in [
          Strike,
          Defend,
          Bash,
          Offering,
          Inflame,
          Whirlwind,
          Shrug_It_Off,
          Metallicize,
          Battle_Trance,
          Heavy_Blade,
          Corruption,
          Feed,
        ] {
        b.hand.push(card)
      }
      if name == "inspect_card" {
        let r = game.layout.card_rect(10, b.hand.length())
        game.cursor_x = r.x + 2.0
        game.cursor_y = r.y + 30.0
      }
    }
    "low_energy" | "energy_empty" | "energy_selected" => {
      let b = run.battle.unwrap()
      b.player.energy = 0
      b.hand.clear()
      let cards = if name == "energy_empty" {
        [Strike, Defend, Bash]
      } else {
        [Offering, Demon_Form, Whirlwind, Corruption, Seeing_Red]
      }
      for card in cards {
        b.hand.push(card)
      }
      if name == "energy_selected" {
        game.select_card(b, 0)
      }
    }
    "dragging" | "drag_attack" | "drop_enemy" | "drop_outside" => {
      let b = run.battle.unwrap()
      b.hand[0] = if name == "drag_attack" || name == "drop_enemy" {
        Strike
      } else {
        Defend
      }
      let card = game.layout.card_rect(0, b.hand.length())
      let target = match name {
        "drop_enemy" => game.layout.enemy_rect(1, b.enemies.length())
        "drop_outside" => game.layout.end_turn_rect()
        _ => game.layout.player_rect()
      }
      game.select_card(b, 0)
      let source_at = fn(x, y) { game.drag_source_at(x, y) }
      let target_at = fn(source, x, y) { game.drag_target_at(source, x, y) }
      let _ = game.drag.handle_pointer(
        @ui.UIPointerFrame::new(
          Mouse,
          card.x + 12.0,
          card.y + 30.0,
          pressed=true,
          down=true,
        ),
        source_at~,
        target_at~,
      )
      let _ = game.drag.handle_pointer(
        @ui.UIPointerFrame::new(
          Mouse,
          target.x + target.w / 2.0,
          target.y + target.h / 2.0,
          down=true,
        ),
        source_at~,
        target_at~,
      )
      game.cursor_x = target.x + target.w / 2.0
      game.cursor_y = target.y + target.h / 2.0
      game.hint = if game.need_target {
        "DROP ON AN ENEMY"
      } else {
        "DROP ON THE BATTLEFIELD"
      }
    }
    _ => ()
  }
  game
}
