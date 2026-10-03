///|
test "event completion displays progress and pointer can enter the next connected floor" {
  for id in [HealingSpring, LostPurse, BloodAltar, ForgottenLibrary] {
    let game = Game::new()
    game.set_viewport(640, 440)
    game.apply_screen_action(StartAdventure(Ironclad, Ascent, 42))
    let run = game.run.get()
    assert_true(apply_run_choice(run, "node:1"))
    run.battle.unwrap().phase = Victory
    on_battle_victory(run)
    pick_card_reward(run, -1)
    for node in available_rooms(run) {
      if node.kind == RoomEvent {
        assert_true(apply_run_choice(run, "node:\{node.id}"))
        break
      }
    }
    assert_eq(run.phase, EventRoom)
    let event_node = run.route.unwrap().current.unwrap()
    run.event = Some(id)
    let leave = run_choices(run).filter(c => c.id == "event:2")[0]
    let rect = game.room_choice_rect(leave)
    game.update(pointer_input(rect.cx(), rect.cy(), true))
    settle_presentation(game)
    assert_eq(run.phase, RouteMap)
    assert_eq(drop_text(game, "floor"), Some("ACT 1 / NEXT FLOOR 3"))
    assert_true(
      drop_snapshot(game).nodes.any(n => {
        n.path.has_prefix("map_node_\{event_node}>") && n.text == Some("DONE")
      }),
    )
    assert_true(available_rooms(run).all(n => n.floor == 3))
    let next = run_choices(run)[0]
    let next_rect = game.room_choice_rect(next)
    game.update(pointer_input(next_rect.cx(), next_rect.cy(), false))
    game.update(pointer_input(next_rect.cx(), next_rect.cy(), true))
    settle_presentation(game)
    assert_eq(run.floor, 3)
    assert_true(run.phase != RouteMap)
    assert_false(apply_run_choice(run, "event:2"))
  }
}

///|
test "branch maps are seeded connected and expose only the next reachable rooms" {
  let run = RunState::adventure(Ironclad, Ascent, seed=42)
  let other = RunState::adventure(Ironclad, Ascent, seed=42)
  assert_eq(run.phase, RouteMap)
  assert_eq(run.floor, 0)
  assert_eq(run.gold, 99)
  assert_eq(run.route.unwrap().nodes, other.route.unwrap().nodes)
  let nodes = available_rooms(run)
  assert_eq(nodes.length(), 3)
  assert_true(nodes.all(n => n.floor == 1 && n.kind == RoomBattle))
  assert_false(apply_run_choice(run, "node:40"))
  assert_eq(run.floor, 0)
  assert_true(apply_run_choice(run, "node:1"))
  assert_eq(run.phase, Battle)
  assert_eq(run.floor, 1)
  assert_false(apply_run_choice(run, "node:1"))
  run.battle.unwrap().phase = Victory
  on_battle_victory(run)
  pick_card_reward(run, -1)
  assert_eq(run.phase, RouteMap)
  assert_eq(run.floor, 1)
  let next = available_rooms(run)
  assert_true(next.all(n => n.floor == 2))
  assert_false(next.any(n => n.id == 1))
  for node in run.route.unwrap().nodes {
    if node.floor < 15 {
      assert_true(!node.next.is_empty())
      assert_true(
        node.next.all(id => {
          run.route.unwrap().nodes.any(n => {
            n.id == id && n.floor == node.floor + 1
          })
        }),
      )
    }
  }
}

///|
test "events charge resources once and reject unavailable options without mutation" {
  let run = RunState::adventure(Ironclad, Ascent)
  run.phase = EventRoom
  run.event = Some(HealingSpring)
  run.player_hp = 40
  run.gold = 0
  assert_false(run_choices(run).any(c => c.id == "event:1"))
  assert_false(apply_run_choice(run, "event:1"))
  assert_eq(run.player_max_hp, 80)
  assert_true(apply_run_choice(run, "event:0"))
  assert_eq(run.player_hp, 56)
  assert_eq(run.phase, RouteMap)
  assert_false(apply_run_choice(run, "event:0"))
  assert_eq(run.player_hp, 56)
}

///|
test "shop purchases are atomic sold once and account for relic discounts" {
  let run = RunState::adventure(Ironclad, Ascent)
  run.phase = ShopRoom
  run.shop = Some(ShopState::new(run))
  let shop = run.shop.unwrap()
  let offer = shop.offers[0]
  let price = shop_price(run, offer.price)
  run.gold = price - 1
  let count = run.deck.length()
  assert_false(apply_run_choice(run, "buy:0"))
  assert_eq(run.gold, price - 1)
  assert_eq(run.deck.length(), count)
  run.gold = price
  assert_true(apply_run_choice(run, "buy:0"))
  assert_eq(run.gold, 0)
  assert_eq(run.deck.length(), count + 1)
  assert_true(offer.sold)
  assert_false(apply_run_choice(run, "buy:0"))
  assert_eq(run.deck.length(), count + 1)
  run.relics.push(MerchantCharm)
  assert_eq(shop_price(run, 100), 80)
}

