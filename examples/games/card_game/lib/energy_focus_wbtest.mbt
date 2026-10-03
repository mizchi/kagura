///|
fn energy_focus_snapshot(game : Game) -> @ui.UISnapshot {
  @scene.ui_snapshot_from_scene(
    game.view(),
    screen_width=game.layout.w,
    screen_height=game.layout.h,
  )
}

///|
test "zero energy focuses End Turn and confirm starts exactly one enemy turn" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.player.energy = 0
  game.update(@core.empty_input_snapshot())
  let snapshot = energy_focus_snapshot(game)
  assert_eq(snapshot.nodes.filter(n => n.focused).map(n => n.id), [
    "end_turn_btn",
  ])
  assert_eq(snapshot.focus_order, ["end_turn_btn"])
  assert_true(snapshot.nodes.any(n => n.id == "end_turn_btn_focus_ring"))
  assert_true(
    snapshot.nodes.any(n => {
      n.id == "hint" && n.text == Some("ENERGY 0 - ENTER / E TO END TURN")
    }),
  )
  game.update(key_input([13]))
  assert_eq(b.phase, EnemyTurn)
  assert_eq(b.turn, 1)
  assert_true(energy_focus_snapshot(game).nodes.all(n => !n.focused))
  for _ in 0..<240 {
    game.update(key_input([13]))
  }
  assert_eq(b.turn, 2)
  assert_eq(b.player.energy, 3)
  assert_true(energy_focus_snapshot(game).nodes.all(n => !n.focused))
}

///|
test "last energy is followed by End Turn focus only after the card effect" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.player.energy = 1
  game.commit_card(b, 0, 1)
  assert_eq(b.player.energy, 0)
  assert_false(game.end_turn_focused())
  game.update(key_input([13]))
  assert_eq(b.phase, PlayerTurn)
  settle_presentation(game)
  assert_true(game.end_turn_focused())
  assert_eq(b.turn, 1)
}

///|
test "zero cost selection takes precedence over End Turn focus and energy gain clears it" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.player.energy = 0
  b.hand[0] = Bloodletting
  assert_true(game.end_turn_focused())
  game.update(key_input([49]))
  assert_false(game.end_turn_focused())
  assert_true(energy_focus_snapshot(game).nodes.all(n => !n.focused))
  game.update(key_input([13]))
  assert_eq(b.player.energy, 2)
  assert_eq(b.phase, PlayerTurn)
  settle_presentation(game)
  assert_false(game.end_turn_focused())
}

///|
test "select and confirm in one frame at zero energy plays the chosen card" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.player.energy = 0
  b.hand[0] = Bloodletting
  game.update(key_input([49, 13]))
  assert_eq(b.player.energy, 2)
  assert_eq(b.phase, PlayerTurn)
}

///|
test "a free card drag suspends the end guide and cancelling restores it" {
  let game = interaction_game()
  let b = game.run.get().battle.unwrap()
  b.player.energy = 0
  b.hand[0] = Anger
  press_card(game, 0)
  assert_false(game.end_turn_focused())
  let target = game.layout.enemy_rect(1, 2)
  game.update(pointer_input(target.cx(), target.cy(), true))
  assert_false(game.end_turn_focused())
  game.update(key_input([27]))
  assert_true(game.end_turn_focused())
  game.open_pile(Deck)
  assert_false(game.end_turn_focused())
  assert_eq(
    energy_focus_snapshot(game).nodes.filter(n => n.focused).map(n => n.id),
    ["deck_close"],
  )
  game.close_pile(@ui.UIModalCloseReason::Explicit)
  game.combat_focus = None
  b.phase = Victory
  assert_false(game.end_turn_focused())
}
