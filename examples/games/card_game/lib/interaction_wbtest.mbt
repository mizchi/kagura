///|
fn UiRect::cx(self : UiRect) -> Double {
  self.x + self.w / 2.0
}

///|
fn UiRect::cy(self : UiRect) -> Double {
  self.y + self.h / 2.0
}

///|
fn pointer_input(x : Double, y : Double, down : Bool) -> @core.InputSnapshot {
  @core.new_input_snapshot_full(
    x,
    y,
    0.0,
    0.0,
    [],
    if down {
      [0]
    } else {
      []
    },
    [],
    [],
  )
}

///|
fn key_input(keys : Array[Int]) -> @core.InputSnapshot {
  @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, keys)
}

///|
fn interaction_game() -> Game {
  let game = Game::new()
  game.set_viewport(640, 480)
  let battle = BattleState::new([GreenLouse, RedLouse])
  battle.hand.clear()
  battle.hand.push(Strike)
  battle.hand.push(Defend)
  battle.hand.push(Bash)
  game.run.get().battle = Some(battle)
  game
}

///|
fn press_card(game : Game, index : Int) -> Unit {
  let b = game.run.get().battle.unwrap()
  let r = game.layout.card_rect(index, b.hand.length())
  game.update(pointer_input(r.cx(), r.cy(), true))
}

///|
fn drag_to(game : Game, x : Double, y : Double) -> Unit {
  game.update(pointer_input(x, y, true))
  game.update(pointer_input(x, y, false))
}

///|
test "pressing a card does not spend energy before release" {
  let game = interaction_game()
  let battle = game.run.get().battle.unwrap()
  press_card(game, 1)
  assert_eq(battle.player.energy, 3)
  assert_eq(battle.hand.length(), 3)
  assert_eq(battle.player.block, 0)
}

///|
test "dragging outside the battlefield cancels without consuming the card" {
  let game = interaction_game()
  let battle = game.run.get().battle.unwrap()
  press_card(game, 1)
  drag_to(game, 4.0, 4.0)
  assert_eq(battle.player.energy, 3)
  assert_eq(battle.hand.length(), 3)
  assert_eq(game.selected_card.get(), -1)
  assert_true(game.drag.snapshot() is None)
}

///|
test "attack drop damages only the chosen enemy and spends exactly once" {
  let game = interaction_game()
  let battle = game.run.get().battle.unwrap()
  let first_hp = battle.enemies[0].fighter.hp
  let second_hp = battle.enemies[1].fighter.hp
  let r = game.layout.enemy_rect(1, 2)
  press_card(game, 0)
  game.update(pointer_input(r.cx(), r.cy(), true))
  assert_eq(battle.enemies[1].fighter.hp, second_hp)
  assert_eq(game.snapshot_state(), "dragging")
  game.update(pointer_input(r.cx(), r.cy(), false))
  game.update(pointer_input(r.cx(), r.cy(), false))
  assert_eq(battle.enemies[0].fighter.hp, first_hp)
  assert_eq(battle.enemies[1].fighter.hp, second_hp - 6)
  assert_eq(battle.player.energy, 2)
  assert_eq(battle.hand.length(), 2)
  assert_eq(battle.discard_pile.length(), 1)
}

///|
test "skill drop on the player gains block" {
  let game = interaction_game()
  let battle = game.run.get().battle.unwrap()
  let r = game.layout.player_rect()
  press_card(game, 1)
  drag_to(game, r.cx(), r.cy())
  assert_eq(battle.player.block, 6)
  assert_eq(battle.player.energy, 2)
}

///|
test "attack drop on player is cancelled" {
  let game = interaction_game()
  let battle = game.run.get().battle.unwrap()
  let r = game.layout.player_rect()
  press_card(game, 0)
  drag_to(game, r.cx(), r.cy())
  assert_eq(battle.player.energy, 3)
  assert_eq(battle.hand.length(), 3)
}

///|
test "dropping an attack onto a dead enemy cannot spend energy" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.enemies[0].fighter.hp = 0
  let r = game.layout.enemy_rect(0, 2)
  press_card(game, 0)
  drag_to(game, r.cx(), r.cy())
  assert_eq(b.player.energy, 3)
  assert_eq(b.hand.length(), 3)
}

///|
test "escape cancels an active drag even when the pointer is later released" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  press_card(game, 0)
  game.update(pointer_input(440.0, 160.0, true))
  game.update(key_input([27]))
  game.update(pointer_input(440.0, 160.0, false))
  assert_eq(b.player.energy, 3)
  assert_eq(b.hand.length(), 3)
  assert_true(game.drag.snapshot() is None)
}

