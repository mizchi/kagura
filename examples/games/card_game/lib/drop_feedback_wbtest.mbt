///|
fn drop_snapshot(game : Game) -> @ui.UISnapshot {
  @scene.ui_snapshot_from_scene(
    game.view(),
    screen_width=game.layout.w,
    screen_height=game.layout.h,
  )
}

///|
fn drop_text(game : Game, id : String) -> String? {
  drop_snapshot(game).nodes.iter().find_first(n => n.id == id).bind(n => n.text)
}

///|
fn has_drop_zone(game : Game, value : Int) -> Bool {
  drop_snapshot(game).nodes.any(n => n.id == "drop_zone_" + value.to_string())
}

///|
test "drop feedback preserves the enemy actor and keeps badges clear of intent and HP" {
  for dims in [(640, 360), (640, 480), (360, 640), (960, 640)] {
    let game = interaction_game()
    game.set_viewport(dims.0, dims.1)
    press_card(game, 0)
    let second = game.layout.enemy_rect(1, 2)
    game.update(pointer_input(second.cx(), second.cy(), true))
    let snapshot = drop_snapshot(game)
    for index in 0..<2 {
      let prefix = "enemy_body_" + index.to_string() + ">"
      assert_true(
        snapshot.nodes.any(n => n.id == "foe" && n.path.has_prefix(prefix)),
      )
      if snapshot.nodes
        .iter()
        .find_first(n => n.id == "drop_badge_text_" + index.to_string())
        is Some(badge) {
        for node in snapshot.nodes {
          if node.path.has_prefix(prefix) &&
            node.text is Some(_) &&
            node.id != badge.id {
            assert_false(
              rects_overlap(
                {
                  x: badge.left,
                  y: badge.top,
                  w: badge.width,
                  h: badge.height,
                },
                { x: node.left, y: node.top, w: node.width, h: node.height, },
              ),
            )
          }
        }
      }
    }
  }
}

///|
test "dragging an attack shows every accepting enemy and follows enter leave" {
  let game = interaction_game()
  press_card(game, 0)
  assert_false(has_drop_zone(game, enemy_drag_id_base))
  let player = game.layout.player_rect()
  game.update(pointer_input(player.cx(), player.cy(), true))
  assert_true(has_drop_zone(game, enemy_drag_id_base))
  assert_true(has_drop_zone(game, enemy_drag_id_base + 1))
  assert_false(has_drop_zone(game, battlefield_drag_id))
  assert_eq(drop_text(game, "drop_badge_text_0"), Some("DROP"))
  assert_eq(drop_text(game, "drop_badge_text_1"), Some("DROP"))
  let second = game.layout.enemy_rect(1, 2)
  game.update(pointer_input(second.cx(), second.cy(), true))
  assert_eq(drop_text(game, "drop_badge_text_1"), Some("RELEASE"))
  assert_eq(drop_text(game, "drop_badge_text_0"), Some("DROP"))
  assert_eq(drop_text(game, "hint"), Some("RELEASE TO PLAY"))
  game.update(pointer_input(player.cx(), player.cy(), true))
  assert_eq(drop_text(game, "drop_badge_text_1"), Some("DROP"))
  assert_eq(drop_text(game, "hint"), Some("MOVE TO A HIGHLIGHTED ENEMY"))
  assert_eq(game.run.get().battle.unwrap().player.energy, 3)
}

///|
test "battlefield cards show the same full area that accepts their drop" {
  for id in [Defend, Inflame, Cleave, Whirlwind] {
    let game = interaction_game()
    game.run.get().battle.unwrap().hand[0] = id
    press_card(game, 0)
    game.update(pointer_input(4.0, 4.0, true))
    assert_true(has_drop_zone(game, battlefield_drag_id))
    assert_false(has_drop_zone(game, enemy_drag_id_base))
    assert_eq(drop_text(game, "drop_status"), Some("DROP IN THE BATTLEFIELD"))
    let player = game.layout.player_rect()
    game.update(pointer_input(player.cx(), player.cy(), true))
    assert_eq(drop_text(game, "drop_status"), Some("RELEASE TO PLAY"))
    assert_eq(drop_text(game, "hint"), Some("RELEASE TO PLAY"))
    let zone = drop_snapshot(game).nodes
      .iter()
      .find_first(n => n.id == "drop_zone_2000")
      .unwrap()
    let area = game.layout.play_area()
    assert_eq(zone.left, area.x)
    assert_eq(zone.top, area.y)
    assert_eq(zone.width, area.w)
    assert_eq(zone.height, area.h)
  }
}

///|
test "drop feedback rejects dead enemies unavailable cards and locked screens" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.enemies[0].fighter.hp = 0
  press_card(game, 0)
  let second = game.layout.enemy_rect(1, 2)
  game.update(pointer_input(second.cx(), second.cy(), true))
  assert_false(has_drop_zone(game, enemy_drag_id_base))
  assert_true(has_drop_zone(game, enemy_drag_id_base + 1))
  b.player.energy = 0
  game.update(pointer_input(second.cx(), second.cy(), true))
  assert_false(has_drop_zone(game, enemy_drag_id_base + 1))
  assert_eq(drop_text(game, "hint"), Some("CANNOT PLAY THIS CARD"))
  game.cancel_card()
  assert_false(has_drop_zone(game, enemy_drag_id_base + 1))
  assert_true(game.card_drop_targets(@ui.UINodeId::new(0)).is_empty())
  b.player.energy = 3
  game.open_pile(Deck)
  assert_true(game.card_drop_targets(@ui.UINodeId::new(0)).is_empty())
  game.close_pile(@ui.UIModalCloseReason::Explicit)
  game.combat_focus = None
  b.phase = Victory
  assert_true(game.card_drop_targets(@ui.UINodeId::new(0)).is_empty())
}

///|
test "every advertised drop zone uses the same acceptance and disappears on cancel" {
  let game = interaction_game()
  for slot in [0, 1] {
    for target in game.card_drop_targets(@ui.UINodeId::new(slot)) {
      assert_eq(
        game.drag_target_at(
          @ui.UINodeId::new(slot),
          target.rect.cx(),
          target.rect.cy(),
        ),
        Some(target.id),
      )
    }
  }
  press_card(game, 0)
  let second = game.layout.enemy_rect(1, 2)
  game.update(pointer_input(second.cx(), second.cy(), true))
  game.update(key_input([27]))
  assert_false(has_drop_zone(game, enemy_drag_id_base + 1))
  assert_true(drop_text(game, "drop_badge_text_1") is None)
  assert_eq(game.run.get().battle.unwrap().player.energy, 3)
}