///|
test "shop card removal preserves resources on invalid index and increases service cost" {
  let run = RunState::adventure(Warden, Ascent)
  run.phase = ShopRoom
  run.shop = Some(ShopState::new(run))
  run.gold = 100
  assert_true(apply_run_choice(run, "remove_card"))
  assert_eq(run.phase, CardRemoval)
  let count = run.deck.length()
  assert_false(apply_run_choice(run, "remove:99"))
  assert_eq(run.gold, 100)
  assert_true(apply_run_choice(run, "remove:0"))
  assert_eq(run.deck.length(), count - 1)
  assert_eq(run.gold, 50)
  assert_eq(run.phase, ShopRoom)
  assert_eq(card_removal_price(run), 75)
  assert_false(run_choices(run).any(c => c.id == "remove_card"))
}

///|
test "treasure never offers owned relics and unique enemy rewards apply in later battles" {
  let run = RunState::adventure(Ironclad, Ascent)
  open_treasure(run)
  assert_true(run.treasure_rewards.all(id => !run.relics.contains(id)))
  let relic = run.treasure_rewards[0]
  assert_true(apply_run_choice(run, "relic:0"))
  assert_true(run.relics.contains(relic))
  assert_false(apply_run_choice(run, "relic:0"))
  run.current_room = Some(RoomUnique)
  run.battle = Some(start_unique_battle(run))
  run.phase = Battle
  assert_true(
    run.unique_enemies_seen.contains(run.battle.unwrap().enemies[0].id),
  )
  let first = run.battle.unwrap().enemies[0].id
  run.battle.unwrap().phase = Victory
  on_battle_victory(run)
  assert_true(run.last_relic is Some(_))
  let earned = run.last_relic.unwrap()
  assert_true(run.relics.contains(earned))
  let next = start_unique_battle(run)
  assert_true(next.enemies[0].id != first)
  claim_relic(run, EmberSeal) |> ignore
  let battle = start_run_battle(run, SingleJawWorm)
  assert_eq(battle.player.status.strength, 2)
}

///|
test "combat gold and guaranteed relic rewards cannot be claimed twice" {
  let run = RunState::adventure(Warden, Ascent)
  assert_true(apply_run_choice(run, "node:1"))
  let initial = run.gold
  run.battle.unwrap().phase = Victory
  on_battle_victory(run)
  let claimed = run.gold
  assert_true(claimed > initial)
  on_battle_victory(run)
  assert_eq(run.gold, claimed)
  run.phase = RouteMap
  run.relics.push(Wayfinder)
  assert_true(combat_gold(run, RoomBattle) >= 30)
}

///|
test "boss completion opens the second act and the final boss ends the adventure" {
  let run = RunState::adventure(Ironclad, Ascent)
  run.floor = 15
  run.phase = CardReward
  run.current_room = Some(RoomBoss)
  run.player_hp = 20
  run.route.unwrap().current = Some(43)
  pick_card_reward(run, -1)
  assert_eq(run.phase, RouteMap)
  assert_eq(run.player_hp, 80)
  assert_true(available_rooms(run).all(n => n.floor == 16))
  run.floor = 30
  run.phase = CardReward
  run.current_room = Some(RoomBoss)
  pick_card_reward(run, -1)
  assert_eq(run.phase, RunVictory)
  assert_true(run_choices(run).is_empty())
}

///|
test "unique enemies cycle their signature intents and guarding absorbs the next player attack" {
  let duelist = spawn_enemy(CinderDuelist)
  let sentinel = spawn_enemy(GildedSentinel)
  let oracle = spawn_enemy(HollowOracle)
  assert_eq(duelist.intent, AttackIntent(10))
  assert_eq(sentinel.intent, DefendIntent(12))
  assert_eq(oracle.intent, DebuffIntent)
  for enemy in [duelist, sentinel, oracle] {
    let initial = enemy.intent
    let player = Fighter::new("Test", 300)
    for _ in 0..<4 {
      execute_enemy_intent(enemy, player) |> ignore
    }
    assert_eq(enemy.intent, initial)
  }
  let run = RunState::start(Ironclad, Ascent)
  let b = run.battle.unwrap()
  b.enemies.clear()
  b.enemies.push(sentinel)
  end_player_turn(b)
  assert_eq(sentinel.fighter.block, 12)
  b.hand.clear()
  b.hand.push(Strike)
  let hp = sentinel.fighter.hp
  assert_eq(play_card(b, 0, 0), Ok)
  assert_eq(sentinel.fighter.hp, hp)
  assert_eq(sentinel.fighter.block, 6)
  end_player_turn(b)
  assert_eq(sentinel.fighter.block, 0)
}