///|
test "unaffordable cards cannot be dragged" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.player.energy = 0
  press_card(game, 0)
  assert_true(game.drag.snapshot() is None)
  assert_eq(game.selected_card.get(), -1)
}

///|
test "corruption skills use the rules cost in drag validation" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.player.energy = 0
  b.powers.corruption = true
  let r = game.layout.player_rect()
  press_card(game, 1)
  drag_to(game, r.cx(), r.cy())
  assert_eq(b.player.block, 6)
  assert_eq(b.player.energy, 0)
  assert_eq(b.exhaust_pile.length(), 1)
}

///|
test "X cost cards can be dragged with zero energy" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.hand[0] = Whirlwind
  b.player.energy = 0
  press_card(game, 0)
  assert_true(game.drag.snapshot() is Some(_))
}

///|
test "keyboard chooses a card and living enemy then confirms" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  let hp = b.enemies[1].fighter.hp
  game.update(key_input([49]))
  game.update(key_input([39]))
  game.update(key_input([13]))
  assert_eq(b.enemies[1].fighter.hp, hp - 6)
  assert_eq(b.player.energy, 2)
}

///|
test "click selection then enemy click still works" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  let card = game.layout.card_rect(0, 3)
  press_card(game, 0)
  game.update(pointer_input(card.cx(), card.cy(), false))
  assert_true(game.need_target)
  let r = game.layout.enemy_rect(1, 2)
  game.update(pointer_input(r.cx(), r.cy(), true))
  assert_eq(b.player.energy, 2)
  assert_eq(b.hand.length(), 2)
}

///|
test "end turn clears selection and refills energy" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  game.update(key_input([49]))
  game.update(key_input([69]))
  settle_presentation(game)
  assert_eq(b.turn, 2)
  assert_eq(b.player.energy, 3)
  assert_eq(game.selected_card.get(), -1)
}

///|
test "deck inspection suspends combat input" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  game.update(key_input([68]))
  game.update(key_input([69]))
  assert_eq(b.turn, 1)
  assert_eq(game.snapshot_state(), "deck")
  game.update(key_input([27]))
  assert_eq(game.snapshot_state(), "battle")
}

///|
test "reward selection grows the deck and advances the floor" {
  let game = interaction_game()
  let run = game.run.get()
  run.phase = CardReward
  run.card_rewards.clear()
  run.card_rewards.push(Inflame)
  let n = run.deck.length()
  game.update(key_input([49]))
  settle_presentation(game)
  assert_eq(run.deck.length(), n + 1)
  assert_eq(run.deck[n], Inflame)
  assert_eq(run.floor, 2)
}

///|
test "rest does not advance on an accidental background click" {
  let game = interaction_game()
  let run = game.run.get()
  run.phase = RestSite
  run.floor = 5
  run.player_hp = 40
  game.update(pointer_input(2.0, 80.0, true))
  assert_eq(run.phase, RestSite)
  game.update(key_input([13]))
  settle_presentation(game)
  assert_eq(run.player_hp, 60)
  assert_eq(run.floor, 6)
}

///|
test "touch drop uses the final owned touch position" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  let card = game.layout.card_rect(0, 3)
  let target = game.layout.enemy_rect(1, 2)
  game.update(
    @core.new_input_snapshot_full(
      -1.0,
      -1.0,
      0.0,
      0.0,
      [],
      [],
      [@core.new_touch_point(7, card.cx(), card.cy())],
      [],
    ),
  )
  game.update(
    @core.new_input_snapshot_full(
      -1.0,
      -1.0,
      0.0,
      0.0,
      [],
      [],
      [
        @core.new_touch_point(7, target.cx(), target.cy()),
        @core.new_touch_point(8, 1.0, 1.0),
      ],
      [],
    ),
  )
  game.update(@core.empty_input_snapshot())
  assert_eq(b.player.energy, 2)
  assert_eq(b.enemies[1].fighter.hp, 7)
}

///|
test "multiple games keep independent viewport geometry" {
  let first = interaction_game()
  let second = interaction_game()
  second.set_viewport(360, 640)
  assert_eq(first.layout.w, 640.0)
  assert_eq(second.layout.w, 360.0)
}

///|
test "crowded hands stay onscreen and hit the topmost painted card" {
  let l = GameLayout::new(360, 640)
  for i = 0; i < 20; i = i + 1 {
    let r = l.card_rect(i, 20)
    assert_true(r.x >= 0.0 && r.x + r.w <= l.w)
    let exposed_x = r.x + 2.0
    assert_eq(hit_card(l, 20, exposed_x, r.cy()), i)
  }
}

///|
test "CSS pointer and touch coordinates scale to the same logical targets" {
  let input = @core.new_input_snapshot_full(
    120.0,
    80.0,
    1.0,
    2.0,
    [49],
    [0],
    [@core.new_touch_point(9, 120.0, 80.0)],
    [],
  )
  let scaled = scale_pointer_input(input, 960.0, 640.0, 480.0, 320.0)
  assert_eq(scaled.cursor_x, 240.0)
  assert_eq(scaled.cursor_y, 160.0)
  assert_eq(scaled.touches[0].x, 240.0)
  assert_eq(scaled.touches[0].y, 160.0)
  assert_eq(scaled.pressed_keys[0], 49)
  assert_eq(scaled.pressed_mouse_buttons[0], 0)
  assert_eq(scaled.wheel_y, 2.0)
}

///|
test "resizing cancels the gesture and applying the same viewport preserves it" {
  let game = interaction_game()
  press_card(game, 0)
  game.set_viewport(640, 480)
  assert_true(game.drag.snapshot() is Some(_))
  game.set_viewport(360, 640)
  assert_true(game.drag.snapshot() is None)
  assert_eq(game.run.get().battle.unwrap().player.energy, 3)
}

///|
test "drag preview leaves player and enemy information unobscured" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  for dims in [(360, 640), (640, 360), (640, 480), (960, 640)] {
    game.set_viewport(dims.0, dims.1)
    for i = 0; i < b.enemies.length(); i = i + 1 {
      let target = game.layout.enemy_rect(i, b.enemies.length())
      let r = drag_card_rect(game.layout, b, 0, target.cx(), target.cy())
      assert_true(!rects_overlap(r, target))
      assert_true(!rects_overlap(r, game.layout.player_rect()))
    }
  }
}

///|
test "all reward card descriptions stay within their cards at supported viewports" {
  for dims in [(360, 640), (640, 360), (640, 480), (960, 640)] {
    let l = GameLayout::new(dims.0, dims.1)
    let r = l.reward_rect(0, 3)
    for id in all_card_ids() {
      let snap = @scene.ui_snapshot_from_scene(
        ui_card("card", r, id, card_def(id).cost, true, false, detailed=true),
        screen_width=l.w,
        screen_height=l.h,
      )
      for node in snap.nodes {
        assert_true(
          node.left >= r.x && node.left + node.width <= r.x + r.w + 0.01,
        )
        assert_true(
          node.top >= r.y && node.top + node.height <= r.y + r.h + 0.01,
        )
      }
    }
  }
}

///|
test "deck inspection includes every acquired relic" {
  let game = interaction_game()
  let run = game.run.get()
  run.relics.push(Vajra)
  run.relics.push(Anchor)
  let snap = @scene.ui_snapshot_from_scene(
    view_deck(run, game.layout, 1),
    screen_width=640.0,
    screen_height=480.0,
  )
  let mut has_vajra = false
  let mut has_anchor = false
  for n in snap.nodes {
    if n.text is Some(text) {
      if text.contains("VAJRA") {
        has_vajra = true
      }
      if text.contains("ANCHOR") {
        has_anchor = true
      }
    }
  }
  assert_true(has_vajra && has_anchor)
}

///|
test "battlefield units stay inside the arena at narrow and short sizes" {
  for
    dims in [
      (360, 480),
      (360, 560),
      (360, 640),
      (375, 667),
      (640, 440),
      (960, 640),
    ] {
    let l = GameLayout::new(dims.0, dims.1)
    let arena = l.play_area()
    let player = l.player_rect()
    assert_true(arena.contains(player.x, player.y))
    assert_true(arena.contains(player.x + player.w, player.y + player.h))
    for i = 0; i < 3; i = i + 1 {
      let enemy = l.enemy_rect(i, 3)
      assert_true(arena.contains(enemy.x, enemy.y))
      assert_true(arena.contains(enemy.x + enemy.w, enemy.y + enemy.h))
      assert_true(!rects_overlap(enemy, player))
    }
  }
}

///|
test "the hero stays left and every enemy stays right in all layouts" {
  for dims in [(360, 560), (360, 640), (640, 360), (640, 480), (960, 640)] {
    let l = GameLayout::new(dims.0, dims.1)
    let hero = l.player_rect()
    for count in [1, 2, 3] {
      for i = 0; i < count; i = i + 1 {
        let enemy = l.enemy_rect(i, count)
        assert_true(hero.x + hero.w < enemy.x)
      }
    }
  }
}