///|
test "application starts at the map and controller commits one legal node after the transition" {
  let game = Game::new_app()
  game.apply_screen_action(StartAdventure(Warden, Ascent, 42))
  assert_eq(game.snapshot_state(), "map")
  assert_eq(game.run.get().floor, 0)
  controller_press(game, [15])
  assert_eq(game.scene_focus, 1)
  controller_press(game, [0])
  assert_eq(game.snapshot_state(), "transition")
  assert_eq(game.run.get().floor, 0)
  settle_presentation(game)
  assert_eq(game.run.get().floor, 1)
  assert_eq(game.run.get().route.unwrap().current, Some(1))
  assert_eq(game.snapshot_state(), "battle")
  assert_eq(game.run.get().battle.unwrap().player.block, 10)
}

///|
test "room pointer hit areas agree with semantic choices and disabled event rows have no focus" {
  let game = Game::new()
  game.apply_screen_action(StartAdventure(Ironclad, Ascent, 42))
  let run = game.run.get()
  run.phase = EventRoom
  run.event = Some(HealingSpring)
  run.gold = 0
  assert_false(
    drop_snapshot(game).nodes.any(n => n.id == "event_1" && n.focusable),
  )
  let choices = run_choices(run)
  let rect = game.room_choice_rect(choices[0])
  game.update(pointer_input(rect.x + rect.w / 2.0, rect.y + rect.h / 2.0, true))
  assert_true(game.presentation is Some(_))
  settle_presentation(game)
  assert_eq(run.phase, RouteMap)
  run.phase = ShopRoom
  run.shop = Some(ShopState::new(run))
  controller_press(game, [1])
  settle_presentation(game)
  assert_eq(run.phase, RouteMap)
}

///|
test "map browsing never activates a hidden node and returning focus restores next rooms" {
  let game = Game::preview("map_unique", 640, 360)
  let floor = game.run.get().floor
  game.browse_map(true)
  assert_eq(game.room_page, 1)
  controller_press(game, [0])
  assert_eq(game.room_page, 0)
  assert_eq(game.snapshot_state(), "map")
  assert_eq(game.run.get().floor, floor)
  game.browse_map(false)
  assert_eq(game.room_page, -1)
  controller_press(game, [15])
  assert_eq(game.room_page, 0)
  assert_eq(game.snapshot_state(), "map")
}

///|
test "card removal keeps the selected card visible across viewport changes" {
  let game = Game::preview("card_removal", 960, 640)
  game.scene_focus = 5
  assert_eq(game.room_page, 0)
  game.set_viewport(360, 640)
  assert_eq(game.room_page, 1)
  assert_true(
    drop_snapshot(game).nodes.any(n => n.id == "remove_5" && n.focused),
  )
}

///|
test "shops cannot sell duplicate relics or exceed potion capacity and signatures are exclusive" {
  let run = RunState::adventure(Warden, Ascent)
  run.phase = ShopRoom
  run.gold = 1000
  run.shop = Some(ShopState::new(run))
  let shop = run.shop.unwrap()
  for offer in shop.offers {
    if offer.item is ShopRelic(id) {
      assert_false(id == MerchantCharm || id == EmberSeal || id == Wayfinder)
    }
  }
  run.potions.append([FirePotion, BlockPotion, StrengthPotion])
  for index, offer in shop.offers {
    if offer.item is ShopPotion(_) {
      assert_false(apply_run_choice(run, "buy:\{index}"))
    }
  }
  let relic = ShopOffer::{ item: ShopRelic(Anchor), price: 10, sold: false, }
  shop.offers.push(relic)
  assert_false(shop_offer_enabled(run, relic))
  assert_eq(run.gold, 1000)
}

///|
test "deck modal returns a single focus in noncombat rooms and confirmation reopens the origin" {
  for
    name in ["map", "shop", "event", "card_removal", "treasure", "card_reward"] {
    let game = Game::preview(name, 960, 640)
    game.open_pile(Deck)
    game.close_pile(@ui.UIModalCloseReason::Explicit)
    assert_eq(drop_snapshot(game).nodes.filter(n => n.focused).map(n => n.id), [
      "deck_btn",
    ])
    game.update(key_input([13]))
    assert_eq(game.snapshot_state(), "deck")
    game.close_pile(@ui.UIModalCloseReason::Explicit)
    controller_press(game, [15])
    assert_eq(drop_snapshot(game).nodes.filter(n => n.focused).length(), 1)
    assert_false(game.combat_focus is Some(DeckButton))
  }
}

///|
test "relic copy retains health thresholds in the bitmap font" {
  assert_true(
    render_copy(relic_def(RedSkull).description).contains("HP AT MOST 50%"),
  )
  assert_true(
    render_copy(relic_def(MeatOnTheBone).description).contains("HP AT MOST 50%"),
  )
  assert_true(render_copy("HP >= 25%").contains("HP AT LEAST 25%"))
}
